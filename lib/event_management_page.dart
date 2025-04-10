import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soen343/components/auth_service.dart';
import 'package:soen343/components/event_creation_form.dart';
import 'package:soen343/controllers/profile_controller.dart';
import 'package:soen343/views/calendar_view.dart';
import 'package:soen343/views/analytics_view.dart';
import 'package:soen343/components/event_analytics_screen.dart';

class EventManagementPage extends StatefulWidget {
  final String title;
  const EventManagementPage({super.key, required this.title});

  @override
  State<EventManagementPage> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagementPage> {
  String? _email;
  final ProfileController _profileController = ProfileController(AuthService());
  String? type;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
    _fetchUserRole();
  }

  Future<void> _fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userRole = await _profileController.getEmailById(user.uid);
      setState(() {
        _email = userRole;
        print('Fetched email: $_email');
      });
    } else {
      setState(() {
        _email = "gftjytkyk";
      });
    }
  }

    Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userRole = await _profileController.getRoleById(user.uid);
      print(userRole);
      setState(() {
        type = userRole;
      });
    }
  }

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
    if (type != null &&
          (type!.toLowerCase() == 'organizer' ||
              type!.toLowerCase() == 'administration' ||
              type!.toLowerCase() == 'stakeholders'))
      Container(
        alignment: Alignment.center,
        child: const EventCreationForm(),
      ),
      Container(
        alignment: Alignment.center,
        child: _email != null
            ? CalendarComponent(
                key: ValueKey(_email),
                userEmail: _email!,
              )
            : const CircularProgressIndicator(),
      ),
      if (type != null &&
            (type!.toLowerCase() == 'organizer' ||
                type!.toLowerCase() == 'administration' ||
                type!.toLowerCase() == 'stakeholders'))
      Container(
        alignment: Alignment.center,
        child: const AnalyticsView(),
      ),     
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            child: NavigationRail(
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
              destinations:  [
              if (type == 'organizer'||type == 'Stakeholders'||type == 'administration')
                NavigationRailDestination(
                  icon: Icon(Icons.event),
                  label: Text('Events Creation'),
                ),
          
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Event Management'),
                ),
                if (type == 'organizer'||type == 'Stakeholders'||type == 'administration')
                NavigationRailDestination(
                  icon: Icon(Icons.analytics),
                  label: Text('Analytics & Reports'),
                ),
              ],
              labelType: NavigationRailLabelType.all,
            ),
          ),
          Expanded(child: screens[_selectedIndex]),
        ],
      ),
    );
  }
}
