import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String label;
  final String category;
  final String state;
  final String description;
  final int experience;
  final double fee;
  final bool isFeeNegotiable;
  final String userId;

  Service({
    required this.id,
    required this.label,
    required this.category,
    required this.state,
    required this.description,
    required this.experience,
    required this.fee,
    required this.isFeeNegotiable,
    required this.userId,
  });

  factory Service.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Service(
      id: snapshot.id,
      label: data['label'] ?? '',
      category: data['category'] ?? '',
      state: data['state'] ?? '',
      description: data['description'] ?? '',
      experience: data['experience'] ?? 0,
      fee: (data['fee'] ?? 0.0).toDouble(),
      isFeeNegotiable: data['is_fee_negotiable'] ?? false,
      userId: data['userId'] ?? '',
    );
  }
}
