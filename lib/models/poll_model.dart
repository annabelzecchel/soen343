import 'package:flutter/foundation.dart';

class Poll {
  final String id;
  final String eventId;
  final String createdByEmail;
  final String question;
  final Map<String, List<String>> votes;
  final DateTime createdAt;

  Poll._builder(PollBuilder builder)
      : id = builder.id!,
        eventId = builder.eventId!,
        createdByEmail = builder.createdByEmail!,
        question = builder.question!,
        votes = builder.votes,
        createdAt = builder.createdAt!;

  factory Poll.fromFirestore(Map<String, dynamic> data, String documentId) {
    try {
      return PollBuilder()
          .setId(documentId)
          .setEventId(data['eventId'] ?? '')
          .setCreatedByEmail(data['createdByEmail'] ?? '')
          .setQuestion(data['question'] ?? '')
          .setVotes(_parseVotes(data['votes']))
          .setCreatedAt(_parseDateTime(data['createdAt']))
          .build();
    } catch (e) {
      debugPrint('Error parsing poll data: $e');
      return PollBuilder()
          .setId(documentId)
          .setEventId(data['eventId'] ?? '')
          .setCreatedByEmail(data['createdByEmail'] ?? '')
          .setQuestion(data['question'] ?? 'Error loading poll')
          .setVotes({'up': [], 'down': []})
          .setCreatedAt(DateTime.now())
          .build();
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'createdByEmail': createdByEmail,
      'question': question,
      'votes': votes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static Map<String, List<String>> _parseVotes(dynamic votesData) {
    Map<String, List<String>> result = {'up': [], 'down': []};

    if (votesData == null) {
      return result;
    }

    try {
      if (votesData['up'] != null) {
        if (votesData['up'] is List) {
          result['up'] = List<String>.from(votesData['up']);
        } else if (votesData['up'] is Map) {
          result['up'] =
              votesData['up'].values.map<String>((e) => e.toString()).toList();
        }
      }

      if (votesData['down'] != null) {
        if (votesData['down'] is List) {
          result['down'] = List<String>.from(votesData['down']);
        } else if (votesData['down'] is Map) {
          result['down'] = votesData['down']
              .values
              .map<String>((e) => e.toString())
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error parsing votes data: $e');
    }

    return result;
  }

  static DateTime _parseDateTime(dynamic dateTimeData) {
    if (dateTimeData == null) return DateTime.now();
    try {
      return DateTime.parse(dateTimeData.toString());
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return DateTime.now();
    }
  }

  int get thumbsUpCount => votes['up']?.length ?? 0;
  int get thumbsDownCount => votes['down']?.length ?? 0;
  int get totalVotes => thumbsUpCount + thumbsDownCount;

  double get thumbsUpPercentage =>
      totalVotes > 0 ? (thumbsUpCount / totalVotes) * 100 : 0;
  double get thumbsDownPercentage =>
      totalVotes > 0 ? (thumbsDownCount / totalVotes) * 100 : 0;

  bool hasUserVoted(String userEmail) {
    return votes['up']?.contains(userEmail) == true ||
        votes['down']?.contains(userEmail) == true;
  }

  String? getUserVote(String userEmail) {
    if (votes['up']?.contains(userEmail) == true) return 'up';
    if (votes['down']?.contains(userEmail) == true) return 'down';
    return null;
  }
}

class PollBuilder {
  String? id;
  String? eventId;
  String? createdByEmail;
  String? question;
  Map<String, List<String>> votes = {'up': [], 'down': []};
  DateTime? createdAt;

  PollBuilder setId(String id) {
    this.id = id;
    return this;
  }

  PollBuilder setEventId(String eventId) {
    this.eventId = eventId;
    return this;
  }

  PollBuilder setCreatedByEmail(String email) {
    this.createdByEmail = email;
    return this;
  }

  PollBuilder setQuestion(String question) {
    this.question = question;
    return this;
  }

  PollBuilder setVotes(Map<String, List<String>> votes) {
    this.votes = votes;
    return this;
  }

  PollBuilder setCreatedAt(DateTime createdAt) {
    this.createdAt = createdAt;
    return this;
  }

  Poll build() {
    if (id == null) {
      throw Exception("Missing ID for Poll creation");
    }

    eventId ??= '';
    createdByEmail ??= '';
    question ??= '';
    createdAt ??= DateTime.now();

    return Poll._builder(this);
  }
}
