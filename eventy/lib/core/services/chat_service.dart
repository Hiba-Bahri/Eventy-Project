import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/firebase_auth_services.dart';
import 'package:eventy/data/models/User.dart' as UserModel;
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final FirebaseAuthService authService;

  ChatService({required this.firestore, required this.firebaseAuth, required this.authService});

  String? getCurrentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  Stream<QuerySnapshot> getChatRooms(String currentUserId) {
    return firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String senderId,
    required String receiverId,
  }) async {
    final timestamp = FieldValue.serverTimestamp();
    await firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'text': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'readBy': null,
    });

    await firestore.collection('chatRooms').doc(chatRoomId).set({
      'users': [senderId, receiverId],
      'lastMessage': message,
      'timestamp': timestamp,
    }, SetOptions(merge: true));
  }

  Stream<int> getUnreadMessageCount(String chatRoomId, String currentUserId) {
    return firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('readBy', isNull: true)
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.length);
  }

  Future<void> markMessagesAsRead(String chatRoomId, String currentUserId) async {
    final unreadMessages = await firestore
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
  }

  String generateChatRoomId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '${user1}_$user2'
        : '${user2}_$user1';
  }

  Future<List<String>?> initiateChatRoomAndSendMessage({
    required String user1Id,
    required String user2Id,
  }) async {
    const String message = "Hello There!";

    final chatRoomId = generateChatRoomId(user1Id, user2Id);
    final timestamp = FieldValue.serverTimestamp();

    final chatRoomRef = firestore.collection('chatRooms').doc(chatRoomId);

    try {
      final chatRoomSnapshot = await chatRoomRef.get();

      if (!chatRoomSnapshot.exists) {
        await chatRoomRef.set({
          'users': [user1Id, user2Id],
          'lastMessage': message,
          'timestamp': timestamp,
        });
      }

      await sendMessage(
        chatRoomId: chatRoomId,
        message: message,
        senderId: user1Id,
        receiverId: user2Id,
      );

      final UserModel.User? user = await authService.getUserData(user2Id);
      return [chatRoomId, user2Id, user!.username];
    } catch (e) {
      print("Error accessing or updating chat room: $e");
      return null;
    }
  }

  Stream<int> getTotalUnreadMessagesStream(String currentUserId) {
    return firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      int totalUnread = 0;
      for (var chatRoom in snapshot.docs) {
        final chatRoomId = chatRoom.id;
        final unreadMessagesSnapshot = await firestore
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

  Future<int> getTotalUnreadMessages(String currentUserId) async {
    int totalUnread = 0;
    final chatRoomsSnapshot = await firestore
        .collection('chatRooms')
        .where('users', arrayContains: currentUserId)
        .get();

    for (var chatRoom in chatRoomsSnapshot.docs) {
      final chatRoomId = chatRoom.id;
      final unreadMessagesSnapshot = await firestore
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