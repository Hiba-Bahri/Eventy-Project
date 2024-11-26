import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String label;
  final String description;
  final String fee;
  final bool isFeeNegotiable;
  final String? category;

  const Service({
    required this.id,
    required this.label,
    required this.description,
    required this.fee,
    required this.isFeeNegotiable,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'fee': fee,
      'isFeeNegotiable': isFeeNegotiable,
      'category': category,
    };
  }

  static Service fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Service(
      id: snapshot.id,
      label: data['label'] ?? '',
      description: data['description'] ?? '',
      fee: data['fee'] ?? '',
      isFeeNegotiable: data['is_fee_negotiable'] ?? false,
      category: data['category'],
    );
  }
}