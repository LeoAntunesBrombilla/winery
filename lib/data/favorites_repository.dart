import 'package:flutter/foundation.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery.dart';

/// Repositório reativo que armazena a lista de vinícolas favoritas de forma 100% independente por usuário.
class FavoritesRepository extends ChangeNotifier {
  FavoritesRepository._();
  static final FavoritesRepository instance = FavoritesRepository._();

  // Mapeamento independente de favoritos por ID de Usuário
  final Map<String, Set<String>> _userFavorites = <String, Set<String>>{};

  String get _currentUserId => AuthRepository.instance.currentUser?.id ?? 'guest';

  Set<String> get _activeFavorites => _userFavorites.putIfAbsent(_currentUserId, () => <String>{});

  Set<String> get favoriteIds => Set<String>.unmodifiable(_activeFavorites);

  bool isFavorite(String wineryId) => _activeFavorites.contains(wineryId);

  void toggleFavorite(String wineryId) {
    if (_activeFavorites.contains(wineryId)) {
      _activeFavorites.remove(wineryId);
    } else {
      _activeFavorites.add(wineryId);
    }
    notifyListeners();
  }

  List<Winery> getFavoriteWineries() {
    final ids = _activeFavorites;
    return WineryRepository.instance.wineries
        .where((w) => ids.contains(w.id))
        .toList();
  }
}
