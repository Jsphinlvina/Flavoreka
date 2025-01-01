import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _profilePictureController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userData = userProvider.currentUserData;

    if (userData != null) {
      _nameController.text = userData.name;
      _usernameController.text = userData.username;
      _profilePictureController.text = userData.profilePicture;
    }
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final updatedData = {
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'profilePicture': _profilePictureController.text.trim(),
    };

    await userProvider.editUser(updatedData);
    Navigator.pop(context); // Kembali ke layar sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _profilePictureController,
              decoration:
                  const InputDecoration(labelText: "Profile Picture URL"),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity, // Membuat tombol memenuhi lebar penuh
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text("Save Changes"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
