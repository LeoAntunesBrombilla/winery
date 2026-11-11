import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/weekly_hours.dart';

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
    required this.address,
    required this.coordinates,
    required this.wineTypes,
    required this.hours,
    required this.rating,
    required this.tastingPriceCents,
    required this.requiresReservation,
    this.phone,
    this.website,
    this.photoUrls = const <String>[],
    this.distanceKm,
  });

  final String id;
  final String name;
  final String city;
  final String address;
  final Coordinates coordinates;
  final Set<WineType> wineTypes;

  /// Horário de funcionamento por dia da semana.
  final WeeklyHours hours;

  /// Distância até o usuário, em quilômetros; `null` sem localização.
  final double? distanceKm;

  /// Nota de 0 a 5 dada pela equipe; `null` = sem nota.
  final double? rating;

  /// Preço da degustação por pessoa, em centavos. Zero = gratuita.
  final int tastingPriceCents;

  /// A visita exige reserva antecipada.
  final bool requiresReservation;
  final String? phone;
  final String? website;

  /// URLs das fotos no Firebase Storage, na ordem de exibição.
  final List<String> photoUrls;

  /// Cópia com a distância até [user] (ou sem distância, se `null`).
  Winery withDistanceFrom(Coordinates? user) {
    return Winery(
      id: id,
      name: name,
      city: city,
      address: address,
      coordinates: coordinates,
      wineTypes: wineTypes,
      hours: hours,
      rating: rating,
      tastingPriceCents: tastingPriceCents,
      requiresReservation: requiresReservation,
      phone: phone,
      website: website,
      photoUrls: photoUrls,
      distanceKm: user?.distanceKmTo(coordinates),
    );
  }
}
