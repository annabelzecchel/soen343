import 'package:flutter/material.dart';
import '../models/event_feedback_model.dart';
import '../views/feedback_analytics_view.dart';
import '../controllers/event_feedback_service.dart';

class AnalyticsScreen extends StatelessWidget {
  final String eventId;
  final FeedbackService feedbackService = FeedbackService();

  AnalyticsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Analytics')),
      body: StreamBuilder<List<EventFeedback>>(
        stream: feedbackService.getFeedbackForEvent(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No feedback data available'));
          }

          return FeedbackAnalyticsView(feedbackList: snapshot.data!);
        },
      ),
    );
  }
}