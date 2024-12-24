import 'package:eventy/core/services/chat_service.dart';
import 'package:eventy/core/services/firebase_auth_services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_service_test.mocks.dart';
import 'package:eventy/data/models/User.dart' as UserModel;

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference<Map<String, dynamic>>,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot,
  FieldValue,
  FirebaseAuthService,
], customMocks: [
  MockSpec<UserModel.User>(as: #MockUserModel)
])
void main() {
  late MockFirebaseAuthService mockFirebaseAuthService;
  late ChatService underTest;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockDocumentReference<Map<String, dynamic>> mockChatRoomRef;
  late MockDocumentReference<Map<String, dynamic>> mockMessageRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockChatRoomSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockMessageSnapshot;
  late MockUser mockUser;
  late MockUserModel mockSender;

  setUp(() {
    mockFirebaseAuthService = MockFirebaseAuthService();
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockChatRoomRef = MockDocumentReference<Map<String, dynamic>>();
    mockMessageRef = MockDocumentReference<Map<String, dynamic>>();
    mockChatRoomSnapshot = MockDocumentSnapshot();
    mockMessageSnapshot = MockDocumentSnapshot();
    mockUser = MockUser();
    mockSender = MockUserModel();

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('user1');
    when(mockFirebaseAuthService.getUserData('user1'))
        .thenAnswer((_) async => Future<UserModel.User?>.value(mockSender));

    underTest = ChatService(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
        authService: mockFirebaseAuthService);
  });

  test(
      'initiateChatRoomAndSendMessage creates chat room and sends message successfully',
      () async {
    const user1Id = 'user1';
    const user2Id = 'user2';
    const message = 'Hello There!';
    const chatRoomId = 'user1_user2';
    final timestamp = FieldValue.serverTimestamp();

    final mockChatRoomCollection =
        MockCollectionReference<Map<String, dynamic>>();

    final mockMessageCollection =
        MockCollectionReference<Map<String, dynamic>>();

    when(mockFirestore.collection('chatRooms'))
        .thenReturn(mockChatRoomCollection);

    when(mockChatRoomCollection.doc(chatRoomId)).thenReturn(mockChatRoomRef);

    when(mockChatRoomRef.collection('messages'))
        .thenReturn(mockMessageCollection);

    when(mockChatRoomRef.get()).thenAnswer((_) async => mockChatRoomSnapshot);

    // Mock the chat room does not exist initially
    when(mockChatRoomSnapshot.exists).thenReturn(false);

    final result = await underTest.initiateChatRoomAndSendMessage(
      user1Id: user1Id,
      user2Id: user2Id,
    );

    verify(mockMessageCollection.add(any));

    verify(mockChatRoomRef.set({
      'users': [user1Id, user2Id],
      'lastMessage': message,
      'timestamp': timestamp,
    })).called(1);
  });
}
