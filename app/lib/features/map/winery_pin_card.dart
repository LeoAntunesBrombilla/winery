import 'package:flutter/material.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/widgets/reservation_badge.dart';
import 'package:winery_finder/widgets/route_button.dart';

/// Card exibido ao tocar num pin do mapa (US01): nome, distância, nota,
/// selo de reserva (US07), rota (US10) e atalho para a ficha.
class WineryPinCard extends StatelessWidget {
  const WineryPinCard({
    required this.winery,
    this.onTap,
    this.openUrl = openExternally,
    super.key,
  });

  final Winery winery;

  /// Abre a ficha da vinícola.
  final VoidCallback? onTap;

  /// Usado pelo botão Como chegar; injetável nos testes.
  final UrlOpener openUrl;

  /// "Bento Gonçalves · 12,4 km · ★ 4,7".
  static String summary(Winery winery) {
    final double? distanceKm = winery.distanceKm;
    return <String>[
      winery.city,
      if (distanceKm != null) WineryFilter.formatDistance(distanceKm),
      '★ ${WineryFilter.formatRating(winery.rating)}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(winery.name, style: theme.textTheme.titleMedium),
              Text(summary(winery), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              ReservationBadge(requiresReservation: winery.requiresReservation),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  RouteButton(
                    destination: winery.coordinates,
                    openUrl: openUrl,
                  ),
                  TextButton(onPressed: onTap, child: const Text('Ver ficha')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
