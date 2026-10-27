import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';

void main() {
  group('wineryFromFirestore', () {
    test('lê o documento gravado pela carga inicial', () {
      final Winery winery = wineryFromFirestore(
        'casa-valduga',
        <String, dynamic>{
          'name': 'Casa Valduga',
          'city': 'Bento Gonçalves',
          'location': const GeoPoint(-29.1756, -51.5577),
          'wineTypes': <Object?>['tinto', 'espumante'],
          'openingHours': 'Seg a sáb, 9h às 17h',
          'tastingPriceCents': 8500,
          'requiresReservation': true,
          'rating': 4.7,
        },
      );

      expect(winery.id, 'casa-valduga');
      expect(winery.name, 'Casa Valduga');
      expect(winery.coordinates, const Coordinates(-29.1756, -51.5577));
      expect(winery.wineTypes, <WineType>{WineType.tinto, WineType.espumante});
      expect(winery.tastingPriceCents, 8500);
      expect(winery.requiresReservation, isTrue);
      expect(winery.rating, 4.7);
      expect(winery.distanceKm, isNull);
    });

    test('sem nota assume zero e ignora tipos desconhecidos', () {
      final Winery winery = wineryFromFirestore('aurora', <String, dynamic>{
        'name': 'Aurora',
        'city': 'Bento Gonçalves',
        'location': const GeoPoint(-29.16, -51.51),
        'wineTypes': <Object?>['branco', 'laranja'],
        'tastingPriceCents': 0,
        'requiresReservation': false,
        'rating': null,
      });

      expect(winery.rating, 0);
      expect(winery.wineTypes, <WineType>{WineType.branco});
    });
  });

  test('EmptyWineryRepository devolve lista vazia', () async {
    expect(await const EmptyWineryRepository().fetchAll(), isEmpty);
  });
}
