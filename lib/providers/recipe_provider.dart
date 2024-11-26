import 'package:flutter/material.dart';
import '../controllers/recipe_controller.dart';
import '../models/recipe_model.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeController _controller = RecipeController();
  List<RecipeModel> _recipes = [];

  List<RecipeModel> get recipes => _recipes;

  // Ambil semua resep
  Future<void> fetchRecipes() async {
    _recipes = await _controller.getAllRecipes();
    notifyListeners();
  }

  // Tambah resep
  Future<void> addRecipe(RecipeModel recipe) async {
    await _controller.addRecipe(recipe);
    await fetchRecipes(); // Refresh data setelah menambah
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _controller.deleteRecipe(id);
    await fetchRecipes(); // Refresh data setelah menghapus
  }
}
