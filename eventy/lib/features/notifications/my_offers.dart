import 'package:eventy/core/providers/request_service_provider.dart';
import 'package:eventy/features/booking_management/request_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyOffers extends StatefulWidget {
  const MyOffers({super.key});

  @override
  _MyOfferState createState() => _MyOfferState();
}

class _MyOfferState extends State<MyOffers> {
    //Get the current user's ID
  final userId = FirebaseAuth.instance.currentUser!.uid;

 @override
  void initState() {
    super.initState();
    // Initialize the stream when the widget is created
    final provider = Provider.of<RequestServiceProvider>(context, listen: false);
    provider.getRequestsForServiceOwner(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green[600],
        title: const Text(
          'My Offers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<RequestServiceProvider>(
        builder: (context, provider, child) {
          // If the filteredRequests is empty, show the loading spinner
          if (provider.serviceOwnerRequests.isEmpty) {
            return const Center(
              child: Text("You don't have any offers yet")
            );
          }

          // Display only requests for services owned by the current user
          return ListView.builder(
            itemCount: provider.serviceOwnerRequests.length,
            itemBuilder: (context, index) {
              final request = provider.serviceOwnerRequests[index];
              return GestureDetector(
                child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    'Service: ${request['serviceLabel']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${request['status']}'),
                      Text('Category: ${request['category']}'),
                    ],
                  ),
                  trailing: Icon(
                    request['status'] == 'Accepted' 
                        ? Icons.check_circle
                        : request['status'] == 'Rejected'
                            ? Icons.cancel
                            : Icons.pending,
                    color: request['status'] == 'Accepted'
                        ? Colors.green
                        : request['status'] == 'Rejected'
                            ? Colors.red
                            : Colors.orange,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to the request details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestDetails(requestId: request['id']),
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
