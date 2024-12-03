import 'package:eventy/core/services/firestore_events_management.dart';
import 'package:eventy/features/booking_management/screens/booking.dart';
import 'package:flutter/material.dart';
import 'package:eventy/shared/widgets/dropdown_field.dart';
import 'package:intl/intl.dart';

class ScheduleEvent extends StatefulWidget {
  const ScheduleEvent({super.key});

  @override
  _ScheduleEventState createState() => _ScheduleEventState();
}

class _ScheduleEventState extends State<ScheduleEvent> {
  String? _selectedEventType;
  final Map<String, String> _selectedServiceProviders = {};
  final List<String> _additionalServices = [];
  DateTime? _eventDateTime;
  final FirestoreEventService _eventService = FirestoreEventService();

  // Event types and their corresponding services
  final Map<String, List<String>> _eventServices = {
    'Conference': ['Catering', 'Audio/Visual', 'Security'],
    'Wedding': ['Photography', 'Catering', 'Music'],
    'Birthday': ['Cake', 'Decorations', 'Entertainment'],
    'Corporate Meeting': ['Catering', 'Audio/Visual', 'Security', 'Transportation'],
    'Concert': ['Stage Setup', 'Sound System', 'Lighting', 'Security'],
    'Festival': ['Food Stalls', 'Entertainment', 'Security', 'First Aid'],
  };

  // All available services (for additional service selection)
  final Map<String, List<String>> _serviceProviders = {
    'Catering': ['Gourmet Catering', 'Budget Bites', 'Elegant Eats'],
    'Audio/Visual': ['Tech Wizards', 'Sound Masters', 'Visual Pros'],
    'Security': ['SafeGuard', 'Elite Protection', 'Event Sentinels'],
    'Photography': ['Capture Moments', 'Lens Masters', 'Memory Makers'],
    'Music': ['Groove Band', 'DJ Pros', 'Live Performers'],
    'Cake': ['Sweet Delights', 'Cake Haven', 'Bakery Bliss'],
    'Decorations': ['Design Dreams', 'Decor Experts', 'Creative Styles'],
    'Entertainment': ['Fun Factory', 'Event Entertainers', 'Party Planners'],
    'Transportation': ['Ride Pros', 'Shuttle Experts', 'Event Movers'],
    'Stage Setup': ['Stage Masters', 'Event Riggers', 'Performance Pros'],
    'Sound System': ['Audio Experts', 'Sound Specialists', 'Acoustic Pros'],
    'Lighting': ['Light Masters', 'Illumination Pros', 'Event Lighting'],
    'Food Stalls': ['Street Food Hub', 'Culinary Corners', 'Tasty Treats'],
    'First Aid': ['Medical Pros', 'Emergency Response', 'Health Guardians'],
  };

  Future<void> _selectEventDateTime() async {
  // Pick a date
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: _eventDateTime?.toLocal() ?? DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2025),
  );
  if (pickedDate == null) return;

  // Pick a time
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: _eventDateTime != null
        ? TimeOfDay.fromDateTime(_eventDateTime!)
        : TimeOfDay.now(),
  );
  if (pickedTime == null) return;

  // Combine date and time
  setState(() {
    _eventDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  });
}

  // Get all unique services
  List<String> get _allAvailableServices {
    return _serviceProviders.keys.toList();
  }

  // Navigate to BookingPage and handle booking result
  Future<void> _navigateToBookingPage(String serviceName) async {
    if (_eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date first!')),
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          service: serviceName,
          eventDateTime: _eventDateTime!,
        ),
      ),
    );

    // Handle the booking result
    if (result != null && result is String) {
      setState(() {
        _selectedServiceProviders[serviceName] = result;
      });
    }
  }

  Future<void> _saveEvent() async {
    // Validate all required fields are filled
    if (_selectedEventType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event type')),
      );
      return;
    }

    if (_eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date and time')),
      );
      return;
    }

    // Check if all required services are booked
    final requiredServices = _eventServices[_selectedEventType!]!;
    final unbookedServices = requiredServices
        .where((service) => !_selectedServiceProviders.containsKey(service))
        .toList();

    if (unbookedServices.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please book the following services: ${unbookedServices.join(", ")}'
          ),
        ),
      );
      return;
    }

    try {
      // Save the event to Firestore
      await _eventService.saveEvent(
        eventType: _selectedEventType!,
        eventDateTime: _eventDateTime!,
        serviceProviders: _selectedServiceProviders,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event successfully scheduled!')),
      );

      // Reset the form
      setState(() {
        _selectedEventType = null;
        _selectedServiceProviders.clear();
        _eventDateTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule an Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Schedule an Event',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Event Type Dropdown
            DropdownField<String>(
              value: _selectedEventType,
              hintText: 'Select Event Type',
              items: _eventServices.keys.toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEventType = newValue;
                  // Clear additional services and selected providers
                  _additionalServices.clear();
                  _selectedServiceProviders.clear();
                });
              },
            ),
            
            // Event Date Picker
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectEventDateTime,
              child: Text(
                _eventDateTime == null
                    ? 'Select Event Date'
                    : 'Selected: ${DateFormat('yyyy-MM-dd HH:mm').format(_eventDateTime!)}',
              ),
            ),
            
            // Required Services Buttons
            if (_selectedEventType != null) ...[
              const SizedBox(height: 16),
              Text(
                'Required Services',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _eventServices[_selectedEventType!]!.map((service) => 
                  ElevatedButton(
                    onPressed: () => _navigateToBookingPage(service),
                    child: Text(
                      _selectedServiceProviders.containsKey(service)
                        ? '$service - ${_selectedServiceProviders[service]!.split(' - ')[0]}'
                        : service
                    ),
                  )
                ).toList(),
              ),
            ],
            if (_selectedEventType != null && 
              _eventDateTime != null && 
              _selectedServiceProviders.isNotEmpty && 
              _selectedServiceProviders.length == _eventServices[_selectedEventType!]!.length) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white
              ),
              child: const Text('Save Event'),
            ),
          ],
          ],
        ),
      ),
    );
  }
}