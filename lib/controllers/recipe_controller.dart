import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';
import '../utils/auth_service.dart';

class RecipeController {
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');
  final AuthService _authService;

  RecipeController(this._authService);

  // Fungsi untuk menambahkan resep baru
  Future<void> addRecipe({
    required String title,
    required String imageUrl,
    required String ingredients,
    required String steps,
  }) async {
    // Ambil userId pengguna yang sedang login
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      throw Exception("You must be logged in to add a recipe.");
    }

    // Buat objek Recipe
    final newRecipe = Recipe(
      id: "",
      title: title.trim(),
      imageUrl: imageUrl.trim(),
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

    // Simpan ke Firestore
    await _recipeCollection.add(newRecipe.toMap());
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

  // Update resep
  // Function to update an existing recipe
  Future<void> updateRecipe({
    required Recipe recipe,
    required String title,
    required String imageUrl,
    required String ingredients,
    required String steps,
  }) async {
    final updatedRecipe = recipe.copyWith(
      title: title.trim(),
      imageUrl: imageUrl.trim(),
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
