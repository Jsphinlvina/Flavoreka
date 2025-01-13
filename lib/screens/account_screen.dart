import 'package:flavoreka/providers/favorite_provider.dart';
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
      final userId =
          Provider.of<AuthService>(context, listen: false).currentUser?.uid;
      if (userId != null) {
        Provider.of<UserDataProvider>(context, listen: false)
            .fetchUserData(userId);
      }
    });
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final favoriteProvider =
        Provider.of<FavoriteProvider>(context, listen: false);

    await authService.logout();
    favoriteProvider.updateUserId(''); // Reset userId
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final username = userProvider.currentUserData?.username ?? "";

    String inputUsername = "";
    String inputPassword = "";

    final result = await showDialog<bool>(
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
                "To confirm, please type your username and password below:",
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
              const SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  inputPassword = value;
                },
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (inputUsername != username) {
        _showErrorDialog(context, "Username doesn't match",
            "The username you entered is incorrect. Please try again.");
        return;
      }

      try {
        await userProvider.deleteCurrentUser(inputPassword);
        await authService.logout();

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        _showErrorDialog(context, "Error", "Failed to delete account: $e");
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
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
        title: const Text("Account"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user data found"))
              : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                radius: 80,
                                child: const Icon(
                                  Icons.account_circle,
                                  size: 80,
                                ),
                              );
                            } else {
                              return CircleAvatar(
                                radius: 80,
                                backgroundImage: FileImage(snapshot.data!),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        userData.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "@${userData.username}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: Text(userData.email),
                      ),
                      ListTile(
                        leading: const Icon(Icons.food_bank),
                        title:
                            Text("Recipes Created: ${userData.createRecipes}"),
                      ),
                      ListTile(
                        leading: const Icon(Icons.favorite),
                        title: Text(
                          "Favorite Recipes: ${userData.favoriteRecipes.length}",
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(
                          "Joined: ${userData.createdAt.toLocal().toString().split(' ')[0]}",
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
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
                          const SizedBox(width: 10),
                          Expanded(
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _deleteAccount(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(200, 50),
                        ),
                        child: const Text(
                          "Delete Account",
                          style: TextStyle(color: Colors.white),
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
