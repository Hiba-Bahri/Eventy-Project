import 'package:flutter/material.dart';
import 'package:eventy/core/services/request_service_repository.dart';

class RequestServiceProvider extends ChangeNotifier {
  final RequestServiceRepository _repository;
  
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _filteredServices = [];
  Map<String, dynamic>? _currentRequest;
  String? _selectedCategory;
  
  List<Map<String, dynamic>> _allRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  String _selectedStatus = 'All';

  RequestServiceProvider(this._repository);

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

  void initRequestsListener(String eventId, String userId) {
    _repository.getServiceRequestsStream(eventId, userId).listen((requests) {
      _allRequests = requests;
      filterRequests();
      notifyListeners();
    });
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

  Future<void> sendRequest({
    required String eventId,
    required String userId,
    required Map<String, dynamic> service,
  }) async {
    if (_currentRequest != null && _currentRequest!['category'] == service['category']) {
      throw Exception('Cannot request another service in the same category until the status is "Rejected".');
    }

    await _repository.sendRequest(
      eventId: eventId,
      userId: userId,
      serviceId: service['id'],
      serviceLabel: service['label'],
      category: service['category'],
    );
  }
}