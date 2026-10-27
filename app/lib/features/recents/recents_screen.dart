import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Aba Recentes: histórico das vinícolas já visitadas no app.
class RecentsScreen extends StatelessWidget {
  const RecentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Recentes',
      message: 'Nenhuma vinícola visitada ainda.',
      icon: Icons.history,
    );
  }
}
