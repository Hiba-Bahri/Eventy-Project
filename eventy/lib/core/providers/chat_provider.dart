import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eventy/data/models/User.dart' as UserModel;

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? currentUserId;

  // Fetch chat rooms where the user is a participant.
  Stream<QuerySnapshot> getChatRooms() {
    currentUserId = _auth.currentUser!.uid;
    print("---------------current user ---------------------- $currentUserId");
    return _firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Fetch messages for a specific chat room.
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a message to a specific chat room.
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
      'readBy': null,
    });

    // Update chat room metadata
    await _firestore.collection('chatRooms').doc(chatRoomId).set({
      'users': [currentUserId, receiverId],
      'lastMessage': message,
      'timestamp': timestamp,
    }, SetOptions(merge: true));
  }

  Stream<int> getUnreadMessageCount(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('readBy', isNull: true)
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }

Future<void> markMessagesAsRead(String chatRoomId) async {
  final unreadMessages = await _firestore
      .collection('chatRooms')
      .doc(chatRoomId)
      .collection('messages')
      .where('readBy', isNull: true)
      .where('receiverId', isEqualTo: currentUserId)
      .get();

  for (var message in unreadMessages.docs) {
    final readBy = message['readBy'];

    if (readBy == null || !(readBy as List).contains(currentUserId)) {
      await message.reference.update({
        'readBy': FieldValue.arrayUnion([currentUserId]),
      });
    }
  }

  notifyListeners();
}


  // Generate a chat room ID based on user IDs.
  String generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  Future<List<String>?> initiateChatRoomAndSendMessage({
    required String user1Id, // the authenticated user id
    required String user2Id, // the other person in the chat
  }) async {
    const String message = "Hello There!";

    final chatRoomId = generateChatRoomId(user1Id, user2Id);
    final timestamp = FieldValue.serverTimestamp();

    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);

    try {
      // Check if the chat room already exists
      final chatRoomSnapshot = await chatRoomRef.get();
      print("-------------------------------$chatRoomRef");

      // else :
      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'users': [user1Id, user2Id],
          'lastMessage': message,
          'timestamp': timestamp,
        });
        print("Chat room created with ID: $chatRoomId");
      } else {
        print("Chat room already exists with ID: $chatRoomId");
      }

      await sendMessage(
          chatRoomId: chatRoomId, message: message, receiverId: user2Id);

      UserModel.User? user = await _authService.getUserData(user2Id);

      return [chatRoomId, user2Id, user!.username];
    } catch (e) {
      print("Error accessing or updating chat room: $e");
      return null;
    }
  }

  Stream<int> getTotalUnreadMessagesStream() {
    return _firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      int totalUnread = 0;
      for (var chatRoom in snapshot.docs) {
        final chatRoomId = chatRoom.id;
        final unreadMessagesSnapshot = await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .where('readBy', isNull: true)
            .where('receiverId', isEqualTo: currentUserId)
            .get();

        totalUnread += unreadMessagesSnapshot.docs.length;
      }
      return totalUnread;
    });
  }

  Future<int> getTotalUnreadMessages() async {
  int totalUnread = 0;
  final chatRoomsSnapshot = await _firestore
      .collection('chatRooms')
      .where('users', arrayContains: currentUserId)
      .get();

  for (var chatRoom in chatRoomsSnapshot.docs) {
    final chatRoomId = chatRoom.id;
    final unreadMessagesSnapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('readBy', isNull: true)
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    totalUnread += unreadMessagesSnapshot.docs.length;
  }

  return totalUnread;
}


}
