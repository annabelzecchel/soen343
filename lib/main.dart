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
import 'package:soen343/components/open_ai_chatbot.dart';

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
    await dotenv.load(fileName: ".env");
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
      home: ChatBotWrapper(child: HomePage(title: 'PLANINI')),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatBotWrapper extends StatelessWidget {
  final Widget child;
  const ChatBotWrapper({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          child,
          const Positioned(
            bottom: 16.0,
            right: 16.0,
            child: OpenAIChatBot(),
          ),
        ],
      ),
    );
  }
}
