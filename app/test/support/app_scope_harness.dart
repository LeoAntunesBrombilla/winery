import 'package:flutter/material.dart';
import 'package:winery_finder/app_scope.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';

/// MaterialApp com o [AppScope] do app, para testar telas que usam
/// favoritos.
Widget withAppScope(
  Widget home, {
  FavoritesStore? favorites,
  WineryCatalog? catalog,
}) {
  return AppScope(
    catalog: catalog ?? WineryCatalog(),
    favorites: favorites ?? FavoritesStore(),
    child: MaterialApp(home: home),
  );
}
