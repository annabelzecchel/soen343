import 'package:flutter/material.dart';
import 'package:soen343/components/event_creation_form.dart';
import 'package:soen343/components/app_theme.dart';
import 'package:soen343/components/manage_event_tab.dart';

class EventManagementPage extends StatefulWidget {
  final String title;
  const EventManagementPage({super.key, required this.title});

  @override
  State<EventManagementPage> createState() => _EventManagementState();
}

class _EventManagementState extends State<EventManagementPage> {
  
  final List<Widget> _screens = [
    Container(
        color: AppTheme.colorScheme.primary,
        alignment: Alignment.center,
        child: const EventCreationForm(),
        ),
    Container(
        color: AppTheme.colorScheme.primary,
        alignment: Alignment.center,
        child: const ManageEventTab(),
        ),
    Container(
        color: AppTheme.colorScheme.primary,
        alignment: Alignment.center,
        child: const Text(
          'Settings',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: AppTheme.colorScheme.primary,
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
        backgroundColor: AppTheme.colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey, width: 1)), // Border for separation
            ),
            child: NavigationRail(
              backgroundColor: AppTheme.colorScheme.surface,
              indicatorColor: AppTheme.colorScheme.secondaryContainer,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.event),
                  label: Text('Create New Event'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Manage My Events'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Analytics & Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.info),
                  label: Text('About'),
                ),
              ],
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: TextStyle(
                color: AppTheme.colorScheme.tertiary,
              ),
              selectedIconTheme: IconThemeData(
                color: AppTheme.colorScheme.tertiary,
              ),
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
