import 'package:flutter/material.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';

/// Lista de vinícolas na ordem recebida (US02): nome, cidade, distância e
/// nota. Tocar num item chama [onSelected], que abre a ficha.
class WineryList extends StatelessWidget {
  const WineryList({
    required this.wineries,
    required this.onSelected,
    super.key,
  });

  final List<Winery> wineries;
  final ValueChanged<Winery> onSelected;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ListView.separated(
      itemCount: wineries.length,
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 1),
      itemBuilder: (BuildContext context, int index) {
        final Winery winery = wineries[index];
        final double? distanceKm = winery.distanceKm;
        return ListTile(
          title: Text(winery.name),
          subtitle: Text(
            distanceKm == null
                ? winery.city
                : '${winery.city} · ${WineryFilter.formatDistance(distanceKm)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.star, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 4),
              Text(WineryFilter.formatRating(winery.rating)),
            ],
          ),
          onTap: () => onSelected(winery),
        );
      },
    );
  }
}
