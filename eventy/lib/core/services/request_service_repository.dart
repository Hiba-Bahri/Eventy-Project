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

  Future<String> sendRequest({
  required String eventId,
  required String userId,
  required String serviceId,
  required String serviceLabel,
  required String category,
}) async {
  final requestRef = await _firestore.collection('requests').add({
    'eventId': eventId,
    'userId': userId,
    'serviceId': serviceId,
    'serviceLabel': serviceLabel,
    'category': category,
    'status': 'Pending',
    'timestamp': FieldValue.serverTimestamp(),
  });
  return requestRef.id; // Return the generated request ID
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
            .map((doc) => doc.data())
            .toList());
  }
    /* Future<void> saveNotification({
    required String senderId,
    required String receiverId,
    required String message,
    required String requestId,
    
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'requestId': requestId, // Save the requestId
        'timestamp': FieldValue.serverTimestamp(),
        'read': false, // Initially set to unread
      });
    } catch (e) {
      throw Exception('Error saving notification: $e');
    }
  } */
  //GET Request By ID
  Future<Map<String, dynamic>?> getRequestById(String requestId) async {
    final DocumentSnapshot doc = await _firestore.collection('requests').doc(requestId).get();
    if (!doc.exists) return null;
    return {
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    };
  }
  //Respond to Request
  Future<void> respondToRequest(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({
      'status': status,
    });
  }

  Future<String?> getUserIdForService(String serviceId) async {
  var docSnapshot = await _firestore.collection('services').doc(serviceId).get();
  if (docSnapshot.exists) {
    return docSnapshot.data()?['userId']; // Assuming userId is stored in the service document
  }
  return null;
}
  //Get User Requests
  Stream<List<Map<String, dynamic>>> getUserRequestsStream(String serviceId) {
  return getUserIdForService(serviceId).asStream().asyncExpand((userId) {
    if (userId == null) {
      return Stream.value([]); // Return empty list if userId is null
    }

    return _firestore
        .collection('requests')
        .where('serviceId', isEqualTo: serviceId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data())
            .toList());
  });
}
Stream<List<Map<String, dynamic>>> getRequestsForServiceOwner(String ownerId) {
    return _firestore
        .collection('services')
        .where('userId', isEqualTo: ownerId)
        .snapshots()
        .asyncMap((serviceSnapshot) async {
          // Get all services owned by this user
          final serviceIds = serviceSnapshot.docs.map((doc) => doc.id).toList();
          
          if (serviceIds.isEmpty) return [];

          // Get all requests for these services
          final requestsSnapshot = await _firestore
              .collection('requests')
              .where('serviceId', whereIn: serviceIds)
              .get();

          return requestsSnapshot.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList();
        });
  }
}