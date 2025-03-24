import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:developer';
class AuthService{
    final _auth=FirebaseAuth.instance;

    Future<User?> createUserWithEmailAndPassword(String email, String password) async{
       try{

        final cred= await _auth.createUserWithEmailAndPassword(
          email: email, 
          password: password);
       return cred.user;
       }catch(e){
          
            print("Something went wrong2");
       }
       return null;
    }

     Future<User?> loginUserWithEmailAndPassword(String email, String password) async{
       try{

        final cred= await _auth.signInWithEmailAndPassword(email:email, password:password);
       return cred.user;
       }catch(e){
            print("Something went wrong1");
       }
       return null;
    }
}