import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soen343/components/auth_service.dart';
import 'package:soen343/components/event_creation_form.dart';
import 'package:soen343/controllers/profile_controller.dart';
import 'package:soen343/views/calendar_view.dart';
import 'package:soen343/views/analytics_view.dart';
import 'package:soen343/views/event_promotion.dart';

class EventManagementPage extends StatefulWidget {
  final String title;
  const EventManagementPage({super.key, required this.title});

  @override
  State<EventManagementPage> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagementPage> {
  String? _email;
  final ProfileController _profileController = ProfileController(AuthService());

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
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
      Container(
        alignment: Alignment.center,
        child: const EventPromotionPage(),
      ),
      Container(
        alignment: Alignment.center,
        child: AnalyticsView(),
      ),
      Container(
        alignment: Alignment.center,
        child: const Text(
          'About',
          style: TextStyle(fontSize: 40),
        ),
      )
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
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.event),
                  label: Text('Events Creation'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Event Management'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.share),
                  label: Text('Event Promotion'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics),
                  label: Text('Analytics & Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info),
                  label: Text('About'),
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
