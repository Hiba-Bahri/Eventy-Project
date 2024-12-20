import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:eventy/features/booking_management/screens/request_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eventy/core/providers/request_service_provider.dart'; // Update with your actual path

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

  @override
  void initState() {
    super.initState();
    eventServices = widget.eventData['services'] ?? {};
    // Initialize the requests data using the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final requestProvider = context.read<RequestServiceProvider>();
      requestProvider.initRequestsListener(widget.eventId, widget.eventData['userId']);
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
              // Service Requests Section with Provider Consumer
              Consumer<RequestServiceProvider>(
                builder: (context, provider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Requests',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: provider.selectedStatus,
                        isExpanded: true,
                        items: ['All', 'Pending', 'Accepted', 'Rejected']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          provider.setSelectedStatus(value!);
                        },
                      ),
                      const SizedBox(height: 8),
                      // Display Requests
                      provider.filteredRequests.isEmpty
                          ? const Center(
                              child: Text(
                                'No requests found.',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: provider.filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = provider.filteredRequests[index];
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
          ).then((_) {
            // Refresh requests when returning from RequestService page
            final requestProvider = context.read<RequestServiceProvider>();
            requestProvider.initRequestsListener(widget.eventId, widget.eventData['userId']);
          });
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