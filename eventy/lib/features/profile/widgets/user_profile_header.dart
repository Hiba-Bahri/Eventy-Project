import 'package:flutter/material.dart';

class UserProfileHeader extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final String address;

  const UserProfileHeader({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username: $name',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text('Phone: $phone'),
        const SizedBox(height: 8),
        Text('Email: $email'),
        const SizedBox(height: 8),
        Text('Address: $address'),
      ],
    );
  }
}