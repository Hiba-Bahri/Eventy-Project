import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final String? cin;
  final String? phone;
  final String? address;
  final bool? is_service_provider;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.cin,
    this.phone,
    this.address,
    this.is_service_provider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'cin': cin,
      'phone': phone,
      'address': address,
      'is_service_provider': is_service_provider,
    };
  }

  static User fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      id: snapshot.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      cin: data['cin'],
      phone: data['phone'],
      address: data['address'],
      is_service_provider: data['is_service_provider'],
    );
  }
}