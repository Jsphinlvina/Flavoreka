import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_model.dart';
import '../controllers/user_data_controller.dart';

class UserDataProvider extends ChangeNotifier {
  final UserDataController _controller = UserDataController();

  UserData? _currentUserData; // Data pengguna yang sedang login
  UserData? get currentUserData => _currentUserData;

  bool _isLoading = false; // State loading
  bool get isLoading => _isLoading;

  // Mengambil data user yang sedang login
  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.uid.isEmpty) {
      print("No user is currently logged in or userId is empty.");
      _currentUserData = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final userData = await _controller.getUserData(currentUser.uid);
      if (userData != null) {
        _currentUserData = userData;
      } else {
        print("No user data found for ID: ${currentUser.uid}");
        _currentUserData = null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   // Edit user data
  Future<void> editUser(Map<String, dynamic> updatedData) async {
    if (_currentUserData == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _controller.editUserData(_currentUserData!.id, updatedData);
      await fetchUserData(); // Refresh data setelah update
    } catch (e) {
      print("Error editing user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus akun user yang sedang login
  Future<void> deleteCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("No user is logged in.");
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _controller.deleteUser(currentUser.uid);

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
}
