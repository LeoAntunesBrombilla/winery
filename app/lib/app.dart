import 'package:flutter/material.dart';
import 'package:winery_finder/app_scope.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/features/home/home_shell.dart';

/// Raiz do aplicativo: tema e tela inicial.
class WineryFinderApp extends StatefulWidget {
  const WineryFinderApp({
    this.repository = const EmptyWineryRepository(),
    this.location = const NoLocationProvider(),
    this.favorites,
    super.key,
  });

  final WineryRepository repository;
  final LocationProvider location;

  /// Favoritos salvos no aparelho; sem valor, ficam só em memória.
  final FavoritesStore? favorites;

  @override
  State<WineryFinderApp> createState() => _WineryFinderAppState();
}

class _WineryFinderAppState extends State<WineryFinderApp> {
  late final FavoritesStore _favorites = widget.favorites ?? FavoritesStore();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      favorites: _favorites,
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
        home: HomeShell(
          repository: widget.repository,
          location: widget.location,
        ),
      ),
    );
  }
}
