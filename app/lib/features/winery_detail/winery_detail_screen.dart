import 'package:flutter/material.dart';
import 'package:winery_finder/domain/tasting_price.dart';
import 'package:winery_finder/domain/winery.dart';

/// Ficha da vinícola. O cabeçalho fica fora da rolagem para que as
/// informações de decisão (preço, reserva) apareçam sem rolar a tela.
class WineryDetailScreen extends StatelessWidget {
  const WineryDetailScreen({required this.winery, super.key});

  final Winery winery;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(winery.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(winery.city, style: theme.textTheme.titleMedium),
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
          ],
        ),
      ),
    );
  }
}
