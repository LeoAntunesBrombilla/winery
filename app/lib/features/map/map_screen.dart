import 'package:flutter/material.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/features/map/winery_list.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Desenha o mapa com os pins das vinícolas recebidas (US01).
typedef WineryMapBuilder = Widget Function(
  BuildContext context,
  List<Winery> wineries,
  ValueChanged<Winery> onSelected,
);

enum _MapView { map, list }

/// Aba Mapa: alterna entre o mapa e a lista por proximidade (US02). As duas
/// visões recebem o mesmo conjunto de vinícolas, na mesma ordem.
class MapScreen extends StatefulWidget {
  const MapScreen({
    this.repository = const EmptyWineryRepository(),
    this.location = const NoLocationProvider(),
    this.mapBuilder = _placeholderMap,
    super.key,
  });

  final WineryRepository repository;
  final LocationProvider location;
  final WineryMapBuilder mapBuilder;

  static Widget _placeholderMap(
    BuildContext context,
    List<Winery> wineries,
    ValueChanged<Winery> onSelected,
  ) {
    return Center(child: Text('${wineries.length} vinícolas no mapa'));
  }

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  _MapView _view = _MapView.map;
  late final Future<List<Winery>> _wineries = _load();

  Future<List<Winery>> _load() async {
    final (List<Winery> wineries, Coordinates? user) = await (
      widget.repository.fetchAll(),
      widget.location.current(),
    ).wait;
    return WineryFilter.apply(
      wineries.map((Winery w) => w.withDistanceFrom(user)),
    );
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
    return FutureBuilder<List<Winery>>(
      future: _wineries,
      builder: (BuildContext context, AsyncSnapshot<List<Winery>> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final List<Winery> wineries = snapshot.data ?? const <Winery>[];
        if (wineries.isEmpty) {
          return const PlaceholderScreen(
            title: 'Mapa',
            message: 'Vinícolas próximas aparecerão aqui.',
            icon: Icons.map_outlined,
          );
        }
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
          body: switch (_view) {
            _MapView.map => widget.mapBuilder(context, wineries, _openDetail),
            _MapView.list => WineryList(
              wineries: wineries,
              onSelected: _openDetail,
            ),
          },
        );
      },
    );
  }
}
