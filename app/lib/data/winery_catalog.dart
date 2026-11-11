import 'package:flutter/foundation.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/nearby.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';

/// Vinícolas carregadas uma vez e compartilhadas entre as abas: Mapa,
/// Favoritos e Recentes mostram os mesmos dados, com a mesma distância.
class WineryCatalog extends ChangeNotifier {
  WineryCatalog({
    this.repository = const EmptyWineryRepository(),
    this.location = const NoLocationProvider(),
  });

  final WineryRepository repository;
  final LocationProvider location;

  Future<void>? _loading;
  bool _loaded = false;
  List<Winery> _all = const <Winery>[];
  Coordinates? _user;
  NearbySelection _nearby = const NearbySelection(
    <Winery>[],
    bentoGoncalves,
    NearbyMode.noLocation,
  );

  bool get isLoaded => _loaded;

  /// Todas as vinícolas, com distância, da mais próxima para a mais longe
  /// (ou por nome, sem localização).
  List<Winery> get all => _all;

  Coordinates? get user => _user;

  /// Recorte inicial do mapa e da lista (US01).
  NearbySelection get nearby => _nearby;

  /// Carrega na primeira chamada; as seguintes reaproveitam o resultado.
  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    final (List<Winery> wineries, Coordinates? user) = await (
      repository.fetchAll(),
      location.current(),
    ).wait;
    _user = user;
    _all = WineryFilter.apply(
      wineries.map((Winery w) => w.withDistanceFrom(user)),
    );
    _nearby = Nearby.select(_all, user);
    _loaded = true;
    notifyListeners();
  }

  Winery? byId(String id) {
    for (final Winery winery in _all) {
      if (winery.id == id) {
        return winery;
      }
    }
    return null;
  }
}
