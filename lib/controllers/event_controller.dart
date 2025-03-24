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
      if (!event.attendees.contains(userId)) {
        List<String> updatedAttendees = List.from(event.attendees)..add(userId);

        Map<String, dynamic> attendeesMap = {};
        for (int i = 0; i < updatedAttendees.length; i++) {
          attendeesMap[i.toString()] = updatedAttendees[i];
        }

        await _firestore
            .collection(collectionPath)
            .doc(eventId)
            .update({'attendees': attendeesMap});
      }
    } catch (e) {
      throw Exception('Failed to add attendee: $e');
    }
  }
}
