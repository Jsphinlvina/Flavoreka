import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class FavoriteController {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  Future<List<Recipe>> getFavorites(String userId) async {
    final userDoc = await _userCollection.doc(userId).get();
    final favoriteRecipeIds =
        List<String>.from(userDoc['favoriteRecipes'] ?? []);

    if (favoriteRecipeIds.isEmpty) {
      return [];
    }

    final querySnapshot = await _recipeCollection
        .where(FieldPath.documentId, whereIn: favoriteRecipeIds)
        .get();

    return querySnapshot.docs.map((doc) {
      return Recipe.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<void> addFavorite(String userId, Recipe recipe) async {
    final userDoc = _userCollection.doc(userId);
    final recipeDoc = _recipeCollection.doc(recipe.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userDoc, {
        'favoriteRecipes': FieldValue.arrayUnion([recipe.id])
      });

      transaction.update(recipeDoc, {
        'favoritesCount': FieldValue.increment(1),
      });
    });
  }

  Future<void> removeFavorite(String userId, Recipe recipe) async {
    final userDoc = _userCollection.doc(userId);
    final recipeDoc = _recipeCollection.doc(recipe.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(userDoc, {
        'favoriteRecipes': FieldValue.arrayRemove([recipe.id])
      });

      transaction.update(recipeDoc, {
        'favoritesCount': FieldValue.increment(-1),
      });
    });
  }
}
