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
}
