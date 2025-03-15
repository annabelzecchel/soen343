import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class EventCreationForm extends StatefulWidget {
  const EventCreationForm({super.key});

  @override
  _EventCreationFormState createState() => _EventCreationFormState();
}

class _EventCreationFormState extends State<EventCreationForm> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Text(
            'Register New Event',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Enter Event Name',
              labelText: 'Event Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter event name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Enter Event Description',
              labelText: 'Description',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter event description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField(
            value: typeController.text.isEmpty ? null : typeController.text,
            onChanged: (String? newValue) {
              setState(() {
                typeController.text = newValue ?? '';
              });
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Select Event Type',
              labelText: 'Type',
            ),
            items: const [
              DropdownMenuItem(
                value: 'conference', child: Text('Conference'), 
              ),
              DropdownMenuItem(
                value: 'workshop', child: Text('Workshop'), 
              ),
              DropdownMenuItem(
                value: 'seminar', child: Text('Seminar'),
              ),
              DropdownMenuItem(
                value: 'webinar', child: Text('Webinar'), 
              ),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter event type';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                String name = nameController.text;
                String email = typeController.text;
                // You can handle the form submission here
                print('Event Name: $name, Organizer Email: $email');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
