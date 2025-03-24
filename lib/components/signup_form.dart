import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:soen343/components/auth_service.dart';
import 'dart:developer';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
 final _auth = AuthService();

  final _formKey = GlobalKey<FormState>(); // Form key to validate
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();

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
            'Sign up!',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Enter Name',
              labelText: 'Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 50),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              icon: Icon(Icons.filter_vintage_outlined),
              hintText: 'Enter Email',
              labelText: 'Email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Email';
              }
              return null;
            },
          ),
          const SizedBox(height: 50),
          TextFormField(
            controller: _passwordController,
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
        //   const SizedBox(height: 50),
        //   DropdownButtonFormField(
        //     value: _roleController.text.isEmpty ? null : _roleController.text,
        //     onChanged: (String? newValue) {
        //       setState(() {
        //         _roleController.text = newValue ?? '';
        //       });
        //     },
        //     decoration: const InputDecoration(
        //       icon: Icon(Icons.filter_vintage_outlined),
        //       hintText: 'Select Role',
        //       labelText: 'Role',
        //     ),
        //     items: const [
        //       DropdownMenuItem(
        //         value: 'organizer', child: Text('Organizer'), 
        //       ),
        //       DropdownMenuItem(
        //         value: 'attendee', child: Text('Attendee'), 
        //       ),
        //       DropdownMenuItem(
        //         value: 'administration', child: Text('Administration'),
        //       ),
        //       DropdownMenuItem(
        //         value: 'Stakeholders', child: Text('Stakeholders'), 
        //       ),
        //     ],
        //     validator: (value) {
        //       if (value == null || value.isEmpty) {
        //         return 'Please enter role type';
        //       }
        //       return null;
        //     },
        //   ),
    
          const SizedBox(height: 50),
          ElevatedButton(
            onPressed:  _signup, 
            child: const Text('Sign up')
          ),
        ],
      ),
    
    );
  }

  _signup() async{
    final user = await _auth.createUserWithEmailAndPassword(_emailController.text,_passwordController.text);
    if (user != null){
        print("User Created Succefully");
    }
}
}



 // {
            //   if (_formKey.currentState?.validate() ?? false) {
            //    // String name = nameController.text;
            //     //String email = typeController.text;
            //     // You can handle the form submission here
            //    // print('Event Name: $name, Organizer Email: $email');
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Processing Data')),
            //     );
            //   }
            // },