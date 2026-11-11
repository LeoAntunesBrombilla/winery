import 'package:flutter/material.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/features/map/winery_list.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Aba Favoritos (US12): as vinícolas favoritas com distância e nota, da
/// mais próxima para a mais longe. Tocar abre a ficha; o coração remove.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.catalog,
    required this.favorites,
    super.key,
  });

  final WineryCatalog catalog;
  final FavoritesStore favorites;

  static const String emptyMessage =
      'Você ainda não salvou nenhuma vinícola.\n'
      'Toque no coração na ficha ou na lista para favoritar.';

  /// Favoritas que ainda existem no catálogo, ordenadas por distância.
  List<Winery> _favoriteWineries() =>
      WineryFilter.apply(favorites.ids.map(catalog.byId).nonNulls);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[catalog, favorites]),
      builder: (BuildContext context, Widget? child) {
        if (favorites.ids.isEmpty) {
          return const PlaceholderScreen(
            title: 'Favoritos',
            message: emptyMessage,
            icon: Icons.favorite_outline,
          );
        }
        if (!catalog.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Favoritos')),
          body: WineryList(
            wineries: _favoriteWineries(),
            onSelected: (Winery winery) => openWineryDetail(context, winery),
          ),
        );
      },
    );
  }
}
