import 'package:flutter/material.dart';
import 'package:winery_finder/app_scope.dart';
import 'package:winery_finder/features/favorites/favorites_screen.dart';
import 'package:winery_finder/features/map/map_screen.dart';
import 'package:winery_finder/features/recents/recents_screen.dart';

/// Casca da tela inicial com a navegação inferior entre as três abas
/// do protótipo: Mapa, Favoritos e Recentes.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          MapScreen(catalog: scope.catalog),
          FavoritesScreen(catalog: scope.catalog, favorites: scope.favorites),
          const RecentsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) => setState(() => _index = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: 'Favoritos',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Recentes'),
        ],
      ),
    );
  }
}
