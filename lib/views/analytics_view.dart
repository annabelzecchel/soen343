import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AnalyticsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Real-time Insights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Track attendee participation, event success metrics, and collect feedback in real-time.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMetricCard('Attendee Participation', '75% Active'),
                  _buildMetricCard('Event Success', '85% Positive Feedback'),
                  _buildMetricCard('Feedback Collected', '120 Responses'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        leading: Icon(Icons.analytics, color: Color.fromARGB(255, 118, 157, 123)),
      ),
    );
  }
}