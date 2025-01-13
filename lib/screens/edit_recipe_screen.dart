import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../models/recipe_model.dart';
import 'my_recipes_screen.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.recipe});

  @override
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.recipe.title;
    _ingredientsController.text = widget.recipe.ingredients.join('. ');
    _stepsController.text = widget.recipe.steps.join('; ');
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeProvider =
          Provider.of<RecipeProvider>(context, listen: false);

      try {
        await recipeProvider.updateRecipe(
          recipe: widget.recipe,
          title: _titleController.text,
          imageFile: _selectedImage, // Use the updated image if any
          ingredients: _ingredientsController.text,
          steps: _stepsController.text,
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MyRecipesScreen(),
          ),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipe updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update recipe: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Recipe"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text("Choose from Gallery"),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text("Take a Picture"),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add_a_photo,
                                size: 30,
                                color: Colors.black54,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tap to select an image",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Recipe Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please enter a title"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Ingredients (separate each with a dot: .)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stepsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: "Steps (separate each with a semicolon: ;) ",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _submitRecipe,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
