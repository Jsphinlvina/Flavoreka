import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavoreka/providers/recipe_provider.dart';

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
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipeProvider.recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipeProvider.recipes[index];
                return ListTile(
                  title: Text(recipe.title),
                  subtitle: Text(recipe.ingredients.join(", ")),
                );
              },
            ),
    );
  }
}
