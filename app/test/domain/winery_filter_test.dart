import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';

void main() {
  const Winery valduga = Winery(
    id: '1',
    name: 'Casa Valduga',
    city: 'Bento Gonçalves',
    wineTypes: <WineType>{WineType.tinto, WineType.espumante},
    distanceKm: 12.4,
    rating: 4.7,
    tastingPriceCents: 0,
  );
  const Winery aurora = Winery(
    id: '2',
    name: 'Vinícola Aurora',
    city: 'Bento Gonçalves',
    wineTypes: <WineType>{WineType.branco},
    distanceKm: 3.2,
    rating: 4.3,
    tastingPriceCents: 0,
  );
  const Winery miolo = Winery(
    id: '3',
    name: 'Miolo',
    city: 'Vale dos Vinhedos',
    wineTypes: <WineType>{WineType.tinto, WineType.rose},
    distanceKm: 0.65,
    rating: 4.8,
    tastingPriceCents: 0,
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

  group('WineryFilter.formatDistance', () {
    test('abaixo de 1 km mostra metros', () {
      expect(WineryFilter.formatDistance(0.65), '650 m');
    });

    test('a partir de 1 km mostra quilômetros com uma casa', () {
      expect(WineryFilter.formatDistance(1), '1.0 km');
      expect(WineryFilter.formatDistance(12.44), '12.4 km');
    });
  });
}
