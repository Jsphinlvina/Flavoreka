import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavoreka/providers/recipe_provider.dart';
import 'package:flavoreka/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          // '/my-recipes': (context) => const MyRecipes(),
          // '/favorites': (context) => const FavoriteRecipes(),
          // '/account': (context) => const Account(),
        },
      ),
    );
  }
}
