import 'package:geolocator/geolocator.dart';
import 'package:winery_finder/domain/coordinates.dart';

/// Localização atual do usuário, ou `null` quando ela não está disponível
/// (permissão negada, GPS desligado, tempo esgotado).
abstract interface class LocationProvider {
  Future<Coordinates?> current();
}

/// Usado nos testes e quando não se quer pedir permissão.
class NoLocationProvider implements LocationProvider {
  const NoLocationProvider();

  @override
  Future<Coordinates?> current() async => null;
}

class GeolocatorLocationProvider implements LocationProvider {
  const GeolocatorLocationProvider();

  @override
  Future<Coordinates?> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return Coordinates(position.latitude, position.longitude);
    } on Object {
      return null;
    }
  }
}
