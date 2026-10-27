import 'package:flutter/material.dart';
import 'package:winery_finder/features/home/home_shell.dart';

/// Raiz do aplicativo: tema e tela inicial.
class WineryFinderApp extends StatelessWidget {
  const WineryFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winery Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9184D9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}
