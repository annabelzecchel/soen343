import 'package:flutter/material.dart';
import 'package:soen343/controllers/event_feedback_service.dart';
import 'package:soen343/models/event_feedback_model.dart';
import 'package:intl/intl.dart';


class FeedbackList extends StatelessWidget {
  final String eventId;
  
  const FeedbackList({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();

    return StreamBuilder<List<EventFeedback>>(
      stream: feedbackService.getFeedbackForEvent(eventId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading feedback: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedbackList = snapshot.data ?? [];

        if (feedbackList.isEmpty) {
          return const Center(child: Text('No feedback yet'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            final feedback = feedbackList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          feedback.userName ?? 'Anonymous',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM dd, yyyy').format(feedback.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < feedback.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(feedback.comment),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}