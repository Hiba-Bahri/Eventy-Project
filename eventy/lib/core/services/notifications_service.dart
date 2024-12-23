import 'package:cloud_firestore/cloud_firestore.dart';



class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time notifications stream
  Stream<List<Map<String, dynamic>>> notificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .orderBy('timestamp', descending: true) // Order by timestamp instead of name
        .snapshots()
        .handleError((error) {
          print('Notifications stream error: $error');
          return Stream.value([]); // Return empty list on error
        })
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Fetch sender name for a notification
  Future<String> getSenderName(String senderId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(senderId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['username'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print('Failed to fetch sender name: $e');
      return 'Unknown';
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true}); // Ensure consistency in the field name
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}


/* import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time notifications stream
  Stream<List<Map<String, dynamic>>> notificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<String> getSenderName(String senderId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(senderId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['username'] ?? 'Unknown';
      }
      return 'Unknown';
    } catch (e) {
      print('Failed to fetch sender name: $e');
      return 'Unknown';
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
}
 */