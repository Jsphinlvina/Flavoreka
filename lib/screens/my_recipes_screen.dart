import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';
import '../providers/recipe_provider.dart';
import '../widgets/navbar.dart';
import 'add_recipe_screen.dart';
import 'recipe_detail_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Periksa apakah pengguna sudah login
    if (authService.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("My Recipes")),
        body: const Center(
          child: Text("You must be logged in to view your recipes."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Recipes"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipeScreen()),
              ).then((_) {
                Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
              });
            },
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, _) {
          final userRecipes = recipeProvider.recipes.where((recipe) {
            final query = _searchQuery.toLowerCase();
            return recipe.userId == authService.currentUser!.uid &&
                (recipe.title.toLowerCase().contains(query) ||
                    recipe.ingredients.any((ingredient) =>
                        ingredient.toLowerCase().contains(query)));
          }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search your recipes...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Recipe list
              Expanded(
                child: userRecipes.isEmpty
                    ? const Center(
                        child: Text("No recipes found. Add your first recipe!"),
                      )
                    : ListView.builder(
                        itemCount: userRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = userRecipes[index];
                          return FutureBuilder<File?>(
                            future: Provider.of<RecipeProvider>(context, listen: false).loadImage(recipe.imageUrl),
                            builder: (context, snapshot) {
                              final localImage = snapshot.data;
                              return ListTile(
                                leading: localImage != null
                                    ? Image.file(
                                        localImage,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image_not_supported),
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
                          );
                        },
                      ),
              ),
            ],
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
