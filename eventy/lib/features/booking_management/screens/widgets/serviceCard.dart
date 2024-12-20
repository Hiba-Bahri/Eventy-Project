// First, let's create the ServiceCard widget
import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isRequested;
  final bool isCategoryLocked;
  final VoidCallback onRequest;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.isRequested,
    required this.isCategoryLocked,
    required this.onRequest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3498db).withOpacity(0.1),
          child: Icon(
            Icons.business_center,
            color: const Color(0xFF3498db),
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
            Text('Experience: ${service['experience'] ?? 0} years'),
            Text('Description: ${service['description'] ?? ''}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: isRequested
              ? null
              : isCategoryLocked
                  ? null
                  : onRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: isRequested ? Colors.grey : const Color(0xFF3498db),
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
  }
}