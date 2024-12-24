import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/firestore_events_management.dart';
import 'package:eventy/features/event_management/widgets/custom_date_picker.dart';
import 'package:eventy/features/event_management/widgets/custom_dropdown_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ScheduleEvent extends StatefulWidget {
  const ScheduleEvent({super.key});

  @override
  _ScheduleEventState createState() => _ScheduleEventState();
}

class _ScheduleEventState extends State<ScheduleEvent> {
  String? _selectedEventType;
  String? _eventTypeError;
  String? _dateTimeError;
  final Map<String, String> _selectedServiceProviders = {};
  final List<String> _additionalServices = [];
  DateTime? _eventDateTime;
  final FirestoreEventService _eventService = FirestoreEventService(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance);

  // Event types and their corresponding services
  final Map<String, List<String>> _eventServices = {
    'Conference': ['Catering', 'Audio', 'Visual', 'Security'],
    'Wedding': ['Photography', 'Catering', 'Audio'],
    'Birthday': ['Cake', 'Decorations', 'Entertainment'],
    'Corporate Meeting': [
      'Catering',
      'Audio',
      'Visual',
      'Security',
      'Transportation'
    ],
    'Concert': ['Stage Setup', 'Audio', 'Lighting', 'Security'],
    'Festival': ['Food Stalls', 'Entertainment', 'Security', 'First Aid'],
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

    try {
      // Get the required services for the selected event type
      final requiredServices = _eventServices[_selectedEventType!]!;

      // Create a map of services with null values
      final services = {
        for (var service in requiredServices) service.toLowerCase(): null
      };

      // Save the event to Firestore with the new structure
      await _eventService.saveEvent(
        eventType: _selectedEventType!,
        eventDateTime: _eventDateTime!,
        services: services,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event successfully scheduled!')),
      );

      // Reset the form
      setState(() {
        _selectedEventType = null;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Schedule an Event',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // Custom Dropdown Field

            CustomDropdownField(
              value: _selectedEventType,
              items: _eventServices.keys.toList(),
              hintText: 'Select Event Type',
              errorText: _eventTypeError,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedEventType = newValue;
                  _eventTypeError = null;
                  _additionalServices.clear();
                  _selectedServiceProviders.clear();
                });
              },
            ),

            const SizedBox(height: 16),

            CustomDateTimePicker(
              selectedDateTime: _eventDateTime,
              errorText: _dateTimeError,
              onSelectDateTime: () async {
                // Existing date time selection logic
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _eventDateTime?.toLocal() ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2025),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.blue,
                          primary: Colors.blue.shade600,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate == null) return;

                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _eventDateTime != null
                      ? TimeOfDay.fromDateTime(_eventDateTime!)
                      : TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: Colors.blue,
                          primary: Colors.blue.shade600,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedTime == null) return;

                setState(() {
                  _eventDateTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  _dateTimeError = null;
                });
              },
            ),

            if (_selectedEventType == null) ...[
              const SizedBox(height: 210),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note,
                      color: Colors.blue.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Start by selecting an event type to schedule your event.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            //Required Services
            if (_selectedEventType != null) ...[
              const SizedBox(height: 16),
              Text(
                'Required Services',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _eventServices[_selectedEventType!]!.length,
                itemBuilder: (context, index) {
                  final service = _eventServices[_selectedEventType!]![index];
                  final isSelected =
                      _selectedServiceProviders.containsKey(service);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green.shade200
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                              ),
                              if (isSelected)
                                Text(
                                  'Provider: ${_selectedServiceProviders[service]}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                )
                              else
                                Text(
                                  'No provider selected',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey.shade500,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            // Create Event Button
            if (_selectedEventType != null && _eventDateTime != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _saveEvent,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      child: Center(
                        child: Text(
                          'Create Event',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
