import 'package:flutter/foundation.dart';
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

  static const Duration timeLimit = Duration(seconds: 10);

  /// Como pedir a posição em cada sistema. No Android a leitura vai direto
  /// ao serviço de localização do sistema (LocationManager), sem depender
  /// do Google Play Services: funciona em aparelhos sem Play Services e no
  /// emulador, onde a localização do Play Services não chega.
  static LocationSettings settingsFor(TargetPlatform platform) {
    if (platform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        forceLocationManager: true,
        timeLimit: timeLimit,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: timeLimit,
    );
  }

  @override
  Future<Coordinates?> current() async {
    final TargetPlatform platform = defaultTargetPlatform;
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
      final Position? position = await currentOrLastKnown(
        current: () => Geolocator.getCurrentPosition(
          locationSettings: settingsFor(platform),
        ),
        lastKnown: () => Geolocator.getLastKnownPosition(
          forceAndroidLocationManager: platform == TargetPlatform.android,
        ),
      );
      return position == null
          ? null
          : Coordinates(position.latitude, position.longitude);
    } on Object {
      return null;
    }
  }
}

/// Posição atual ou, se ela não vier (tempo esgotado, sem sinal), a última
/// conhecida pelo aparelho. Separado do Geolocator para ser testado.
Future<Position?> currentOrLastKnown({
  required Future<Position> Function() current,
  required Future<Position?> Function() lastKnown,
}) async {
  try {
    return await current();
  } on Object {
    return lastKnown();
  }
}
