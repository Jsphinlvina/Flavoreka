import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class RecipeController {
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  // Tambah resep
  Future<void> addRecipe(RecipeModel recipe) async {
    await _recipeCollection.add(recipe.toMap());
  }

  // Ambil semua resep
  Future<List<RecipeModel>> getAllRecipes() async {
    QuerySnapshot snapshot = await _recipeCollection.get();
    return snapshot.docs.map((doc) {
      return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Ambil detail resep
  Future<RecipeModel> getRecipeById(String id) async {
    DocumentSnapshot doc = await _recipeCollection.doc(id).get();
    return RecipeModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Hapus resep
  Future<void> deleteRecipe(String id) async {
    await _recipeCollection.doc(id).delete();
  }
}
