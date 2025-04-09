import 'package:flutter/material.dart';
import '../models/event_feedback_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../controllers/feedback_analytics_service.dart';

class FeedbackAnalyticsView extends StatelessWidget {
  final List<EventFeedback> feedbackList;

  const FeedbackAnalyticsView({super.key, required this.feedbackList});

  @override
  Widget build(BuildContext context) {
    final analytics = FeedbackAnalytics(feedbackList);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(analytics),
          const SizedBox(height: 20),
          _buildRatingDistribution(analytics),
          const SizedBox(height: 20),
          _buildWordCloud(analytics),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(FeedbackAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Feedback Summary', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Total', analytics.allFeedback.length.toString()),
                _buildStatItem('Avg Rating', analytics.averageRating.toStringAsFixed(1)),
                _buildStatItem('Recent', analytics.recentFeedback.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildRatingDistribution(FeedbackAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rating Distribution', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ...analytics.ratingDistribution.entries.map((entry) {
              final percentage = (entry.value / analytics.allFeedback.length * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text('${entry.key} stars'),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey[200],
                        color: _getRatingColor(entry.key),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${percentage.toStringAsFixed(1)}%'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCloud(FeedbackAnalytics analytics) {
    final topWords = analytics.commonWords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(15); // Show top 15 words

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Frequent Words', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topWords.map((entry) {
                return Chip(
                  label: Text(entry.key),
                  backgroundColor: Colors.blue[50],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    return switch (rating) {
      5 => Colors.green,
      4 => Colors.lightGreen,
      3 => Colors.amber,
      2 => Colors.orange,
      1 => Colors.red,
      _ => Colors.grey,
    };
  }
}