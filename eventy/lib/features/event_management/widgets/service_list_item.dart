import 'package:flutter/material.dart';

class ServiceListItem extends StatelessWidget {
  final String serviceName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ServiceListItem({
    super.key,
    required this.serviceName,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: serviceName,
                  suffixIcon: const Icon(Icons.arrow_forward),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
