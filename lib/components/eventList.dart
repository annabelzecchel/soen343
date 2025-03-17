import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events List")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          //Case 1: Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //Case 2: No events
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No events found"));
          }
          //Case 3: Events found
          var events = snapshot.data!.docs;

          return SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['name'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "📅 Date: ${event['dateTime'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "📍 Location: ${event['location'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "💰 Price: ${event['price'] ?? 'Free'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "📝 Description: ${event['description'] ?? 'No Description'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "🎭 Type: ${event['type'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "🔗 Format: ${event['format'] ?? 'N/A'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
