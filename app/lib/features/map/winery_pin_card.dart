import 'package:flutter/material.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/widgets/reservation_badge.dart';
import 'package:winery_finder/widgets/route_button.dart';

/// Card exibido ao tocar num pin do mapa, com o selo de reserva (US07).
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
              Text(winery.city, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              ReservationBadge(requiresReservation: winery.requiresReservation),
              const SizedBox(height: 8),
              RouteButton(destination: winery.coordinates, openUrl: openUrl),
            ],
          ),
        ),
      ),
    );
  }
}
