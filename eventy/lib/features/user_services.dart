import 'package:eventy/core/providers/chat_provider.dart';
import 'package:eventy/features/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserServices extends StatefulWidget {
  const UserServices({super.key});

  @override
  _UserServicesState createState() => _UserServicesState();
}

class _UserServicesState extends State<UserServices> {
  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatProvider>(context);
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final infos = await chatService.initiateChatRoomAndSendMessage(
              user1Id: "3mR7jMzoDJRoEByEsYEzAm2egDx2", // the authenticated user id (hedhi id mta3 l compte mte3i)
              user2Id: "4ZWDZmHWXHVlaRLAMDQ5JxGpu553", // the other user in the chat (hedhi mtaa ay aabd ekher , idha ken laabd hedheka andou deja conversation m3ak bch yabaathk ll conversation hedhika snn yaaml convo jdida)
            );

            if (infos != null && infos.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatRoomId: infos[0],
                    receiverId: infos[1],
                    senderUsername: infos[2]
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to initiate chat")),
              );
            }
          },
          child: const Text("Click"),
        ),
      ),
    );
  }
}
