import 'package:flutter/foundation.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery.dart';

/// Repositório para gerenciar a lista de vinícolas salvas como favoritas.
class FavoritesRepository extends ChangeNotifier {
  FavoritesRepository._();
  static final FavoritesRepository instance = FavoritesRepository._();

  final Set<String> _favoriteIds = <String>{};

  Set<String> get favoriteIds => Set<String>.unmodifiable(_favoriteIds);

  bool isFavorite(String wineryId) => _favoriteIds.contains(wineryId);

  void toggleFavorite(String wineryId) {
    if (_favoriteIds.contains(wineryId)) {
      _favoriteIds.remove(wineryId);
    } else {
      _favoriteIds.add(wineryId);
    }
    notifyListeners();
  }

  List<Winery> getFavoriteWineries() {
    return WineryRepository.instance.wineries
        .where((w) => _favoriteIds.contains(w.id))
        .toList();
  }
}
