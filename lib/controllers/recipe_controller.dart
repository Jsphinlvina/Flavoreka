import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recipe_model.dart';
import '../utils/auth_service.dart';

class RecipeController {
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');
  final AuthService _authService;

  RecipeController(this._authService);

  // Simpan gambar ke direktori lokal aplikasi
  Future<String> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final localPath = '${directory.path}/$fileName.jpg';

    final localImage = await imageFile.copy(localPath);
    return localImage.path;
  }

  // Tambahkan resep baru dengan gambar lokal
  Future<void> addRecipe({
    required String title,
    required File imageFile,
    required String ingredients,
    required String steps,
  }) async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      throw Exception("You must be logged in to add a recipe.");
    }

    String localImagePath = await _saveImageLocally(imageFile);

    final newRecipe = Recipe(
      id: "",
      title: title.trim(),
      imageUrl: localImagePath, // Simpan path lokal
      ingredients: ingredients.trim().split('.').map((e) => e.trim()).toList(),
      steps: steps
          .trim()
          .split(';')
          .map((e) => e.trim())
          .where((step) => step.isNotEmpty)
          .toList(),
      userId: currentUser.uid,
      createdAt: DateTime.now(),
      favoritesCount: 0,
    );

    await _recipeCollection.add(newRecipe.toMap());
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

  // Ambil semua resep
  Future<List<Recipe>> getAllRecipes() async {
    QuerySnapshot snapshot =
        await _recipeCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return Recipe.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Ambil detail resep
  Future<Recipe> getRecipeById(String id) async {
    DocumentSnapshot doc = await _recipeCollection.doc(id).get();
    return Recipe.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Update resep dengan gambar lokal
  Future<void> updateRecipe({
    required Recipe recipe,
    required String title,
    File? imageFile,
    required String ingredients,
    required String steps,
  }) async {
    String imageUrl = recipe.imageUrl;

    if (imageFile != null) {
      imageUrl =
          await _saveImageLocally(imageFile); // Simpan gambar baru secara lokal
    }

    final updatedRecipe = recipe.copyWith(
      title: title.trim(),
      imageUrl: imageUrl,
      ingredients: ingredients.trim().split('.').map((e) => e.trim()).toList(),
      steps: steps
          .trim()
          .split(';')
          .map((e) => e.trim())
          .where((step) => step.isNotEmpty)
          .toList(),
    );

    await _recipeCollection.doc(updatedRecipe.id).update(updatedRecipe.toMap());
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _recipeCollection.doc(id).delete();
  }
}
