
import 'package:eventy/core/services/provider_availability_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  final String service;
  final DateTime eventDateTime;
  final Map<String, List<String>> serviceProviders = {
    'Catering': ['Gourmet Catering Co.', 'Flavor Feast', 'Delish Catering'],
    'Photography': ['SnapHappy Studios', 'Moment Capture', 'Picture Perfect'],
    'Cake': ['Gourmandise', 'Eric Kaiser', 'Feredic Cassel'],
    'Entertainment': ['Clown Anis', 'Ammi Radhouene', 'LiveIt Up Entertainment'],
    'Music': ['Tarattata', 'DJ Danger', 'Mazzika', 'Boudinar'],
    'Security': ['MAS Security', 'Secure Events', 'Shield Force'],
    'Audio/Visual': ['Crystal Clear Audio', 'Visual Impact Productions', 'Sonic Waves AV'],
    'Decorations': ['Dream Decor', 'Elegant Events Decor', 'Festive Touch'],
    'Transportation': ['Luxe Rides', 'Comfort Travel Services', 'QuickShuttle'],
    'Stage Setup': ['StageCraft Productions', 'Premier Stage Solutions', 'Event Stage Specialists'],
    'Sound System': ['SoundWave Rentals', 'Pro Audio Solutions', 'Bass Boost Systems'],
    'Lighting': ['BrightLight Events', 'Glow Lighting Solutions', 'Illumination Pros'],
    'Food Stalls': ['Street Eats Co.', 'Gourmet Food Trucks', 'Flavor on Wheels'],
    'First Aid': ['Quick Response Medics', 'Safety First Aid Services', 'On-Site Medical Support'],
  };

  BookingPage({super.key, required this.service, required this.eventDateTime});
  
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? selectedProvider;
  String? selectedTimeSlot;
  late Map<String, ProviderAvailability> _providersAvailability;
@override
  void initState() {
    super.initState();
    _initializeProvidersAvailability();
  }

  void _initializeProvidersAvailability() {
    _providersAvailability = {
      'Gourmet Catering Co.': ProviderAvailability(
        providerId: 'gourmet_catering',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Flavor Feast': ProviderAvailability(
        providerId: 'flavor_feast',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Delish Catering': ProviderAvailability(
        providerId: 'delish_catering',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Gourmandise': ProviderAvailability(
        providerId: 'gourmandise',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Eric Kaiser': ProviderAvailability(
        providerId: 'eric_kaiser',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Feredic Cassel': ProviderAvailability(
        providerId: 'feredic_cassel',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Clown Anis': ProviderAvailability(
        providerId: 'clown_anis',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Ammi Radhouene': ProviderAvailability(
        providerId: 'ammi_radhouene',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'LiveIt Up Entertainment': ProviderAvailability(
        providerId: 'liveit_up_entertainment',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Tarattata': ProviderAvailability(
        providerId: 'tarattata',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'DJ Danger': ProviderAvailability(
        providerId: 'dj_danger',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Mazzika': ProviderAvailability(
        providerId: 'mazzika',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Boudinar': ProviderAvailability(
        providerId: 'boudinar',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'MAS Security': ProviderAvailability(
        providerId: 'mas_security',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Secure Events': ProviderAvailability(
        providerId: 'secure_events',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Shield Force': ProviderAvailability(
        providerId: 'shield_force',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Crystal Clear Audio': ProviderAvailability(
        providerId: 'crystal_clear_audio',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Visual Impact Productions': ProviderAvailability(
        providerId: 'visual_impact_productions',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Sonic Waves AV': ProviderAvailability(
        providerId: 'sonic_waves_av',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Dream Decor': ProviderAvailability(
        providerId: 'dream_decor',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Elegant Events Decor': ProviderAvailability(
        providerId: 'elegant_events_decor',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Festive Touch': ProviderAvailability(
        providerId: 'festive_touch',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'Luxe Rides': ProviderAvailability(
        providerId: 'luxe_rides',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Comfort Travel Services': ProviderAvailability(
        providerId: 'comfort_travel_services',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'QuickShuttle': ProviderAvailability(
        providerId: 'quickshuttle',
        availableTimeSlots: {
          widget.eventDateTime: ['09:30', '10:30', '11:30', '14:30', '15:30'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
      'StageCraft Productions': ProviderAvailability(
        providerId: 'stagecraft_productions',
        availableTimeSlots: {
          widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        },
      ),
      'Premier Stage Solutions': ProviderAvailability(
        providerId: 'premier_stage_solutions',
        availableTimeSlots: {
          widget.eventDateTime: ['10:00', '11:00', '12:00', '15:00', '16:00'],
          widget.eventDateTime.add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
          widget.eventDateTime.add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
        },
      ),
    };
  }
  
  DateTime get selectedDate => widget.eventDateTime;

  /*final Map<String, ProviderAvailability> _providersAvailability = {
    'Gourmet Catering Co.': ProviderAvailability(
      providerId: 'gourmet_catering',
      availableTimeSlots: {
        DateTime.now(): ['09:00', '10:00', '11:00', '14:00', '15:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
        DateTime.now().add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
        DateTime.now().add(const Duration(days: 3)): ['10:00', '12:00', '14:00'],
        DateTime.now().add(const Duration(days: 4)): ['09:00', '11:00', '13:00'],
      },
    ),
    'Flavor Feast': ProviderAvailability(
      providerId: 'flavor_feast',
      availableTimeSlots: {
        DateTime.now(): ['10:00', '11:00', '12:00', '15:00', '16:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'Delish Catering': ProviderAvailability(
      providerId: 'delish_catering',
      availableTimeSlots: {
        DateTime.now(): ['09:30', '10:30', '11:30', '14:30', '15:30'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'SnapHappy Studios': ProviderAvailability(
      providerId: 'snaphappy_studios',
      availableTimeSlots: {
        DateTime.now(): ['09:00', '10:00', '11:00', '14:00', '15:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
        DateTime.now().add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
      },
    ),
    'Moment Capture': ProviderAvailability(
      providerId: 'moment_capture',
      availableTimeSlots: {
        DateTime.now(): ['10:00', '11:00', '12:00', '15:00', '16:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'Picture Perfect': ProviderAvailability(
      providerId: 'picture_perfect',
      availableTimeSlots: {
        DateTime.now(): ['09:30', '10:30', '11:30', '14:30', '15:30'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'Gourmandise': ProviderAvailability(
    providerId: 'gourmandise',
    availableTimeSlots: {
      widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
      // Or if you want multiple dates:
      widget.eventDateTime: ['09:00', '10:00', '11:00', '14:00', '15:00'],
      widget.eventDateTime.add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
      widget.eventDateTime.add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
    },
  ),
    'Eric Kaiser': ProviderAvailability(
      providerId: 'eric_kaiser',
      availableTimeSlots: {
        DateTime.now(): ['10:00', '11:00', '12:00', '15:00', '16:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'Feredic Cassel': ProviderAvailability(
      providerId: 'feredic_cassel',
      availableTimeSlots: {
        DateTime.now(): ['09:30', '10:30', '11:30', '14:30', '15:30'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'Clown Anis': ProviderAvailability(
      providerId: 'clown_anis',
      availableTimeSlots: {
        DateTime.now(): ['09:00', '10:00', '11:00', '14:00', '15:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:00', '10:00', '14:00'],
        DateTime.now().add(const Duration(days: 2)): ['11:00', '13:00', '15:00'],
      },
    ),
    'Ammi Radhouene': ProviderAvailability(
      providerId: 'ammi_radhouene',
      availableTimeSlots: {
        DateTime.now(): ['10:00', '11:00', '12:00', '15:00', '16:00'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
    'LiveIt Up Entertainment': ProviderAvailability(
      providerId: 'liveit_up_entertainment',
      availableTimeSlots: {
        DateTime.now(): ['09:30', '10:30', '11:30', '14:30', '15:30'],
        DateTime.now().add(const Duration(days: 1)): ['09:30', '10:30', '14:30'],
        DateTime.now().add(const Duration(days: 2)): ['11:30', '13:30', '15:30'],
      },
    ),
  };

  */
  List<String> _getFilteredProviders() {
    return widget.serviceProviders[widget.service]!.where((provider) {
      final availability = _providersAvailability[provider];
      if (availability == null) return false;
      return availability.availableTimeSlots.containsKey(widget.eventDateTime);
    }).toList();
  }

  List<String> getAvailableTimeSlots() {
    if (selectedProvider == null) return [];
    final availability = _providersAvailability[selectedProvider];
    if (availability == null) return [];
    return availability.getTimeSlotsForDate(widget.eventDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final filteredProviders = _getFilteredProviders();

    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.service}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Book ${widget.service} for ${DateFormat('MMMM d, yyyy').format(widget.eventDateTime)}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: selectedProvider == null
                ? _buildProviderList(filteredProviders)
                : _buildTimeSlotsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderList(List<String> providers) {
    if (providers.isEmpty) {
      return Center(
        child: Text(
          'No providers available for the selected date.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(providers[index]),
          onTap: () {
            setState(() {
              selectedProvider = providers[index];
            });
          },
        );
      },
    );
  }

  Widget _buildTimeSlotsList() {
    final timeSlots = getAvailableTimeSlots();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Select a time slot for ${selectedProvider ?? ''}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: timeSlots.isEmpty
              ? Center(
                  child: Text(
                    'No available time slots for this provider.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: timeSlots.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(timeSlots[index]),
                      onTap: () {
                        setState(() {
                          selectedTimeSlot = timeSlots[index];
                        });
                      },
                      trailing: selectedTimeSlot == timeSlots[index]
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    );
                  },
                ),
        ),
        if (selectedTimeSlot != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  '$selectedProvider - ${DateFormat('yyyy-MM-dd').format(widget.eventDateTime)} $selectedTimeSlot',
                );
              },
              child: const Text('Confirm Booking'),
            ),
          ),
      ],
    );
  }
}