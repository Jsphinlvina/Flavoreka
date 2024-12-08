import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import '../screens/login_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Periksa apakah pengguna sudah login
    if (authService.currentUser == null) {
      // Jika belum login, arahkan ke LoginScreen
      return const LoginScreen();
    }

    // Jika sudah login, tampilkan halaman
    return child;
  }
}
