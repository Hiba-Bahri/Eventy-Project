import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';

class ConversationsList extends StatelessWidget {
  const ConversationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatProvider>(context);

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
              final otherUser = (chatRoom['users'] as List)
                  .firstWhere((user) => user != chatService.currentUserId);

              return ListTile(
                title: Text('Chat with $otherUser'),
                subtitle: Text(chatRoom['lastMessage']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: chatRoom.id,
                        receiverId: otherUser,
                      ),
                    ),
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
