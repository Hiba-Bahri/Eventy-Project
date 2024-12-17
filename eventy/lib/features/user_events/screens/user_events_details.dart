import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/features/booking_management/screens/request_service.dart';
import 'package:eventy/features/event_management/widgets/custom_dropdown_field.dart';
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
  late Map<String, dynamic> additionalServices;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize with existing services from event data
    eventServices = widget.eventData['services'] ?? {};
    additionalServices = {};
  }
  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return 'No date';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('EEE, MMM d, yyyy • h:mm a').format(dateTime);
  }

  void _showAddServiceDialog() {
    final TextEditingController serviceNameController = TextEditingController();
    final TextEditingController providerController = TextEditingController();
    final services = ['Catering','Audio','Visual','Security','Photography','Cake','Decorations','Entertainment','Transportation','Stage Setup','Lighting','Food Stalls','First Aid'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            CustomDropdownField(items: services, hintText: 'Service', onChanged: (value) {
              serviceNameController.text = value ?? '';
            }),
          const SizedBox(height: 10),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Add Service'),
              onPressed: () async {
              // Validate and add service
              if (serviceNameController.text.isNotEmpty) {
                String serviceKey = serviceNameController.text.toLowerCase();
                if (eventServices.containsKey(serviceKey)) {
                  Navigator.of(context).pop();
                  // Show a message that the service already exists
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Service already exists in required services')),
                  );
                } else {
                  // Update local state
                  setState(() {
                    additionalServices[serviceKey] = providerController.text.isNotEmpty
                        ? providerController.text
                        : null;
                  });

                  // Add the service to the database
                  try {
                    // Reference the event document
                    DocumentReference eventRef = FirebaseFirestore.instance
                        .collection('events')
                        .doc(widget.eventId); 

                    // Fetch current services mapping
                    DocumentSnapshot eventSnapshot = await eventRef.get();
                    Map<String, dynamic> services =
                        (eventSnapshot.data() as Map<String, dynamic>)['services'] ?? {};

                    // Update the services mapping
                    services[serviceKey] = providerController.text.isNotEmpty
                        ? providerController.text
                        : null;

                    // Update Firestore document
                    await eventRef.update({'services': services});

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service added successfully')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add service: $e')),
                    );
                  }
                }
              }
            },
            ),
          ],
        );
      },
    );
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
              //Event Details Section
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

              // Required Services Section
              Text(
                'Suggested Services',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildServiceList(context, eventServices),
              
              const SizedBox(height: 16),
              
              // Additional Services Section
              if (additionalServices.isNotEmpty) ...[
                Text(
                  "Additional Services", 
                  style: Theme.of(context).textTheme.titleMedium
                ),
                const SizedBox(height: 8),
                _buildServiceList(context, additionalServices),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddServiceDialog,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Service'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildServiceList(BuildContext context, Map<String, dynamic> services) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final serviceKey = services.keys.elementAt(index);
        final serviceName = serviceKey[0].toUpperCase() + serviceKey.substring(1);

        return GestureDetector(
          onLongPress: ()async {
          try{
            final eventRef = FirebaseFirestore.instance
                .collection('events') // Replace with your collection
                .doc(widget.eventId); // Replace with your document ID

            // Create a local copy of the services
            Map<String, dynamic> updatedServices = Map.from(services);

            // Remove the service locally
            updatedServices.remove(serviceKey);

            // Update Firestore
            await eventRef.update({'services': updatedServices});

            // Update the local state
            setState(() {
              services.remove(serviceKey);
            });

            // Show success feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Service "$serviceName" removed')),
            );
          }catch(e){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to remove service: $e')),
            );
          }
          }, 
          // Update the services mapping in Firestore
          onTap: () {
            // Navigate to the service providers page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ServiceProvidersPage(
                  eventId: widget.eventId,
                  userId: widget.eventData['userId'],
                  serviceName: serviceName,
                ),
              ),
            );
        
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                      ),
                      Text(
                        services.entries.elementAt(index).value != null 
                          ? 'Provider: ${services.entries.elementAt(index).value}' 
                          : 'No provider assigned',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        );
      },
    );
  }
}