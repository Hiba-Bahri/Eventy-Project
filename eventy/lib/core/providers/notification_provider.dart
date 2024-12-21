import 'package:eventy/core/services/notifications_service.dart';
import 'dart:async'; // For StreamSubscription
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationsService _notificationsService = NotificationsService();
  List<Map<String, dynamic>> notifications = [];
  StreamSubscription<List<Map<String, dynamic>>>? _notificationsSubscription;
  String? _currentUserId;

  /// Listen to notifications for the specified user ID.
  int get unreadNotificationsCount {
    return notifications.where((notification) => 
      !(notification['read'] ?? false)
    ).length;
  }
  
  void listenToNotifications(String userId) {
    // Cancel existing subscription if any
    _notificationsSubscription?.cancel();
    _currentUserId = userId;

    try {
      _notificationsSubscription =
          _notificationsService.notificationsStream(userId).listen(
        (newNotifications) {
          if (_currentUserId == userId) { // Only update if still listening for same user
            notifications = newNotifications;
            notifyListeners();
          }
        },
        onError: (error) {
          print('Notification stream error: $error');
          notifications = [];
          notifyListeners();
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('Error setting up notification listener: $e');
      notifications = [];
      notifyListeners();
    }
  }

  Future<void> clearListeners() async {
    try {
      await _notificationsSubscription?.cancel();
      _notificationsSubscription = null;
      _currentUserId = null;
      notifications = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing notification listeners: $e');
    }
  }

  @override
  void dispose() {
    clearListeners();
    super.dispose();
  }
}


/* import 'package:eventy/core/services/notifications_service.dart';
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationsService _notificationsService = NotificationsService();

  List<Map<String, dynamic>> notifications = [];

  void listenToNotifications(String userId) {
    _notificationsService.notificationsStream(userId).listen((newNotifications) {
      notifications = newNotifications;
      notifyListeners();
    });
  }

  int get unreadNotificationsCount =>
      notifications.where((notif) => !(notif['isRead'] ?? false)).length;

  Future<void> markAsRead(String notificationId) async {
    await _notificationsService.markNotificationAsRead(notificationId);
  }
  
}
 */