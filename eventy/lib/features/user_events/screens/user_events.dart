import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserEvents extends StatefulWidget {
  const UserEvents({super.key});

  @override
  _UserEventsState createState() => _UserEventsState();
}
class _UserEventsState extends State<UserEvents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Events'),
        ),
        body: const Center(
          child: Text('Please log in to view your events'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('events')
            .where('userId', isEqualTo: _currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading events: ${snapshot.error}'),
            );
          }

          // Handle empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('You have no scheduled events'),
            );
          }

          // Display events
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              // Get the event document
              var eventDoc = snapshot.data!.docs[index];
              var eventData = eventDoc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    eventData['eventType'] ?? 'Unnamed Event',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${_formatDateTime(eventData['eventDateTime'])}',
                      ),
                      const SizedBox(height: 4),
                      // Display service providers
                      if (eventData['serviceProviders'] != null)
                        ...(_buildServiceProviderWidgets(eventData['serviceProviders'])),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteEvent(eventDoc.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Format DateTime to a readable string
  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  // Build widgets for service providers
  List<Widget> _buildServiceProviderWidgets(Map<String, dynamic> serviceProviders) {
    return serviceProviders.entries.map((entry) {
      return Text(
        '${entry.key}: ${entry.value}',
        style: const TextStyle(fontSize: 12),
      );
    }).toList();
  }

  // Delete event method
  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }
}