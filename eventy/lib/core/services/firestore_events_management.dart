import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreEventService {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FirestoreEventService({required this.firebaseAuth, required this.firestore});

  Future<void> saveEvent({
    required String eventType,
    required DateTime eventDateTime,
    required Map<String, dynamic> services,
  }) async {
    try {
      // Get the current logged-in user
      final User? currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Prepare the event data
      final eventData = {
        'userId': currentUser.uid, // Explicitly store the user ID
        'eventType': eventType,
        'eventDateTime':
            Timestamp.fromDate(eventDateTime), // Convert DateTime to Timestamp
        'services': services
      };
      // Save to Firestore
      await firestore.collection('events').add(eventData);
    } catch (e) {
      print('Detailed error saving event: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserEvents() async {
    try {
      final User? currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final querySnapshot = await firestore
          .collection('events')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('eventDateTime', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      print('Error retrieving events: $e');
      rethrow;
    }
  }
}
