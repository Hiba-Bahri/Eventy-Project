import 'package:eventy/core/services/firebase_service_services.dart';
import 'package:eventy/data/models/Service.dart';
import 'package:eventy/shared/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  final servicesService = FirebaseServiceServices();
  bool loading = true;
  List<Service> services = [];
  List<Service> currentUserServices = [];
  List<Service> filteredServices = [];
  User? user;

  Future<void> getServices() async {
    try {
      services = await servicesService.getAllServices();
      filteredServices = services;
      loading = false;
      notifyListeners();
    } catch (e) {
      throw Exception("Fetch failed: $e");
    }
  }

  Future<void> getMyServices() async {
    try {
      currentUserServices = await servicesService.getMyServices();
      print("------------------------$currentUserServices");
      loading = false;
      notifyListeners();
    } catch (e) {
      throw Exception("Fetch failed: $e");
    }
  }

  void resetFilters() {
    filteredServices = services;
    notifyListeners();
  }

  void filterServices(String query) {
    if (query.isEmpty) {
      filteredServices = services;
    } else {
      filteredServices = services
          .where((service) =>
              service.label.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterServicesByFilters(
    String? label,
    String? state,
    String? category,
    bool? isFeeNegotiable,
    double? feeRange,
    int? experience,
  ) {
    print(
        "---------------------- $label, $state, $category, $isFeeNegotiable, $feeRange, $experience");

    filteredServices = services.where((service) {
      final matchesLabel = (label == null) || (service.label == label);
      final matchesState = (state == null) || (service.state == state);
      final matchesCategory =
          (category == null) || (service.category == category);
      final matchesNegotiable = (isFeeNegotiable == null) ||
          (service.isFeeNegotiable == isFeeNegotiable);
      final matchesFee = (feeRange == null) || (service.fee <= feeRange);
      final matchesExperience =
          (experience == 0) || (service.experience >= experience!);
      print("-------------------$matchesState");
      return matchesLabel &&
          matchesState &&
          matchesCategory &&
          matchesNegotiable &&
          matchesFee &&
          matchesExperience;
    }).toList();
    print(filteredServices);

    notifyListeners();
  }

  //Get Service By Id
  Future<Map<String, dynamic>?> getServiceDetails(String serviceId) async {
    final service = await servicesService.getServiceById(serviceId);
    return service;
  }

  Future<void> addService({
    required String userId,
    required String state,
    required String category,
    required String description,
    required double fee,
    required bool isFeeNegotiable,
    required String label,
    required int experience,
  }) async {
    try {
      await servicesService.addService(
        userId: userId,
        state: state,
        category: category,
        description: description,
        fee: fee,
        isFeeNegotiable: isFeeNegotiable,
        label: label,
        experience: experience,
      );
      getMyServices();
      notifyListeners();
      showToast(message: 'Service added successfully!');
    } catch (e) {
      showToast(message: 'Failed to add service: $e');
    }
  }


Future<void> deleteService(String id) async {
  try {
    final result = await servicesService.deleteService(id);

    if (result == 'Service deleted successfully') {
      await getMyServices();
    } else {
      throw Exception("Failed to delete service: $result");
    }
  } catch (e) {
    debugPrint("Error deleting service: $e");
    rethrow;
  }
}

}