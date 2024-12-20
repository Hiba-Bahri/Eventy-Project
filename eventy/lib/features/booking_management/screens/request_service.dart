import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> allServices = [];
  List<Map<String, dynamic>> filteredServices = [];
  String? selectedCategory;
  List<String> categories = ['Catering', 'Audio', 'Visual', 'Security', 'Photography', 'Cake', 'Decorations', 'Entertainment', 'Transportation', 'Stage Setup', 'Lighting', 'Food Stalls', 'First Aid'];
  String? requestedCategory; // Tracks the category with an active request
  String? requestedServiceId; // Tracks the specific requested service ID

  @override
  void initState() {
    super.initState();
    fetchServices();
    fetchExistingRequests();
  }

  // Fetch all services
  Future<void> fetchServices() async {
    final QuerySnapshot snapshot = await firestore.collection('services').get();
    final services = snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();

   /*Set<String> uniqueCategories = services.map((service) {
      return service['category'] as String? ?? 'Uncategorized';
    }).toSet();*/

    setState(() {
      allServices = services;
      filteredServices = services;
      //categories = uniqueCategories.toList();
    });
  }

  // Check if the user has any pending request
  Future<void> fetchExistingRequests() async {
    final QuerySnapshot requestSnapshot = await firestore
        .collection('requests')
        .where('userId', isEqualTo: widget.userId)
        .where('status', isEqualTo: 'Pending') // Active request
        .get();

    if (requestSnapshot.docs.isNotEmpty) {
      final requestData = requestSnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        requestedCategory = requestData['category'];
        requestedServiceId = requestData['serviceId'];
      });
    }
  }

  // Send a new service request
  Future<void> sendRequest(Map<String, dynamic> service) async {
    if (requestedCategory == service['category']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot request another service in the same category until the status is "Rejected".'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await firestore.collection('requests').add({
        'eventId': widget.eventId,
        'userId': widget.userId,
        'serviceId': service['id'],
        'serviceLabel': service['label'],
        'category': service['category'],
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        requestedCategory = service['category'];
        requestedServiceId = service['id'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Filter services by category
  void filterServices(String? category) {
    setState(() {
      selectedCategory = category;
      if (category == null || category == 'All') {
        filteredServices = allServices;
      } else {
        filteredServices = allServices
            .where((service) => service['category'] == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    value: selectedCategory,
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
                      filterServices(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // List of Services
          Expanded(
            child: filteredServices.isEmpty
                ? const Center(
                    child: Text(
                      'No services available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      final isRequested = requestedServiceId == service['id'];
                      final isCategoryLocked =
                          requestedCategory == service['category'] &&
                              !isRequested;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color(0xFF3498db).withOpacity(0.1),
                            child: const Icon(
                              Icons.business_center,
                              color: Color(0xFF3498db),
                            ),
                          ),
                          title: Text(
                            service['label'] ?? 'No Label',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category: ${service['category'] ?? 'N/A'}'),
                              Text('Fee: \$${service['fee'] ?? 0}'),
                              Text(
                                  'Experience: ${service['experience'] ?? 0} years'),
                              Text('Description: ${service['description'] ?? ''}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: isRequested
                                ? null
                                : isCategoryLocked
                                    ? null
                                    : () {
                                        sendRequest(service);
                                      },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRequested
                                  ? Colors.grey
                                  : const Color(0xFF3498db),
                            ),
                            child: Text(
                              isRequested
                                  ? 'Requested'
                                  : isCategoryLocked
                                      ? 'Locked'
                                      : 'Request',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
