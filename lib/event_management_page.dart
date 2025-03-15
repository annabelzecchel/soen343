import 'package:flutter/material.dart';

class EventManagementPage extends StatefulWidget {
  final String title;
  const EventManagementPage({super.key, required this.title});

  @override
  State<EventManagementPage> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagementPage> {
  final List<Widget> _screens = [
    //Content Event page tab
    Container(
        color: Colors.red,
        alignment: Alignment.center,
        child: const Text(
          'Events',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: Colors.blue,
        alignment: Alignment.center,
        child: const Text(
          'Profile',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: Colors.green,
        alignment: Alignment.center,
        child: const Text(
          'Settings',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: Colors.yellow,
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
        backgroundColor: Colors.deepPurple,
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
