import 'package:flutter/material.dart';
import '../controllers/favorite_controller.dart';
import '../models/recipe_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteController _controller;
  String userId;
  List<Recipe> _favoriteRecipes = [];

  FavoriteProvider(this._controller, this.userId);

  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  bool isFavorite(String recipeId) {
    return _favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  void updateUserId(String newUserId) async {
    userId = newUserId;
    _favoriteRecipes.clear(); // Bersihkan data lama
    if (userId.isNotEmpty) {
      await fetchFavorites(); // Ambil data favorit baru
    }
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
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
