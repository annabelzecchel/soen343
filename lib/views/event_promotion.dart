import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class EventPromotionPage extends StatelessWidget {
  const EventPromotionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marketing Tools',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Campaigns'),
              subtitle: Text('Create and send promotional emails.'),
            ),
            const ListTile(
              leading: Icon(Icons.share),
              title: Text('Social Media Integration'),
              subtitle: Text('Share events on social media platforms.'),
            ),
            const ListTile(
              leading: Icon(Icons.web),
              title: Text('Customizable Event Pages'),
              subtitle: Text('Design event pages to attract attendees.'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add functionality for starting a campaign
              },
              child: const Text('Start Campaign'),
            ),
          ],
        ),
      ),
    );
  }
}