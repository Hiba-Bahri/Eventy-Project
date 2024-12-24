import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/firebase_services_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import '../events/firestore_event_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference<Map<String, dynamic>>,
])
void main() {
  late FirebaseServicesService underTest;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();

    when(mockFirestore.collection('services')).thenReturn(mockCollectionRef);
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');

    underTest = FirebaseServicesService(
        firebaseAuth: mockAuth, firestore: mockFirestore);
  });

  test('Add service Success', () async {
    const mockServiceState = "Ben Arous";
    const mockServiceCategory = "Catering";
    const mockServiceDescription = "Cupcakes made with love";
    const mockServiceFee = 150.0;
    const mockExperience = 2;
    const mockNegotiability = false;
    const mockServiceLabel = "She's Cake";

    final serviceData = {
      'state': mockServiceState,
      'category': mockServiceCategory,
      'description': mockServiceDescription,
      'fee': mockServiceFee,
      'experience': mockExperience,
      'is_fee_negotiable': mockNegotiability,
      'label': mockServiceLabel,
      'userId': 'test-user-id',
    };

    when(mockCollectionRef.add(any))
        .thenAnswer((_) async => MockDocumentReference());

    await underTest.addService(
        state: mockServiceState,
        category: mockServiceCategory,
        description: mockServiceDescription,
        fee: mockServiceFee,
        experience: mockExperience,
        isFeeNegotiable: mockNegotiability,
        label: mockServiceLabel,
        userId: 'test-user-id');

    verify(mockCollectionRef.add(serviceData)).called(1);
  });

  test('Add service Throws No User Logged In', () async {
    const mockServiceState = "Ben Arous";
    const mockServiceCategory = "Catering";
    const mockServiceDescription = "Cupcakes made with love";
    const mockServiceFee = 150.0;
    const mockExperience = 2;
    const mockNegotiability = false;
    const mockServiceLabel = "She's Cake";

    when(mockAuth.currentUser).thenReturn(null);

    expect(
      () async => await underTest.addService(
          state: mockServiceState,
          category: mockServiceCategory,
          description: mockServiceDescription,
          fee: mockServiceFee,
          experience: mockExperience,
          isFeeNegotiable: mockNegotiability,
          label: mockServiceLabel,
          userId: 'test-user-id'),
      throwsA(isA<Exception>()),
    );

    verifyNever(mockCollectionRef.add(any));
  });

  // if possible get services
}
