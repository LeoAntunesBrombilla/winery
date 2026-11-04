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

/// Catálogo carregado: todas as vinícolas (para a busca) e o recorte
/// próximo ao usuário (para a abertura do mapa).
class _Catalog {
  const _Catalog(this.all, this.nearby);

  final List<Winery> all;
  final NearbySelection nearby;
}

class _MapScreenState extends State<MapScreen> {
  _MapView _view = _MapView.map;
  late final Future<_Catalog> _catalog = _load();
  final TextEditingController _search = TextEditingController();

  String get _query => _search.text;

  Future<_Catalog> _load() async {
    final (List<Winery> wineries, Coordinates? user) = await (
      widget.repository.fetchAll(),
      widget.location.current(),
    ).wait;
    final List<Winery> sorted = WineryFilter.apply(
      wineries.map((Winery w) => w.withDistanceFrom(user)),
    );
    return _Catalog(sorted, Nearby.select(sorted, user));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  /// Conjunto exibido no mapa e na lista. A busca procura no catálogo
  /// inteiro (o usuário pode buscar uma cidade fora dos 50 km); sem busca,
  /// vale o recorte próximo.
  NearbySelection _visible(_Catalog catalog) {
    final bool searching = WineryFilter.isSearching(_query);
    final List<Winery> base = searching ? catalog.all : catalog.nearby.wineries;
    return NearbySelection(
      WineryFilter.apply(base, query: _query),
      catalog.nearby.center,
      catalog.nearby.mode,
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
    return FutureBuilder<_Catalog>(
      future: _catalog,
      builder: (BuildContext context, AsyncSnapshot<_Catalog> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final _Catalog? catalog = snapshot.data;
        if (catalog == null || catalog.all.isEmpty) {
          return const PlaceholderScreen(
            title: 'Mapa',
            message: 'Vinícolas próximas aparecerão aqui.',
            icon: Icons.map_outlined,
          );
        }
        final NearbySelection selection = _visible(catalog);
        final String? notice = WineryFilter.isSearching(_query)
            ? null
            : Nearby.notice(selection.mode);
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
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  controller: _search,
                  onChanged: (String _) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Buscar vinícola ou cidade',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.close),
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              if (notice != null) _Notice(notice),
              Expanded(
                child: selection.wineries.isEmpty
                    ? _NoResults(query: _query.trim(), onClear: _clearSearch)
                    : switch (_view) {
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

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.onClear});

  final String query;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.search_off, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'Nenhuma vinícola encontrada para "$query".',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Limpar busca'),
            ),
          ],
        ),
      ),
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
