import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

class FavoriteController {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _recipeCollection =
      FirebaseFirestore.instance.collection('recipes');

  Future<List<Recipe>> getFavorites(String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID is empty.");
      return [];
    }

    final userDoc = await _userCollection.doc(userId).get();
    if (!userDoc.exists) {
      print("Error: User document does not exist.");
      return [];
    }

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
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    final userDoc = _userCollection.doc(userId);
    final recipeDoc = _recipeCollection.doc(recipe.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDoc);
      final recipeSnapshot = await transaction.get(recipeDoc);

      if (!userSnapshot.exists || !recipeSnapshot.exists) {
        throw Exception("User or recipe does not exist.");
      }

      transaction.update(userDoc, {
        'favoriteRecipes': FieldValue.arrayUnion([recipe.id])
      });

      transaction.update(recipeDoc, {
        'favoritesCount': FieldValue.increment(1),
      });
    });
  }

  Future<void> removeFavorite(String userId, Recipe recipe) async {
    if (userId.isEmpty) {
      throw Exception("User ID cannot be empty.");
    }

    final userDoc = _userCollection.doc(userId);
    final recipeDoc = _recipeCollection.doc(recipe.id);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDoc);
      final recipeSnapshot = await transaction.get(recipeDoc);

      if (!userSnapshot.exists || !recipeSnapshot.exists) {
        throw Exception("User or recipe does not exist.");
      }

      transaction.update(userDoc, {
        'favoriteRecipes': FieldValue.arrayRemove([recipe.id])
      });

      transaction.update(recipeDoc, {
        'favoritesCount': FieldValue.increment(-1),
      });
    });
  }

  Future<void> removeFavoritesByRecipe(String recipeId) async {
    if (recipeId.isEmpty) {
      throw Exception("Recipe ID cannot be empty.");
    }

    final usersWithFavorites = await _userCollection
        .where('favoriteRecipes', arrayContains: recipeId)
        .get();

    for (var userDoc in usersWithFavorites.docs) {
      await _userCollection.doc(userDoc.id).update({
        'favoriteRecipes': FieldValue.arrayRemove([recipeId])
      });
    }
  }
}
