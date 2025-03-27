import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../controllers/profile_controller.dart';
import '../components/auth_service.dart';
import '../models/event_model.dart';
import 'event_form_view.dart';
import 'payment_screen.dart';

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
  late Event _currentEvent;
  String? type;

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
      print(userRole);
      setState(() {
        type = userRole;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEvent.name),
        actions: (type == 'organizer' ||
                type == "stakeholders" ||
                type == "administrator")
            ? [
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
                              Navigator.pop(context); //Dialog
                              Navigator.pop(context); //List
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add),
              label: const Text('Register for Event'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Register for Event'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _userController,
                          decoration: const InputDecoration(
                            labelText: 'Enter your email',
                            hintText: 'user@example.com',
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        if (_currentEvent.price >
                            0) // Only show payment option if event has a price
                          const SizedBox(height: 16),
                        if (_currentEvent.price > 0)
                          const Text(
                              'Payment will be required after registration',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_userController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your email')));
                return;
              }

              // Validate email format
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(_userController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email')));
                return;
              }

              try {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                // Register attendee
                await _eventController.addAttendee(
                    _currentEvent.id, _userController.text);
                await _refreshEventData();

                // Close loading dialog
                Navigator.pop(context);

                // Close registration dialog
                Navigator.pop(context);

                // If event has a price, navigate to payment screen
                if (_currentEvent.price > 0) {
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        event: _currentEvent,
                        attendeeEmail: _userController.text,
                        amount: _currentEvent.price,
                      ),
                    ),
                  );
                } else {
                  // Show success message for free event
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration successful!')));
                }
              } catch (e) {
                // Close loading dialog if still open
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Register'),
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
                '\$${widget.event.price.toStringAsFixed(2)}'),
            _buildInfoRow(Icons.category, 'Type: ${_currentEvent.type}'),
            _buildInfoRow(
                Icons.format_align_left, 'Format: ${_currentEvent.format}'),
            _buildInfoRow(
                Icons.email, 'Created by: ${_currentEvent.createdByEmail}'),
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
          Expanded(
            child: Text(text),
          ),
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
            widget.event.attendees.isEmpty
                ? const Text('No attendees yet')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    //WORKS
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
}
