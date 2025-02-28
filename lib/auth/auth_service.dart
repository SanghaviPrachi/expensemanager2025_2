import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Register user
  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    }
  }

  // Login user
  Future<String?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    }
  }

  // Logout user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase errors
  String _handleAuthError(FirebaseAuthException e) {
    if (kDebugMode) {
      print("Firebase Auth Error: ${e.code}");
    }

    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already in use. Try logging in.";
      case 'invalid-email':
        return "The email format is invalid.";
      case 'weak-password':
        return "The password is too weak. Try a stronger one.";
      case 'user-not-found':
        return "No account found for this email.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'network-request-failed':
        return "Check your internet connection and try again.";
      default:
        return "An unexpected error occurred. Please try again.";
    }
  }
}
