import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              recipe.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 100),
            ),
            const SizedBox(height: 16),
            Text(
              recipe.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Favorites: ${recipe.favoritesCount}"),
            Text("Created at: ${recipe.createdAt.toLocal()}"),
            const SizedBox(height: 16),
            const Text(
              "Ingredients:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            for (var ingredient in recipe.ingredients)
              Text("- $ingredient", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              "Steps:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            for (var step in recipe.steps)
              Text("${recipe.steps.indexOf(step) + 1}. $step",
                  style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
