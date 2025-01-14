import 'package:firebase_core/firebase_core.dart';
import 'package:flavoreka/providers/user_data_provider.dart';
import 'package:flavoreka/screens/favorite_recipes_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavoreka/providers/recipe_provider.dart';
import 'package:flavoreka/providers/auth_provider.dart';
import 'package:flavoreka/screens/home_screen.dart';
import 'package:flavoreka/screens/my_recipes_screen.dart';
import 'package:flavoreka/screens/login_screen.dart';
import 'package:flavoreka/screens/account_screen.dart';
import 'package:flavoreka/providers/favorite_provider.dart';
import 'controllers/favorite_controller.dart';
import 'utils/auth_service.dart';
import 'utils/auth_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, RecipeProvider>(
          create: (context) =>
              RecipeProvider(Provider.of<AuthService>(context, listen: false)),
          update: (_, authService, previous) => RecipeProvider(authService),
        ),
        ChangeNotifierProxyProvider<AuthService, FavoriteProvider>(
          create: (context) => FavoriteProvider(
            FavoriteController(),
            Provider.of<AuthService>(context, listen: false).currentUser?.uid ??
                '',
          ),
          update: (_, authService, previous) => FavoriteProvider(
            FavoriteController(),
            authService.currentUser?.uid ?? '',
          ),
        ),
        ChangeNotifierProxyProvider<AuthService, UserDataProvider>(
          create: (context) => UserDataProvider(
              Provider.of<AuthService>(context, listen: false)),
          update: (_, authService, previous) => UserDataProvider(authService),
        ),
        ChangeNotifierProvider(create: (_) => MyAuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/my-recipes': (context) => const AuthGuard(
                child: MyRecipesScreen(),
              ),
          '/favorites': (context) => const AuthGuard(
                child: FavoriteRecipesScreen(),
              ),
          '/account': (context) => const AuthGuard(
                child: AccountScreen(),
              ),
        },
      ),
    );
  }
}
