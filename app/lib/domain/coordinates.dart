import 'dart:math' as math;

/// Ponto geográfico em graus decimais.
class Coordinates {
  const Coordinates(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  static const double _earthRadiusKm = 6371;

  /// Distância em linha reta (fórmula de haversine), em quilômetros.
  double distanceKmTo(Coordinates other) {
    final double dLat = _radians(other.latitude - latitude);
    final double dLng = _radians(other.longitude - longitude);
    final double a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(_radians(latitude)) *
            math.cos(_radians(other.latitude)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * _earthRadiusKm * math.asin(math.sqrt(a));
  }

  static double _radians(double degrees) => degrees * math.pi / 180;

  @override
  bool operator ==(Object other) =>
      other is Coordinates &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}
