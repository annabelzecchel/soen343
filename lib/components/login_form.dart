import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>(); // Form key to validate
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
    void dispose(){
        super.dispose();
        _emailController.dispose();
        _passwordController.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      
      child: Column(
        children: [
          const Text(
            'Login',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          TextFormField(
            //controller: nameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Enter Username',
              labelText: 'Username',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter username';
              }
              return null;
            },
          ),
          const SizedBox(height: 50),
          TextFormField(
            //controller: descriptionController,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Enter Password',
              labelText: 'Password',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              return null;
            },
          ),

          const SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
               // String name = nameController.text;
                //String email = typeController.text;
                // You can handle the form submission here
               // print('Event Name: $name, Organizer Email: $email');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
