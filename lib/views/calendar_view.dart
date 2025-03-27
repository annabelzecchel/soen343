import 'package:flutter/material.dart';
import 'package:soen343/controllers/event_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/event_model.dart';

class CalendarComponent extends StatefulWidget {
  final String userEmail;

  const CalendarComponent({Key? key, required this.userEmail})
      : super(key: key);

  @override
  _CalendarComponentState createState() => _CalendarComponentState();
}

class _CalendarComponentState extends State<CalendarComponent> {
  final EventController _eventController = EventController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Event> _getEventsForDay(DateTime day, List<Event> events) {
    return events.where((event) {
      DateTime eventDateTime = event.dateTime;
      return isSameDay(eventDateTime, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Event>>(
      stream: _eventController.getUserEvents(widget.userEmail),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading events: ${snapshot.error}'),
          );
        }

        // No events state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            children: [
              _buildCalendar([], context),
              Expanded(
                child: Center(
                  child: Text(
                    'No upcoming events',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              )
            ],
          );
        }

        final events = snapshot.data!;
        return Column(
          children: [
            _buildCalendar(events, context),
            Expanded(
              child: _buildEventList(events),
            )
          ],
        );
      },
    );
  }

  Widget _buildCalendar(List<Event> events, BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      daysOfWeekHeight: 45,
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      eventLoader: (day) => _getEventsForDay(day, events),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.green.shade200,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        markerMargin: const EdgeInsets.only(bottom: 10),
        defaultTextStyle: const TextStyle(
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    final displayEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, events)
        : events.where((event) {
            DateTime eventDateTime = event.dateTime;
            return eventDateTime.isAfter(DateTime.now());
          }).toList();

    displayEvents.sort((a, b) {
      DateTime dateA = a.dateTime;
      DateTime dateB = b.dateTime;
      return dateA.compareTo(dateB);
    });

    return displayEvents.isEmpty
        ? Center(
            child: Text(
              'No events on this day ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        : ListView.builder(
            itemCount: displayEvents.length,
            itemBuilder: (context, index) {
              final event = displayEvents[index];

              DateTime eventDateTime = event.dateTime;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy HH:mm')
                            .format(eventDateTime),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (event.description.isNotEmpty)
                        Text(
                          event.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
