import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_model.dart';
import '../controllers/user_data_controller.dart';
import '../utils/auth_service.dart';

class UserDataProvider extends ChangeNotifier {
  final UserDataController _controller;

  UserDataProvider(AuthService authService)
      : _controller = UserDataController(authService);

  UserData? _currentUserData; // Data pengguna yang sedang login
  UserData? get currentUserData => _currentUserData;

  bool _isLoading = false; // State loading
  bool get isLoading => _isLoading;

  Future<File?> loadProfilePicture() async {
    if (_currentUserData == null) return null;
    return await _controller.loadImage(_currentUserData!.profilePicture);
  }

  // Mengambil data user yang sedang login
  Future<void> fetchUserData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _controller.getUserData(userId);
      if (userData != null) {
        _currentUserData = userData;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getUsernameById(String userId) async {
  try {
    final userData = await _controller.getUserData(userId);
    return userData?.username;
  } catch (e) {
    print("Error fetching username for $userId: $e");
    return null;
  }
}


  // Membuat data user baru
  Future<void> createUserData({
    required String id,
    required String name,
    required String email,
    required String username,
  }) async {
    try {
      await _controller.createUserData(
        id: id,
        name: name,
        email: email,
        username: username,
      );
    } catch (e) {
      print("Error creating user data: $e");
      throw Exception("Failed to create user data.");
    }
  }

  // Edit user data
  Future<void> editUserData(Map<String, dynamic> updatedData,
      {File? profilePicture}) async {
    if (_currentUserData == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _controller.editUserData(
        _currentUserData!.id,
        updatedData,
        profilePicture: profilePicture,
      );
      await fetchUserData(_currentUserData!.id); // Refresh data setelah update
    } catch (e) {
      print("Error editing user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus akun user yang sedang login
  Future<void> deleteCurrentUser(String password) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("No user is logged in.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _controller.deleteUser(currentUser.uid, password); // Kirim password
      print("User account deleted successfully.");
      _currentUserData = null;
    } catch (e) {
      print("Error deleting user account: $e");
      throw Exception("Failed to delete account. Please try again.");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> validateCurrentPassword(String currentPassword) async {
    return await _controller.validateCurrentPassword(currentPassword);
  }

  Future<void> updatePassword(String newPassword) async {
    await _controller.updatePassword(newPassword);
    notifyListeners();
  }

  // Validasi username unik
  Future<bool> checkUsernameUniqueness(String username) async {
    final currentUserId = _currentUserData?.id ?? '';
    return await _controller.isUsernameUnique(username, currentUserId);
  }

  // Validasi email unik
  Future<bool> checkEmailUniqueness(String email) async {
    return await _controller.isEmailUnique(email);
  }
}
