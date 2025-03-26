import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import '../controllers/profile_controller.dart';
import '../models/users_model.dart';
import '../models/auth_model.dart';
import 'package:soen343/components/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'event_form_view.dart';
import '../controllers/event_controller.dart';
import 'package:soen343/views/events_list_view.dart';
import 'package:soen343/views/event_detail_view.dart';
import '../models/event_model.dart';

class ProfilePage extends StatefulWidget{
    const ProfilePage({Key?key}): super (key: key);

    @override 
    State<ProfilePage> createState()=> _ProfilePageState();

}

class _ProfilePageState extends State<ProfilePage>{
    final ProfileController _controller= ProfileController(AuthService());
    final EventController _eventController = EventController();
    Auth ?_user;
    bool _isLoading=false;
    final user= FirebaseAuth.instance.currentUser!;
    final firestore=FirebaseFirestore.instance;
    String? userName;
    User ? userModel;
    String? uName;
    String?role;
    String?userRole;
    String? type;


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
      _fetchUserRole();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(()=>_isLoading=true);
      final user=FirebaseAuth.instance.currentUser;

      if (user!=null){
        final userModel = await _controller.getProfile(user?.uid ?? '');
         final uName = await _controller.getNameById(user?.uid ?? '');
         final role = await _controller.getRoleById(user?.uid ?? '');

        setState((){_user=userModel;userName=uName;userRole=role;});
      }
 
    } catch (e) {
      print('Error loading user name: $e');
    }
  }

    Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userRole = await _controller.getRoleById(user.uid);
      print(userRole);
      setState(() {
        type = userRole;
      });
    }
  }

    @override
    Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to your Profile Page ${userName ?? 'User'}'),
        actions: (type == 'organizer' ||
                type == "stakeholders" ||
                type == "administrator"||
                type =="attendee")
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    //NEED TO ADD THE EDIT METHOD
                    // Navigator.push(
                    //   context,
                    //   // MaterialPageRoute(
                    //   //   builder: (context) =>,
                    //   // ),
                    // );
                  },
                )
              ]
            : null,
        ),

          body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildMyEventsList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Account Settings", style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            _buildInfoRow("Name : ${userName}" ),
            _buildInfoRow('Email : ${user.email ?? 'User Unavailale'}'),
            _buildInfoRow('Account Type : ${userRole ?? 'Role Unavailable'}'),
          ],
        ),
      ),
    );
    }

    Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

    Widget _buildMyEventsList(BuildContext context) {
    

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My events ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            (_eventController.getUserEvents(user.email!).length==0)
                ? const Text('No Events yet')
                : StreamBuilder<List<Event>>(
                  stream: _eventController.getUserEvents(user.email!),
                  builder: (context, snapshot){
                    if (!snapshot.hasData){
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final events=snapshot.data!;
                     return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event= events[index];
                      return ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(event.name),
                        dense: true,
                      );
                    },
                  );
                  }
                )
               
          ],
        ),
      ),
    );
  }
}