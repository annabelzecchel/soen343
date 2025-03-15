import 'package:flutter/material.dart';
import 'package:soen343/components/event_creation_form.dart';

class EventManagementPage extends StatefulWidget {
  final String title;
  const EventManagementPage({super.key, required this.title});

  @override
  State<EventManagementPage> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagementPage> {
  final List<Widget> _screens = [
    Container(
        color: const Color.fromARGB(100, 244, 67, 54),
        alignment: Alignment.center,
        child: const EventCreationForm(),
        ),
    Container(
        color: const Color.fromARGB(101, 33, 149, 243),
        alignment: Alignment.center,
        child: const Text(
          'Manage Events',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: const Color.fromARGB(103, 76, 175, 79),
        alignment: Alignment.center,
        child: const Text(
          'Settings',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: const Color.fromARGB(100, 255, 235, 59),
        alignment: Alignment.center,
        child: const Text(
          'About',
          style: TextStyle(fontSize: 40),
        ))
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 170, 130, 239),
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey, width: 1)), // Border for separation
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
                  label: Text('Events'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Profile'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info),
                  label: Text('About'),
                ),
              ],
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: const TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
