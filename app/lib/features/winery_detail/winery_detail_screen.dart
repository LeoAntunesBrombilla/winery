import 'package:flutter/material.dart';
import 'package:winery_finder/domain/tasting_price.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/winery_detail/opening_hours_section.dart';
import 'package:winery_finder/widgets/reservation_badge.dart';

/// Ficha da vinícola, aberta a partir do pin e da lista. As informações de
/// decisão (endereço, reserva, preço) ficam no topo, visíveis sem rolar.
class WineryDetailScreen extends StatelessWidget {
  const WineryDetailScreen({
    required this.winery,
    this.now = DateTime.now,
    super.key,
  });

  final Winery winery;

  /// Relógio usado para destacar o dia de hoje; injetável nos testes.
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(winery.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(winery.city, style: theme.textTheme.titleMedium),
          if (winery.address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: <Widget>[
                  Icon(Icons.place_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(winery.address)),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ReservationBadge(
              requiresReservation: winery.requiresReservation,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(Icons.wine_bar, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                TastingPrice.label(winery.tastingPriceCents),
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const Divider(height: 32),
          OpeningHoursSection(hours: winery.hours, today: now().weekday),
        ],
      ),
    );
  }
}
