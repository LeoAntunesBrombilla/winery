import 'package:flutter/material.dart';

/// Cinco estrelas para uma nota de 0 a 5, com meia estrela a partir de
/// 0,25 e estrela cheia a partir de 0,75 da unidade.
class RatingStars extends StatelessWidget {
  const RatingStars({required this.rating, this.size = 20, super.key});

  final double rating;
  final double size;

  /// Ícone de cada uma das cinco estrelas.
  static List<IconData> icons(double rating) => <IconData>[
    for (int i = 0; i < 5; i++)
      if (rating - i >= 0.75)
        Icons.star
      else if (rating - i >= 0.25)
        Icons.star_half
      else
        Icons.star_border,
  ];

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final IconData icon in icons(rating))
          Icon(icon, size: size, color: color),
      ],
    );
  }
}
