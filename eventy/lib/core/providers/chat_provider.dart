import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/chat_service.dart';
import 'package:eventy/core/services/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {

  final ChatService _chatService = ChatService(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      authService: FirebaseAuthService(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

  String? get currentUserId => _chatService.getCurrentUserId();

  Stream<QuerySnapshot> getChatRooms() {
    return _chatService.getChatRooms(currentUserId!);
  }

  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _chatService.getMessages(chatRoomId);
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String receiverId,
  }) async {
    await _chatService.sendMessage(
      chatRoomId: chatRoomId,
      message: message,
      senderId: currentUserId!,
      receiverId: receiverId,
    );
    notifyListeners();
  }

  Stream<int> getUnreadMessageCount(String chatRoomId) {
    return _chatService.getUnreadMessageCount(chatRoomId, currentUserId!);
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    await _chatService.markMessagesAsRead(chatRoomId, currentUserId!);
    notifyListeners();
  }

  Future<List<String>?> initiateChatRoomAndSendMessage({
    required String user1Id,
    required String user2Id,
  }) async {
    return await _chatService.initiateChatRoomAndSendMessage(
      user1Id: user1Id,
      user2Id: user2Id,
    );
  }

  Stream<int> getTotalUnreadMessagesStream() {
    return _chatService.getTotalUnreadMessagesStream(currentUserId!);
  }

  Future<int> getTotalUnreadMessages() async {
    return await _chatService.getTotalUnreadMessages(currentUserId!);
  }
}
