import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';

class ConversationsList extends StatelessWidget {
  const ConversationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatProvider>(context);
    final authService = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatRooms = snapshot.data!.docs;

          if (chatRooms.isEmpty) {
            return const Center(child: Text('No chats yet!'));
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final otherUserId = (chatRoom['users'] as List)
                  .firstWhere((user) => user != chatService.currentUserId);

              return FutureBuilder(
                future: authService.getUserData(otherUserId), // Now uses caching
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                      subtitle: Text('Fetching user details...'),
                    );
                  }

                  if (snapshot.hasError) {
                    return const ListTile(
                      title: Text('Error'),
                      subtitle: Text('Could not fetch user details.'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const ListTile(
                      title: Text('Unknown User'),
                      subtitle: Text('No user details available.'),
                    );
                  }

                  final user = snapshot.data;

                  return ListTile(
                    title: Text('Chat with ${user.username}'), // Display the user’s name
                    subtitle: Text(chatRoom['lastMessage']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: chatRoom.id,
                            receiverId: otherUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              );

            },
          );
        },
      ),
    );
  }
}
