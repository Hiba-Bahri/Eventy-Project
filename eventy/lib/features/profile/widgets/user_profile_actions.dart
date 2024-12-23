import 'package:flutter/material.dart';

class UserProfileActions extends StatelessWidget {
  final bool isServiceProvider;
  final VoidCallback onAddService;
  final VoidCallback onToggleServiceProvider;

  const UserProfileActions({
    super.key,
    required this.isServiceProvider,
    required this.onAddService,
    required this.onToggleServiceProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onToggleServiceProvider,
          style: ElevatedButton.styleFrom(
            backgroundColor: isServiceProvider ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(isServiceProvider
              ? 'Cancel Becoming Service Provider'
              : 'Become Service Provider'),
        ),
      ],
    );
  }
}