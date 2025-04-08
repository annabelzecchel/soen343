import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailForm extends StatefulWidget {
  final List<String> emails;

  // Expect a list of email addresses in the constructor.
  EmailForm({Key? key, required this.emails}) : super(key: key);

  @override
  _EmailFormState createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  // Although _emailController is still used to display the emails,
  // the user cannot change these values.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Populate the email field with the comma separated list.
    _emailController.text = widget.emails.join(', ');
  }

  Future<void> _sendEmail() async {
    setState(() {
      _isSending = true;
    });

    // EmailJS configuration: replace these with your actual IDs.
    final serviceId = 'service_1a57wf4';
    final templateId = 'template_vgw44vb';
    final userId = '1IU41pMjUlpDzNsdH';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Build a list of POST requests, one for each recipient.
    List<Future<http.Response>> emailRequests = widget.emails.map((recipient) {
      return http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_name': _nameController.text,
            'user_email': recipient,
            'message': _messageController.text,
          },
        }),
      );
    }).toList();

    // Execute all requests concurrently.
    List<http.Response> responses = await Future.wait(emailRequests);

    setState(() {
      _isSending = false;
    });

    // Check if every response was successful.
    bool allSuccessful =
        responses.every((response) => response.statusCode == 200);

    if (allSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emails sent successfully to all recipients!')),
      );
      // Clear only the fields the user can edit.
      _nameController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to send email to one or more recipients.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Emails to all attendees'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              // Recipients Field (read-only)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Recipients'),
                readOnly: true,
              ),
              // Message Field
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Send Button or Progress Indicator
              _isSending
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sendEmail();
                        }
                      },
                      child: Text('Send Emails'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
