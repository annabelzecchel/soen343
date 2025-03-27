import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String name;
  final List<String> participants;
  final String eventId;
  final bool isGroupChat;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    required this.eventId,
    required this.isGroupChat,
    required this.createdAt,
  });

  factory ChatRoom.fromFirestore(Map<String, dynamic> data, String documentId) {
    return ChatRoom(
      id: documentId,
      name: data['name'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      eventId: data['eventId'] ?? '',
      isGroupChat: data['isGroupChat'] ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'participants': participants,
      'eventId': eventId,
      'isGroupChat': isGroupChat,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
