import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/route_link.dart';

void main() {
  const Coordinates valduga = Coordinates(-29.1756, -51.5577);

  List<String> schemes(TargetPlatform platform) =>
      RouteLink.candidates(valduga, platform).map((Uri u) => u.scheme).toList();

  group('RouteLink.candidates', () {
    test('Android: navegação do Google Maps, depois navegador', () {
      expect(schemes(TargetPlatform.android), <String>[
        'google.navigation',
        'https',
      ]);
      expect(
        RouteLink.candidates(valduga, TargetPlatform.android).first.toString(),
        'google.navigation:q=-29.1756,-51.5577&mode=d',
      );
    });

    test('iOS: Google Maps, Apple Maps, depois navegador', () {
      final List<Uri> links = RouteLink.candidates(valduga, TargetPlatform.iOS);

      expect(schemes(TargetPlatform.iOS), <String>[
        'comgooglemaps',
        'maps',
        'https',
      ]);
      expect(links[0].queryParameters['daddr'], '-29.1756,-51.5577');
      expect(links[1].queryParameters['daddr'], '-29.1756,-51.5577');
    });

    test('nenhum link fixa a origem: parte da localização atual', () {
      for (final TargetPlatform platform in <TargetPlatform>[
        TargetPlatform.android,
        TargetPlatform.iOS,
      ]) {
        for (final Uri uri in RouteLink.candidates(valduga, platform)) {
          expect(uri.queryParameters.containsKey('saddr'), isFalse);
          expect(uri.queryParameters.containsKey('origin'), isFalse);
        }
      }
    });
  });

  test('RouteLink.browser usa a API de rotas do Google Maps', () {
    final Uri uri = RouteLink.browser(valduga);

    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters, <String, String>{
      'api': '1',
      'destination': '-29.1756,-51.5577',
      'travelmode': 'driving',
    });
  });

  group('RouteLink.open', () {
    test('para no primeiro app que abre', () async {
      final List<Uri> tried = <Uri>[];

      final bool ok = await RouteLink.open(
        (Uri uri) async {
          tried.add(uri);
          return true;
        },
        valduga,
        TargetPlatform.iOS,
      );

      expect(ok, isTrue);
      expect(tried.single.scheme, 'comgooglemaps');
    });

    test('sem app de mapas, abre no navegador', () async {
      final List<Uri> tried = <Uri>[];

      final bool ok = await RouteLink.open(
        (Uri uri) async {
          tried.add(uri);
          if (uri.scheme == 'google.navigation') {
            throw Exception('ActivityNotFound');
          }
          return uri.scheme == 'https';
        },
        valduga,
        TargetPlatform.android,
      );

      expect(ok, isTrue);
      expect(tried.map((Uri u) => u.scheme), <String>[
        'google.navigation',
        'https',
      ]);
    });

    test('devolve false quando nada abre', () async {
      final bool ok = await RouteLink.open(
        (Uri uri) async => false,
        valduga,
        TargetPlatform.iOS,
      );

      expect(ok, isFalse);
    });
  });
}
