import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Konversi dari Firestore ke objek User Data
  factory UserData.fromFiresotre(Map<String, dynamic> data, String id) {
    return UserData(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      favoriteRecipes: (data['favoriteRecipes'] is List)
          ? List<String>.from(data['favoriteRecipes'])
          : [], // Default ke list kosong jika bukan List
      createRecipes: data['createRecipes'] ?? 0,
      createdAt: (data['createAt'] is Timestamp)
          ? (data['createAt'] as Timestamp).toDate() // Konversi Timestamp ke DateTime
          : DateTime.parse(data['createAt'] ?? DateTime.now().toIso8601String()), // Fallback jika String
    );
  }

  // Konversi dari UserData ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'favoriteRecipes': favoriteRecipes,
      'createRecipes': createRecipes,
      'createAt': createdAt.toIso8601String(),
      'username': username,
      'email': email,
    };
  }
}
