import 'package:flutter/material.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/tasting_price.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/winery_detail/contact_section.dart';
import 'package:winery_finder/features/winery_detail/opening_hours_section.dart';
import 'package:winery_finder/features/winery_detail/rating_section.dart';
import 'package:winery_finder/widgets/favorite_button.dart';
import 'package:winery_finder/widgets/reservation_badge.dart';
import 'package:winery_finder/widgets/route_button.dart';

/// Abre a ficha de [winery] por cima da tela atual.
Future<void> openWineryDetail(BuildContext context, Winery winery) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => WineryDetailScreen(winery: winery),
    ),
  );
}

/// Ficha da vinícola, aberta a partir do pin e da lista. As informações de
/// decisão (endereço, reserva, preço) ficam no topo, visíveis sem rolar.
class WineryDetailScreen extends StatelessWidget {
  const WineryDetailScreen({
    required this.winery,
    this.now = DateTime.now,
    this.openUrl = openExternally,
    super.key,
  });

  final Winery winery;

  /// Relógio usado para destacar o dia de hoje; injetável nos testes.
  final DateTime Function() now;

  /// Abre discador, navegador e app de mapas; injetável nos testes.
  final UrlOpener openUrl;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(winery.name),
        actions: <Widget>[FavoriteButton(winery: winery)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(winery.city, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          RatingSection(rating: winery.rating),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          RouteButton(destination: winery.coordinates, openUrl: openUrl),
          const SizedBox(height: 8),
          ContactSection(
            phone: winery.phone,
            website: winery.website,
            openUrl: openUrl,
          ),
          const Divider(height: 32),
          OpeningHoursSection(hours: winery.hours, today: now().weekday),
        ],
      ),
    );
  }
}
