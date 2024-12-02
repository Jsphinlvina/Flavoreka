import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<RecipeProvider>(context, listen: false).fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flavoreka"),
      ),
      body: recipeProvider.recipes.isEmpty
          ? const Center(child: Text("Tidak ada resep untuk ditampilkan"))
          : ListView.builder(
              itemCount: recipeProvider.recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipeProvider.recipes[index];
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
                  trailing: Text(recipe.createdAt.toLocal().toString().split(' ')[0]),
                );
              },
            ),
    );
  }
}
