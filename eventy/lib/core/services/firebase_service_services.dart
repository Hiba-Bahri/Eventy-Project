import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/data/models/Service.dart' as ServiceModel;
import 'package:eventy/shared/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServiceServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<ServiceModel.Service>> getAllServices() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('services').get();
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
      QuerySnapshot querySnapshot = await _firestore
          .collection('services')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();
      List<ServiceModel.Service> myServices = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        myServices.add(ServiceModel.Service.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>));
      }
      print("-------------------------$myServices");
      return myServices;
    } catch (e) {
      print('Failed to fetch the current user\'s service data: $e');
      showToast(message: 'Failed to fetch the current user\'s service data');
      return [];
    }
  }

  Future<void> addService({
    required String userId,
    required String category,
    required String description,
    required double fee,
    required bool isFeeNegotiable,
    required String label,
    required int experience,
  }) async {
    try {
      final serviceData = {
        'category': category,
        'description': description,
        'fee': fee,
        'experience': experience,
        'is_fee_negotiable': isFeeNegotiable,
        'label': label,
        'userId': userId,
      };

      await FirebaseFirestore.instance.collection('services').add(serviceData);
    } catch (e) {
      throw Exception('Failed to add service: $e');
    }
  }

  Future<bool> updateServiceData(
      String serviceId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('services').doc(serviceId).update(data);
      return true;
    } catch (e) {
      showToast(message: 'Failed to update service data');
      return false;
    }
  }
  //Get Service By ID :
  Future<Map<String, dynamic>?> getServiceById(String serviceId) async {
   final DocumentSnapshot doc = await _firestore.collection('services').doc(serviceId).get();
   if(!doc.exists) return null;
   return{
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    };
   }
  }
