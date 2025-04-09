import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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

  Future<List<Map<String,dynamic>>> getEventAttendees (String eventID) async{
    try{
      DocumentSnapshot eventDocument= await FirebaseFirestore.instance
        .collection(collectionPath)
        .doc(eventID)
        .get();

        if (!eventDocument.exists ||!(eventDocument.data() as Map<String, dynamic>).containsKey('attendees')){
          return [];
        }

        List<dynamic> attendeeEmails = (eventDocument.data() as Map<String, dynamic>)['attendees'];
        List<Map<String, dynamic>> attendees = [];

        for (String email in attendeeEmails.cast<String>()){
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo:email)
            .limit(1)
            .get();

          if (userSnapshot.docs.isNotEmpty){
            Map<String, dynamic> userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
            userData['id']=userSnapshot.docs.first.id;
            attendees.add(userData);
          }
        }
        return attendees;
    }catch (e){
      print('ERROR GETTING ALL ATTENDEES : $e');
      return [];
    }
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

    Future<void> addSponsor(String eventId, String userId, int amount) async {
    try {
      final event = await getEventById(eventId);

    DocumentSnapshot eventDoc = await _firestore.collection(collectionPath).doc(eventId).get();
    Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;
 
    Map<String, dynamic> stakeholders =  (eventData['stakeholder'] as Map<String, dynamic>?) ?? {};
    
      stakeholders[userId] = amount;
      await _firestore.collection(collectionPath).doc(eventId).update({'stakeholder': stakeholders});
  
    } catch (e) {
      throw Exception('Failed to add sponsor: $e');
    }
  }

   Stream<List<Event>> getSponsorEvents(String email) {
       return FirebaseFirestore.instance
      .collection(collectionPath) 
      .snapshots()
      .map((snapshot) {
        List<Event> events = [];
        
        for (var doc in snapshot.docs) {
          try {
            Event event = Event.fromFirestore(doc.data(), doc.id);
            if (event.stakeholder.containsKey(email)) {
              events.add(event);
            }
          } catch (e) {
            print('ERROR GETTING EVENT ${doc.id}: $e');
          }
        }
        return events;
      });
  }

}
