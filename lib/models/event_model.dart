import 'package:flutter/material.dart';

class Event {
  final String id;
  final List<String> attendees;
  final String createdByEmail;
  final DateTime dateTime;
  final String description;
  final String format;
  final String location;
  final String name;
  final double price;
  final String type;

  Event._builder(EventBuilder builder)
      : id = builder.id!,
        attendees = builder.attendees,
        createdByEmail = builder.createdByEmail!,
        dateTime = builder.dateTime!,
        description = builder.description!,
        format = builder.format!,
        location = builder.location!,
        name = builder.name!,
        price = builder.price!,
        type = builder.type!;

  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    return EventBuilder()
        .setId(documentId)
        .setAttendees(_parseAttendees(data['attendees']))
        .setCreatedByEmail(data['createdByEmail'] ?? '')
        .setDateTime(_parseDateTime(data['dateTime']))
        .setDescription(data['description'] ?? '')
        .setFormat(data['format'] ?? '')
        .setLocation(data['location'] ?? '')
        .setName(data['name'] ?? '')
        .setPrice(data['price'] != null
            ? double.tryParse(data['price'].toString()) ?? 0.0
            : 0.0)
        .setType(data['type'] ?? '')
        .build();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attendees': _convertAttendees(attendees),
      'createdByEmail': createdByEmail,
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'format': format,
      'location': location,
      'name': name,
      'price': price.toString(),
      'type': type,
    };
  }

  static List<String> _parseAttendees(dynamic attendeesData) {
    if (attendeesData == null) return [];
    if (attendeesData is Map) {
      return attendeesData.values.map((e) => e.toString()).toList();
    }
    if (attendeesData is List) {
      return attendeesData.map((e) => e.toString()).toList();
    }
    return [];
  }

  static DateTime _parseDateTime(dynamic dateTimeData) {
    if (dateTimeData == null) return DateTime.now();
    try {
      return DateTime.parse(dateTimeData.toString());
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
    }
  }

  static Map<String, dynamic> _convertAttendees(List<String> attendees) {
    Map<String, dynamic> attendeesMap = {};
    for (int i = 0; i < attendees.length; i++) {
      attendeesMap[i.toString()] = attendees[i];
    }
    return attendeesMap;
  }
}

class EventBuilder {
  String? id;
  List<String> attendees = [];
  String? createdByEmail;
  DateTime? dateTime;
  String? description;
  String? format;
  String? location;
  String? name;
  double? price;
  String? type;

  EventBuilder setId(String id) {
    this.id = id;
    return this;
  }

  EventBuilder setAttendees(List<String> attendees) {
    this.attendees = attendees;
    return this;
  }

  EventBuilder setCreatedByEmail(String email) {
    this.createdByEmail = email;
    return this;
  }

  EventBuilder setDateTime(DateTime dateTime) {
    this.dateTime = dateTime;
    return this;
  }

  EventBuilder setDescription(String description) {
    this.description = description;
    return this;
  }

  EventBuilder setFormat(String format) {
    this.format = format;
    return this;
  }

  EventBuilder setLocation(String location) {
    this.location = location;
    return this;
  }

  EventBuilder setName(String name) {
    this.name = name;
    return this;
  }

  EventBuilder setPrice(double price) {
    this.price = price;
    return this;
  }

  EventBuilder setType(String type) {
    this.type = type;
    return this;
  }

  Event build() {
    if (id == null ||
        createdByEmail == null ||
        dateTime == null ||
        description == null ||
        format == null ||
        location == null ||
        name == null ||
        price == null ||
        type == null) {
      throw Exception("Missing required fields for Event creation");
    }
    return Event._builder(this);
  }
}
