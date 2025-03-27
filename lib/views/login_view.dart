import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/login_controller.dart';
import 'profile_view.dart';
import 'package:soen343/components/auth_service.dart';

class LoginForm extends StatefulWidget {
  final String title;
  const LoginForm({super.key, required this.title});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final LoginController _controller = LoginController(AuthService());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
Widget build(BuildContext context) {
  return Scaffold(  // Wrap in Scaffold to provide Material widget
    body: Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  hintText: 'Enter your email',
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } if (value != _passwordController.text) {
                      return 'Password or email is incorrect';
                    }
                  return null;
                },
              ),
              const SizedBox(height: 20), 
              _isLoading ? const CircularProgressIndicator():
              ElevatedButton(
                onPressed: ()async{
                    if (_formKey.currentState?.validate() ??false){
                        setState(()=>_isLoading=true);
                      try{
                        final auth = await _controller.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim()
                        );
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder:(_)=>ProfilePage()),

                        );
                      }catch (e){
                        throw Exception("ERROR"+e.toString());
                      }finally {
                        setState(()=>_isLoading=false);
                      }
                    }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
