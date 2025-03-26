import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:developer';

class AuthService{
    final _auth=FirebaseAuth.instance;
    final _firestore=FirebaseFirestore.instance;

    Future<String?> signUp({ required String email, required String password, required String name,required String role}) async{
      try{

        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, 
            password: password);

        final usersDB = FirebaseFirestore.instance.collection("users");
      
          await usersDB.doc(credential.user!.uid).set({
            'name':name.trim(),
            'email':email.trim(),
            'role':role,
          });
      return null;
      }catch(e){
          
            print("User could not be created");
      }
      return null;
    }

    Future<User?> loginUserWithEmailAndPassword(String email, String password) async{
      try{

        final cred= await _auth.signInWithEmailAndPassword(email:email, password:password);
      return cred.user;
      }catch(e){
            print(e);
      }
      return null;
    }
}