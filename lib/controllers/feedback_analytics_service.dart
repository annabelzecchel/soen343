import '../models/event_feedback_model.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';


class FeedbackAnalytics {
  final List<EventFeedback> allFeedback;

  FeedbackAnalytics(this.allFeedback);

  // Average Rating Calculation
  double get averageRating {
    if (allFeedback.isEmpty) return 0;
    return allFeedback.map((f) => f.rating).reduce((a, b) => a + b) / allFeedback.length;
  }

  // Rating Distribution (1-5 stars)
  Map<int, int> get ratingDistribution {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final feedback in allFeedback) {
      distribution[feedback.rating] = (distribution[feedback.rating] ?? 0) + 1;
    }
    return distribution;
  }

  // Most Common Words in Comments
  Map<String, int> get commonWords {
    final wordCount = <String, int>{};
    const stopWords = {'the', 'and', 'a', 'to', 'was', 'it', 'in', 'of', 'for'};

    for (final feedback in allFeedback) {
      if (feedback.comment.isEmpty) continue;
      
      feedback.comment
          .toLowerCase()
          .split(RegExp(r'\W+'))
          .where((word) => word.length > 3 && !stopWords.contains(word))
          .forEach((word) {
            wordCount[word] = (wordCount[word] ?? 0) + 1;
          });
    }

    return wordCount;
  }

  // Recent Feedback (last 7 days)
  List<EventFeedback> get recentFeedback {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return allFeedback.where((f) => f.timestamp.isAfter(weekAgo)).toList();
  }

  // Generate CSV Report
  String generateCSV() {
    final csvRows = [
      ['Rating', 'Comment', 'User', 'Date'],
      ...allFeedback.map((f) => [
        f.rating.toString(),
        f.comment,
        f.userName ?? 'Anonymous',
        DateFormat('yyyy-MM-dd').format(f.timestamp),
      ])
    ];
    return const ListToCsvConverter().convert(csvRows);
  }
}