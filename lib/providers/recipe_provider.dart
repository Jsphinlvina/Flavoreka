import 'package:flutter/material.dart';
import '../controllers/recipe_controller.dart';
import '../models/recipe_model.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeController _controller = RecipeController();
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  // Ambil semua resep
  Future<void> fetchRecipes() async {
    _recipes = await _controller.getAllRecipes();
    notifyListeners(); 
  }

  // Tambah resep
  Future<void> addRecipe(Recipe recipe) async {
    await _controller.addRecipe(recipe);
    await fetchRecipes();
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _controller.deleteRecipe(id);
    await fetchRecipes();
  }
}
