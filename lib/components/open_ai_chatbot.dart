import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIChatBot extends StatefulWidget {
  const OpenAIChatBot({Key? key}) : super(key: key);

  @override
  _OpenAIChatBotState createState() => _OpenAIChatBotState();
}

class _OpenAIChatBotState extends State<OpenAIChatBot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isOpen = false;
  bool _isTyping = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // OpenAI configuration
  final String _apiKey =
      'YOUR_OPENAI_API_KEY'; // Replace with your actual API key
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _model =
      'gpt-3.5-turbo'; // You can use 'gpt-4' if you have access

  // System message that sets the context for the AI
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

Keep your responses concise and focused on helping the user navigate the application.
''';

  final List<Map<String, String>> _conversationHistory = [];

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

    // Initialize conversation history with system message
    _conversationHistory.add({
      'role': 'system',
      'content': _systemMessage,
    });
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
        // Add welcome message if this is the first time opening
        if (_messages.isEmpty) {
          _addBotMessage(
            "Hi there! I'm Planini Assistant. How can I help you today? You can ask me about creating events, finding events, chat features, or any other aspect of the Planini platform.",
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

    // Add user message to conversation history
    _conversationHistory.add({
      'role': 'user',
      'content': text,
    });

    // Send to OpenAI API
    _getOpenAIResponse();
  }

  Future<void> _getOpenAIResponse() async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': _conversationHistory,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];

        // Add assistant response to conversation history
        _conversationHistory.add({
          'role': 'assistant',
          'content': botResponse,
        });

        // Process the response to extract any navigation or email links
        _processOpenAIResponse(botResponse);
      } else {
        _addBotMessage(
          "I'm having trouble connecting to my knowledge base. Please try again later or contact support@planini.com for assistance.",
          links: [
            BotLink(
              text: "Copy Email Address",
              onTap: () {
                Clipboard.setData(
                    const ClipboardData(text: "support@planini.com"));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email copied to clipboard')),
                );
              },
            ),
          ],
        );
      }
    } catch (e) {
      _addBotMessage(
        "I encountered an error while processing your request. Please try again or contact our support team.",
        links: [
          BotLink(
            text: "Contact Support",
            onTap: () => _launchEmail("support@planini.com"),
          ),
        ],
      );
    }
  }

  void _processOpenAIResponse(String response) {
    // Check for navigation indicators
    List<BotLink> links = [];

    // Check for navigation suggestions
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

    // Collect potential navigation links
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

        // Only add unique links (avoid duplicates)
        if (!links.any((link) => link.text == linkText)) {
          links.add(BotLink(
            text: linkText,
            onTap: () => _navigateTo(path),
          ));
        }
      }
    });

    // Check for support email
    if (response.toLowerCase().contains('support@planini.com')) {
      links.add(
        BotLink(
          text: "Copy Email Address",
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

    // Add the processed response
    _addBotMessage(response, links: links);
  }

  void _navigateTo(String route) {
    // In a real implementation, this would navigate to different routes
    // For now, just acknowledge the action
    _addBotMessage("Navigating to $route...");

    // Here you would implement actual navigation, for example:
    /*
    switch (route) {
      case '/event-management':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EventManagementPage(
              title: 'Event Management',
            ),
          ),
        );
        break;
      case '/events-list':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EventsListView(),
          ),
        );
        break;
      // Add other routes as needed
    }
    */
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Planini Support Request',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      _addBotMessage(
          "Unable to open email client. Please manually send an email to $email");
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
    return Positioned(
      bottom: 16.0,
      right: 16.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Chat Window
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
                    // Chat Header
                    Container(
                      height: 60.0,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFFABC5AE), // Primary green color
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
                                itemCount:
                                    _messages.length + (_isTyping ? 1 : 0),
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
      ),
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
