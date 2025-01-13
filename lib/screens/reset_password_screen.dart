import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _checkCurrentPasswordValid = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Manage Password",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Change your password securely",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  errorText: _checkCurrentPasswordValid
                      ? null
                      : "Current password is incorrect.",
                ),
                controller: _currentPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                controller: _newPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Password must be at least 6 characters.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Repeat Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                controller: _repeatPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return "Passwords do not match.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () async {
                  _checkCurrentPasswordValid = await userProvider
                      .validateCurrentPassword(
                          _currentPasswordController.text);
                  setState(() {});

                  if (_formKey.currentState!.validate() &&
                      _checkCurrentPasswordValid) {
                    try {
                      await userProvider
                          .updatePassword(_newPasswordController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Password updated successfully."),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
