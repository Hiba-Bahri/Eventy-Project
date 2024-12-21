import 'package:eventy/core/services/event_service.dart';
import 'package:flutter/material.dart';

class EventDetailsProvider extends ChangeNotifier{
  final EventService eventService;
  final String eventId;
  final String userId;

  final List<Map<String, dynamic>> _allRequests = [];
  final List<Map<String, dynamic>> _filteredRequests = [];
  final String _selectedStatus = 'All';

  EventDetailsProvider({required this.eventService, required this.eventId, required this.userId});

}