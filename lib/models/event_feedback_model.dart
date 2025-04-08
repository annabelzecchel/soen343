class EventFeedback {
  final String eventId;
  final String userId;
  final String? userName;
  final int rating; // 1-5 scale
  final String comment;
  final DateTime timestamp;

  EventFeedback({
    required this.eventId,
    required this.userId,
    this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EventFeedback.fromMap(Map<String, dynamic> map) {
    return EventFeedback(
      eventId: map['eventId'],
      userId: map['userId'],
      userName: map['userName'],
      rating: map['rating'],
      comment: map['comment'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}