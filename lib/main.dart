import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:soen343/components/openai_chatbot.dart';
import 'package:soen343/views/home_page_view.dart';
import 'package:soen343/components/app_theme.dart';
import 'package:logging/logging.dart';
import 'package:soen343/service/openai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();
  final logger = Logger('main');

  try {
    await dotenv.load();
    if (kIsWeb) {
      await dotenv.load(fileName: ".env");
    }
    logger.info("Environment variables loaded successfully");

    final openaiKey = dotenv.env['OPENAI_API_KEY'];
    if (openaiKey != null && openaiKey.isNotEmpty) {
      logger.info("OpenAI API key found: ${_redactApiKey(openaiKey)}");
    } else {
      logger.warning("OpenAI API key not found in environment variables");
    }

    final openAIService = OpenAIService();
    try {
      await openAIService.initialize();
      logger.info("OpenAI service initialized successfully");
    } catch (e) {
      logger.severe("Failed to initialize OpenAI service: $e");
    }
  } catch (e) {
    logger.severe("Error loading environment variables: $e");
  }

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

void _setupLogging() {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = kReleaseMode ? Level.INFO : Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    }
  });
}

String _redactApiKey(String key) {
  if (key.length <= 6) return '***';
  return '${key.substring(0, 3)}...${key.substring(key.length - 3)}';
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
      home: const ChatBotWrapper(child: HomePage(title: 'PLANINI')),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatBotWrapper extends StatelessWidget {
  final Widget child;
  const ChatBotWrapper({super.key, required this.child});
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
