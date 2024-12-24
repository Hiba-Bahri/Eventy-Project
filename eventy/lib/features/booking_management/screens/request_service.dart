import 'package:eventy/core/providers/request_service_provider.dart';
import 'package:eventy/features/booking_management/widgets/serviceCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequestService extends StatefulWidget {
  final String eventId;
  final String userId;

  const RequestService({
    super.key,
    required this.eventId,
    required this.userId,
  });

  @override
  _RequestServiceState createState() => _RequestServiceState();
}

class _RequestServiceState extends State<RequestService> {
  // Add the categories list as a class field
  final List<String> categories = [
    'Catering',
    'Audio',
    'Visual',
    'Security',
    'Photography',
    'Cake',
    'Decorations',
    'Entertainment',
    'Transportation',
    'Stage Setup',
    'Lighting',
    'Food Stalls',
    'First Aid'
  ];

  @override
  void initState() {
    super.initState();
    context.read<RequestServiceProvider>().init(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestServiceProvider>(
      builder: (context, provider, child) {
        final currentRequest = provider.currentRequest;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Request Services'),
            centerTitle: true,
            backgroundColor: const Color(0xFF3498db),
          ),
          body: Column(
            children: [
              // Dropdown Filter
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Filter by Category: ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: provider.selectedCategory,
                        isExpanded: true,
                        hint: const Text('Select a category'),
                        items: [
                          const DropdownMenuItem(
                            value: 'All',
                            child: Text('All Categories'),
                          ),
                          ...categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          provider.filterServices(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // List of Services
              Expanded(
                child: provider.filteredServices.isEmpty
                    ? const Center(
                        child: Text(
                          'No services available.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = provider.filteredServices[index];
                          final isRequested = currentRequest != null &&
                              currentRequest['serviceId'] == service['id'];
                          final isCategoryLocked = currentRequest != null &&
                              currentRequest['category'] == service['category'] &&
                              !isRequested;

                          return ServiceCard(
                            service: service,
                            isRequested: isRequested,
                            isCategoryLocked: isCategoryLocked,
                            onRequest: () async {
                                try {
                                  // Send the service request and get the requestId
                                  final requestId = await provider.sendRequest(
                                    eventId: widget.eventId,
                                    userId: widget.userId,
                                    service: service,
                                  );

                                  // Send the notification with the requestId
                                  /* await provider.sendNotification(
                                    receiverId: service['userId'],
                                    message: 'New service request for ${service['label']}',
                                    requestId: requestId, // Pass the requestId here
                                  ); */

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Service request sent successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    print('Error sending request: $e');
                                  }
                                }
                              },
                          );  
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}