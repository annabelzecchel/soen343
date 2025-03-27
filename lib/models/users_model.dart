import 'package:firebase_auth/firebase_auth.dart';
class Users {
    final String id;
    final String email;
    final String name; 
    final String role;

  Users._builder(UsersBuilder builder)
      : id = builder.id!,
        email = builder.email!,
        name = builder.name!,
        role = builder.role!;

  Map<String, dynamic> toFirestore() {
    return {

      'id': id,
      'email': email,
      'name':name,
      'role': role,
    };
  }

    factory Users.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UsersBuilder()
        .setId(documentId)
        .setEmail(data['email'] ?? '')
        .setName(data['name'] ?? '')
        .setRole(data['role'] ?? '')
        .build();
  }

}

class UsersBuilder {
  String? id;
  String? email;
  String? name;
  String? role;

  UsersBuilder setId(String id) {
    this.id = id;
    return this;
  }

  UsersBuilder setEmail(String email) {
    this.email = email;
    return this;
  }

  UsersBuilder setName(String name) {
    this.name = name;
    return this;
  }

  UsersBuilder setRole(String role) {
    this.role = role;
    return this;
  }

  Users build() {
    if (id == null ||
        email == null ||
        name == null ||
        role == null ) {
      throw Exception("Missing required fields for User creation");
    }
    return Users._builder(this);
  }

}

