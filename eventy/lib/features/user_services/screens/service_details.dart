import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/data/models/service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ServiceDetails extends StatelessWidget {
  final String serviceId;

  const ServiceDetails({Key? key, required this.serviceId}) : super(key: key);

  Future<Service> fetchServiceDetails(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('services').doc(id).get();
    if (doc.exists) {
      return Service.fromSnapshot(doc);
    } else {
      throw Exception('Service not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Service>(
      future: fetchServiceDetails(serviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Service Not Found'),
            ),
            body: const Center(child: Text('Service not found.')),
          );
        }

        final service = snapshot.data!;
        return Consumer<AuthProvider>(builder: (context, authProvider, _) {
          authProvider.getUserData(service.userId);

          return Scaffold(
            appBar: AppBar(
              title: Text(service.category),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Center(
                      child: Column(
                        children: [
                          Text(
                            service.label,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.category,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text('State: ${service.state}'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.description),
                              title:
                                  Text('Description: ${service.description}'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.calendar_today),
                              title: Text(
                                  'Experience: ${service.experience} years'),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: Text(
                                'Fee: \$${service.fee.toStringAsFixed(2)}',
                              ),
                              subtitle: service.isFeeNegotiable
                                  ? const Text('(Negotiable)')
                                  : null,
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(
                                  'Service Provider ID: ${authProvider.fetchedUser!.username}'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /*const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),*/
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
