import 'package:flutter/material.dart';
import 'package:winery_finder/data/winery_catalog.dart';
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
    required this.catalog,
    this.mapBuilder = _googleMap,
    super.key,
  });

  final WineryCatalog catalog;
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
  final TextEditingController _search = TextEditingController();
  final Set<WineType> _types = <WineType>{};

  String get _query => _search.text;

  @override
  void initState() {
    super.initState();
    widget.catalog.ensureLoaded();
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

  bool get _hasFilters => _types.isNotEmpty || _query.isNotEmpty;

  /// Limpar filtros (US04): tira tipos e busca, restaurando a lista.
  void _clearFilters() {
    _search.clear();
    setState(_types.clear);
  }

  void _toggleType(WineType type, bool selected) {
    setState(() => selected ? _types.add(type) : _types.remove(type));
  }

  /// Conjunto exibido no mapa e na lista. A busca procura no catálogo
  /// inteiro (o usuário pode buscar uma cidade fora dos 50 km); sem busca,
  /// vale o recorte próximo.
  NearbySelection _visible(WineryCatalog catalog) {
    final bool searching = WineryFilter.isSearching(_query);
    final List<Winery> base = searching ? catalog.all : catalog.nearby.wineries;
    return NearbySelection(
      WineryFilter.apply(base, query: _query, types: _types),
      catalog.nearby.center,
      catalog.nearby.mode,
    );
  }

  void _openDetail(Winery winery) => openWineryDetail(context, winery);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.catalog,
      builder: (BuildContext context, Widget? child) {
        final WineryCatalog catalog = widget.catalog;
        if (!catalog.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (catalog.all.isEmpty) {
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
              _TypeFilters(
                selected: _types,
                onToggle: _toggleType,
                resultCount: selection.wineries.length,
                onClear: _hasFilters ? _clearFilters : null,
              ),
              if (notice != null) _Notice(notice),
              Expanded(
                child: selection.wineries.isEmpty
                    ? _NoResults(
                        query: _query.trim(),
                        types: _types,
                        onClear: _clearFilters,
                      )
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
  const _NoResults({
    required this.query,
    required this.types,
    required this.onClear,
  });

  final String query;
  final Set<WineType> types;
  final VoidCallback onClear;

  String get _message {
    final String typeNames = types.map((WineType t) => t.label).join(', ');
    if (WineryFilter.isSearching(query) && types.isNotEmpty) {
      return 'Nenhuma vinícola de $typeNames encontrada para "$query".';
    }
    if (types.isNotEmpty) {
      return 'Nenhuma vinícola de $typeNames por aqui.';
    }
    return 'Nenhuma vinícola encontrada para "$query".';
  }

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
              _message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onClear,
              child: Text(types.isEmpty ? 'Limpar busca' : 'Limpar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chips de tipo de vinho (US04): seleção múltipla, contagem de resultados
/// e Limpar filtros.
class _TypeFilters extends StatelessWidget {
  const _TypeFilters({
    required this.selected,
    required this.onToggle,
    required this.resultCount,
    required this.onClear,
  });

  final Set<WineType> selected;
  final void Function(WineType type, bool selected) onToggle;
  final int resultCount;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final WineType type in WineType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.label),
                      selected: selected.contains(type),
                      onSelected: (bool value) => onToggle(type, value),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  resultCount == 1 ? '1 vinícola' : '$resultCount vinícolas',
                ),
              ),
              if (onClear != null)
                TextButton(
                  onPressed: onClear,
                  child: const Text('Limpar filtros'),
                ),
            ],
          ),
        ],
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
