import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soen343/models/event_feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitFeedback(EventFeedback feedback) async {
    try {
      await _firestore.collection('event_feedback').add(feedback.toMap());
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Stream<List<EventFeedback>> getFeedbackForEvent(String eventId) {
        return _firestore.collection('event_feedback').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EventFeedback.fromMap(doc.data());
      }).toList();
    });
  }
}