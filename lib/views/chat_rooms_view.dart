import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_room_model.dart';
import 'chat_detail_view.dart';
import 'dart:async';

class ChatRoomsView extends StatefulWidget {
  const ChatRoomsView({super.key});

  @override
  State<ChatRoomsView> createState() => _ChatRoomsViewState();
}

class _ChatRoomsViewState extends State<ChatRoomsView> {
  final ChatController _chatController = ChatController();
  final user = FirebaseAuth.instance.currentUser;
  late StreamSubscription<String> _chatRoomSubscription;

  @override
  void initState() {
    super.initState();
    // PATTERN: Subscribe to chat room creation updates (Observer pattern)
    /** UI as observer here wdiget subscribes/listen to the onCharRoomCreated stream of line 17 in chat_controller */
    _chatRoomSubscription =
        _chatController.onChatRoomCreated.listen((chatRoomId) {
      setState(() {});
    });
  }

// Dispose the subscription when the widget is removed from the tree
  @override
  void dispose() {
    _chatRoomSubscription.cancel();
    super.dispose();
  }

  Future<void> _createChatRoom(String name, bool isGroupChat) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // demo purposes
      final participants = [currentUser.uid];

      await _chatController.createChatRoom(
        name: name,
        participants: participants,
        eventId: '',
        isGroupChat: isGroupChat,
      );

      // Success message can be shown here if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat room created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(
        child: Text('Please log in to view your chats'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
      ),
      body: StreamBuilder<List<ChatRoom>>(
        stream: _chatController.getUserChatRooms(user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chat rooms found'));
          }

          final chatRooms = snapshot.data!;

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(chatRoom.name),
                  subtitle: Text(
                    chatRoom.isGroupChat ? 'Group Chat' : 'Direct Message',
                  ),
                  leading: Icon(
                    chatRoom.isGroupChat ? Icons.group : Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatDetailView(chatRoom: chatRoom),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateChatDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateChatDialog() {
    final TextEditingController nameController = TextEditingController();
    // Remove unused variable
    bool isGroupChat = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Add StatefulBuilder
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create New Chat'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Chat Name',
                    hintText: 'Enter a name for this chat',
                  ),
                ),
                const SizedBox(height: 15),
                SwitchListTile(
                  title: const Text('Group Chat'),
                  value: isGroupChat,
                  onChanged: (value) {
                    setDialogState(() {
                      // Use setDialogState instead of setState
                      isGroupChat = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a chat name')),
                  );
                  return;
                }

                // Store needed values before async operation
                final chatName = nameController.text.trim();
                final groupChatValue = isGroupChat;

                // Close the dialog before performing async operations
                Navigator.pop(context);

                // Now perform the async operations
                _createChatRoom(chatName, groupChatValue);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
