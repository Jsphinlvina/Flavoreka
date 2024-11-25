class RecipeModel {
  String id;
  String title;
  List<String> ingredients;
  List<String> steps;
  String imageUrl; 
  String userId; 

  RecipeModel({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.userId,
  });

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
