import 'package:flutter/widgets.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/data/recents_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';

/// Estado compartilhado entre as abas e as fichas abertas por cima delas.
class AppScope extends InheritedWidget {
  const AppScope({
    required this.catalog,
    required this.favorites,
    required this.recents,
    required super.child,
    super.key,
  });

  final WineryCatalog catalog;
  final FavoritesStore favorites;
  final RecentsStore recents;

  /// `null` fora do app (ex.: testes de um widget isolado).
  static AppScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();

  static AppScope of(BuildContext context) {
    final AppScope? scope = maybeOf(context);
    assert(scope != null, 'AppScope ausente acima de $context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      catalog != oldWidget.catalog ||
      favorites != oldWidget.favorites ||
      recents != oldWidget.recents;
}
