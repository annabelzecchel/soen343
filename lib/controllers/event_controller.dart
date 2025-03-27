import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'events';

  // CREATE
  Future<void> createEvent(Event event) async {
    try {
      await _firestore.collection(collectionPath).add(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  // READ all STREAM ALLWOS FOR REAL TIME UPDATES
  Stream<List<Event>> getEvents() {
    return _firestore.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // Read a single event by ID ##REFACTOR TO STREAM IF POSSIBLE FOR IRL TIME UPDATE
  Future<Event> getEventById(String id) async {
    try {
      final doc = await _firestore.collection(collectionPath).doc(id).get();
      if (doc.exists) {
        return Event.fromFirestore(doc.data()!, doc.id);
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      throw Exception('Failed to get event: $e');
    }
  }

  // UPDATE
  Future<void> updateEvent(Event event) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(event.id)
          .update(event.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // DELELE
  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // ADD ATTENDEE
  Future<void> addAttendee(String eventId, String userId) async {
    try {
      final event = await getEventById(eventId);

      List<String> attendees = event.attendees ?? [];

      if (!attendees.contains(userId)) {
        await _firestore.collection(collectionPath).doc(eventId).update({
          'attendees': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      throw Exception('Failed to add attendee: $e');
    }
  }

  //Get all the events A user attends
  Stream<List<Event>> getUserEvents(String email) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('attendees', arrayContains: email)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<Event>((doc) {
        return Event.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

    Stream<List<Event>> getOrganizerEvents(String email) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('createdByEmail', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<Event>((doc) {
        return Event.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

    Future<void> addSponsor(String eventId, String userId) async {
    try {
      final event = await getEventById(eventId);

        await _firestore.collection(collectionPath).doc(eventId).update({
          'stakeholder': userId
        });
    } catch (e) {
      throw Exception('Failed to add sponsor: $e');
    }
  }

   Stream<List<Event>> getSponsorEvents(String email) {
    return FirebaseFirestore.instance
        .collection(collectionPath)
        .where('stakeholder', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map<Event>((doc) {
        return Event.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }
}
