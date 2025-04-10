import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/openai_service.dart';

class OpenAIChatBot extends StatefulWidget {
  const OpenAIChatBot({super.key});

  @override
  _OpenAIChatBotState createState() => _OpenAIChatBotState();
}

class _OpenAIChatBotState extends State<OpenAIChatBot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final OpenAIService _openAIService = OpenAIService();

  bool _isOpen = false;
  bool _isTyping = false;
  bool _isInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  final String _systemMessage = '''
You are Planini Assistant, a helpful chatbot for the Planini event management application.
Your role is to help users navigate the app and provide information about its features.

About Planini:
- It's an event management platform where users can create, find, and register for events
- It offers tools for event organizers including analytics, promotion, and attendee management
- It has chat features for communication between organizers and attendees
- It supports various user roles: organizers, attendees, stakeholders, and administrators

When users ask questions about the app, provide helpful information and suggest relevant sections they can navigate to.
For questions outside the scope of the app, suggest contacting support@planini.com.

Available app sections:
- Event Creation: Where organizers can create and configure new events
- Event Management: For organizing and editing existing events
- Events List: For finding and browsing events
- Event Details: For viewing specific event information
- Registration: For signing up to attend events
- Profile: For viewing and editing user information
- Chat Rooms: For communication between users
- Event Promotion: For marketing events
- Analytics: For viewing event statistics
- Polls: For gathering attendee feedback

Keep your responses concise, focused, and brief. Users prefer short, clear answers.
''';

  final List<Map<String, dynamic>> _conversationHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeOpenAIService();

    _conversationHistory.add({
      'role': 'system',
      'content': _systemMessage,
    });
  }

  Future<void> _initializeOpenAIService() async {
    try {
      await _openAIService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing OpenAI service: $e');
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleChatBot() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
        if (_messages.isEmpty) {
          _addBotMessage(
            "Hi! I'm Planini Assistant. How can I help with your event planning today?",
          );
        }
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
      _textController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    _conversationHistory.add({
      'role': 'user',
      'content': text,
    });

    _getOpenAIResponse();
  }

  Future<void> _getOpenAIResponse() async {
    if (!_isInitialized) {
      _addBotMessage(
        "I'm not fully set up yet. Please try again in a moment.",
        links: [
          BotLink(
            text: "Email Support",
            onTap: () => _launchEmail("support@planini.com"),
          ),
        ],
      );
      return;
    }

    try {
      final response =
          await _openAIService.generateChatResponse(_conversationHistory);

      if (response['success']) {
        _conversationHistory.add({
          'role': 'assistant',
          'content': response['message'],
        });

        _processOpenAIResponse(response['message']);
      } else {
        _addBotMessage(
          "I'm having trouble processing your request. ${response['message']}",
          links: [
            BotLink(
              text: "Contact Support",
              onTap: () => _launchEmail("support@planini.com"),
            ),
          ],
        );
      }
    } catch (e) {
      _addBotMessage(
        "I encountered an error processing your request. Please try again later.",
        links: [
          BotLink(
            text: "Contact Support",
            onTap: () => _launchEmail("support@planini.com"),
          ),
        ],
      );
    }
  }

  bool _shouldPerformWebSearch(String query) {
    final searchTriggers = [
      'current trends',
      'latest news',
      'recent developments',
      'what is happening',
      'up to date information',
    ];

    return searchTriggers
        .any((trigger) => query.toLowerCase().contains(trigger));
  }

  void _processOpenAIResponse(String response) {
    List<BotLink> links = [];

    Map<String, String> navigationPaths = {
      'event creation': '/event-management',
      'create event': '/event-management',
      'event management': '/event-management',
      'events list': '/events-list',
      'browse events': '/events-list',
      'find events': '/events-list',
      'profile': '/profile',
      'account': '/profile',
      'chat': '/chat-rooms',
      'message': '/chat-rooms',
      'promotion': '/event-promotion',
      'marketing': '/event-promotion',
      'analytics': '/analytics',
      'statistics': '/analytics',
      'reports': '/analytics',
      'login': '/login',
      'sign in': '/login',
      'sign up': '/signup',
      'register': '/signup',
    };

    navigationPaths.forEach((keyword, path) {
      if (response.toLowerCase().contains(keyword)) {
        String linkText = '';
        switch (path) {
          case '/event-management':
            linkText = 'Go to Event Creation';
            break;
          case '/events-list':
            linkText = 'Browse Events';
            break;
          case '/profile':
            linkText = 'Go to Profile';
            break;
          case '/chat-rooms':
            linkText = 'Go to Chat Rooms';
            break;
          case '/event-promotion':
            linkText = 'Go to Event Promotion';
            break;
          case '/analytics':
            linkText = 'View Analytics';
            break;
          case '/login':
            linkText = 'Log In';
            break;
          case '/signup':
            linkText = 'Sign Up';
            break;
          default:
            linkText = 'Navigate';
        }

        if (!links.any((link) => link.text == linkText)) {
          links.add(BotLink(
            text: linkText,
            onTap: () => _navigateTo(path),
          ));
        }
      }
    });

    if (response.toLowerCase().contains('support@planini.com')) {
      links.add(
        BotLink(
          text: "Copy Email",
          onTap: () {
            Clipboard.setData(const ClipboardData(text: "support@planini.com"));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email copied to clipboard')),
            );
          },
        ),
      );
      links.add(
        BotLink(
          text: "Send Email",
          onTap: () => _launchEmail("support@planini.com"),
        ),
      );
    }

    _addBotMessage(response, links: links);
  }

  void _navigateTo(String route) {
    _addBotMessage("Navigating to $route...");
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Planini Support Request',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email client';
      }
    } catch (e) {
      if (mounted) {
        _addBotMessage(
            "Unable to open email client. Please manually send an email to $email");
      }
    }
  }

  void _addBotMessage(String text, {List<BotLink> links = const []}) {
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        links: links,
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isOpen)
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: 1.0,
            child: Container(
              width: 350.0,
              height: 500.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 60.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFABC5AE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              "P",
                              style: TextStyle(
                                color: Colors.brown[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            "Planini Assistant",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.brown[800],
                          onPressed: _toggleChatBot,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      color: const Color(0xFFEBF6EC),
                      child: _messages.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length + (_isTyping ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _messages.length && _isTyping) {
                                  return _buildTypingIndicator();
                                }
                                return _buildMessage(_messages[index]);
                              },
                            ),
                    ),
                  ),
                  Container(
                    height: 60.0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3.0,
                          spreadRadius: 1.0,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              hintText: "Ask me anything...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30.0),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0xFFEBF6EC),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                            ),
                            onSubmitted: _handleSubmitted,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        CircleAvatar(
                          backgroundColor: const Color(0xFFABC5AE),
                          child: IconButton(
                            icon: const Icon(Icons.send),
                            color: Colors.brown[800],
                            onPressed: () =>
                                _handleSubmitted(_textController.text),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16.0),
        FloatingActionButton(
          onPressed: _toggleChatBot,
          backgroundColor: const Color(0xFFABC5AE),
          child: Icon(
            _isOpen ? Icons.close : Icons.chat,
            color: Colors.brown[800],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFABC5AE) : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 280.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 13.0,
                height: 1.4,
                color: message.isUser ? Colors.brown[800] : Colors.black87,
              ),
            ),
            if (message.links.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              ...message.links.map((link) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: InkWell(
                      onTap: link.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCA946F),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Text(
                          link.text,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 100.0),
        child: Row(
          children: [
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: const Color(0xFFABC5AE),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.5, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: value,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final List<BotLink> links;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.links = const [],
  });
}

class BotLink {
  final String text;
  final VoidCallback onTap;

  BotLink({
    required this.text,
    required this.onTap,
  });
}
