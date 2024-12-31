import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_model.dart';

class UserDataProvider extends ChangeNotifier {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  UserData? _currentUserData; // Data pengguna yang sedang login
  UserData? get currentUserData => _currentUserData;

  bool _isLoading = false; // State loading
  bool get isLoading => _isLoading;

  // Fetch data user yang sedang login
  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print("No user is currently logged in.");
      return;
    }

    print("Fetching user data for ID: ${currentUser.uid}");

    _isLoading = true;
    notifyListeners();

    try {
      final docSnapshot = await _userCollection.doc(currentUser.uid).get();

      if (docSnapshot.exists) {
        _currentUserData = UserData.fromFiresotre(
          docSnapshot.data() as Map<String, dynamic>,
          currentUser.uid,
        );
        print("User data successfully loaded.");
      } else {
        print("No document found for user ID: ${currentUser.uid}");
        _currentUserData = null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Membuat data user baru di Firestore
  // Future<void> createUserData({
  //   required String name,
  //   required String email,
  //   required String username,
  // }) async {
  //   final currentUser = FirebaseAuth.instance.currentUser;

  //   if (currentUser == null) return;

  //   final newUser = UserData(
  //     id: currentUser.uid,
  //     name: name,
  //     email: email,
  //     username: username,
  //     profilePicture: "",
  //     favoriteRecipes: [],
  //     createRecipes: 0,
  //     createdAt: DateTime.now(),
  //   );

  //   try {
  //     await _userCollection.doc(currentUser.uid).set(newUser.toMap());
  //     _currentUserData = newUser;
  //     notifyListeners();
  //   } catch (e) {
  //     print("Error creating user data: $e");
  //   }
  // }

  // Update data user di Firestore
  Future<void> updateUserData(Map<String, dynamic> updatedData) async {
    if (_currentUserData == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _userCollection.doc(_currentUserData!.id).update(updatedData);
      await fetchUserData(); // Refresh data setelah update
    } catch (e) {
      print("Error updating user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Account
  Future<void> deleteCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // Hapus data pengguna dari Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();

        // Hapus akun dari Firebase Authentication
        await currentUser.delete();
        print("User account deleted successfully.");
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print("Error: User needs to reauthenticate.");
          throw Exception("You need to log in again to delete your account.");
        } else {
          print("FirebaseAuthException: $e");
          throw Exception("Failed to delete account. Please try again.");
        }
      } catch (e) {
        print("General Error: $e");
        throw Exception("Failed to delete account. Please try again.");
      }
    } else {
      throw Exception("No user is logged in.");
    }
  }
}
