import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winery_finder/features/spike/route_link.dart';

/// Abre uma URL fora do app; devolve `false` se nenhum app puder abri-la.
typedef UrlOpener = Future<bool> Function(Uri uri);

/// Desenha o mapa centrado no pin. Injetável para os testes de widget, que
/// não têm a view nativa do Google Maps.
typedef SpikeMapBuilder = Widget Function(LatLng pin, String label);

/// Spike do TT01: mapa com um pin e botão que abre a rota no app de
/// navegação. Valida a chave do Maps e o deep link nos dois sistemas.
class MapSpikeScreen extends StatelessWidget {
  const MapSpikeScreen({
    this.openUrl = _openExternally,
    this.mapBuilder = _googleMap,
    super.key,
  });

  /// Casa Valduga, no Vale dos Vinhedos.
  static const LatLng pin = LatLng(-29.1756, -51.5577);
  static const String pinLabel = 'Casa Valduga';

  final UrlOpener openUrl;
  final SpikeMapBuilder mapBuilder;

  static Future<bool> _openExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  static Widget _googleMap(LatLng pin, String label) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: pin, zoom: 14),
      markers: <Marker>{
        Marker(
          markerId: const MarkerId('spike'),
          position: pin,
          infoWindow: InfoWindow(title: label),
        ),
      },
    );
  }

  Future<void> _openRoute(BuildContext context) async {
    final Uri uri = RouteLink.directions(
      latitude: pin.latitude,
      longitude: pin.longitude,
      platform: Theme.of(context).platform,
    );
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (!await openUrl(uri)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o app de navegação.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spike: mapa e rota')),
      body: mapBuilder(pin, pinLabel),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRoute(context),
        icon: const Icon(Icons.directions),
        label: const Text('Traçar rota'),
      ),
    );
  }
}
