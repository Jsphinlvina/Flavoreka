import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/navbar.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
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
            return recipe.title.toLowerCase().contains(query) ||
                recipe.ingredients.any(
                    (ingredient) => ingredient.toLowerCase().contains(query));
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
                    : ListView.builder(
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
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
                                trailing: Text(recipe.createdAt
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0]),
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
