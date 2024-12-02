class Recipe {
  String id;
  String title;
  List<String> ingredients;
  List<String> steps;
  String imageUrl;
  String userId;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.userId,
  });

  factory Recipe.fromFirestore(Map<String, dynamic> data, String id) {
    return Recipe(
      id: id,
      title: data['title'],
      ingredients: List<String>.from(data['ingredients']),
      steps: List<String>.from(data['steps']),
      imageUrl: data['image_url'],
      userId: data['user_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'image_url': imageUrl,
      'user_name': userId,
    };
  }
}
