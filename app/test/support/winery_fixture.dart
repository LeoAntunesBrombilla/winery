import 'package:winery_finder/domain/winery.dart';

/// Vinícola de teste com valores padrão; sobrescreva só o que o teste usa.
Winery testWinery({
  String id = 'casa-valduga',
  String name = 'Casa Valduga',
  String city = 'Bento Gonçalves',
  Set<WineType> wineTypes = const <WineType>{WineType.tinto},
  double distanceKm = 12.4,
  double rating = 4.7,
  int tastingPriceCents = 8500,
}) {
  return Winery(
    id: id,
    name: name,
    city: city,
    wineTypes: wineTypes,
    distanceKm: distanceKm,
    rating: rating,
    tastingPriceCents: tastingPriceCents,
  );
}
