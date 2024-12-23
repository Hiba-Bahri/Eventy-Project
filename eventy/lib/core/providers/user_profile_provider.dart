import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfileProvider extends ChangeNotifier {
  bool isExpanded = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isEditing = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    usernameController.text = userData?['username'] ?? '';
    phoneController.text = userData?['phone'] ?? '';
    addressController.text = userData?['address'] ?? '';
  }

  Future<void> fetchUserData(String userId) async {
    if (userId.isEmpty) return;
    
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      userData = userDoc.data();
      _updateControllers();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw Exception("Failed to fetch user data: $e");
    }
  }

  Future<void> saveProfileChanges(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': usernameController.text,
        'phone': phoneController.text,
        'address': addressController.text,
      });

      await fetchUserData(userId);
      toggleEditing();
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  void toggleEditing() {
    isEditing = !isEditing;
    notifyListeners();
  }

  Future<void> toggleServiceProviderStatus(String userId, bool status) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'is_service_provider': status});
      
      await fetchUserData(userId);
    } catch (e) {
      throw Exception("Failed to update service provider status: $e");
    }
  }

  // Getters for user data
  String get username => userData?['username'] ?? 'N/A';
  String get phone => userData?['phone'] ?? 'N/A';
  String get email => userData?['email'] ?? 'N/A';
  String get address => userData?['address'] ?? 'N/A';
  bool get isServiceProvider => userData?['is_service_provider'] ?? false;
}