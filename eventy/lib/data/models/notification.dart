class Notification {
  final String message;
  final bool read;
  final String receiverId;
  final String senderId;
  final String requestId;
  final DateTime timestamp;

  Notification({
    required this.message,
    required this.read,
    required this.receiverId,
    required this.senderId,
    required this.requestId,
    required this.timestamp,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      message: map['message'] ?? '',
      read: map['read'] ?? false,
      receiverId: map['receiverId'] ?? '',
      senderId: map['senderId'] ?? '',
      requestId: map['requestId'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
    );
  }
}