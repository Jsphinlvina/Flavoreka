import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataController {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // Membuat data user baru
  Future<void> createUserData({
    required String id,
    required String name,
    required String email,
    required String username,
  }) async {
    final userData = UserData(
      id: id,
      name: name,
      email: email,
      username: username,
      profilePicture: "", // Default profile picture
      favoriteRecipes: [],
      createRecipes: 0,
      createdAt: DateTime.now(),
    );

    await _userCollection.doc(id).set(userData.toMap());
  }

  // Mengambil data user yang sedang login
  Future<UserData?> getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("No user is currently logged in.");
      return null;
    }

    try {
      final docSnapshot = await _userCollection.doc(currentUser.uid).get();

      if (docSnapshot.exists) {
        return UserData.fromFiresotre(
          docSnapshot.data() as Map<String, dynamic>,
          currentUser.uid,
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
}
