import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';

/// Centro do mapa quando não há localização utilizável (US01).
const Coordinates bentoGoncalves = Coordinates(-29.1667, -51.5167);

/// De onde vem o conjunto de vinícolas exibido no mapa e na lista.
enum NearbyMode {
  /// Vinícolas a até [Nearby.radiusKm] do usuário, centrado nele.
  nearUser,

  /// Sem permissão ou sem GPS: todas, centrado em Bento Gonçalves.
  noLocation,

  /// Usuário longe da Serra: todas, centrado em Bento Gonçalves.
  noneNearby,
}

class NearbySelection {
  const NearbySelection(this.wineries, this.center, this.mode);

  final List<Winery> wineries;
  final Coordinates center;
  final NearbyMode mode;
}

/// Escolhe as vinícolas e o centro do mapa a partir da localização (US01).
abstract final class Nearby {
  static const double radiusKm = 50;

  /// [wineries] já devem ter a distância até [user]
  /// ([Winery.withDistanceFrom]). A ordem é preservada.
  static NearbySelection select(List<Winery> wineries, Coordinates? user) {
    if (user == null) {
      return NearbySelection(wineries, bentoGoncalves, NearbyMode.noLocation);
    }
    final List<Winery> near = wineries
        .where((Winery w) => (w.distanceKm ?? double.infinity) <= radiusKm)
        .toList();
    if (near.isEmpty) {
      return NearbySelection(wineries, bentoGoncalves, NearbyMode.noneNearby);
    }
    return NearbySelection(near, user, NearbyMode.nearUser);
  }

  /// Aviso exibido acima do mapa e da lista, ou `null` quando o conjunto é
  /// o das vinícolas próximas.
  static String? notice(NearbyMode mode) => switch (mode) {
    NearbyMode.nearUser => null,
    NearbyMode.noLocation =>
      'Sem acesso à sua localização. Mostrando Bento Gonçalves — '
          'busque pela sua cidade.',
    NearbyMode.noneNearby =>
      'Nenhuma vinícola a até 50 km de você. Mostrando a Serra Gaúcha — '
          'busque pela cidade que vai visitar.',
  };
}
