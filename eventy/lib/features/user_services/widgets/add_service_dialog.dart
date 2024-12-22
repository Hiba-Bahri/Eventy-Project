import 'package:eventy/core/providers/auth_provider.dart';
import 'package:eventy/core/providers/service_provider.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showAddServiceDialog(BuildContext context) async {
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController labelController = TextEditingController();
  bool isFeeNegotiable = false;
  String? selectedCategory;

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
  authProvider.getCurrentUser();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Service'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'Catering',
                      'Audio',
                      'Visual',
                      'Security',
                      'Photography',
                      'Cake',
                      'Decorations',
                      'Entertainment',
                      'Transportation',
                      'Stage Setup',
                      'Lighting',
                      'Food Stalls',
                      'First Aid',
                    ]
                        .map((category) => DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: experienceController,
                    decoration:
                        const InputDecoration(labelText: 'Experience (years)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Label'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feeController,
                    decoration: const InputDecoration(labelText: 'Fee'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Is Fee Negotiable?'),
                    value: isFeeNegotiable,
                    onChanged: (value) {
                      setState(() {
                        isFeeNegotiable = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedCategory == null ||
                  descriptionController.text.isEmpty ||
                  feeController.text.isEmpty ||
                  labelController.text.isEmpty) {
                showToast(message: 'Please fill all fields');
                return;
              }

              try {
                await serviceProvider.addService(
                  userId: authProvider.user!.uid,
                  category: selectedCategory!,
                  description: descriptionController.text,
                  fee: double.tryParse(feeController.text) ?? 0.0,
                  isFeeNegotiable: isFeeNegotiable,
                  label: labelController.text,
                  experience: int.tryParse(experienceController.text) ?? 0,
                );
                showToast(message: 'Service added successfully');
              } catch (e) {
                showToast(message: 'Failed to add service: $e');
              }

              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
