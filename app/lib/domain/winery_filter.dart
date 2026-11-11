import 'package:winery_finder/domain/winery.dart';

/// Regras puras de busca e filtro da aba Mapa.
///
/// Sem dependência de Flutter nem de Firebase, para serem testadas
/// unitariamente.
abstract final class WineryFilter {
  /// Busca só vale a partir de [minQueryLength] caracteres (US03).
  static const int minQueryLength = 2;

  /// A busca está ativa para [query] (2+ caracteres sem contar espaços).
  static bool isSearching(String query) =>
      query.trim().length >= minQueryLength;

  /// Filtra por texto (nome ou cidade, ignorando maiúsculas e acentos, a
  /// partir de 2 caracteres) e por tipos de vinho. Um conjunto vazio de
  /// tipos significa "todos".
  /// O resultado vem ordenado da vinícola mais próxima para a mais distante;
  /// sem distância (usuário sem localização), por nome.
  static List<Winery> apply(
    Iterable<Winery> wineries, {
    String query = '',
    Set<WineType> types = const <WineType>{},
  }) {
    final String normalizedQuery = isSearching(query)
        ? normalize(query.trim())
        : '';

    final List<Winery> result = wineries.where((Winery w) {
      final bool matchesQuery =
          normalizedQuery.isEmpty ||
          normalize(w.name).contains(normalizedQuery) ||
          normalize(w.city).contains(normalizedQuery);
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
    return normalize(a.name).compareTo(normalize(b.name));
  }

  /// Minúsculas e sem acento: "Álvaro" e "alvaro" ficam iguais na busca e
  /// na ordenação.
  static String normalize(String name) {
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

  /// Nota com uma casa decimal: "4,7", ou "Sem nota".
  static String formatRating(double? rating) => rating == null
      ? 'Sem nota'
      : rating.toStringAsFixed(1).replaceAll('.', ',');
}
