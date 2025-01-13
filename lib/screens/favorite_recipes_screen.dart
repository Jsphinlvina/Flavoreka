import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';
import '../providers/favorite_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/navbar.dart';
import 'recipe_detail_screen.dart';

class FavoriteRecipesScreen extends StatefulWidget {
  const FavoriteRecipesScreen({super.key});

  @override
  _FavoriteRecipesScreenState createState() => _FavoriteRecipesScreenState();
}

class _FavoriteRecipesScreenState extends State<FavoriteRecipesScreen> {
  String _searchQuery = "";
  Map<String, String> userIdToUsername = {}; // userId -> username

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

      if (authService.currentUser != null) {
        await favoriteProvider.fetchFavorites();
        final userIds = favoriteProvider.favoriteRecipes
            .map((recipe) => recipe.userId)
            .toSet()
            .toList();
        await fetchUsernames(userIds);
        setState(() {});
      }
    });
  }

  Future<void> fetchUsernames(List<String> userIds) async {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    for (var userId in userIds) {
      final username = await userDataProvider.getUsernameById(userId);
      if (username != null) {
        userIdToUsername[userId] = username;
      }
    }
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
            final username = userIdToUsername[recipe.userId]?.toLowerCase() ?? '';
            return recipe.title.toLowerCase().contains(query) ||
                recipe.ingredients.any((ingredient) => ingredient.toLowerCase().contains(query)) ||
                username.contains(query);
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
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 5 / 6,
                        ),
                        itemCount: favoriteRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = favoriteRecipes[index];
                          return FutureBuilder<File?>(
                            future: recipeProvider.loadImage(recipe.imageUrl),
                            builder: (context, snapshot) {
                              final localImage = snapshot.data;
                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                  favoriteProvider.fetchFavorites();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: localImage != null
                                            ? Image.file(
                                                localImage,
                                                width: double.infinity,
                                                height: 120,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: double.infinity,
                                                height: 120,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe.title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "by ${userIdToUsername[recipe.userId] ?? 'Unknown'}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                const Icon(
                                                  Icons.favorite_border,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${recipe.favoritesCount}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
