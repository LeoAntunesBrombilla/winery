import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ids das vinícolas favoritas (US11), guardados no aparelho: persistem
/// depois de fechar o app e funcionam sem internet.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore({
    Iterable<String> initial = const <String>[],
    Future<void> Function(List<String> ids)? save,
  }) : _ids = LinkedHashSet<String>.of(initial),
       _save = save ?? _keepInMemory;

  /// Lê os favoritos salvos e grava cada mudança no `shared_preferences`.
  factory FavoritesStore.fromPreferences(SharedPreferences preferences) {
    return FavoritesStore(
      initial: preferences.getStringList(preferencesKey) ?? const <String>[],
      save: (List<String> ids) =>
          preferences.setStringList(preferencesKey, ids),
    );
  }

  static const String preferencesKey = 'favorites';

  final LinkedHashSet<String> _ids;
  final Future<void> Function(List<String> ids) _save;

  static Future<void> _keepInMemory(List<String> ids) async {}

  /// Na ordem em que foram favoritadas.
  List<String> get ids => List<String>.unmodifiable(_ids);

  bool contains(String id) => _ids.contains(id);

  /// Alterna o favorito e devolve o novo estado (`true` = favorita).
  Future<bool> toggle(String id) async {
    final bool favorite = !_ids.remove(id);
    if (favorite) {
      _ids.add(id);
    }
    notifyListeners();
    await _save(ids);
    return favorite;
  }

  Future<void> remove(String id) async {
    if (_ids.remove(id)) {
      notifyListeners();
      await _save(ids);
    }
  }
}
