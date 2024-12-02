class Recipe {
  String id;
  String title;
  String imageUrl;
  List<String> ingredients;
  List<String> steps;
  String userId;
  DateTime createdAt;
  int favoritesCount;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.userId,
    required this.createdAt,
    required this.favoritesCount,
  });

  // Konversi dari Firestore ke objek Recipe
  factory Recipe.fromFirestore(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      userId: data['userId'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      favoritesCount: data['favoritesCount'] ?? 0,
    );
  }

  // Konversi dari Recipe ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'favoritesCount': favoritesCount,
    };
  }
}
