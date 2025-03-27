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
import 'event_form_view.dart';
import '../controllers/event_controller.dart';
import 'package:soen343/views/events_list_view.dart';
import 'package:soen343/views/event_detail_view.dart';
import '../models/event_model.dart';
import 'package:soen343/views/calendar_view.dart';

class ProfilePage extends StatefulWidget{
    final Users? users;
    
    const ProfilePage({Key?key, this.users}): super (key: key);
    
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
    String? _email;
    final _emailController = TextEditingController();
    final _nameController = TextEditingController();
     final _roleController = TextEditingController();
       final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    _loadUserProfile();
      _fetchUserRole();
       _setUserEmail();
       _saveUser();
        final users = widget.users;
  }

   Future<void> _setUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = await _controller.getEmailById(user.uid);
      setState(() {
        _email = email;
      });
    } 
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
         setState(() => _isLoading = true);
      try {
      if (widget.users != null) {
        final updatedUser = UsersBuilder()
            .setId(widget.users!.id)
            .setEmail(_emailController.text)
            .setName(_nameController.text)
            .setRole(_roleController.text)
            .build();
          await _controller.updateUser(updatedUser);

        }

         Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
         final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to your Profile Page ${userName ?? 'User'}'),
        actions:[ if (type == 'organizer' ||
                type == "Stakeholders" ||
                type == "administrator"||
                type =="attendee")
              ...[
                IconButton(
                  icon: const Icon(Icons.payment),
                  onPressed: () {
                    Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const PaymentView()),
               );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.analytics),
                  onPressed: () {
                  Navigator.push(
                 context,
                MaterialPageRoute(builder: (context) => AnalyticsView()),
                );
                  },
                ),
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
                ),
              
          
              ]]
      ,
        ),
       body: Column(
        children: [

          // Search Bar - Styled with green and brown
          Padding(
            padding: const EdgeInsets.all(16.0),
            //child: 
          ),
           _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildMyEventsList(context),
            const SizedBox(height: 24),
            if(type == 'organizer')
            _buildMyOrganizedEventsList(context),
            if(type == 'Stakeholders')
            _buildMySponsorsList(context),
            const SizedBox(height: 24),
            Text('All Users'),
            
            if(type == 'administration')
               Expanded(
            child: StreamBuilder<List<Users>>(
              stream: _controller.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.brown[600],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading users',
                      style: TextStyle(color: Colors.brown[800]),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 50, color: Colors.brown[600]),
                        const SizedBox(height: 16),
                        Text(
                          'No users available',
                          style: TextStyle(
                            color: Colors.brown[800],
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }
               final users = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: colorScheme.inversePrimary, // Light green
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary, // Medium green
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.account_circle,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: TextStyle(
                                            color: Colors.brown[800],
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.role,
                                          style: TextStyle(
                                            color: Colors.brown[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ), IconButton(
                                      icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Are you sure you WANT to Update User'),
                                            content: 
                                            Container(
                                            child:Form(
                                              key: _formKey,
                                              child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextFormField(
                                                            controller: _nameController,
                                                            decoration: const InputDecoration(
                                                              icon: Icon(Icons.email),
                                                              hintText: 'Enter the new name',
                                                              labelText: 'Name',
                                                            ),
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Please enter NEW name';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          TextFormField(
                                                            controller: _emailController,
                                                            decoration: const InputDecoration(
                                                              icon: Icon(Icons.email),
                                                              hintText: 'Enter the NEW email',
                                                              labelText: 'Email',
                                                            ),
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Please enter NEW email';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                          TextFormField(
                                                            controller: _roleController,
                                                            decoration: const InputDecoration(
                                                              icon: Icon(Icons.email),
                                                              hintText: 'Enter the NEW Role',
                                                              labelText: 'Role',
                                                            ),
                                                            validator: (value) {
                                                              if (value == null || value.isEmpty) {
                                                                return 'Please enter NEW Role';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                            
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                             TextButton(
                                                  onPressed: _saveUser,
                                                  
                                                  child: const Text("Update a User"),
                                                ),
                                            ])
                                            ),),
                                          ),
                                        );
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete User'),
                                            content: const Text(
                                                'Are you SURE you want to DELETE this user?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await _controller
                                                      .deleteUser(user.id);
                                                  Navigator.pop(context); //Dialog
                                                  Navigator.pop(context); //List
                                                },
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.alternate_email,
                                    size: 18,
                                    color: Colors.brown[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                   user.email,
                                    style: TextStyle(
                                      color: Colors.brown[600],
                                    ),
                                  ),
                                  const Spacer(),

           
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            )),

             Row(
                    mainAxisSize: MainAxisSize.min,
                    children: 
                    [
                // IconButton(
                //   icon: const Icon(Icons.edit),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) =>
                //             EventFormView(event: _currentEvent),
                //       ),
                //     );
                //   },
                // ),
              ]
                    )
            
        ],
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
              'My Upcoming Events...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
                 StreamBuilder<List<Event>>(
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
                    if(events.isEmpty){
                      return ListTile(
                        title: Text("You have not registered for any events yet!"),
                        dense: true,
                      );
                    }
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
                ),
          ],
        ),
      ),
    );
  }

     Widget _buildMyOrganizedEventsList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events I am Organizing... ',
              style:Theme.of(context).textTheme.headlineSmall
            ),
            const SizedBox(height: 8),
                 StreamBuilder<List<Event>>(
                  stream: _eventController.getOrganizerEvents(user.email!),
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
                    if(events.isEmpty){
                      return ListTile(
                        title: Text("You have not created any events yet!"),
                        dense: true,
                      );
                    }
                     return ListView.builder(
                    shrinkWrap: true,
                    //physics: const NeverScrollableScrollPhysics(),
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

       Widget _buildMySponsorsList(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Events I am Sponsoring...',
              style:Theme.of(context).textTheme.headlineSmall
            ),
            const SizedBox(height: 8),
                 StreamBuilder<List<Event>>(
                  stream: _eventController.getSponsorEvents(user.email!),
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
                    if(events.isEmpty){
                      return ListTile(
                        title: Text("You have not created any events yet!"),
                        dense: true,
                      );
                    }
                     return ListView.builder(
                    shrinkWrap: true,
                    //physics: const NeverScrollableScrollPhysics(),
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