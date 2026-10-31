import 'package:flutter/material.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/features/auth/login_screen.dart';
import 'package:winery_finder/features/home/home_shell.dart';

/// Raiz do aplicativo: tema com a cor vinho (Burgundy), autenticação e tela inicial.
class WineryFinderApp extends StatelessWidget {
  const WineryFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winery Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF722F37), // Cor Vinho (Burgundy)
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: AnimatedBuilder(
        animation: AuthRepository.instance,
        builder: (context, child) {
          if (!AuthRepository.instance.isLoggedIn) {
            return const LoginScreen();
          }
          return const HomeShell();
        },
      ),
    );
  }
}
