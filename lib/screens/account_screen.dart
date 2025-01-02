import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/auth_service.dart';
import '../widgets/navbar.dart';
import 'edit_account_screen.dart';
import 'reset_password_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final userId = Provider.of<AuthService>(context, listen: false).currentUser?.uid;
    if (userId != null) {
      Provider.of<UserDataProvider>(context, listen: false).fetchUserData(userId);
    }
  });
}

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final username = userProvider.currentUserData?.username ?? "";

    String inputUsername = "";

    final messenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Are you sure you want to delete your account? This action is irreversible.",
              ),
              const SizedBox(height: 10),
              const Text(
                "To confirm, please type your username below:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  inputUsername = value;
                },
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (inputUsername == username) {
                  try {
                    await userProvider.deleteCurrentUser();
                    await authService.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text("Failed to delete account: $e")),
                    );
                  }
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      content:
                          Text("Username doesn't match. Deletion cancelled."),
                    ),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    final userData = userProvider.currentUserData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: FutureBuilder<File?>(
                          future: userProvider.loadProfilePicture(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError ||
                                snapshot.data == null) {
                              return CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.account_circle,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              );
                            } else {
                              return CircleAvatar(
                                radius: 60,
                                backgroundImage: FileImage(snapshot.data!),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("Name: ${userData.name}",
                          style: const TextStyle(fontSize: 18)),
                      Text("Username: ${userData.username}",
                          style: const TextStyle(fontSize: 18)),
                      Text("Email: ${userData.email}",
                          style: const TextStyle(fontSize: 18)),
                      Text("Recipes Created: ${userData.createRecipes}",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          "Favorite Recipes: ${userData.favoriteRecipes.length} recipes",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          "Created At: ${userData.createdAt.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50, // Atur tinggi tombol
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const EditUserScreen()),
                                  );
                                },
                                child: const Text("Edit Profile"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ResetPasswordScreen()),
                                  );
                                },
                                child: const Text('Reset Password'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () => _deleteAccount(context),
                            child: const Text(
                              "Delete Account",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: Navbar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/my-recipes');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/account');
              break;
          }
        },
      ),
    );
  }
}
