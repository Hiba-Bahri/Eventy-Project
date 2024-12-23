import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAlert extends StatelessWidget {
  final String id;

  const DeleteAlert(this.id, {Key? key}) : super(key: key);

  Widget _button(
      BuildContext context, ServiceProvider subjectProvider) {
    return ElevatedButton(
      onPressed: () {
          subjectProvider.deleteService(id).then((_) {
            Navigator.of(context).pop();
            showToast(message: "Service Deleted!");
          }).catchError((error) {
            Navigator.of(context).pop();
            showToast(message: "Error: $error");
          });

      },

      style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  
        minimumSize: const Size(100, 50),
      ),
      child: const Text("Confirm"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, subjectProvider, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Are you sure you want to delete this service?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _button(context, subjectProvider),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
