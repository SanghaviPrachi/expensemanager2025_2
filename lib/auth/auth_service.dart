 import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register User with error handling
  Future<User?> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw "An unexpected error occurred. Please try again.";
    }
  }

  // Login User with error handling
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw "An unexpected error occurred. Please try again.";
    }
  }

  // Logout User
  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  // Handle Firebase Authentication Errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Invalid email format. Please enter a valid email.";
      case 'email-already-in-use':
        return "This email is already registered. Please log in.";
      case 'weak-password':
        return "Your password is too weak. Use at least 6 characters.";
      case 'user-not-found':
        return "No account found. Please check your email or sign up.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'too-many-requests':
        return "Too many failed attempts. Please try again later.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}