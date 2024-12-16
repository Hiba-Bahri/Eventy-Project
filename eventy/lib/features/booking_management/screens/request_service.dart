import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServiceProvidersPage extends StatelessWidget {
  final String serviceName;
  final String eventId; // Add eventId here
  final String userId; // Add userId here

  const ServiceProvidersPage({
    super.key,
    required this.serviceName,
    required this.eventId,
    required this.userId,
  });

  void _saveRequest(BuildContext context, String providerId) async {
    // Save request to Firestore
    final request = {
      'userId': userId,
      'providerId': providerId,
      'eventId': eventId,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('requests').add(request);
      if (context.mounted) {
      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully!')),
      );
      Navigator.of(context).pop();
      }
    } catch (e) {
    if (context.mounted) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$serviceName Providers'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('services')
              .where('category', isEqualTo: serviceName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No providers found.'));
            }

            final providers = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

            return ListView.builder(
              itemCount: providers.length,
              itemBuilder: (context, index) {
                final provider = providers[index];
                return ListTile(
                  title: Text(
                    provider['label'] ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    provider['description'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      provider['label']?.substring(0, 1) ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  trailing: const Icon(Icons.contact_mail),
                  onTap: () {
                     _saveRequest(context, provider['userId']);
                    Navigator.of(context).pop();
                    // Action when tapping a provider
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
