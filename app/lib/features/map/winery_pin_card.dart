import 'package:flutter/material.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/widgets/reservation_badge.dart';

/// Card exibido ao tocar num pin do mapa, com o selo de reserva (US07).
class WineryPinCard extends StatelessWidget {
  const WineryPinCard({required this.winery, this.onTap, super.key});

  final Winery winery;

  /// Abre a ficha da vinícola.
  final VoidCallback? onTap;

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
            ],
          ),
        ),
      ),
    );
  }
}
