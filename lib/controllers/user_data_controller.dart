import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flavoreka/controllers/favorite_controller.dart';
import 'package:flavoreka/controllers/recipe_controller.dart';
import 'package:flavoreka/models/recipe_model.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_data_model.dart';
import '../utils/auth_service.dart';

class UserDataController {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');
  final AuthService _authService;

  final RecipeController _recipeController;
  final FavoriteController _favoriteController = FavoriteController();

  UserDataController(AuthService authService)
      : _authService = authService,
        _recipeController = RecipeController(authService);

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

  // Fungsi untuk menyimpan gambar secara lokal
  Future<String> saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final localPath = '${directory.path}/$fileName.jpg';

    final localImage = await imageFile.copy(localPath);
    return localImage.path;
  }

  // Fungsi untuk memuat gambar dari path lokal
  Future<File?> loadImage(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/${imagePath.split('/').last}';
      final file = File(localPath);

      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      print("Error loading image: $e");
    }
    return null;
  }

  // Mengedit data pengguna (termasuk profilePicture)
  Future<void> editUserData(String userId, Map<String, dynamic> updatedData,
      {File? profilePicture}) async {
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    if (profilePicture != null) {
      try {
        final localPath = await saveImageLocally(profilePicture);
        updatedData['profilePicture'] =
            localPath; // Tambahkan path gambar ke data yang diupdate
      } catch (e) {
        print("Error saving profile picture locally: $e");
        throw Exception("Failed to save profile picture.");
      }
    }

    try {
      await _userCollection.doc(userId).update(updatedData);
    } catch (e) {
      print("Error updating user data: $e");
      throw Exception("Failed to update user data.");
    }
  }

  Future<void> deleteUser(String userId, String password) async {
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    try {
      final user = _authService.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception(
            "User not authenticated or does not match the provided userId.");
      }

      // Otentikasi ulang pengguna
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Menghus semua favorite
      final userDoc = await _userCollection.doc(userId).get();
      final favoriteRecipeIds =
          List<String>.from(userDoc['favoriteRecipes'] ?? []);

      // Remove favorites for each recipe
      for (var recipeId in favoriteRecipeIds) {
        final recipeSnapshot = await _recipeCollection.doc(recipeId).get();
        if (recipeSnapshot.exists) {
          final recipeData = Recipe.fromFirestore(
              recipeSnapshot.data() as Map<String, dynamic>, recipeId);

          await _favoriteController.removeFavorite(userId, recipeData);
        }
      }

      // Menghapus semua resep yang dibuat oleh pengguna
      final allRecipes = await _recipeController.getAllRecipes();
      for (var recipe in allRecipes) {
        if (recipe.userId == userId) {
          await _recipeController.deleteRecipe(recipe.id);
          await _favoriteController.removeFavoritesByRecipe(recipe.id);
        }
      }

      await _userCollection.doc(userId).delete();

      // Hapus akun pengguna dari Firebase Authentication
      await user.delete();

      print("User account deleted successfully.");
    } catch (e) {
      print("Error deleting user: $e");
      throw Exception("Failed to delete user. Please try again.");
    }
  }

  Future<bool> validateCurrentPassword(String currentPassword) async {
    final user = _authService.currentUser;
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
      print("Error reauthenticating: $e");
      return false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception("No user is logged in.");
    }

    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      print("Error updating password: $e");
      throw Exception("Failed to update password: ${e.toString()}");
    }
  }

  Future<bool> isUsernameUnique(String username, String currentUserId) async {
    final querySnapshot =
        await _userCollection.where('username', isEqualTo: username).get();

    // Jika dokumen ditemukan, pastikan tidak termasuk user yang sedang login
    for (var doc in querySnapshot.docs) {
      if (doc.id != currentUserId) {
        return false; // Username tidak unik
      }
    }

    return true; // Username unik
  }

  // Validasi apakah email unik
  Future<bool> isEmailUnique(String email) async {
    final querySnapshot =
        await _userCollection.where('email', isEqualTo: email).get();

    return querySnapshot.docs.isEmpty; // Jika kosong, email unik
  }
}
