class RecipeModel {
  String id;
  String title;
  List<String> ingredients;
  List<String> steps;
  String imageUrl; // URL gambar (misalnya dari internet)
  String userId;   // ID pengguna untuk autentikasi

  RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.userId,
  });

  // Konversi dari Firestore ke objek RecipeModel
  factory RecipeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RecipeModel(
      id: id,
      title: data['title'],
      ingredients: List<String>.from(data['ingredients']),
      steps: List<String>.from(data['steps']),
      imageUrl: data['image_url'],
      userId: data['user_id'],
    );
  }

  // Konversi dari RecipeModel ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'image_url': imageUrl,
      'user_id': userId,
    };
  }
}
