import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan instance AuthProvider
    final authProvider = Provider.of<MyAuthProvider>(context);
    final User? user = authProvider.currentUser;

    // Jika pengguna belum login, arahkan ke HomeScreen
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
      return const SizedBox(); // Return widget kosong sementara navigasi berlangsung
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Menampilkan email pengguna
            Text(
              'Email: ${user.email ?? 'Tidak ada email'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Menampilkan User ID
            Text(
              'User ID: ${user.uid}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            // Tombol Logout
            ElevatedButton(
              onPressed: () async {
                await authProvider.logout();
                // Arahkan ke HomeScreen setelah logout
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
