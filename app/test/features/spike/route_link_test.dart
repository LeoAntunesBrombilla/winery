import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/features/spike/route_link.dart';

void main() {
  group('RouteLink.directions', () {
    test('Android abre a rota no Google Maps', () {
      final Uri uri = RouteLink.directions(
        latitude: -29.1756,
        longitude: -51.5577,
        platform: TargetPlatform.android,
      );

      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters, <String, String>{
        'api': '1',
        'destination': '-29.1756,-51.5577',
        'travelmode': 'driving',
      });
    });

    test('iOS abre a rota no Apple Maps', () {
      final Uri uri = RouteLink.directions(
        latitude: -29.1756,
        longitude: -51.5577,
        platform: TargetPlatform.iOS,
      );

      expect(uri.host, 'maps.apple.com');
      expect(uri.queryParameters, <String, String>{
        'daddr': '-29.1756,-51.5577',
        'dirflg': 'd',
      });
    });
  });
}
