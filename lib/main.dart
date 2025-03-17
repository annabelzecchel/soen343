import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soen343/event_management_page.dart';
import 'package:soen343/login.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Home Page'),
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.event), // Event icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const EventManagementPage(title: 'Event Management for Organizers')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.login), // Login icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage(title: 'Login And SignUp')),
              );
            },
          ),
          
        ],
      ),

      // TextFormField(
      //   controller: nameController,
      //   decoration: const InputDecoration(
      //     hintText: 'Name',
      //   ),
      // ),
      // TextFormField(
      //   controller: typeController,
      //   decoration: const InputDecoration(
      //     hintText: 'Type',
      //   ),
      // ),
      // ElevatedButton(
      //   onPressed: () {
      //     CollectionReference colRef =
      //         FirebaseFirestore.instance.collection("events");
      //     colRef.add({
      //       "name": nameController.text,
      //       "type": typeController.text,
      //       "id": colRef.doc().id,
      //     });
      //   },
      //   child: const Text("Add Event"),
      // ),
      // const Text(
      //   'You have pushed the button this many times:',
      // ),
      // Text(
      //   '$_counter',
      //   style: Theme.of(context).textTheme.headlineMedium,
      // ),
    );
  }
}
