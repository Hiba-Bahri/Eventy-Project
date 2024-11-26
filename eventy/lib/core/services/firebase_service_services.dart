import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/data/models/Service.dart' as ServiceModel;
import 'package:eventy/shared/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServiceServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ServiceModel.Service>> getAllServices() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('services').get();
      List<ServiceModel.Service> services = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        services.add(ServiceModel.Service.fromSnapshot(
            doc as DocumentSnapshot<Map<String, dynamic>>));
      }
      print("----------------------------------------");
      return services;
    } catch (e) {
      showToast(message: 'Failed to fetch service data');
      return [];
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
}