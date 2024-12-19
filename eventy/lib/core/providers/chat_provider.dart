import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currentUserId;

  /// Fetch chat rooms where the user is a participant.
  Stream<QuerySnapshot> getChatRooms() {
    currentUserId = _auth.currentUser!.uid;
    print("------------------------------------- $currentUserId");
    return _firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Fetch messages for a specific chat room.
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Send a message to a specific chat room.
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String receiverId,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': message,
      'senderId': currentUserId,
      'receiverId': receiverId,
      'timestamp': timestamp,
    });

    // Update chat room metadata
    await _firestore.collection('chatRooms').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': message,
      'timestamp': timestamp,
    }, SetOptions(merge: true));
  }

  /// Generate a chat room ID based on user IDs.
  String generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }
}
