import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/providers/notification_provider.dart';
import 'package:eventy/features/booking_management/request_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyRequests extends StatelessWidget {
  const MyRequests({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('No requests found.'),
      );
  }
}
