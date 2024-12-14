import 'package:eventy/core/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget serviceCard(ServiceProvider serviceProvider) {
  return Consumer<ServiceProvider>(builder: (context, serviceProvider, _) {
    return Expanded(
      child: serviceProvider.loading
          ? const CircularProgressIndicator()
          : serviceProvider.services.isEmpty
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cases_rounded, size: 100, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      "No services yet!",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 3 / 4,
                  ),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: serviceProvider.services.length,
                  itemBuilder: (context, index) {
                    final service = serviceProvider.services[index];

                    return /*GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              //FlashcardsHome(service: service),
                        ),
                      ),
                      child:*/ Card(
                        elevation: 6.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        color: Colors.grey,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                service.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                service.category,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      //),
                    );
                  },
                ),
    );
  });
}
