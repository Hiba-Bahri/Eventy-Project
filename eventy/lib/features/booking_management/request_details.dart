import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/chat_provider.dart';
import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/features/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:eventy/core/providers/request_service_provider.dart';

class RequestDetails extends StatefulWidget {
  final String requestId;

  const RequestDetails({
    super.key,
    required this.requestId,
  });

  @override
  _RequestDetailsState createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  Map<String, dynamic>? requestDetails;
  Map<String, dynamic>? serviceDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequestDetails();
  }

  Future<void> _fetchRequestDetails() async {
  try {
    final requestProvider = context.read<RequestServiceProvider>();
    final serviceProvider = context.read<ServiceProvider>();
    final details = await requestProvider.getRequestDetails(widget.requestId);

    // Fetch service details to get the userId
    final serviceDetails = await serviceProvider.getServiceDetails(details?['serviceId']);
    final serviceOwnerId = serviceDetails?['userId'];

    setState(() {
      requestDetails = details;
      requestDetails!['serviceOwnerId'] = serviceOwnerId; // Add ownerId to requestDetails
      isLoading = false;
      print("Auth User ID : ${context.read<AuthProvider>().user!.uid}");
      print("Service ID Owner : $serviceOwnerId");
    });
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
//Initiate Chat
Future<void> _initiateChat() async {
  try {
    print("Starting chat initiation...");
    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    
    print("Current user ID: ${authProvider.user?.uid}");
    print("Service owner ID: ${requestDetails?['serviceOwnerId']}");
    print("Sender ID: ${requestDetails?['userId']}");

    // Determine who is the other user in the chat
    String otherUserId;
    if (authProvider.user!.uid == requestDetails!['serviceOwnerId']) {
      // If current user is service owner, chat with request sender
      otherUserId = requestDetails!['userId'];
      print("Current user is service owner, chatting with: $otherUserId");
    } else {
      // If current user is request sender, chat with service owner
      otherUserId = requestDetails!['serviceOwnerId'];
      print("Current user is sender, chatting with: $otherUserId");
    }

    print("Initiating chat room...");
    final chatDetails = await chatProvider.initiateChatRoomAndSendMessage(
      user1Id: authProvider.user!.uid,
      user2Id: otherUserId,
    );
    print("Chat details received: $chatDetails");

    if (chatDetails != null) {
      final [chatRoomId, receiverId, receiverUsername] = chatDetails;
      print("Navigating to chat screen with room ID: $chatRoomId");
      
      // Navigate to ChatScreen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: chatRoomId,
            receiverId: receiverId,
            senderUsername: receiverUsername,
          ),
        ),
      );
    } else {
      print("Chat details were null");
      throw Exception("Failed to create chat room");
    }
  } catch (e, stackTrace) {
    print("Error in _initiateChat: $e");
    print("Stack trace: $stackTrace");
    
    if (mounted) {  // Check if the widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

//Accept Request
void acceptRequest() async {
    try {
      final requestProvider = context.read<RequestServiceProvider>();
      await requestProvider.updateRequestStatus(widget.requestId, 'Accepted');
      
      // Send notification to the user who requested
      /*await requestProvider.sendNotification(
        receiverId: requestDetails!['userId'], // ID of user who made the request
        message: 'Your request for ${requestDetails!['serviceLabel']} has been accepted!',
        requestId: widget.requestId,
      );
      */

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void rejectRequest() async {
    try {
      final requestProvider = context.read<RequestServiceProvider>();
      await requestProvider.updateRequestStatus(widget.requestId, 'Rejected');
      
      // Send notification to the user who requested
      /*await requestProvider.sendNotification(
        receiverId: requestDetails!['userId'], // ID of user who made the request
        message: 'Your request for ${requestDetails!['serviceLabel']} has been rejected.',
        requestId: widget.requestId,
      );*/

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request rejected successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: const Color(0xFF3498db),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requestDetails == null
              ? const Center(child: Text('Request not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request ID: ${widget.requestId}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Category: ${requestDetails!['category']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Status: ${requestDetails!['status']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Service Label: ${requestDetails!['serviceLabel']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Timestamp: ${DateFormat('dd MMM yyyy, HH:mm').format(requestDetails!['timestamp'].toDate())}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Service ID: ${requestDetails!['serviceId']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'SenderID: ${requestDetails!['userId']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      // Check if the connected user is the service owner
                    const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          print("Button pressed!");
                          _initiateChat();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          backgroundColor: Colors.blue,  // Make it visibly blue
                        ),
                        child: const Text(
                          'Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (requestDetails!['serviceOwnerId'].trim() == authProvider.user!.uid.trim() && requestDetails!['status'] == 'Pending') ...[
                    Row(children: [
                      ElevatedButton(
                        onPressed: ()=> acceptRequest(),
                        child: const Text('Accept Request'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => rejectRequest(),
                        child: const Text('Reject Request'),
                      ),
                      const SizedBox(width: 10),

                    ],)
                    ],
                  ],               
                  ),
                ),
    );
  }
}