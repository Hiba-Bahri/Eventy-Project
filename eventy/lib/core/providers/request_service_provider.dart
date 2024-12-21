import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/request_service_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestServiceProvider extends ChangeNotifier {
  final RequestServiceRepository _repository;
  
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];
  Map<String, dynamic>? _currentRequest;
  String? _selectedCategory;
  
  List<Map<String, dynamic>> _allRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  String _selectedStatus = 'All';

  List<Map<String, dynamic>> _notifications = [];

  RequestServiceProvider(this._repository);

  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get services => _services;
  List<Map<String, dynamic>> get filteredServices => _filteredServices;
  Map<String, dynamic>? get currentRequest => _currentRequest;
  String? get selectedCategory => _selectedCategory;
  List<Map<String, dynamic>> get filteredRequests => _filteredRequests;
  String get selectedStatus => _selectedStatus;

  void init(String userId) {
    _repository.getServicesStream().listen((services) {
      _services = services;
      filterServices(_selectedCategory);
      notifyListeners();
    });

    _repository.getUserRequestStream(userId).listen((request) {
      _currentRequest = request;
      notifyListeners();
    });
  }

  void initNotificationsListener(String userId) {
  FirebaseFirestore.instance
      .collection('notifications')
      .where('receiverId', isEqualTo: userId) // Receiver of the notification
      .where('read', isEqualTo: false) // Only unread notifications
      .orderBy('timestamp', descending: true) // Order by timestamp
      .snapshots()
      .listen((snapshot) {
    _notifications = snapshot.docs
        .map((doc) {
          var data = doc.data();
          return {
            'id': doc.id,
            'senderId': data['senderId'],
            'receiverId': data['receiverId'],
            'message': data['message'],
            'timestamp': data['timestamp'],
            'read': data['read'],
          };
        })
        .toList();
    print('Fetched notifications: $_notifications'); // Debugging line
    notifyListeners();
  });
}


  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var id in notificationIds) {
      final docRef = FirebaseFirestore.instance.collection('notifications').doc(id);
      batch.update(docRef, {'read': true});
    }
    await batch.commit();
    notifyListeners();
  }
  
  void initRequestsListener(String eventId, String userId) {
    _repository.getServiceRequestsStream(eventId, userId).listen((requests) {
      _allRequests = requests;
      filterRequests();
      notifyListeners();
    });
  }
  

  Future<void> sendNotification({
  required String receiverId,
  required String message,
  required String requestId,
}) async {
    try {
    // Get the current logged-in user's ID (sender)
    String senderId = FirebaseAuth.instance.currentUser!.uid;

    // Call the repository to save the notification
    await _repository.saveNotification(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      requestId: requestId, // Include the requestId in the notification
    );

    notifyListeners(); // Notify listeners after sending the notification
  } catch (e) {
    print('Error sending notification: $e');
  }
}

  void filterServices(String? category) {
    _selectedCategory = category;
    if (category == null || category == 'All') {
      _filteredServices = _services;
    } else {
      _filteredServices = _services
          .where((service) => service['category'] == category)
          .toList();
    }
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    filterRequests();
    notifyListeners();
  }

  void filterRequests() {
    if (_selectedStatus == 'All') {
      _filteredRequests = _allRequests;
    } else {
      _filteredRequests = _allRequests
          .where((request) => request['status'] == _selectedStatus)
          .toList();
    }
  }

  Future<String> sendRequest({
  required String eventId,
  required String userId,
  required Map<String, dynamic> service,
}) async {
  if (_currentRequest != null && _currentRequest!['category'] == service['category']) {
    throw Exception('Cannot request another service in the same category until the status is "Rejected".');
  }

  // Create the request and return the requestId
  return await _repository.sendRequest(
    eventId: eventId,
    userId: userId,
    serviceId: service['id'],
    serviceLabel: service['label'],
    category: service['category'],
  );
}

//Get Request Details
  Future<Map<String, dynamic>?> getRequestDetails(String requestId) async {
    return await _repository.getRequestById(requestId);
  }

  void clearCurrentRequest() {
    _currentRequest = null;
    notifyListeners();
  }

  //Accept Request or Reject Request
  Future<void> updateRequestStatus(String requestId, String status) async {
    if (status != 'Accepted' && status != 'Rejected') {
      throw Exception('Invalid status');
    }
    await _repository.respondToRequest(requestId, status);
    notifyListeners();
  }
}
