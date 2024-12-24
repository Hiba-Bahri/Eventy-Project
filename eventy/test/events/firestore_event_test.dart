import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/core/services/firestore_events_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'firestore_event_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference,
  QuerySnapshot<Map<String, dynamic>>,
  QueryDocumentSnapshot<Map<String, dynamic>>,
  Query<Map<String, dynamic>>



])
void main() {
  late FirestoreEventService underTest;
  late MockFirebaseAuth mockAuth;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionRef;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;


  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockCollectionRef = MockCollectionReference<Map<String, dynamic>>();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();

    when(mockFirestore.collection('events')).thenReturn(mockCollectionRef);
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-user-id');

    underTest =
        FirestoreEventService(firebaseAuth: mockAuth, firestore: mockFirestore);
  });

test('Save event Success', () async {
  const mockEventType = "Birthday";
  final mockEventDateTime = DateTime.now();
  final mockServices = {'testService': 1};

  final eventData = {
    'userId': 'test-user-id',
    'eventType': mockEventType,
    'eventDateTime': Timestamp.fromDate(mockEventDateTime),
    'services': mockServices
  };

  when(mockCollectionRef.add(any)).thenAnswer((_) async => MockDocumentReference());

  await underTest.saveEvent(
      eventType: mockEventType,
      eventDateTime: mockEventDateTime,
      services: mockServices);

  verify(mockCollectionRef.add(eventData)).called(1);
});

test('Save event Throws No User Logged In', () async {
  const mockEventType = "Birthday";
  final mockEventDateTime = DateTime.now();
  final mockServices = {'testService': 1};

  when(mockAuth.currentUser).thenReturn(null);

  expect(
    () async => await underTest.saveEvent(
      eventType: mockEventType,
      eventDateTime: mockEventDateTime,
      services: mockServices,
    ),
    throwsA(isA<Exception>()),
  );

  verifyNever(mockCollectionRef.add(any));
});

test('Get User Events Success', () async {

  final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  final mockQuery = MockQuery<Map<String, dynamic>>();
  final mockDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

  final mockEventData = {
    'eventType': 'Birthday',
    'eventDateTime': Timestamp.now(),
    'services': {'service1': 1},
  };

  when(mockDocumentSnapshot.id).thenReturn('event-id');
  when(mockDocumentSnapshot.data()).thenReturn(mockEventData);

  when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
  when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

  when(mockCollectionRef.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
  when(mockQuery.orderBy('eventDateTime', descending: true)).thenReturn(mockQuery);

  final result = await underTest.getUserEvents();

  verify(mockCollectionRef.where('userId', isEqualTo: 'test-user-id')).called(1);
  verify(mockQuery.orderBy('eventDateTime', descending: true)).called(1);
  verify(mockQuery.get()).called(1);

  expect(result, [
    {'id': 'event-id', ...mockEventData},
  ]);
});

test('Get User Events Throws No User Logged In', () async {

  when(mockAuth.currentUser).thenReturn(null);

  expect(
    () async => await underTest.getUserEvents(),
    throwsA(isA<Exception>()),
  );

  verifyNever(mockCollectionRef.add(any));
});

}
