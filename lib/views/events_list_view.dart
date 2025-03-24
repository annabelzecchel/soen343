// VIEW
// lib/views/events_list_view.dart
import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'event_detail_view.dart';
import 'event_form_view.dart';

class EventsListView extends StatefulWidget {
  const EventsListView({Key? key}) : super(key: key);

  @override
  _EventsListViewState createState() => _EventsListViewState();
}

class _EventsListViewState extends State<EventsListView> {
  final EventController _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found'));
          }

          final events = snapshot.data!;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text(
                    '${_formatDateTime(event.dateTime)} • ${event.location}',
                  ),
                  trailing: Text('\$${event.price.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailView(event: event),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
