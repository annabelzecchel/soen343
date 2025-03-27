import 'package:flutter/material.dart';
import 'package:soen343/views/profile_view.dart';
import 'package:soen343/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:soen343/views/home_page_view.dart';
import 'package:soen343/components/app_theme.dart';
import 'package:soen343/event_management_page.dart';
import 'package:soen343/views/events_list_view.dart';
import 'package:soen343/views/chat_rooms_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planini',
      theme: AppTheme.lightTheme,
      home: const HomePage(title: 'PLANINI'),
      debugShowCheckedModeBanner: false,
    );
  }
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
  String? loginOut;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 251.0,
        title: Row(
          children: [
            Image.asset(
              '../../assets/Planini_NoBackground.png',
              height: 250,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.event),
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
            icon: const Icon(Icons.chat),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatRoomsView(),
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
          IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login !')),
              );
            },
          ),
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.child_care),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
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
                    builder: (context) => const LoginPage(title: 'Sign In!'),
                  ),
                );
              } else {
                await FirebaseAuth.instance.signOut();
                if (!mounted) return;

                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(title: "HOME"),
                    ));
              }
            },
            child: Text(_currentUser == null ? "Sign in!" : "Sign out!"),
          ),
        ],
      ),
      body: const EventsListView(),
    );
  }
}
