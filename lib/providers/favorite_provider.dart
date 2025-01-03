import 'package:flutter/material.dart';
import '../controllers/favorite_controller.dart';
import '../models/recipe_model.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteController _controller;
  String _userId;
  List<Recipe> _favoriteRecipes = [];

  FavoriteProvider(this._controller, this._userId);

  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  bool isFavorite(String recipeId) {
    return _favoriteRecipes.any((recipe) => recipe.id == recipeId);
  }

  void updateUserId(String newUserId) {
    _userId = newUserId;
    notifyListeners();
  }

  Future<void> fetchFavorites() async {
    _favoriteRecipes = await _controller.getFavorites(_userId);
    notifyListeners();
  }

  Future<void> addFavorite(Recipe recipe) async {
    await _controller.addFavorite(_userId, recipe);
    _favoriteRecipes.add(recipe);
    notifyListeners();
  }

  Future<void> removeFavorite(String recipeId) async {
    final recipe = _favoriteRecipes.firstWhere((r) => r.id == recipeId);
    await _controller.removeFavorite(_userId, recipe);
    _favoriteRecipes.remove(recipe);
    notifyListeners();
  }
}
