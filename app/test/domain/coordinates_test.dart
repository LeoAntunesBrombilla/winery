import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/coordinates.dart';

void main() {
  group('Coordinates.distanceKmTo', () {
    const Coordinates bento = Coordinates(-29.1717, -51.5189);
    const Coordinates garibaldi = Coordinates(-29.2560, -51.5336);

    test('mesmo ponto é zero', () {
      expect(bento.distanceKmTo(bento), 0);
    });

    test('Bento Gonçalves a Garibaldi fica perto de 9,5 km', () {
      expect(bento.distanceKmTo(garibaldi), closeTo(9.5, 0.1));
    });

    test('é simétrica', () {
      expect(bento.distanceKmTo(garibaldi), garibaldi.distanceKmTo(bento));
    });

    test('um grau de latitude no equador tem cerca de 111 km', () {
      expect(
        const Coordinates(0, 0).distanceKmTo(const Coordinates(1, 0)),
        closeTo(111.19, 0.01),
      );
    });
  });
}
