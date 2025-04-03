import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to check authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register User
  Future<User?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw "An unexpected error occurred. Please try again.";
    }
  }

  // Login User
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);
        DocumentSnapshot userDoc = await userDocRef.get();

        if (!userDoc.exists || userDoc.data() == null) {
          // Create a new record if user data doesn't exist
          await userDocRef.set({
            'name': 'N/A',
            'email': user.email ?? 'N/A',
            'phone': 'N/A',
            'created_at': FieldValue.serverTimestamp(),
          });
        } else {
          // Cast userDoc.data() to a Map
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          Map<String, dynamic> updates = {};

          if (!userData.containsKey('email')) updates['email'] = user.email ?? 'N/A';
          if (!userData.containsKey('name')) updates['name'] = 'N/A';
          if (!userData.containsKey('phone')) updates['phone'] = 'N/A';

          if (updates.isNotEmpty) {
            await userDocRef.update(updates);
          }
        }
      }

      return user;
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

  // Handle authentication errors
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
