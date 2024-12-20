import 'package:cloud_firestore/cloud_firestore.dart';

class RequestServiceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getServicesStream() {
    return _firestore.collection('services').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  Stream<Map<String, dynamic>?> getUserRequestStream(String userId) {
    return _firestore
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return {
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      };
    });
  }

  Future<List<Map<String, dynamic>>> fetchServiceRequests(String eventId, String userId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('requests')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  Future<void> sendRequest({
    required String eventId,
    required String userId,
    required String serviceId,
    required String serviceLabel,
    required String category,
  }) async {
    await _firestore.collection('requests').add({
      'eventId': eventId,
      'userId': userId,
      'serviceId': serviceId,
      'serviceLabel': serviceLabel,
      'category': category,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getServiceRequestsStream(String eventId, String userId) {
    // Implement the logic to fetch and stream service requests
    // This is just an example - adjust according to your data source (Firestore, REST API, etc.)
    return _firestore
        .collection('requests')
        .where('eventId', isEqualTo: eventId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }
}