import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

/// Segunda a sábado das 9h às 17h, fechado no domingo.
const WeeklyHours testHours = WeeklyHours(<int, OpeningInterval>{
  DateTime.monday: OpeningInterval(540, 1020),
  DateTime.tuesday: OpeningInterval(540, 1020),
  DateTime.wednesday: OpeningInterval(540, 1020),
  DateTime.thursday: OpeningInterval(540, 1020),
  DateTime.friday: OpeningInterval(540, 1020),
  DateTime.saturday: OpeningInterval(540, 1020),
});

/// Vinícola de teste com valores padrão; sobrescreva só o que o teste usa.
/// Passe `rating: null` para uma vinícola sem nota.
Winery testWinery({
  String id = 'casa-valduga',
  String name = 'Casa Valduga',
  String city = 'Bento Gonçalves',
  String address = 'Via Trento, 2355',
  Set<WineType> wineTypes = const <WineType>{WineType.tinto},
  Coordinates coordinates = const Coordinates(-29.1756, -51.5577),
  WeeklyHours hours = testHours,
  double? distanceKm,
  double? rating = 4.7,
  int tastingPriceCents = 8500,
  bool requiresReservation = false,
  String? phone,
  String? website,
  List<String> photoUrls = const <String>[],
}) {
  return Winery(
    id: id,
    name: name,
    city: city,
    address: address,
    coordinates: coordinates,
    wineTypes: wineTypes,
    hours: hours,
    distanceKm: distanceKm,
    rating: rating,
    tastingPriceCents: tastingPriceCents,
    requiresReservation: requiresReservation,
    phone: phone,
    website: website,
    photoUrls: photoUrls,
  );
}
