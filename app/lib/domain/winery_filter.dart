import 'package:winery_finder/domain/winery.dart';

/// Regras puras de busca e filtro da aba Mapa.
///
/// Sem dependência de Flutter nem de Firebase, para serem testadas
/// unitariamente.
abstract final class WineryFilter {
  /// Filtra por texto (nome ou cidade, sem diferenciar maiúsculas) e por
  /// tipos de vinho. Um conjunto vazio de tipos significa "todos".
  /// O resultado vem ordenado da vinícola mais próxima para a mais distante;
  /// sem distância (usuário sem localização), por nome.
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

    result.sort(_byDistanceThenName);
    return result;
  }

  static int _byDistanceThenName(Winery a, Winery b) {
    final double? da = a.distanceKm;
    final double? db = b.distanceKm;
    if (da != null && db != null && da != db) {
      return da.compareTo(db);
    }
    if (da != null && db == null) {
      return -1;
    }
    if (da == null && db != null) {
      return 1;
    }
    return _sortKey(a.name).compareTo(_sortKey(b.name));
  }

  /// Minúsculas e sem acento, para "Álvaro" ficar junto de "Alvaro".
  static String _sortKey(String name) {
    const String accented = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const String plain = 'aaaaaeeeeiiiiooooouuuuc';
    final StringBuffer key = StringBuffer();
    for (final int rune in name.toLowerCase().runes) {
      final String char = String.fromCharCode(rune);
      final int index = accented.indexOf(char);
      key.write(index < 0 ? char : plain[index]);
    }
    return key.toString();
  }

  /// Formata a distância em quilômetros com uma casa decimal e vírgula,
  /// como pede a US02: "12,4 km", "0,7 km".
  static String formatDistance(double distanceKm) =>
      '${distanceKm.toStringAsFixed(1).replaceAll('.', ',')} km';

  /// Nota com uma casa decimal: "4,7".
  static String formatRating(double rating) =>
      rating.toStringAsFixed(1).replaceAll('.', ',');
}
