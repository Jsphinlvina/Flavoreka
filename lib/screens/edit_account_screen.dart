import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final userData = userProvider.currentUserData;

    if (userData != null) {
      _nameController.text = userData.name;
      _usernameController.text = userData.username;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final username = _usernameController.text.trim();

    // Validasi username unik
    final isUnique = await userProvider.checkUsernameUniqueness(username);
    if (!isUnique) {
      setState(() {
        _usernameError =
            "Username is already taken. Please choose another one.";
      });
      return;
    }

    final updatedData = {
      'name': _nameController.text.trim(),
      'username': username,
    };

    try {
      await userProvider.editUserData(updatedData,
          profilePicture: _selectedImage);
      Navigator.pop(context); // Kembali ke layar sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save changes: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Profile Details",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Update your profile information below",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 50),
            Center(
              child: GestureDetector(
                onTap: () async {
                  final source = await showModalBottomSheet<ImageSource>(
                    context: context,
                    builder: (context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text("Take Photo"),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.camera),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text("Choose from Gallery"),
                              onTap: () =>
                                  Navigator.pop(context, ImageSource.gallery),
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (source != null) {
                    await _pickImage(source);
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(
                          Icons.account_circle,
                          size: 60,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 50),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                errorText: _usernameError,
              ),
              onChanged: (value) {
                setState(() {
                  _usernameError = null; // Reset error saat user mengetik
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _saveChanges,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
