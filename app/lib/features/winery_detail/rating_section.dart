import 'package:flutter/material.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/widgets/rating_stars.dart';

/// Nota da vinícola dada pela equipe (US15): número com uma casa decimal e
/// estrelas, ou "Sem nota".
class RatingSection extends StatelessWidget {
  const RatingSection({required this.rating, super.key});

  final double? rating;

  static const String sourceLabel = 'Nota da equipe Winery Finder';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? value = rating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              WineryFilter.formatRating(value),
              style: theme.textTheme.titleLarge,
            ),
            if (value != null) ...<Widget>[
              const SizedBox(width: 8),
              RatingStars(rating: value),
            ],
          ],
        ),
        Text(sourceLabel, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
