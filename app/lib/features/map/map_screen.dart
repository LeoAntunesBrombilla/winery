import 'package:flutter/material.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/nearby.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/features/map/winery_list.dart';
import 'package:winery_finder/features/map/winery_map.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Desenha o mapa com os pins de [selection] (US01).
typedef WineryMapBuilder = Widget Function(
  BuildContext context,
  NearbySelection selection,
  ValueChanged<Winery> onOpenDetail,
);

enum _MapView { map, list }

/// Aba Mapa: alterna entre o mapa (US01) e a lista por proximidade (US02).
/// As duas visões recebem o mesmo conjunto de vinícolas, na mesma ordem.
class MapScreen extends StatefulWidget {
  const MapScreen({
    this.repository = const EmptyWineryRepository(),
    this.location = const NoLocationProvider(),
    this.mapBuilder = _googleMap,
    super.key,
  });

  final WineryRepository repository;
  final LocationProvider location;
  final WineryMapBuilder mapBuilder;

  static Widget _googleMap(
    BuildContext context,
    NearbySelection selection,
    ValueChanged<Winery> onOpenDetail,
  ) {
    return WineryMap(selection: selection, onOpenDetail: onOpenDetail);
  }

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  _MapView _view = _MapView.map;
  late final Future<NearbySelection> _selection = _load();

  Future<NearbySelection> _load() async {
    final (List<Winery> wineries, Coordinates? user) = await (
      widget.repository.fetchAll(),
      widget.location.current(),
    ).wait;
    final List<Winery> sorted = WineryFilter.apply(
      wineries.map((Winery w) => w.withDistanceFrom(user)),
    );
    return Nearby.select(sorted, user);
  }

  void _openDetail(Winery winery) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => WineryDetailScreen(winery: winery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NearbySelection>(
      future: _selection,
      builder: (BuildContext context, AsyncSnapshot<NearbySelection> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final NearbySelection? selection = snapshot.data;
        if (selection == null || selection.wineries.isEmpty) {
          return const PlaceholderScreen(
            title: 'Mapa',
            message: 'Vinícolas próximas aparecerão aqui.',
            icon: Icons.map_outlined,
          );
        }
        final String? notice = Nearby.notice(selection.mode);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mapa'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SegmentedButton<_MapView>(
                  segments: const <ButtonSegment<_MapView>>[
                    ButtonSegment<_MapView>(
                      value: _MapView.map,
                      icon: Icon(Icons.map_outlined),
                      label: Text('Mapa'),
                    ),
                    ButtonSegment<_MapView>(
                      value: _MapView.list,
                      icon: Icon(Icons.list),
                      label: Text('Lista'),
                    ),
                  ],
                  selected: <_MapView>{_view},
                  onSelectionChanged: (Set<_MapView> value) =>
                      setState(() => _view = value.single),
                ),
              ),
            ),
          ),
          body: Column(
            children: <Widget>[
              if (notice != null) _Notice(notice),
              Expanded(
                child: switch (_view) {
                  _MapView.map => widget.mapBuilder(
                    context,
                    selection,
                    _openDetail,
                  ),
                  _MapView.list => WineryList(
                    wineries: selection.wineries,
                    onSelected: _openDetail,
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.location_off_outlined,
              color: colors.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colors.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
