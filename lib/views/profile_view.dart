import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import '../controllers/profile_controller.dart';
import '../models/users_model.dart';
import '../models/auth_model.dart';
import 'package:soen343/components/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:soen343/views/payment_view.dart';
import 'package:soen343/views/analytics_view.dart'; // Ensure this file exists and contains the AnalyticsView class
import 'dart:developer' as developer;

class ProfilePage extends StatefulWidget{
    const ProfilePage({Key?key}): super (key: key);

    @override 
    State<ProfilePage> createState()=> _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage>{
    final ProfileController _controller= ProfileController(AuthService());
    Auth ?_user;
    bool _isLoading=false;
    final user= FirebaseAuth.instance.currentUser!;
    final firestore=FirebaseFirestore.instance;
    String? userName;
    User ? userModel;
    String? uName;


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(()=>_isLoading=true);
      final user=FirebaseAuth.instance.currentUser;

      if (user!=null){
        final userModel = await _controller.getProfile(user?.uid ?? '');
        final uName = await _controller.getNameById(user?.uid ?? '');
        setState((){_user=userModel;userName=uName;});
      }
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

    @override
    Widget build(BuildContext context){

        return Scaffold(
            appBar: AppBar(
            title: const Center(child: Text('Profile')),
            actions: [
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
              icon: const Icon(Icons.payment),
              onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaymentView()),
              );
              },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnalyticsView()),
              );
              },
              ),
            ),
          ],
            ),
            body:Center(
                child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                        if (user != null)
                        Text('Signed in as: ${user.email ?? 'User'}'),
                        Text('Welcome, ${userName ?? 'User'}'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                        onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                        },
                        child: const Text('Logout'),
                        ),
                    ],
                ),
            ),
        );
    }
}