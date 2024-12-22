import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/features/home/widgets/service_card.dart';
import 'package:eventy/features/user_services/widgets/add_service_dialog.dart';
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
          child: Column(children: [
        ElevatedButton(
          onPressed: () => showAddServiceDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Service'),
        ),
        const SizedBox(height: 16),
        Consumer<ServiceProvider>(builder: (context, serviceProvider, _) {
          return ServiceCardGrid(services: serviceProvider.currentUserServices);
        })
      ])),
    );
  }
}
