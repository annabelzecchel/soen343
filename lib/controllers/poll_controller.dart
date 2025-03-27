import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poll_model.dart';
import 'package:flutter/material.dart';

class PollController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'polls';

  Future<void> createPoll(
      String eventId, String createdByEmail, String question) async {
    try {
      final pollData = {
        'eventId': eventId,
        'createdByEmail': createdByEmail,
        'question': question,
        'votes': {'up': [], 'down': []},
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore.collection(collectionPath).add(pollData);
    } catch (e) {
      debugPrint('Failed to create poll: $e');
      throw Exception('Failed to create poll: $e');
    }
  }

  Stream<List<Poll>> getEventPolls(String eventId) {
    try {
      return _firestore
          .collection(collectionPath)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Poll.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting polls: $e');
      return Stream.value([]);
    }
  }

  Future<void> submitVote(
      String pollId, String userEmail, String voteType) async {
    try {
      final pollDoc =
          await _firestore.collection(collectionPath).doc(pollId).get();
      if (!pollDoc.exists) {
        throw Exception('Poll not found');
      }

      final data = pollDoc.data();
      if (data == null || data['votes'] == null) {
        await _firestore.collection(collectionPath).doc(pollId).update({
          'votes': {'up': [], 'down': []}
        });
      }

      final poll = Poll.fromFirestore(pollDoc.data()!, pollId);

      if (poll.votes[voteType]?.contains(userEmail) == true) {
        return;
      }

      final oppositeType = voteType == 'up' ? 'down' : 'up';
      if (poll.votes[oppositeType]?.contains(userEmail) == true) {
        await _firestore.collection(collectionPath).doc(pollId).update({
          'votes.$oppositeType': FieldValue.arrayRemove([userEmail])
        });
      }

      await _firestore.collection(collectionPath).doc(pollId).update({
        'votes.$voteType': FieldValue.arrayUnion([userEmail])
      });
    } catch (e) {
      debugPrint('Failed to submit vote: $e');
      throw Exception('Failed to submit vote: $e');
    }
  }

  Future<void> deletePoll(String pollId) async {
    try {
      await _firestore.collection(collectionPath).doc(pollId).delete();
    } catch (e) {
      debugPrint('Failed to delete poll: $e');
      throw Exception('Failed to delete poll: $e');
    }
  }
}
