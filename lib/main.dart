import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen343/event_management_page.dart';
import 'package:soen343/login.dart';
import 'package:soen343/components/app_theme.dart';
import 'package:soen343/components/eventList.dart';
import 'package:soen343/views/events_list_view.dart';
import 'package:soen343/views/profile_view.dart';
import 'package:soen343/views/login_view.dart';
import 'package:soen343/views/signUp_view.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: dotenv.env['APIKEY'] ?? '',
            authDomain: dotenv.env['AUTHDOMAIN'] ?? '',
            projectId: dotenv.env['PROJECTID'] ?? '',
            storageBucket: dotenv.env['STORAGEBUCKET'] ?? '',
            messagingSenderId: dotenv.env['MESSAGESENDERID'] ?? '',
            appId: dotenv.env['APPID'] ?? '',
            measurementId: dotenv.env['MEASUREMENTID'] ?? ''));
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final nameController = TextEditingController();
  final typeController = TextEditingController();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => MaterialApp(
        title: 'Planini',
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            return const MyHomePage(title: 'Planini');
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
// Ensure Flutter bindings are initialized before running the app
void ensureFlutterBinding() {
  WidgetsFlutterBinding.ensureInitialized();
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  String ? logIn_Out;
  final FirebaseAuth _auth =FirebaseAuth.instance;
  User?_currentUser;
  
  
  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user){
      setState((){
        _currentUser=user;
      });
    });
    
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 251.0, // Increase the height of the AppBar
      title: Row(
        children: [
        Image.asset(
          '../../assets/Planini_NoBackground.png', // Replace with your image path
          height: 250, // Adjust the height as needed
        ),
        //const SizedBox(width: 10), // Add spacing between image and title
        /*Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40
          ),
        ),*/
        ],
      ),
      actions: [
        IconButton(
        icon: const Icon(Icons.event), // Event icon
        onPressed: () {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EventManagementPage(
              title: 'Event Management for Organizers')),
          );
        },
        ),
          IconButton(
            icon: const Icon(Icons.login), // Login icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login !')),
              );
            },
          ),
          const SizedBox(height: 20),
          // if (_currentUser != null){
            IconButton(
            icon: const Icon(Icons.child_care), // Profile icon
            onPressed: () async {
              final user = await FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login !'),
                  ),
                );
              }
            },
          ),
          
            ElevatedButton(
            onPressed: () async {
              if (_currentUser == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(title:'Sign In!'),
                  ),
                );
              } else {
                await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context,
                     MaterialPageRoute(
                    builder: (context) => const MyHomePage(title: "HOME"),
                     )
                  );
              }
            },child:Text(_currentUser==null?"Sign in!": "Sign out!"),
            ),
          
        ],
      ),
      body: const EventsListView(),
    );
  }
}
