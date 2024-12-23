 import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
class EventService {
  Future<List<Map<String, dynamic>>> fetchServiceRequests(String eventId, String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('requests')
          .where('eventId', isEqualTo: eventId)
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching service requests: $e');
      return [];
    }
  }
}