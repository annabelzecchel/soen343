import 'package:flutter/material.dart';

class EventManagementPage extends StatefulWidget {
  final String title;
  const EventManagementPage({super.key, required this.title});
 
    @override
    State<EventManagementPage> createState() => _EventManagementState();
  }
  
  class _EventManagementState extends State<EventManagementPage> {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Event Management for Organizers'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Event Management',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      );
    }
  }
