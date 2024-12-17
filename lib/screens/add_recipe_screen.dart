import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../providers/recipe_provider.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // Parameter opsional untuk mode edit

  const AddRecipeScreen({super.key, this.recipe});

  @override
  _AddRecipeScreenState createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Jika ada `recipe`, isi controller dengan nilai-nilai yang ada
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _imageUrlController.text = widget.recipe!.imageUrl;
      _ingredientsController.text = widget.recipe!.ingredients.join('. ');
      _stepsController.text = widget.recipe!.steps.join('; ');
    }
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeProvider =
          Provider.of<RecipeProvider>(context, listen: false);

      try {
        await recipeProvider.addRecipe(
          title: _titleController.text,
          imageUrl: _imageUrlController.text,
          ingredients: _ingredientsController.text,
          steps: _stepsController.text,
        );
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipe added successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add recipe: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? "Add Recipe" : "Edit Recipe"),
      ),
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
                  validator: (value) => value == null || value.isEmpty
                      ? "Please enter a title"
                      : null,
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
                  decoration: const InputDecoration(labelText: "Ingredients"),
                ),
                TextFormField(
                  controller: _stepsController,
                  decoration: const InputDecoration(labelText: "Steps"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitRecipe,
                  child: const Text("Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
