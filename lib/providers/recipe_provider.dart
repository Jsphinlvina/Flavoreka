import 'dart:io';
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

  // Memuat gambar dari path lokal melalui controller
  Future<File?> loadImage(String imagePath) async {
    return await _controller.loadImage(imagePath);
  }

  Future<void> addRecipe({
    required String title,
    required File imageFile,
    required String ingredients,
    required String steps,
  }) async {
    await _controller.addRecipe(
      title: title,
      imageFile: imageFile,
      ingredients: ingredients,
      steps: steps,
    );
    await fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    _recipes = await _controller.getAllRecipes();
    notifyListeners();
  }

  // Update resep
  Future<void> updateRecipe({
    required Recipe recipe,
    required String title,
    File? imageFile, // Tambahkan parameter imageFile
    required String ingredients,
    required String steps,
  }) async {
    await _controller.updateRecipe(
      recipe: recipe,
      title: title,
      imageFile: imageFile,
      ingredients: ingredients,
      steps: steps,
    );
    await fetchRecipes();
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _controller.deleteRecipe(id);
    await fetchRecipes();
  }
}
