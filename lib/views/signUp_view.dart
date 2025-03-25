import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soen343/components/auth_service.dart';
import '../controllers/signUp_controller.dart';
import 'profile_view.dart';

class CreateAccountForm extends StatefulWidget {
  @override
  _CreateAccountFormState createState() => _CreateAccountFormState();
}

class _CreateAccountFormState extends State<CreateAccountForm> {
  final SignUpController _controller =SignUpController(AuthService());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Create Account',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    hintText: 'Enter your name',
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
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
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
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
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPassController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    hintText: 'Confirm your password',
                    labelText: 'Re-enter Password',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField(
                  value: _roleController.text.isEmpty ? null : _roleController.text,
                  onChanged: (String? newValue) {
                    setState(() {
                      _roleController.text = newValue ?? '';
                    });
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.filter_vintage_outlined),
                    hintText: 'Select Role',
                    labelText: 'Role',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'organizer', child: Text('Organizer'), 
                    ),
                    DropdownMenuItem(
                      value: 'attendee', child: Text('Attendee'), 
                    ),
                    DropdownMenuItem(
                      value: 'administration', child: Text('Administration'),
                    ),
                    DropdownMenuItem(
                      value: 'Stakeholders', child: Text('Stakeholders'), 
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter role type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                         onPressed: ()async{
                    if (_formKey.currentState?.validate()??false){
                        setState(()=>_isLoading=true);
                       try{
                        final auth = await _controller.signUp(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _nameController.text.trim(),
                            _roleController.text.trim()
                        );
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder:(_)=>ProfilePage())

                        );
                       }catch (e){
                        throw Exception("ERROR"+e.toString());
                       }finally {
                        setState(()=>_isLoading=false);
                       }
                    }
                },
                        child: const Text('Sign Up'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
