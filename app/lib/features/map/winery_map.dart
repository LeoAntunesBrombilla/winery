import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/nearby.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/map/winery_pin_card.dart';

/// O que o mapa nativo precisa desenhar.
class MapViewConfig {
  const MapViewConfig({
    required this.center,
    required this.zoom,
    required this.pins,
    required this.showMyLocation,
    required this.onPinTap,
    required this.onMapTap,
  });

  final Coordinates center;
  final double zoom;
  final List<Winery> pins;
  final bool showMyLocation;
  final ValueChanged<Winery> onPinTap;
  final VoidCallback onMapTap;
}

/// Desenha o mapa nativo. Injetável porque os testes de widget não têm a
/// view do Google Maps.
typedef MapViewBuilder = Widget Function(MapViewConfig config);

/// Mapa com um pin por vinícola (US01). Tocar num pin mostra o card com
/// nome, distância, nota, reserva, rota e atalho para a ficha.
class WineryMap extends StatefulWidget {
  const WineryMap({
    required this.selection,
    required this.onOpenDetail,
    this.openUrl = openExternally,
    this.mapView = googleMapView,
    super.key,
  });

  final NearbySelection selection;
  final ValueChanged<Winery> onOpenDetail;
  final UrlOpener openUrl;
  final MapViewBuilder mapView;

  static Widget googleMapView(MapViewConfig config) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(config.center.latitude, config.center.longitude),
        zoom: config.zoom,
      ),
      myLocationEnabled: config.showMyLocation,
      myLocationButtonEnabled: config.showMyLocation,
      onTap: (LatLng _) => config.onMapTap(),
      markers: <Marker>{
        for (final Winery winery in config.pins)
          Marker(
            markerId: MarkerId(winery.id),
            position: LatLng(
              winery.coordinates.latitude,
              winery.coordinates.longitude,
            ),
            onTap: () => config.onPinTap(winery),
          ),
      },
    );
  }

  @override
  State<WineryMap> createState() => _WineryMapState();
}

class _WineryMapState extends State<WineryMap> {
  Winery? _selected;

  @override
  void didUpdateWidget(WineryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Some com o card se a vinícola saiu do conjunto (busca/filtro).
    if (_selected != null &&
        !widget.selection.wineries.any((Winery w) => w.id == _selected!.id)) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final NearbySelection selection = widget.selection;
    final Winery? selected = _selected;
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: widget.mapView(
            MapViewConfig(
              center: selection.center,
              zoom: selection.mode == NearbyMode.nearUser ? 11 : 10,
              pins: selection.wineries,
              showMyLocation: selection.mode != NearbyMode.noLocation,
              onPinTap: (Winery winery) => setState(() => _selected = winery),
              onMapTap: () => setState(() => _selected = null),
            ),
          ),
        ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: WineryPinCard(
              winery: selected,
              onTap: () => widget.onOpenDetail(selected),
              openUrl: widget.openUrl,
            ),
          ),
      ],
    );
  }
}
