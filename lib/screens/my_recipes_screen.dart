import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';
import '../providers/recipe_provider.dart';
import '../widgets/navbar.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Periksa apakah pengguna sudah login
    if (authService.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Recipes")),
        body: const Center(
          child: Text("You must be logged in to view your recipes."),
        ),
      );
    }

    // Filter resep berdasarkan userId
    final userRecipes = recipeProvider.recipes.where((recipe) {
      return recipe.userId == authService.currentUser!.uid;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Recipes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigasi ke Add Recipe Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
              ).then((_) {
                // Refresh setelah kembali dari Add Recipe
                recipeProvider.fetchRecipes();
              });
            },
          ),
        ],
      ),
      body: userRecipes.isEmpty
          ? const Center(child: Text("No recipes found. Add your first recipe!"))
          : ListView.builder(
              itemCount: userRecipes.length,
              itemBuilder: (context, index) {
                final recipe = userRecipes[index];
                return ListTile(
                  leading: Image.network(
                    recipe.imageUrl,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                  title: Text(recipe.title),
                  subtitle: Text("Favorites: ${recipe.favoritesCount}"),
                  onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                );
              },
            ),
      bottomNavigationBar: Navbar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/my-recipes');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/account');
              break;
          }
        },
      ),
    );
  }
}
