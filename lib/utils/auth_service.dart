import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan pengguna yang sedang login
  User? get currentUser => _auth.currentUser;

  // Login dengan email dan password
  Future<User?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Mendengar perubahan status login
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
