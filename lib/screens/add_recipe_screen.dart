import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/auth_service.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe_model.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

      // Membuat objek resep baru
      final newRecipe = Recipe(
        id: "", 
        title: _titleController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        ingredients: _ingredientsController.text
            .trim()
            .split(',') 
            .map((e) => e.trim())
            .toList(),
        steps: _stepsController.text
            .trim()
            .split('.')
            .map((e) => e.trim())
            .where((step) => step.isNotEmpty)
            .toList(),
        favoritesCount: 0,
        createdAt: DateTime.now(),
        userId: authService.currentUser!.uid,
      );

      // Menambahkan resep baru ke Firestore
      await recipeProvider.addRecipe(newRecipe);

      // Navigasi kembali ke MyRecipesScreen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Recipe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter a title" : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: "Image URL"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter an image URL"
                      : null,
                ),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: const InputDecoration(
                      labelText: "Ingredients (comma-separated)"),
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter ingredients"
                      : null,
                ),
                TextFormField(
                  controller: _stepsController,
                  decoration: const InputDecoration(
                      labelText: "Steps (separate by dots)"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter steps" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRecipe,
                  child: const Text("Add Recipe"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
