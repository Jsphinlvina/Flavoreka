import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../utils/auth_service.dart';
import '../providers/recipe_provider.dart';
import '../providers/favorite_provider.dart';
import 'edit_recipe_screen.dart';
import 'login_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({required this.recipe, super.key});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe recipe;
  File? _localImage;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    _loadImageFromProvider();
  }

  Future<void> _loadImageFromProvider() async {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final localImage = await recipeProvider.loadImage(recipe.imageUrl);
    if (localImage != null) {
      setState(() {
        _localImage = localImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid;
    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(recipe.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Details"),
        actions: [
          if (currentUserId == recipe.userId) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updatedRecipe = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditRecipeScreen(recipe: recipe),
                  ),
                );
                if (updatedRecipe != null && mounted) {
                  setState(() {
                    recipe = updatedRecipe;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Recipe"),
                    content: const Text(
                        "Are you sure you want to delete this recipe?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await recipeProvider.deleteRecipe(recipe.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Recipe deleted successfully.")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to delete recipe: $e")),
                    );
                  }
                }
              },
            ),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _localImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _localImage!,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 100,
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              recipe.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<String?>(
                  future: authService.getUsernameById(recipe.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Made by: Loading...");
                    } else if (snapshot.hasError) {
                      return const Text("Made by: Unknown");
                    } else {
                      final username = snapshot.data ?? "Unknown";
                      return Text(
                        "Made by: $username",
                        style: const TextStyle(fontSize: 16),
                      );
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${recipe.favoritesCount}",
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Created at: $formattedDate",
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 32, thickness: 1),
            const Text(
              "Ingredients:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text("- $ingredient",
                      style: const TextStyle(fontSize: 16)),
                )),
            const Divider(height: 32, thickness: 1),
            const Text(
              "Steps:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...recipe.steps.map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${recipe.steps.indexOf(step) + 1}. ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          final isFavorite = favoriteProvider.isFavorite(recipe.id);
          final currentUserId = favoriteProvider.userId;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (currentUserId.isEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                  return;
                }

                if (isFavorite) {
                  await favoriteProvider.removeFavorite(recipe.id);
                } else {
                  await favoriteProvider.addFavorite(recipe);
                }

                await recipeProvider.fetchRecipes();

                setState(() {
                  recipe = recipe.copyWith(
                    favoritesCount:
                        recipe.favoritesCount + (isFavorite ? -1 : 1),
                  );
                });
              },
              child: Text(
                isFavorite ? "Remove from Favorites" : "Add to Favorites",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}
