import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../controllers/profile_controller.dart';
import '../components/auth_service.dart';
import '../models/event_model.dart';
import 'event_form_view.dart';

class EventDetailView extends StatefulWidget {
  final Event event;

  EventDetailView({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailViewState createState() => _EventDetailViewState();
}

class _EventDetailViewState extends State<EventDetailView> {
  final EventController _eventController = EventController();
  final ProfileController _profileController = ProfileController(AuthService());
  String? type;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
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
        title: Text(widget.event.name),
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
                            EventFormView(event: widget.event),
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
                                  .deleteEvent(widget.event.id);
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
                //IDK TEMPORARY FOR N0W TO SEE IF IT WORKS
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Register for Event'),
                    content: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Enter your user ID',
                      ),
                      //NOT WORKING
                      onSubmitted: (value) async {
                        if (value.isNotEmpty) {
                          await _eventController.addAttendee(
                              widget.event.id, value);
                          //print("$value has been added to the ${event.id}");
                          Navigator.pop(context);
                        }
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
            _buildInfoRow(Icons.description, widget.event.description),
            _buildInfoRow(Icons.location_on, widget.event.location),
            _buildInfoRow(
              Icons.calendar_today,
              _formatDateTime(widget.event.dateTime),
            ),
            _buildInfoRow(Icons.attach_money,
                '\$${widget.event.price.toStringAsFixed(2)}'),
            _buildInfoRow(Icons.category, 'Type: ${widget.event.type}'),
            _buildInfoRow(
                Icons.format_align_left, 'Format: ${widget.event.format}'),
            _buildInfoRow(
                Icons.email, 'Created by: ${widget.event.createdByEmail}'),
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
              'Attendees (${widget.event.attendees.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            widget.event.attendees.isEmpty
                ? const Text('No attendees yet')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    //WORKS
                    itemCount: widget.event.attendees.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(widget.event.attendees[index]),
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
