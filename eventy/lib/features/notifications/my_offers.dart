import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/notification_provider.dart';
import 'package:eventy/features/booking_management/request_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyOffers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.notifications.isEmpty) {
          return const Center(child: Text('No notifications available.'));
        }

        return ListView.builder(
          itemCount: notificationProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = notificationProvider.notifications[index];

            final message = notification['message'] ?? 'No message';
            final isRead = notification['read'] ?? false;
            final timestamp = notification['timestamp'] as Timestamp?;
            final formattedTime = timestamp != null
                ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
                : 'Unknown time';
            final senderId = notification['senderId'] ?? 'Unknown sender';
            final requestId = notification['requestId'];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RequestDetails(requestId: requestId),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    message,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text('From: $senderId'),
                      const SizedBox(height: 5),
                      Text('Received: $formattedTime'),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
