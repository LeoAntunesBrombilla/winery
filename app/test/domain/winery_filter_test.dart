import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';

void main() {
  const Winery valduga = Winery(
    id: '1',
    name: 'Casa Valduga',
    city: 'Bento Gonçalves',
    coordinates: Coordinates(-29.17, -51.52),
    wineTypes: <WineType>{WineType.tinto, WineType.espumante},
    distanceKm: 12.4,
    rating: 4.7,
    tastingPriceCents: 0,
    requiresReservation: false,
  );
  const Winery aurora = Winery(
    id: '2',
    name: 'Vinícola Aurora',
    city: 'Bento Gonçalves',
    coordinates: Coordinates(-29.17, -51.52),
    wineTypes: <WineType>{WineType.branco},
    distanceKm: 3.2,
    rating: 4.3,
    tastingPriceCents: 0,
    requiresReservation: false,
  );
  const Winery miolo = Winery(
    id: '3',
    name: 'Miolo',
    city: 'Vale dos Vinhedos',
    coordinates: Coordinates(-29.17, -51.52),
    wineTypes: <WineType>{WineType.tinto, WineType.rose},
    distanceKm: 0.65,
    rating: 4.8,
    tastingPriceCents: 0,
    requiresReservation: false,
  );
  const List<Winery> all = <Winery>[valduga, aurora, miolo];

  group('WineryFilter.apply', () {
    test('sem filtros devolve todas ordenadas por distância', () {
      final List<Winery> result = WineryFilter.apply(all);

      expect(result.map((Winery w) => w.id), <String>['3', '2', '1']);
    });

    test('busca por nome ignora maiúsculas e espaços', () {
      final List<Winery> result = WineryFilter.apply(all, query: '  aURoRa ');

      expect(result.single.id, '2');
    });

    test('busca por cidade', () {
      final List<Winery> result = WineryFilter.apply(
        all,
        query: 'bento gonçalves',
      );

      expect(result.map((Winery w) => w.id), <String>['2', '1']);
    });

    test('filtra por tipo de vinho', () {
      final List<Winery> result = WineryFilter.apply(
        all,
        types: <WineType>{WineType.tinto},
      );

      expect(result.map((Winery w) => w.id), <String>['3', '1']);
    });

    test('vários tipos funcionam como OU', () {
      final List<Winery> result = WineryFilter.apply(
        all,
        types: <WineType>{WineType.branco, WineType.rose},
      );

      expect(result.map((Winery w) => w.id), <String>['3', '2']);
    });

    test('texto e tipo são combinados com E', () {
      final List<Winery> result = WineryFilter.apply(
        all,
        query: 'bento',
        types: <WineType>{WineType.tinto},
      );

      expect(result.single.id, '1');
    });

    test('devolve lista vazia quando nada casa', () {
      final List<Winery> result = WineryFilter.apply(all, query: 'garibaldi');

      expect(result, isEmpty);
    });
  });

  group('WineryFilter.apply sem localização', () {
    Winery withoutDistance(Winery w) => w.withDistanceFrom(null);

    test('ordena por nome, ignorando maiúsculas e acentos', () {
      final List<Winery> result = WineryFilter.apply(
        <Winery>[valduga, aurora, miolo].map(withoutDistance),
      );

      expect(result.map((Winery w) => w.name), <String>[
        'Casa Valduga',
        'Miolo',
        'Vinícola Aurora',
      ]);
    });

    test('acentos não mudam a ordem alfabética', () {
      final List<Winery> result = WineryFilter.apply(<Winery>[
        _named('Vinícola Zanotto'),
        _named('Álvaro Vinhos'),
        _named('adega Boa Vista'),
      ]);

      expect(result.map((Winery w) => w.name), <String>[
        'adega Boa Vista',
        'Álvaro Vinhos',
        'Vinícola Zanotto',
      ]);
    });

    test('vinícolas com distância vêm antes das sem distância', () {
      final List<Winery> result = WineryFilter.apply(<Winery>[
        withoutDistance(aurora),
        valduga,
      ]);

      expect(result.map((Winery w) => w.id), <String>['1', '2']);
    });

    test('mesma distância desempata por nome', () {
      final List<Winery> result = WineryFilter.apply(<Winery>[
        _named('Zeta', distanceKm: 5),
        _named('Alfa', distanceKm: 5),
      ]);

      expect(result.map((Winery w) => w.name), <String>['Alfa', 'Zeta']);
    });
  });

  group('Winery.withDistanceFrom', () {
    test('calcula a distância até o usuário', () {
      final Winery winery = valduga.withDistanceFrom(
        const Coordinates(-29.17, -51.52),
      );

      expect(winery.distanceKm, 0);
      expect(winery.id, valduga.id);
    });

    test('sem localização a distância é null', () {
      expect(valduga.withDistanceFrom(null).distanceKm, isNull);
    });
  });

  group('WineryFilter.formatDistance', () {
    test('quilômetros com uma casa decimal e vírgula', () {
      expect(WineryFilter.formatDistance(0.65), '0,7 km');
      expect(WineryFilter.formatDistance(1), '1,0 km');
      expect(WineryFilter.formatDistance(12.44), '12,4 km');
    });
  });

  group('WineryFilter.formatRating', () {
    test('uma casa decimal com vírgula', () {
      expect(WineryFilter.formatRating(4.75), '4,8');
      expect(WineryFilter.formatRating(4), '4,0');
    });
  });
}

Winery _named(String name, {double? distanceKm}) => Winery(
  id: name,
  name: name,
  city: 'Bento Gonçalves',
  coordinates: const Coordinates(-29.17, -51.52),
  wineTypes: const <WineType>{WineType.tinto},
  rating: 4,
  tastingPriceCents: 0,
  requiresReservation: false,
  distanceKm: distanceKm,
);
