import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/poll_model.dart';
import '../controllers/poll_controller.dart';
import '../components/poll_components.dart';

class EventPollsView extends StatefulWidget {
  final Event event;

  const EventPollsView({Key? key, required this.event}) : super(key: key);

  @override
  _EventPollsViewState createState() => _EventPollsViewState();
}

class _EventPollsViewState extends State<EventPollsView> {
  final PollController _pollController = PollController();
  bool _showCreatePoll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polls - ${widget.event.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Polls',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create and vote on polls for this event. Use polls to quickly gather attendee opinions on yes/no questions.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(_showCreatePoll ? Icons.remove : Icons.add),
                      label:
                          Text(_showCreatePoll ? 'Cancel' : 'Create New Poll'),
                      onPressed: () {
                        setState(() {
                          _showCreatePoll = !_showCreatePoll;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Poll creation form
            if (_showCreatePoll) PollCreationWidget(eventId: widget.event.id),

            const SizedBox(height: 16),

            // Poll list
            StreamBuilder<List<Poll>>(
              stream: _pollController.getEventPolls(widget.event.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading polls: ${snapshot.error}'),
                  );
                }

                final polls = snapshot.data ?? [];

                if (polls.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.poll_outlined,
                              size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No polls yet. Create the first poll for this event!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: polls.length,
                  itemBuilder: (context, index) {
                    return PollWidget(poll: polls[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
