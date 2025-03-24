import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class EventCreationForm extends StatefulWidget {
  const EventCreationForm({super.key});

  @override
  _EventCreationFormState createState() => _EventCreationFormState();
}

class _EventCreationFormState extends State<EventCreationForm> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formatController = TextEditingController();
  final _dateTimeController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

// Behavior of Date and Time Picker
  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDateTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (pickedDateTime != null) {
      final TimeOfDay? pickedTime =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
            pickedDateTime.year,
            pickedDateTime.month,
            pickedDateTime.day,
            pickedTime.hour,
            pickedTime.minute);
        setState(() {
          _dateTimeController.text = selectedDateTime.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        height: 620,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Register New Event',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.event_available_rounded),
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.description_rounded),
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
                value:
                    _typeController.text.isEmpty ? null : _typeController.text,
                onChanged: (String? newValue) {
                  setState(() {
                    _typeController.text = newValue ?? '';
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.category_rounded),
                  hintText: 'Select Event Type',
                  labelText: 'Type',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'conference',
                    child: Text('Conference'),
                  ),
                  DropdownMenuItem(
                    value: 'workshop',
                    child: Text('Workshop'),
                  ),
                  DropdownMenuItem(
                    value: 'seminar',
                    child: Text('Seminar'),
                  ),
                  DropdownMenuItem(
                    value: 'webinar',
                    child: Text('Webinar'),
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
              DropdownButtonFormField(
                value: _formatController.text.isEmpty
                    ? null
                    : _formatController.text,
                onChanged: (String? newValue) {
                  setState(() {
                    _formatController.text = newValue ?? '';
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.view_agenda_rounded),
                  hintText: 'Select Event Format',
                  labelText: 'Format',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'in-person',
                    child: Text('In person'),
                  ),
                  DropdownMenuItem(
                    value: 'online',
                    child: Text('Online'),
                  ),
                  DropdownMenuItem(
                    value: 'hybrid',
                    child: Text('Hybrid'),
                  ),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dateTimeController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.date_range_rounded),
                  hintText: 'Select Date and Time',
                  labelText: 'Date & Time',
                ),
                onTap: () => _selectDateTime(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.location_on_rounded),
                  hintText: 'Enter Event Location',
                  labelText: 'Location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.attach_money_rounded),
                  hintText: 'Enter Event Ticket Price',
                  labelText: 'Ticket Price (enter value in CAD)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ticket price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Get the currently logged-in user
                    // User? user = FirebaseAuth.instance.currentUser; this is for when user auth implemented
                    String userEmail = "haaha@gmail.com";

                    // if (user == null) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(
                    //         content:
                    //             Text('You must be logged in to create an event')),
                    //   );
                    //   return;
                    // }

                    try {
                      // Reference to Firestore collection
                      CollectionReference colRef =
                          FirebaseFirestore.instance.collection("events");

                      // Add event with creator details
                      await colRef.add({
                        "name": _nameController.text,
                        "description": _descriptionController.text,
                        "type": _typeController.text,
                        "format": _formatController.text,
                        "dateTime": _dateTimeController.text,
                        "location": _locationController.text,
                        "price": _priceController.text,
                        "createdByEmail":
                            userEmail, //when user auth -> user.email
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Event stored successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving event: $e')),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
