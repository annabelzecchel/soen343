import 'package:flutter/material.dart';
import 'package:soen343/views/login_view.dart';
import 'package:soen343/views/signUp_view.dart';

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
            color: Color.fromARGB(100,237,219,207),
            borderRadius: BorderRadius.circular(10)
        ),
        alignment: Alignment.center,
        child:  LoginForm(title: "IT WORKS"),
)),
    Container(
        color: const Color.fromARGB(101, 255, 192, 203),
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
                  icon: Icon(Icons.login),
                  label: Text('Log in'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: Text('Sign up'),
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