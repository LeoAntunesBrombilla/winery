import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:winery_finder/data/location_provider.dart';

void main() {
  Position at(double latitude, double longitude) => Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: DateTime(2026, 11, 24),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  group('GeolocatorLocationProvider.settingsFor', () {
    test('Android lê direto do LocationManager, sem Play Services', () {
      final LocationSettings settings = GeolocatorLocationProvider.settingsFor(
        TargetPlatform.android,
      );

      expect(settings, isA<AndroidSettings>());
      expect((settings as AndroidSettings).forceLocationManager, isTrue);
      expect(settings.accuracy, LocationAccuracy.high);
      expect(settings.timeLimit, const Duration(seconds: 10));
    });

    test('iOS mantém a configuração padrão', () {
      final LocationSettings settings = GeolocatorLocationProvider.settingsFor(
        TargetPlatform.iOS,
      );

      expect(settings, isNot(isA<AndroidSettings>()));
      expect(settings.accuracy, LocationAccuracy.medium);
      expect(settings.timeLimit, const Duration(seconds: 10));
    });
  });

  group('currentOrLastKnown', () {
    test('usa a posição atual quando ela chega', () async {
      final Position? position = await currentOrLastKnown(
        current: () async => at(-29.17, -51.51),
        lastKnown: () async => at(0, 0),
      );

      expect(position?.latitude, -29.17);
    });

    test('sem posição atual, usa a última conhecida', () async {
      final Position? position = await currentOrLastKnown(
        current: () => Future<Position>.error(Exception('timeout')),
        lastKnown: () async => at(-29.25, -51.53),
      );

      expect(position?.latitude, -29.25);
    });

    test('sem nenhuma, devolve null', () async {
      final Position? position = await currentOrLastKnown(
        current: () => Future<Position>.error(Exception('timeout')),
        lastKnown: () async => null,
      );

      expect(position, isNull);
    });
  });
}
