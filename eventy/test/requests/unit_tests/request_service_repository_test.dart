import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/request_service_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'request_service_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>
])
void main() {
  late RequestServiceRepository underTest;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentRef;
  late MockFirebaseFirestore mockFirestore;

  setUp(() {
    mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentRef = MockDocumentReference<Map<String, dynamic>>();
    mockFirestore = MockFirebaseFirestore();

    when(mockFirestore.collection('requests')).thenReturn(mockCollectionRef);

    underTest = RequestServiceRepository(firestore: mockFirestore);
  });

  test("Accept a request Success", () async {
    const mockStatus = "Accepted";
    const mockRequestId = "request1";

    when(mockCollectionRef.doc(mockRequestId)).thenReturn(mockDocumentRef);
    await underTest.respondToRequest(mockRequestId, mockStatus);

    verify(mockDocumentRef.update({
      'status': mockStatus,
    })).called(1);
  });

  test("Decline a request Success", () async {
    const mockStatus = "Declined";
    const mockRequestId = "request1";

    when(mockCollectionRef.doc(mockRequestId)).thenReturn(mockDocumentRef);
    await underTest.respondToRequest(mockRequestId, mockStatus);

    verify(mockDocumentRef.update({
      'status': mockStatus,
    })).called(1);
  });
}
