import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String category;
  final String description;
  final int experience;
  final double fee;
  final bool isFeeNegotiable;
  final String label;
  final String userId;

  const Service({
    required this.id,
    required this.category,
    required this.description,
    required this.experience,
    required this.fee,
    required this.isFeeNegotiable,
    required this.label,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'experience': experience,
      'fee': fee,
      'isFeeNegotiable': isFeeNegotiable,
      'label': label,
      'userId': userId,
    };
  }

  static Service fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Service(
      id: snapshot.id,
      category: data['category'],
      description: data['description'] ?? '',
      experience: data['experience'] ?? 0,
      fee: data['fee'] ?? 0.0,
      isFeeNegotiable: data['is_fee_negotiable'] ?? false,
      label: data['label'] ?? '',
      userId: data['user_id'] ?? '',
    );
  }
}