import 'package:flavoreka/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  String? _usernameError;
  String? _passwordError;
  String? _emailError;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();
      final username = _usernameController.text.trim();

      // Validasi username unik
      final isUniqueUsername = await userDataProvider.checkUsernameUniqueness(username);
      if (!isUniqueUsername) {
        setState(() {
          _usernameError = "Username is already taken. Please choose another one.";
        });
        return;
      }

      // Validasi email unik
      final isUniqueEmail = await userDataProvider.checkEmailUniqueness(email);
      if (!isUniqueEmail) {
        setState(() {
          _emailError = "This email is already registered. Please use another one.";
        });
        return;
      }

      try {
        final user = await authService.signUp(email, password);
        if (user != null) {
          await userDataProvider.createUserData(
            id: user.uid,
            name: name,
            email: email,
            username: username,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully!")),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign up: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter your name" : null,
                ),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    errorText: _usernameError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _usernameError = null; // Reset error saat user mengetik
                    });
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter a username" : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    errorText: _emailError,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _emailError = null; // Reset error saat user mengetik
                    });
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? "Enter your email" : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    errorText: _passwordError,
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _passwordError = null; // Reset error saat user mengetik
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter a password";
                    } else if (value.length < 6) {
                      setState(() {
                        _passwordError = "Password must be at least 6 characters.";
                      });
                      return null;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _signUp,
                    child: const Text("Sign Up"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
