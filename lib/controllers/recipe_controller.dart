import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeController {
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  // Tambah resep
  Future<void> addRecipe(Recipe recipe) async {
    await _recipeCollection.add(recipe.toMap());
  }

  // Ambil semua resep
  Future<List<Recipe>> getAllRecipes() async {
    QuerySnapshot snapshot = await _recipeCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) {
      return Recipe.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Ambil detail resep
  Future<Recipe> getRecipeById(String id) async {
    DocumentSnapshot doc = await _recipeCollection.doc(id).get();
    return Recipe.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _recipeCollection.doc(id).delete();
  }
}
