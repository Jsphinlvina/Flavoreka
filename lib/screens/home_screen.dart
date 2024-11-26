import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Flavoreka")),
      body: FutureBuilder(
        future: recipeProvider.fetchRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: recipeProvider.recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipeProvider.recipes[index];
              return ListTile(
                title: Text(recipe.title),
                subtitle: Text(recipe.ingredients.join(", ")),
                leading: Image.network(recipe.imageUrl), // Menampilkan URL gambar
                onTap: () {
                  // Navigasi ke detail resep
                },
              );
            },
          );
        },
      ),
    );
  }
}
