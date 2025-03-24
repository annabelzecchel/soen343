import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen343/event_management_page.dart';
import 'package:soen343/login.dart';
import 'package:soen343/profile.dart';
import 'package:soen343/components/app_theme.dart';

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
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 235, 246, 236), // Main theme color (soft green)
            primary: const Color(0xFFABC5AE), // Primary color
            secondary: const Color(0xFFCA946F), // Secondary color (light beige)
            tertiary: const Color(0xFFA74D0F), // Tertiary color (dark orange)
            surface: const Color(0xFFCBDBCD), // Background color
            inversePrimary: const Color.fromARGB(255, 235, 246, 236), // Color for app bar
            secondaryContainer: const Color(0xFFeddbcf), // light beige
            error: const Color.fromARGB(255, 214, 7, 7), // Error color (dark orange)
            onPrimary: Colors.black, // Text color on primary
            onSecondary: Colors.white, // Text color on secondary
            onTertiary: Colors.black, // Text color on secondary
            onSurface: Colors.black, // Text color on background
          ),
          useMaterial3: true,
        ),
        home: Builder(builder: (context) {
          AppTheme.init(context);
          return const MyHomePage(title: 'Home Page');
          Auth
        },
        ),
        debugShowCheckedModeBanner: false,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.colorScheme.inversePrimary,
        title: Text(widget.title),
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
            ProfileButton(
            icon: const Icon(Icons.child_care), // Login icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login !')),
              );
            },
          ),
          
        ],
      ),
    );
  }
}
