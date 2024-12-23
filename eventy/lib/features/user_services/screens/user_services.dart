import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/features/user_services/widgets/add_service_dialog.dart';
import 'package:eventy/features/user_services/widgets/service_cards.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserServices extends StatefulWidget {
  const UserServices({super.key});

  @override
  _UserServicesState createState() => _UserServicesState();
}

class _UserServicesState extends State<UserServices> {
  @override
  void initState() {
    super.initState();
    Provider.of<ServiceProvider>(context, listen: false).getMyServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),

            Expanded(
              child: Consumer<ServiceProvider>(
                builder: (context, serviceProvider, _) {
                  return ServiceCardsGrid(services: serviceProvider.currentUserServices);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
          onPressed: () => showAddServiceDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add a Service'),
        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
