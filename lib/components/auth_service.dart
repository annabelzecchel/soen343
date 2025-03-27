import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:developer';

class AuthService {
  /* PATTERN: Singleton creates 1 instance which is _instance below EAGER SINGLETON */
  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /* Privatizing the constructor to prevent new instances from outside class */
  AuthService._internal();

  /* Returns same instance instead of creating new */
  factory AuthService() {
    return _instance;
  }

  Future<String?> signUp(
      {required String email,
      required String password,
      required String name,
      required String role}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final usersDB = FirebaseFirestore.instance.collection("users");

      await usersDB.doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
      });
      return null;
    } catch (e) {
      print("User could not be created");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      print(e);
    }
    return null;
  }
}
