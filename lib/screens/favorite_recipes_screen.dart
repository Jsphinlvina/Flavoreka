import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/navbar.dart';
import 'recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  _FavoriteRecipesScreenState createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Fetch favorite recipes when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

      if (authService.currentUser != null) {
        favoriteProvider.fetchFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Periksa apakah pengguna sudah login
    if (authService.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favorite Recipes")),
        body: const Center(
          child: Text("You must be logged in to view your favorite recipes."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Recipes"),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<FavoriteProvider, RecipeProvider>(
        builder: (context, favoriteProvider, recipeProvider, _) {
          final favoriteRecipes = favoriteProvider.favoriteRecipes.where((recipe) {
            final query = _searchQuery.toLowerCase();
            return recipe.title.toLowerCase().contains(query) ||
                recipe.ingredients.any((ingredient) =>
                    ingredient.toLowerCase().contains(query));
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search favorite recipes...",
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
              Expanded(
                child: favoriteRecipes.isEmpty
                    ? const Center(
                        child: Text("No favorite recipes found."),
                      )
                    : ListView.builder(
                        itemCount: favoriteRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = favoriteRecipes[index];
                          return FutureBuilder<File?>(
                            future: recipeProvider.loadImage(recipe.imageUrl),
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
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                  favoriteProvider.fetchFavorites();
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
        currentIndex: 2,
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
