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
  final String image;

  Event({
    required this.id,
    required this.attendees,
    required this.createdByEmail,
    required this.dateTime,
    required this.description,
    required this.format,
    required this.location,
    required this.name,
    required this.price,
    required this.type,
    required this.image,
  });

  // Firebase to Event
  factory Event.fromFirestore(Map<String, dynamic> data, String documentId) {
    List<String> parseAttendees(dynamic attendeesData) {
      if (attendeesData == null) return [];
      if (attendeesData is Map) {
        return attendeesData.values.map((e) => e.toString()).toList();
      }
      if (attendeesData is List) {
        return attendeesData.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Error for Invalid date format 33 (Solution)
    DateTime parseDateTime(dynamic dateTimeData) {
      if (dateTimeData == null) return DateTime.now();

      try {
        return DateTime.parse(dateTimeData.toString());
      } catch (e) {
        print('Error parsing date: $e');
        return DateTime.now();
      }
    }

    return Event(
      id: documentId,
      attendees: parseAttendees(data['attendees']),
      createdByEmail: data['createdByEmail'] ?? '',
      dateTime: parseDateTime(data['dateTime']),
      description: data['description'] ?? '',
      format: data['format'] ?? '',
      location: data['location'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] != null
          ? double.tryParse(data['price'].toString()) ?? 0.0
          : 0.0,
      type: data['type'] ?? '',
      image: data['image'] ?? '',
    );
  }

  // CEvent to Firebase
  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> attendeesMap = {};
    for (int i = 0; i < attendees.length; i++) {
      attendeesMap[i.toString()] = attendees[i];
    }

    return {
      'attendees': attendeesMap,
      'createdByEmail': createdByEmail,
      //IDK getting invalid date format
      'dateTime': dateTime.toIso8601String(),
      'description': description,
      'format': format,
      'location': location,
      'name': name,
      'price': price.toString(),
      'type': type,
      'image': image,
    };
  }
}
