import 'package:eventy/core/services/event_service.dart';
import 'package:flutter/material.dart';

class EventDetailsProvider extends ChangeNotifier{
  final EventService eventService;
  final String eventId;
  final String userId;

  List<Map<String, dynamic>> _allRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  String _selectedStatus = 'All';

  EventDetailsProvider({required this.eventService, required this.eventId, required this.userId}) {
  }

}