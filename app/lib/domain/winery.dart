/// Tipos de vinho usados nos filtros da aba Mapa.
enum WineType {
  tinto('Tinto'),
  branco('Branco'),
  espumante('Espumante'),
  rose('Rosé');

  const WineType(this.label);

  /// Nome exibido na interface.
  final String label;
}

/// Vinícola cadastrada pela equipe (futuro documento do Firestore).
class Winery {
  const Winery({
    required this.id,
    required this.name,
    required this.city,
    required this.wineTypes,
    required this.distanceKm,
    required this.rating,
    required this.tastingPriceCents,
  });

  final String id;
  final String name;
  final String city;
  final Set<WineType> wineTypes;

  /// Distância até o usuário, em quilômetros.
  final double distanceKm;

  /// Avaliação média de 0 a 5.
  final double rating;

  /// Preço da degustação por pessoa, em centavos. Zero = gratuita.
  final int tastingPriceCents;
}
