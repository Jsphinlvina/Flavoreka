class UserData {
  String id;
  String name;
  String profilePicture;
  List<String> favoriteRecipes;
  int createRecipes;
  String username;
  String email;
  DateTime createdAt;

  UserData({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.favoriteRecipes,
    required this.createRecipes,
    required this.createdAt,
    required this.username,
    required this.email,
  });

  // Konversi dari Firebase ke objek User Data
  factory UserData.fromFiresotre(Map<String, dynamic> data, String id) {
    return UserData(
      id: id,
      name: data['name'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      favoriteRecipes: List<String>.from(data['favoriteRecipes'] ?? []),
      createRecipes: data['createRecipes'] ?? 0,
      createdAt:
          DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      username: data['username'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // Konversi dari User data ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'favoriteRecipes': favoriteRecipes,
      'createRecipes': createRecipes,
      'createAt' : createdAt.toIso8601String(),
      'username' : username,
      'email' : email
    };
  }
}
