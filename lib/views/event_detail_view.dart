import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soen343/components/sendEmail.dart';
import '../controllers/event_controller.dart';
import '../controllers/profile_controller.dart';
import '../components/auth_service.dart';
import '../models/event_model.dart';
import 'event_form_view.dart';
import 'chat_detail_view.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_room_model.dart';
import 'event_polls_view.dart';
import 'payment_screen.dart';
import 'event_feedback_form.dart';
import '../models/event_feedback_model.dart';
import '../../controllers/event_feedback_service.dart';
import 'event_analytics_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailView extends StatefulWidget {
  final Event event;

  EventDetailView({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailViewState createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final EventController _eventController = EventController();
  final ProfileController _profileController = ProfileController(AuthService());
  final _userController = TextEditingController();
  final _amountController = TextEditingController();
  final ChatController _chatController = ChatController();
  late Event _currentEvent;
  String? type;
  String? email;

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
    _fetchUserRole();
  }

  Future<void> _refreshEventData() async {
    final updatedEvent = await _eventController.getEventById(_currentEvent.id);
    setState(() {
      _currentEvent = updatedEvent;
    });
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userRole = await _profileController.getRoleById(user.uid);
      String email1 = await _profileController.getEmailById(user.uid);
      print(userRole);
      setState(() {
        type = userRole;
        email = email1;
      });
    }
  }

  void _initiateChat() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to chat')),
      );
      return;
    }

    try {
      final chatRooms =
          await _chatController.getUserChatRooms(currentUser.uid).first;
      final existingChatRoom = chatRooms
          .where(
              (room) => room.eventId == _currentEvent.id && !room.isGroupChat)
          .toList();

      ChatRoom chatRoom;

      if (existingChatRoom.isNotEmpty) {
        chatRoom = existingChatRoom.first;
      } else {
        final chatRoomId = await _chatController.createChatRoom(
          name: 'Chat about ${_currentEvent.name}',
          participants: [currentUser.uid, _currentEvent.createdByEmail],
          eventId: _currentEvent.id,
          isGroupChat: false,
        );

        // Get the created chat room
        chatRoom = await _chatController.getChatRoomById(chatRoomId);
      }

      // Navigate to chat detail view
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailView(chatRoom: chatRoom),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating chat: $e')),
      );
    }
  }

  void _navigateToPolls() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to access polls')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventPollsView(event: _currentEvent),
      ),
    );
  }

  void _launchUrl(BuildContext context, Uri url) async {
  try {
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: ${url.toString()}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error opening link: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEvent.name),
        actions: (type == 'organizer' || type == "administration")
            ? [
                IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FeedbackAnalyticsSummaryView(
                          eventId: _currentEvent.id,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventFormView(event: _currentEvent),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Event'),
                        content: const Text(
                            'Are you SURE you want to DELETE this event?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await _eventController
                                  .deleteEvent(_currentEvent.id);
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Return to previous view
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildAttendeesList(context),
            const SizedBox(height: 16),
            if (type != null &&
                (type!.toLowerCase() == 'organizer' ||
                    type!.toLowerCase() == 'administration' ||
                    type!.toLowerCase() == 'stakeholders'))
              ElevatedButton.icon(
                icon: const Icon(Icons.email),
                label: const Text('Update Attendees'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EmailForm(emails: _currentEvent.attendees),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            if (type == 'organizer' ||
                type == "administration" ||
                type == 'Stakeholders' ||
                type == "attendee")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text('Register'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(
                                'Are you sure you want to register for this event?'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_currentEvent.price > 0)
                                  const SizedBox(height: 16),
                                if (_currentEvent.price > 0)
                                  const Text(
                                    'Payment will be required after registration',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );

                                    await _eventController.addAttendee(
                                        _currentEvent.id, email ?? '');
                                    await _refreshEventData();

                                    Navigator.pop(context);
                                    Navigator.pop(context);

                                    if (_currentEvent.price > 0) {
                                      if (!mounted) return;
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => PaymentDialog(
                                          event: _currentEvent,
                                          role: type ?? '',
                                          amount: _currentEvent.price,
                                        ),
  );
                                    } else {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Registration successful!')));
                                    }
                                  } catch (e) {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}')),
                                    );
                                  }
                                },
                                child: const Text('Yes!'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                      ),
                      onPressed: _initiateChat,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.poll),
                      label: const Text('Polls'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.surface,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: _navigateToPolls,
                    ),
                  ),
                ],
              ),
            //FEEEDBACK ABOUT EVENT
            const SizedBox(height: 18),
            const Text(
              'Event Feedback',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildEventFeedbackSummary(context),
            const SizedBox(height: 16),
                if (_currentEvent.attendees.contains(email))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const Text(
                    'Your Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  FeedbackForm(eventId: _currentEvent.id),
                  const SizedBox(height: 24),
                  ],
                ),

            // SPONSORING AN EVENT
            const SizedBox(height: 24),
            if(type == 'Stakeholders')
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Sponsor Event'),
              onPressed: () {
                //IDK TEMPORARY FOR N0W TO SEE IF IT WORKS
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sponsor this event'),
                    content: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Enter the amount you are willing to sponsor',
                      ),
                      //NOT WORKING
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          _amountController.text = value;
                        }
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _eventController.addSponsor(
                              _currentEvent.id, email??'',int.parse(_amountController.text) );
                          await _refreshEventData();
                          Navigator.pop(context);
                          Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PaymentDialog(
                                          event: _currentEvent,
                                          role : type ?? '',
                                          amount: double.parse(_amountController.text),
                                        ),
                                      ),
                                    );
                          },
                        child: const Text('Sponsor'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.description, _currentEvent.description),
            _buildInfoRow(Icons.location_on, _currentEvent.location),
            _buildInfoRow(
              Icons.calendar_today,
              _formatDateTime(widget.event.dateTime),
            ),
            _buildInfoRow(Icons.attach_money,
                '\$${_currentEvent.price.toStringAsFixed(2)}'),
            _buildInfoRow(Icons.category, 'Type: ${_currentEvent.type}'),
            _buildInfoRow(
                Icons.format_align_left, 'Format: ${_currentEvent.format}'),
            _buildInfoRow(
                Icons.email, 'Created by: ${_currentEvent.createdByEmail}'),
              Row(   
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                if (_currentEvent.instagram != '' && _currentEvent.instagram!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      final Uri link = Uri.parse(_currentEvent.instagram!);
                      _launchUrl(context, link);
                    },
                    child: Icon(
                      FontAwesomeIcons.instagram,
                      size: 20,
                    ),
                  ),
                if (_currentEvent.instagram != '' && _currentEvent.instagram!.isNotEmpty)
                  SizedBox(width: 16),
      
                if (_currentEvent.facebook != '' && _currentEvent.facebook!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      final Uri link = Uri.parse(_currentEvent.facebook!);
                      _launchUrl(context, link);
                    },
                    child: Icon(
                      FontAwesomeIcons.facebook,
                      size: 20,
                    ),
                  ),
                if (_currentEvent.facebook != '' && _currentEvent.facebook!.isNotEmpty)
                  SizedBox(width: 16),
      
                if (_currentEvent.youtube != '' && _currentEvent.youtube!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      final Uri link = Uri.parse(_currentEvent.youtube!);
                      _launchUrl(context, link);
                    },
                    child: Icon(
                      FontAwesomeIcons.youtube,
                      size: 20,
                    ),
                  ),
              ] ,           
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildAttendeesList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendees (${_currentEvent.attendees.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _currentEvent.attendees.isEmpty
                ? const Text('No attendees yet')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentEvent.attendees.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(_currentEvent.attendees[index]),
                        dense: true,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

Widget _buildEventFeedbackSummary(BuildContext context) {
  final feedbackService = FeedbackService();

  return StreamBuilder<List<EventFeedback>>(
    stream: feedbackService.getFeedbackForEvent(_currentEvent.id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'This event hasn\'t been reviewed yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        );
      }

      final feedbackList = snapshot.data!;
      final averageRating = feedbackList
          .map((f) => f.rating)
          .reduce((a, b) => a + b) / feedbackList.length;

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Event Rating',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 28),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Based on ${feedbackList.length} review${feedbackList.length == 1 ? '' : 's'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
