import 'package:flutter/material.dart';
import 'package:soen343/views/login_view.dart';
import 'package:soen343/views/signUp_view.dart';
import 'package:soen343/components/app_theme.dart';

class LoginPage extends StatefulWidget {
  final String title;
  const LoginPage({super.key, required this.title});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  

  final List<Widget> _screens = [
    UnconstrainedBox(
        child:Container(
        height : 600,
        width:400,
        decoration:BoxDecoration(
            color: Color.fromARGB(255, 235, 246, 236),
            borderRadius: BorderRadius.circular(10)
        ),
        alignment: Alignment.center,
        child:  LoginForm(title: "IT WORKS"),
)),
    Container(
        color: const Color.fromARGB(255, 235, 246, 236),
        alignment: Alignment.center,
        child: CreateAccountForm(),
        ),
  ];
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 235, 246, 236),
      ),
      body: Row(
        children: [
          Container(
            width: 200,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey, width: 1)), // Border for separation
            ),
            child: NavigationRail(
              backgroundColor: const Color.fromARGB(255, 96, 124, 100),
              onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
              },
              selectedIndex: _selectedIndex,
              destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.login, color: Colors.white),
            selectedIcon: Icon(Icons.login, color: const Color.fromARGB(255, 96, 124, 100)), // Selected icon color
            label: Text('Log in', style: TextStyle(color: Colors.white)),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.add_circle_outline, color: Colors.white),
            selectedIcon: Icon(Icons.add_circle_outline, color: const Color.fromARGB(255, 96, 124, 100)), // Selected icon color
            label: Text('Sign up', style: TextStyle(color: Colors.white)),
          ),
              ],
              labelType: NavigationRailLabelType.all,
              selectedLabelTextStyle: const TextStyle(
          color: Colors.white,
              ),
              unselectedLabelTextStyle: const TextStyle(
          color: Colors.white,
              ),
            ),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}