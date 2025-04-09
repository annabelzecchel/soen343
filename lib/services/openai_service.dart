import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();
// API KEY GOES HERE FOR TESTING PURPOSES! .ENV FILE REF DOES NOT WORK
  final String _apiKey = 'put-your-api-key-here';
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  final String _model = 'gpt-3.5-turbo';

  Future<void> initialize() async {
    if (_apiKey.isEmpty || !_apiKey.startsWith('sk-')) {
      throw Exception('Invalid API Key');
    }
  }

  Future<Map<String, dynamic>> generateChatResponse(
    List<Map<String, dynamic>> messages, {
    bool enableWebSearch = false,
    String? webSearchQuery,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return {
        'success': false,
        'message': 'API key not configured. Please set up your OpenAI API key.'
      };
    }

    try {
      // Prepare the request body
      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 500,
      };

      // Add web search functionality if enabled
      if (enableWebSearch && webSearchQuery != null) {
        requestBody['tools'] = [
          {
            'type': 'function',
            'function': {
              'name': 'web_search',
              'description': 'Search the web for current information',
              'parameters': {
                'type': 'object',
                'properties': {
                  'query': {
                    'type': 'string',
                    'description':
                        'Search query to find current web information'
                  }
                },
                'required': ['query']
              }
            }
          }
        ];

        // Add tool choice to force web search
        requestBody['tool_choice'] = {
          'type': 'function',
          'function': {'name': 'web_search'}
        };
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['choices'][0]['message']['content'];
        return {
          'success': true,
          'message': botResponse,
        };
      } else {
        debugPrint(
            'OpenAI API Error: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message':
              'Error communicating with OpenAI API: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      debugPrint('Exception when calling OpenAI API: $e');
      return {
        'success': false,
        'message': 'Failed to connect to OpenAI API: $e',
      };
    }
  }

  // Example usage method
  Future<Map<String, dynamic>> searchWebAndRespond(
    List<Map<String, dynamic>> conversationHistory,
    String query,
  ) async {
    // Add the web search query to the conversation history
    conversationHistory
        .add({'role': 'user', 'content': 'Please search the web for: $query'});

    return await generateChatResponse(
      conversationHistory,
      enableWebSearch: true,
      webSearchQuery: query,
    );
  }

  Map<String, String> getPlaniniSystemMessage() {
    // Keep the existing system message
    return {
      'role': 'system',
      'content': '''
You are Planini Assistant, a helpful chatbot for the Planini event management application.
Your role is to help users navigate the app and provide information about its features.

About Planini:
- It's an event management platform where users can create, find, and register for events
- It offers tools for event organizers including analytics, promotion, and attendee management
- It has chat features for communication between organizers and attendees
- It supports various user roles: organizers, attendees, stakeholders, and administrators

When users ask questions about the app, provide helpful information and suggest relevant sections they can navigate to.
For questions outside the scope of the app, suggest contacting support@planini.com.

Available app sections:
- Event Creation: Where organizers can create and configure new events
- Event Management: For organizing and editing existing events
- Events List: For finding and browsing events
- Event Details: For viewing specific event information
- Registration: For signing up to attend events
- Profile: For viewing and editing user information
- Chat Rooms: For communication between users
- Event Promotion: For marketing events
- Analytics: For viewing event statistics and reports
- Polls: For gathering attendee feedback

Keep your responses concise and focused on helping the user navigate the application.
Use a friendly but professional tone.
'''
    };
  }
}
