import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';

/// Vinícola de teste com valores padrão; sobrescreva só o que o teste usa.
Winery testWinery({
  String id = 'casa-valduga',
  String name = 'Casa Valduga',
  String city = 'Bento Gonçalves',
  Set<WineType> wineTypes = const <WineType>{WineType.tinto},
  Coordinates coordinates = const Coordinates(-29.1756, -51.5577),
  double? distanceKm,
  double rating = 4.7,
  int tastingPriceCents = 8500,
  bool requiresReservation = false,
}) {
  return Winery(
    id: id,
    name: name,
    city: city,
    coordinates: coordinates,
    wineTypes: wineTypes,
    distanceKm: distanceKm,
    rating: rating,
    tastingPriceCents: tastingPriceCents,
    requiresReservation: requiresReservation,
  );
}
