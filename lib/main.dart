import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

class EventManagementPage extends StatelessWidget {
  const EventManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Management Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Go back to Home Page
          },
          child: const Text('Go Back'),
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final typeController = TextEditingController();
  int _counter = 0;

  final List<Widget> _screens = [
    //Content Event page tab
    Container(
        color: Colors.red,
        child: const Text(
          'Events',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: Colors.blue,
        child: const Text(
          'Profile',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: Colors.green,
        child: const Text(
          'Settings',
          style: TextStyle(fontSize: 40),
        )),
    Container(
        color: Colors.yellow,
        child: const Text(
          'About',
          style: TextStyle(fontSize: 40),
        ))
  ];

  int _selectedIndex = 0;

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
                MaterialPageRoute(builder: (context) => const EventManagementPage()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedIndex: _selectedIndex,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.event),
                label: Text('Events'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
            selectedLabelTextStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _screens[_selectedIndex], // Display the selected section
              ],
            ),
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
        ],
      ),
    );
  }
}
