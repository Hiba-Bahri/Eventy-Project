import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/features/user_events/screens/user_events_details.dart';
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

  // Color palette
  final Color _primaryColor = const Color(0xFF3498db);
  final Color _backgroundColor = const Color(0xFFF5F7FA);
  final Color _cardColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return _buildScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.login,
                size: 80,
                color: _primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'Please log in to view your events',
                style: TextStyle(
                  fontSize: 18,
                  color: _primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildScaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('events')
            .where('userId', isEqualTo: _currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'No Upcoming Events',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your scheduled events will appear here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          // Events list
          return RefreshIndicator(
            onRefresh: _refreshEvents,
            color: _primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var eventDoc = snapshot.data!.docs[index];
                var eventData = eventDoc.data() as Map<String, dynamic>;

                return _buildEventCard(eventDoc, eventData);
              },
            ),
          );
        },
      ),
    );
  }

  // Refresh events method
  Future<void> _refreshEvents() async {
    // You can add any additional refresh logic if needed
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Build overall scaffold with consistent styling
  Widget _buildScaffold({required Widget body}) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: body,
    );
  }

  // Build individual event card
  Widget _buildEventCard(DocumentSnapshot eventDoc, Map<String, dynamic> eventData) {
    return Dismissible(
      key: Key(eventDoc.id),
      background: _buildDeleteBackground(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(eventDoc.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: _cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsPage(
                    eventId: eventDoc.id,
                    eventData: eventData,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Event Type Icon
                  Container(
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      _getIconForEventType(eventData['eventType']),
                      color: _primaryColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventData['eventType'] ?? 'Unnamed Event',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDateTime(eventData['eventDateTime']),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        // Service Providers
                        if (eventData['serviceProviders'] != null)
                          ..._buildServiceProviderWidgets(eventData['serviceProviders']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build delete background for dismissible
  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  // Confirmation dialog before deleting
  Future<bool?> _showDeleteConfirmation(String eventId) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteEvent(eventId);
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Existing helper methods remain the same
  IconData _getIconForEventType(String? eventType) {
    switch (eventType?.toLowerCase()) {
      case 'medical':
        return Icons.medical_services_outlined;
      case 'meeting':
        return Icons.meeting_room_outlined;
      case 'consultation':
        return Icons.people_outline;
      default:
        return Icons.event_outlined;
    }
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(dateTime);
  }

  List<Widget> _buildServiceProviderWidgets(Map<String, dynamic> serviceProviders) {
    return serviceProviders.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          '${entry.key}: ${entry.value}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      );
    }).toList();
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete event: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}