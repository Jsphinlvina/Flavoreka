import 'package:flutter/material.dart';
import '../controllers/recipe_controller.dart';
import '../models/recipe_model.dart';
import '../utils/auth_service.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeController _controller;

  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  RecipeProvider(AuthService authService)
      : _controller = RecipeController(authService);

  Future<void> addRecipe({
    required String title,
    required String imageUrl,
    required String ingredients,
    required String steps,
  }) async {
    await _controller.addRecipe(
      title: title,
      imageUrl: imageUrl,
      ingredients: ingredients,
      steps: steps,
    );
    await fetchRecipes(); // Refresh daftar resep setelah menambahkan
  }

  Future<void> fetchRecipes() async {
    _recipes = await _controller.getAllRecipes();
    notifyListeners();
  }
  // Update resep
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    await _controller.updateRecipe(updatedRecipe.id, updatedRecipe.toMap());
    await fetchRecipes(); 
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _controller.deleteRecipe(id);
    await fetchRecipes();
  }
}
