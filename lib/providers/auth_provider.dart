import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _currentUser;
  User? get currentUser => _currentUser;

  MyAuthProvider() {
    _auth.authStateChanges().listen((user) {
      _currentUser = user;
      notifyListeners(); 
    });
  }

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow; 
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
