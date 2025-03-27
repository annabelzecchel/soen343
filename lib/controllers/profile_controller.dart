import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users_model.dart';
import '../models/auth_model.dart';
import 'package:soen343/components/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfileController {
  final AuthService _authService;
  final firestore = FirebaseFirestore.instance;
  Users? user;

  ProfileController(this._authService);

  Future<Auth> getProfile(String userUID) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    try {
      if (currentUser != null) {
        final userP = FirebaseFirestore.instance.collection('users');
        final doc = await userP.doc(userUID).get();
        if (doc.exists) {
          final userData = doc.data()!;
          return Auth(
            id: userUID,
            name: userData['name'],
            email: userData['email'],
            role: userData['role'],
          );
        }
        return Auth(
          id: userUID,
          email: user?.email ?? '',
        );
      }
      return Auth(
        id: userUID,
        email: '',
      );
    } catch (e) {
      throw Exception('LOGIN FAILED');
    }
  }

  Future<String> getNameById(String id) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userP = FirebaseFirestore.instance.collection('users');
        final doc = await userP.doc(id).get();
        if (doc.exists) {
          final userData = doc.data()!;
          return userData['name'] ?? '';
        }
        return '';
      }
      return '';
    } catch (e) {
      throw Exception('LOGIN FAILED');
    }
  }

  Future<String> getRoleById(String id) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userP = FirebaseFirestore.instance.collection('users');
        final doc = await userP.doc(id).get();
        if (doc.exists) {
          final userData = doc.data()!;
          return userData['role'];
        }
        return '';
      }
      return '';
    } catch (e) {
      throw Exception('LOGIN FAILED');
    }
  }

  Future<String> getEmailById(String id) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userP = FirebaseFirestore.instance.collection('users');
        final doc = await userP.doc(id).get();
        if (doc.exists) {
          final userData = doc.data()!;
          return userData['email'];
        }
        return '';
      }
      return '';
    } catch (e) {
      throw Exception('LOGIN FAILED');
    }
  }

  //UPDATE 
   Future<void> updateUser(Users user) async {
    try {
      await firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // DELELE
  Future<void> deleteUser(String id) async {
    try {
      await firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

    // READ all STREAM ALLWOS FOR REAL TIME UPDATES
  Stream<List<Users>> getUsers() {
    // return firestore.collection('users').snapshots().map((snapshot) {
    //   return snapshot.docs.map((doc) {
    //     return Users.fromFirestore(doc.data(), doc.id);
    //   }).toList();
    // });
     return firestore
      .collection('users')
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return [];
        }
        try {
          return snapshot.docs.map((doc) {
            return Users.fromFirestore(doc.data(), doc.id);
          }).toList();
        } catch (e) {
          print('Error mapping users: $e');
          rethrow;
        }
      });
  }
}
