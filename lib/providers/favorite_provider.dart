import 'package:flutter/material.dart';
import '../controllers/favorite_controller.dart';
import '../models/recipe_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteController _controller;
  final String userId;
  List<Recipe> _favoriteRecipes = [];

  FavoriteProvider(this._controller, this.userId);

  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  bool isFavorite(String recipeId) {
    return _favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  Future<void> fetchFavorites() async {
    // Ambil daftar resep favorit dari database
    _favoriteRecipes = await _controller.getFavorites(userId);
    notifyListeners(); 
  }

  Future<void> addFavorite(Recipe recipe) async {
    await _controller.addFavorite(userId, recipe);
    _favoriteRecipes.add(recipe);
    notifyListeners();
  }

  Future<void> removeFavorite(String recipeId) async {
    final recipe = _favoriteRecipes.firstWhere((r) => r.id == recipeId);
    await _controller.removeFavorite(userId, recipe);
    _favoriteRecipes.remove(recipe);
    notifyListeners();
  }
}
