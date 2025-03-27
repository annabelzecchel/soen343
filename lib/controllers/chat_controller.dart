import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/chat_message_model.dart';
import '../models/chat_room_model.dart';

class ChatController {
  /* PATTERN: StreamController is used to notify UI component -> class chat_rooms_view
  the controller manages steam of chat room creations events. Allows controller to decouple from UI it
   doesnt know abt chat_rooms_view widget + stream allows real-time updates */
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final StreamController<String> _chatRoomCreatedController =
      StreamController<String>.broadcast();

  Stream<String> get onChatRoomCreated => _chatRoomCreatedController.stream;

  Future<String> createChatRoom({
    required String name,
    required List<String> participants,
    required String eventId,
    required bool isGroupChat,
  }) async {
    try {
      final chatRoomData = ChatRoom(
        id: '',
        name: name,
        participants: participants,
        eventId: eventId,
        isGroupChat: isGroupChat,
        createdAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore
          .collection('chatRooms')
          .add(chatRoomData.toFirestore());
      /*notifies all UI components that new chat room has been created */
      _chatRoomCreatedController.add(docRef.id);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create chat room: $e');
    }
  }

  Future<void> addChatRoomMembers(
      String chatRoomId, List<String> newMemberIds) async {
    try {
      final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);

      return _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(chatRoomRef);

        if (!snapshot.exists) {
          throw Exception('Chat room not found');
        }

        final data = snapshot.data()!;
        List<String> currentParticipants =
            List<String>.from(data['participants'] ?? []);

        bool changed = false;
        for (var memberId in newMemberIds) {
          if (!currentParticipants.contains(memberId)) {
            currentParticipants.add(memberId);
            changed = true;
          }
        }

        if (changed) {
          transaction
              .update(chatRoomRef, {'participants': currentParticipants});
        }

        return;
      });
    } catch (e) {
      print('Error adding chat members: $e');
      throw Exception('Failed to add chat members: $e');
    }
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final message = ChatMessage(
        id: '',
        senderId: user.uid,
        senderName: user.displayName ?? user.email ?? 'Anonymous',
        content: content,
        timestamp: DateTime.now(),
        chatRoomId: chatRoomId,
      );

      await _firestore.collection('chatMessages').add(message.toFirestore());
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return _firestore
        .collection('chatMessages')
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Stream<List<ChatRoom>> getUserChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatRoom.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<ChatRoom> getChatRoomById(String chatRoomId) async {
    try {
      final doc =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();
      if (doc.exists) {
        return ChatRoom.fromFirestore(doc.data()!, doc.id);
      } else {
        throw Exception('Chat room not found');
      }
    } catch (e) {
      throw Exception('Failed to get chat room: $e');
    }
  }

  void dispose() {
    _chatRoomCreatedController.close();
  }
}
