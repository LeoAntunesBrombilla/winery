import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/nearby.dart';
import 'package:winery_finder/domain/winery.dart';

import '../support/winery_fixture.dart';

void main() {
  const Coordinates bento = Coordinates(-29.1717, -51.5189);
  final List<Winery> catalog = <Winery>[
    testWinery(
      id: 'valduga',
      coordinates: const Coordinates(-29.1756, -51.5577),
    ),
    testWinery(id: 'caxias', coordinates: const Coordinates(-29.17, -51.18)),
    testWinery(id: 'poa', coordinates: const Coordinates(-30.03, -51.23)),
  ];

  List<Winery> from(Coordinates? user) =>
      catalog.map((Winery w) => w.withDistanceFrom(user)).toList();

  group('Nearby.select', () {
    test('com localização: até 50 km, centrado no usuário', () {
      final NearbySelection selection = Nearby.select(from(bento), bento);

      expect(selection.wineries.map((Winery w) => w.id), <String>[
        'valduga',
        'caxias',
      ]);
      expect(selection.center, bento);
      expect(selection.mode, NearbyMode.nearUser);
    });

    test('o limite de 50 km é inclusivo', () {
      final Winery atLimit = testWinery(distanceKm: 50);
      final Winery beyond = testWinery(id: 'x', distanceKm: 50.01);

      expect(Nearby.select(<Winery>[atLimit, beyond], bento).wineries, <Winery>[
        atLimit,
      ]);
    });

    test('sem localização: todas, centrado em Bento Gonçalves', () {
      final NearbySelection selection = Nearby.select(from(null), null);

      expect(selection.wineries, hasLength(3));
      expect(selection.center, bentoGoncalves);
      expect(selection.mode, NearbyMode.noLocation);
    });

    test('longe de todas: todas, centrado em Bento Gonçalves', () {
      const Coordinates saoPaulo = Coordinates(-23.55, -46.63);
      final NearbySelection selection = Nearby.select(from(saoPaulo), saoPaulo);

      expect(selection.wineries, hasLength(3));
      expect(selection.center, bentoGoncalves);
      expect(selection.mode, NearbyMode.noneNearby);
    });
  });

  test('Nearby.notice só aparece fora do modo próximo', () {
    expect(Nearby.notice(NearbyMode.nearUser), isNull);
    expect(Nearby.notice(NearbyMode.noLocation), contains('busque'));
    expect(Nearby.notice(NearbyMode.noneNearby), contains('50 km'));
  });
}
