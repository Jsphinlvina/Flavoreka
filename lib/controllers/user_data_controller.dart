import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_data_model.dart';

class UserDataController {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Membuat data user baru
  Future<void> createUserData({
    required String id,
    required String name,
    required String email,
    required String username,
  }) async {
    if (id.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    final userData = UserData(
      id: id,
      name: name,
      email: email,
      username: username,
      profilePicture: "",
      favoriteRecipes: [],
      createRecipes: 0,
      createdAt: DateTime.now(),
    );

    await _userCollection.doc(id).set(userData.toMap());
  }

  // Mengambil data user berdasarkan userId
  Future<UserData?> getUserData(String userId) async {
    if (userId.isEmpty) {
      print("Error: userId is empty.");
      return null;
    }

    try {
      final docSnapshot = await _userCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return UserData.fromFiresotre(
          docSnapshot.data() as Map<String, dynamic>,
          userId,
        );
      } else {
        print("User data not found.");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  // Edit user data
  Future<void> editUserData(
      String userId, Map<String, dynamic> updatedData) async {
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }
    await _userCollection.doc(userId).update(updatedData);
  }

  // Menghapus data user
  Future<void> deleteUser(String userId) async {
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    try {
      await _userCollection.doc(userId).delete();

      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        await currentUser.delete();
        print("User deleted successfully from Firebase Authentication.");
      } else {
        print("No authenticated user matches the given userId.");
      }
    } catch (e) {
      print("Error deleting user: $e");
      throw Exception("Failed to delete user. Please try again.");
    }
  }

  Future<bool> validateCurrentPassword(String currentPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception("Failed to update password: ${e.toString()}");
    }
  }
}
