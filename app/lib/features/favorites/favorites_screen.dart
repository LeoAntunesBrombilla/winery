import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Aba Favoritos: vinícolas salvas pelo usuário para visitar depois.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Favoritos',
      message: 'Você ainda não salvou nenhuma vinícola.',
      icon: Icons.favorite_outline,
    );
  }
}
