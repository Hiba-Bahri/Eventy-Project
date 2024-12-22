import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/chat_provider.dart';
import 'package:eventy/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverId;
  final String senderUsername;

  ChatScreen(
      {required this.chatRoomId,
      required this.receiverId,
      required this.senderUsername});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final chatService = Provider.of<ChatProvider>(context, listen: false);
    chatService.markMessagesAsRead(widget.chatRoomId);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.getUserData(chatService.currentUserId!);
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.senderUsername)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getMessages(widget.chatRoomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe =
                        message['senderId'] == chatService.currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              child: Text(
                                widget.senderUsername.substring(0, 1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: 
                                Text(
                                  message['text'],
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                
                            ) 
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 8),
                            Icon(
                                    message['readBy'] == null ?  Icons.check_circle_outline_rounded : Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 20.0,
                                    ),
                                    const SizedBox(width: 8),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                return CircleAvatar(
                                  child: Text(
                                    authProvider.fetchedUser?.username
                                            .substring(0, 1) ??
                                        '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                            
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      hintText: 'Type a message...',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 16),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      chatService.sendMessage(
                        chatRoomId: widget.chatRoomId,
                        message: _messageController.text,
                        receiverId: widget.receiverId,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
