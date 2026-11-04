import 'package:flutter/widgets.dart';
import 'package:winery_finder/data/favorites_store.dart';

/// Estado compartilhado entre as abas e as fichas abertas por cima delas.
class AppScope extends InheritedWidget {
  const AppScope({required this.favorites, required super.child, super.key});

  final FavoritesStore favorites;

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
      favorites != oldWidget.favorites;
}
