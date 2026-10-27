import 'package:flutter/material.dart';

/// Tela de estado vazio usada enquanto as features reais não existem.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.message,
    required this.icon,
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(message, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
