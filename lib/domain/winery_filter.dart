import 'package:winery_finder/domain/winery.dart';

/// Regras puras de busca e filtro da aba Mapa.
///
/// Sem dependência de Flutter nem de Firebase, para serem testadas
/// unitariamente.
abstract final class WineryFilter {
  /// Filtra por texto (nome ou cidade, sem diferenciar maiúsculas) e por
  /// tipos de vinho. Um conjunto vazio de tipos significa "todos".
  /// O resultado vem ordenado da vinícola mais próxima para a mais distante.
  static List<Winery> apply(
    Iterable<Winery> wineries, {
    String query = '',
    Set<WineType> types = const <WineType>{},
  }) {
    final String normalizedQuery = query.trim().toLowerCase();

    final List<Winery> result = wineries.where((Winery w) {
      final bool matchesQuery =
          normalizedQuery.isEmpty ||
          w.name.toLowerCase().contains(normalizedQuery) ||
          w.city.toLowerCase().contains(normalizedQuery);
      final bool matchesType = types.isEmpty || w.wineTypes.any(types.contains);
      return matchesQuery && matchesType;
    }).toList();

    result.sort((Winery a, Winery b) => a.distanceKm.compareTo(b.distanceKm));
    return result;
  }

  /// Formata a distância para exibição: metros abaixo de 1 km, senão
  /// quilômetros com uma casa decimal.
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }
}
