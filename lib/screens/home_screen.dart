import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/user_data_provider.dart';
import '../widgets/navbar.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  Map<String, String> userIdToUsername = {}; // userId -> username

  @override
  void initState() {
    super.initState();
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    recipeProvider.fetchRecipes().then((_) async {
      final userIds =
          recipeProvider.recipes.map((recipe) => recipe.userId).toList();
      await fetchUsernames(userIds);
      setState(() {});
    });
  }

  Future<void> fetchUsernames(List<String> userIds) async {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);

    for (var userId in userIds) {
      final username = await userDataProvider.getUsernameById(userId);
      if (username != null) {
        userIdToUsername[userId] = username;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flavoreka"),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, recipeProvider, _) {
          final filteredRecipes = recipeProvider.recipes.where((recipe) {
            final query = _searchQuery.toLowerCase();
            final username =
                userIdToUsername[recipe.userId]?.toLowerCase() ?? '';
            return recipe.title.toLowerCase().contains(query) ||
                recipe.ingredients.any(
                    (ingredient) => ingredient.toLowerCase().contains(query)) ||
                username.contains(query);
          }).toList();

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search recipes...",
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
                child: filteredRecipes.isEmpty
                    ? const Center(child: Text("No recipes found"))
                    : GridView.builder(
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 4 / 5,
                        ),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return FutureBuilder<File?>(
                            future: Provider.of<RecipeProvider>(context,
                                    listen: false)
                                .loadImage(recipe.imageUrl),
                            builder: (context, snapshot) {
                              final localImage = snapshot.data;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
        currentIndex: 0,
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
