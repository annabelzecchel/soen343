import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soen343/controllers/event_controller.dart';
import 'package:soen343/models/event_model.dart';
import 'package:soen343/views/profile_view.dart';
import 'package:soen343/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:soen343/views/home_page_view.dart';
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
    return MaterialApp(
      title: 'Planini',
      theme: AppTheme.lightTheme,
      home: const HomePage(title: 'PLANINI'),
      debugShowCheckedModeBanner: false,
    );
  }
}
// // Ensure Flutter bindings are initialized before running the app
// void ensureFlutterBinding() {
//   WidgetsFlutterBinding.ensureInitialized();
// }

