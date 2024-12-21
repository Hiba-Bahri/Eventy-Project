import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/notification_provider.dart';
import 'package:eventy/features/notifications/my_offers.dart';
import 'package:eventy/features/notifications/my_requests.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget{
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,

          title: const Text('Notifications'),
          bottom: const TabBar(
            labelColor: Colors.white,
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            tabs: [
              Tab(text: 'My Offers'),
              Tab(text: 'My requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyOffers(),
            MyRequests(),
          ],
        ),
      ),
    );
}
}





/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];

          // Extract notification details
          final message = notification['message'] ?? 'No message';
          final isRead = notification['read'] ?? false;
          final timestamp = notification['timestamp'] as Timestamp?;
          final formattedTime = timestamp != null
              ? DateFormat('dd MMM yyyy, HH:mm').format(timestamp.toDate())
              : 'Unknown time';
          final senderId = notification['senderId'] ?? 'Unknown sender';

          return Card(
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
              trailing: isRead
                  ? const Icon(Icons.check, color: Colors.green)
                  : IconButton(
                      icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                      onPressed: () {
                        // Mark notification as read
                        notificationProvider.markAsRead(notification[index]);
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
 */