import 'package:winery_finder/domain/coordinates.dart';

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

/// Vinícola cadastrada pela equipe (documento de `wineries/{id}`).
class Winery {
  const Winery({
    required this.id,
    required this.name,
    required this.city,
    required this.coordinates,
    required this.wineTypes,
    required this.rating,
    required this.tastingPriceCents,
    required this.requiresReservation,
    this.distanceKm,
  });

  final String id;
  final String name;
  final String city;
  final Coordinates coordinates;
  final Set<WineType> wineTypes;

  /// Distância até o usuário, em quilômetros; `null` sem localização.
  final double? distanceKm;

  /// Avaliação média de 0 a 5.
  final double rating;

  /// Preço da degustação por pessoa, em centavos. Zero = gratuita.
  final int tastingPriceCents;

  /// A visita exige reserva antecipada.
  final bool requiresReservation;

  /// Cópia com a distância até [user] (ou sem distância, se `null`).
  Winery withDistanceFrom(Coordinates? user) {
    return Winery(
      id: id,
      name: name,
      city: city,
      coordinates: coordinates,
      wineTypes: wineTypes,
      rating: rating,
      tastingPriceCents: tastingPriceCents,
      requiresReservation: requiresReservation,
      distanceKm: user?.distanceKmTo(coordinates),
    );
  }
}
