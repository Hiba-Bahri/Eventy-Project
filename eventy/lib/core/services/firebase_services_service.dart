import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/data/models/Service.dart' as ServiceModel;
import 'package:eventy/shared/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServicesService {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

    FirebaseServicesService({required this.firebaseAuth, required this.firestore});


  Future<List<ServiceModel.Service>> getAllServices() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('services').get();
      List<ServiceModel.Service> services = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        services.add(ServiceModel.Service.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>));
      }
      return services;
    } catch (e) {
      print('Failed to fetch service data: $e');
      showToast(message: 'Failed to fetch service data');
      return [];
    }
  }

  Future<List<ServiceModel.Service>> getMyServices() async {
    try {
      
      QuerySnapshot querySnapshot = await firestore
          .collection('services')
          .where('userId', isEqualTo: firebaseAuth.currentUser!.uid)
          .get();
          print("------------my services-------------$querySnapshot");

      List<ServiceModel.Service> myServices = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        myServices.add(ServiceModel.Service.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>));
      }
      return myServices;
    } catch (e) {
      print('Failed to fetch the current user\'s service data: $e');
      showToast(message: 'Failed to fetch the current user\'s service data');
      return [];
    }
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

      final User? currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      final serviceData = {
        'state': state,
        'category': category,
        'description': description,
        'fee': fee,
        'experience': experience,
        'is_fee_negotiable': isFeeNegotiable,
        'label': label,
        'userId': userId,
      };

      await firestore.collection('services').add(serviceData);
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  Future<bool> updateServiceData(
      String serviceId, Map<String, dynamic> data) async {
    try {
      await firestore.collection('services').doc(serviceId).update(data);
      return true;
    } catch (e) {
      showToast(message: 'Failed to update service data');
      return false;
    }
  }

Future<String> deleteService(String serviceId) async {
  try {
    await firestore.collection('services').doc(serviceId).delete();
    return 'Service deleted successfully';
  } catch (e) {
    showToast(message: 'Failed to delete service data');
    return 'Failed to delete service data';
  }
}


  //Get Service By ID :
  Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
   final DocumentSnapshot doc = await firestore.collection('services').doc(serviceId).get();
   if(!doc.exists) return null;
   return{
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    };
   }
  }
