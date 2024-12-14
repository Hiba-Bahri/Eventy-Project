import 'package:eventy/core/services/firebase_service_services.dart';
//import 'package:eventy/data/models/service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  final servicesService = FirebaseServiceServices();
  bool loading = true;
  List services = [];
  User? user;

  Future<void> getServices() async {

    await Future.delayed(const Duration(seconds: 1));

    try {
      services = await servicesService.getAllServices();
      print("------------------------------");
      loading = false;
      notifyListeners();
    } catch (e) {
      throw Exception("Fetch failed: $e");
    }
  }

  /*Future<void> addService(Service service) async {
    final serviceJson = service.toJson();
    try {
      await servicesService.addService(serviceJson);
      await getServices(user);
    } catch (e) {
      print("Error adding service: $e");
      throw Exception("Add failed: $e");
    }
  }

  Future<void> deleteService(int id) async {
    try {
      final response = await serviceService.deleteService(id);
      if (response.statusCode == 200 || response.statusCode == 204) {
        await getServices(user);
      } else {
        throw Exception("Failed to delete service: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error deleting service: $e");
      rethrow;
    }
  }*/
}
