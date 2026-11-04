import 'package:flutter/material.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/route_link.dart';

/// Botão "Como chegar" (US10): abre a rota até [destination] no app de
/// mapas do aparelho ou, sem app, no navegador.
class RouteButton extends StatelessWidget {
  const RouteButton({
    required this.destination,
    this.openUrl = openExternally,
    super.key,
  });

  static const String label = 'Como chegar';

  final Coordinates destination;
  final UrlOpener openUrl;

  Future<void> _openRoute(BuildContext context) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool opened = await RouteLink.open(
      openUrl,
      destination,
      Theme.of(context).platform,
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir a rota.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _openRoute(context),
      icon: const Icon(Icons.directions),
      label: const Text(label),
    );
  }
}
