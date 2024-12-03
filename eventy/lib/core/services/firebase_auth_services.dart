import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventy/data/models/User.dart' as UserModel;
import 'package:eventy/shared/widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      showToast(message: message);
      return null;
    } catch (e) {
      showToast(message: 'An unexpected error occurred');
      return null;
    }
  }

  Future<User?> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String username
  ) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        showToast(message: 'Please fill in all fields');
        return null;
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password,
      );
      
      if (credential.user != null) {
        
        await _createUserDocument(
          credential.user!.uid,
          email.trim(),
          username.trim(),
        );
        
        return credential.user;
      } else {
        return null;
      }

    } on FirebaseAuthException catch (e) {
      String message = _getAuthErrorMessage(e.code);
      showToast(message: message);
      return null;
      
    } catch (e) {
      showToast(message: 'An unexpected error occurred');
      return null;
    }
  }

  Future<void> _createUserDocument(
    String uid, 
    String email, 
    String username,
  ) async {
    try {
      final UserModel.User newUser = UserModel.User(
        id: uid,
        email: email,
        username: username,
        is_service_provider: 'false',
      );

      final userData = newUser.toJson();

      await _firestore
          .collection('users')
          .doc(uid)
          .set(userData);
          
    } catch (e) {
      showToast(message: 'Failed to create user profile');
      try {
        await _auth.currentUser?.delete();
      } catch (deleteError) {}
      rethrow;
    }
  }

  Future<UserModel.User?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = 
          await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        return UserModel.User.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      showToast(message: 'Failed to fetch user data');
      return null;
    }
  }

  Future<bool> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update(data);
      return true;
    } catch (e) {
      showToast(message: 'Failed to update user data');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      showToast(message: 'Failed to sign out');
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email address is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Please enter a stronger password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'An error occurred: $code';
    }
  }
}