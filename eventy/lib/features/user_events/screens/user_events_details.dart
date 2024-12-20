import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/features/booking_management/screens/request_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventDetailsPage({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Map<String, dynamic> eventServices;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> allRequests = [];
  List<Map<String, dynamic>> filteredRequests = [];
  String selectedStatus = 'All'; // Default dropdown filter value

  @override
  void initState() {
    super.initState();
    eventServices = widget.eventData['services'] ?? {};
    fetchServiceRequests();
  }

  /// Fetch service requests for this event and user
  Future<void> fetchServiceRequests() async {
    try {
      final querySnapshot = await firestore
          .collection('requests')
          .where('eventId', isEqualTo: widget.eventId)
          .where('userId', isEqualTo: widget.eventData['userId'])
          .get();

      final requests = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      setState(() {
        allRequests = requests;
        filterRequests();
      });
    } catch (e) {
      print('Error fetching service requests: $e');
    }
  }

  /// Filter requests based on status
  void filterRequests() {
    setState(() {
      if (selectedStatus == 'All') {
        filteredRequests = allRequests;
      } else {
        filteredRequests = allRequests
            .where((request) => request['status'] == selectedStatus)
            .toList();
      }
    });
  }

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.eventData['eventType'] ?? 'Event Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 16),
              // Event Details Section
              Text(
                'Event Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Event Type: ${widget.eventData['eventType']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Event Date: ${widget.eventData["eventDateTime"] is Timestamp 
                  ? _formatDateTime(widget.eventData["eventDateTime"]) 
                  : 'No date available'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Filtering Dropdown
              Text(
                'Service Requests',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: ['All', 'Pending', 'Accepted', 'Rejected']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedStatus = value!;
                    filterRequests();
                  });
                },
              ),
              const SizedBox(height: 8),
              // Display Requests
              filteredRequests.isEmpty
                  ? const Center(
                      child: Text(
                        'No requests found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              child: Icon(
                                Icons.business,
                                color: Colors.blue.shade600,
                              ),
                            ),
                            title: Text(
                              request['serviceLabel'] ?? 'No Label',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category: ${request['category']}'),
                                Text('Status: ${request['status']}'),
                              ],
                            ),
                            trailing: Icon(
                              Icons.circle,
                              color: _getStatusColor(request['status']),
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RequestService(
                eventId: widget.eventId,
                userId: widget.eventData['userId'],
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Request Service'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// Get color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
