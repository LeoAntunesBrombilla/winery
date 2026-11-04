import 'package:flutter/material.dart';
import 'package:winery_finder/app_scope.dart';
import 'package:winery_finder/data/connectivity_monitor.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/recents_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/features/home/home_shell.dart';

/// Raiz do aplicativo: tema e tela inicial.
class WineryFinderApp extends StatefulWidget {
  const WineryFinderApp({
    this.repository = const EmptyWineryRepository(),
    this.location = const NoLocationProvider(),
    this.favorites,
    this.recents,
    this.connectivity = const AlwaysOnline(),
    super.key,
  });

  final WineryRepository repository;
  final LocationProvider location;

  /// Favoritos salvos no aparelho; sem valor, ficam só em memória.
  final FavoritesStore? favorites;

  /// Histórico salvo no aparelho; sem valor, fica só em memória.
  final RecentsStore? recents;

  /// Estado da rede para o aviso de offline.
  final ConnectivityMonitor connectivity;

  @override
  State<WineryFinderApp> createState() => _WineryFinderAppState();
}

class _WineryFinderAppState extends State<WineryFinderApp> {
  late final FavoritesStore _favorites = widget.favorites ?? FavoritesStore();
  late final RecentsStore _recents = widget.recents ?? RecentsStore();
  late final WineryCatalog _catalog = WineryCatalog(
    repository: widget.repository,
    location: widget.location,
  )..ensureLoaded();

  @override
  void dispose() {
    _catalog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      catalog: _catalog,
      favorites: _favorites,
      recents: _recents,
      child: MaterialApp(
        title: 'Winery Finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9184D9),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: HomeShell(connectivity: widget.connectivity),
      ),
    );
  }
}
