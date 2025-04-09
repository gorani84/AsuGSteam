import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '1051673137607-rvqvlvvjjqgkqvqtqvqtqvqtqvqtqvqt.apps.googleusercontent.com'
        : null,
  );

  User? get getUser => _auth.currentUser;
  Stream<User?> get user => _auth.userChanges();

  FirebaseAuth getAuth() {
    return _auth;
  }

  Future<String?> getUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.displayName;
    }
    return null;
  }

  Future<User?> googleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      print('Logged in User: ${result.user}');
      return result.user;
    } catch (err) {
      print('Google Sign In Error: $err');
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password, Function(String?) errorCallBack) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      print('Error signing in: ${e.code}');

      if (e.code == "invalid-credential") {
        errorCallBack("Invalid Credentials");
      } else {
        errorCallBack('Login failed. Please try again.');
      }
      return null;
    }
  }

  Future<void> resetPassword(String email, Function(String) onError) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      onError(e.toString()); // Pass the error message to the UI
    }
  }

  // Register a new user with email and password
  Future<User?> registerWithEmailAndPassword(
      String email, String password, Function(String?) errorCallBack) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      if (e.code == "email-already-in-use") {
        errorCallBack("email already register");
      } else {
        errorCallBack('Signup failed. Please try again.');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (err) {
      print('Sign Out Error: $err');
    }
  }
}
