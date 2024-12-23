import 'package:eventy/features/user_services/screens/service_details.dart';
import 'package:eventy/features/user_services/widgets/delete_pop_up.dart';
import 'package:flutter/material.dart';
import '../../../data/models/Service.dart';

class ServiceCardsGrid extends StatelessWidget {
  final List<Service> services;

  const ServiceCardsGrid({super.key, required this.services});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          childAspectRatio: 3 / 2,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];


          return GestureDetector(
                  onLongPress: () {
                    print("----------------------------------------");
                    showDeleteDialog(context: context, id: service.id);
                  },
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetails(serviceId: service.id),
                        ),
                      );                  },
                  child: Card(
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
                  ));
        },
      ),
    );
  }
}
