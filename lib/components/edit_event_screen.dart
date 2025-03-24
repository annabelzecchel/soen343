import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditEventScreen({Key? key, required this.eventId, required this.eventData}) : super(key: key);

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateTimeController;
  late TextEditingController _locationController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _typeController;
  late TextEditingController _formatController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.eventData['name']);
    _dateTimeController = TextEditingController(text: widget.eventData['dateTime']);
    _locationController = TextEditingController(text: widget.eventData['location']);
    _priceController = TextEditingController(text: widget.eventData['price']);
    _descriptionController = TextEditingController(text: widget.eventData['description']);
    _typeController = TextEditingController(text: widget.eventData['type']);
    _formatController = TextEditingController(text: widget.eventData['format']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateTimeController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({
        'name': _nameController.text,
        'dateTime': _dateTimeController.text,
        'location': _locationController.text,
        'price': _priceController.text,
        'description': _descriptionController.text,
        'type': _typeController.text,
        'format': _formatController.text,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateEvent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateTimeController,
                decoration: const InputDecoration(labelText: 'Date and Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date and time';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _formatController,
                decoration: const InputDecoration(labelText: 'Format'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the format';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}