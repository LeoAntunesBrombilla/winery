import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

import '../support/winery_fixture.dart';

/// Documento de exemplo de docs/modelo-de-dados.md.
Map<String, dynamic> exampleDocument() => <String, dynamic>{
  'name': 'Casa Valduga',
  'city': 'Bento Gonçalves',
  'address': 'Via Trento, 2355 - Vale dos Vinhedos',
  'location': const GeoPoint(-29.1756, -51.5577),
  'wineTypes': <Object?>['tinto', 'espumante'],
  'openingHours': <String, dynamic>{
    'mon': <String, dynamic>{'open': '09:00', 'close': '17:00'},
    'tue': <String, dynamic>{'open': '09:00', 'close': '17:00'},
    'wed': <String, dynamic>{'open': '09:00', 'close': '17:00'},
    'thu': <String, dynamic>{'open': '09:00', 'close': '17:00'},
    'fri': <String, dynamic>{'open': '09:00', 'close': '17:00'},
    'sat': <String, dynamic>{'open': '09:00', 'close': '17:00'},
    'sun': null,
  },
  'tastingPriceCents': 8500,
  'requiresReservation': true,
  'rating': 4.7,
  'phone': '(54) 2105-3122',
  'website': 'https://casavalduga.com.br',
  'photos': <Object?>[
    'https://firebasestorage.googleapis.com/v0/b/x/o/wineries%2Fcasa-valduga%2F1.jpg',
  ],
  'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 10, 26)),
};

void main() {
  group('wineryFromFirestore', () {
    test('lê o documento de exemplo do modelo de dados', () {
      final Winery winery = wineryFromFirestore(
        'casa-valduga',
        exampleDocument(),
      );

      expect(winery.id, 'casa-valduga');
      expect(winery.name, 'Casa Valduga');
      expect(winery.address, 'Via Trento, 2355 - Vale dos Vinhedos');
      expect(winery.coordinates, const Coordinates(-29.1756, -51.5577));
      expect(winery.wineTypes, <WineType>{WineType.tinto, WineType.espumante});
      expect(winery.hours, testHours);
      expect(winery.tastingPriceCents, 8500);
      expect(winery.requiresReservation, isTrue);
      expect(winery.rating, 4.7);
      expect(winery.phone, '(54) 2105-3122');
      expect(winery.website, 'https://casavalduga.com.br');
      expect(winery.photoUrls, hasLength(1));
      expect(winery.distanceKm, isNull);
    });

    test('campos opcionais ausentes ou vazios', () {
      final Map<String, dynamic> data = exampleDocument()
        ..remove('photos')
        ..remove('address')
        ..['rating'] = null
        ..['phone'] = ''
        ..['website'] = null
        ..['wineTypes'] = <Object?>['branco', 'laranja'];

      final Winery winery = wineryFromFirestore('aurora', data);

      expect(winery.rating, isNull);
      expect(winery.phone, isNull);
      expect(winery.website, isNull);
      expect(winery.photoUrls, isEmpty);
      expect(winery.address, '');
      expect(winery.wineTypes, <WineType>{WineType.branco});
    });
  });

  group('horários no Firestore', () {
    test('dias ausentes, nulos ou inválidos ficam fechados', () {
      final WeeklyHours hours = weeklyHoursFromFirestore(<String, dynamic>{
        'mon': <String, dynamic>{'open': '09:00', 'close': '17:00'},
        'tue': null,
        'wed': <String, dynamic>{'open': '18:00', 'close': '09:00'},
        'thu': <String, dynamic>{'open': 'nove'},
      });

      expect(hours.days.keys, <int>[DateTime.monday]);
      expect(weeklyHoursFromFirestore(null), WeeklyHours.closed);
    });

    test('ida e volta preserva os horários', () {
      final Map<String, Map<String, String>?> stored = weeklyHoursToFirestore(
        testHours,
      );

      expect(stored.keys, WeeklyHours.keys);
      expect(stored['sun'], isNull);
      expect(stored['mon'], <String, String>{
        'open': '09:00',
        'close': '17:00',
      });
      expect(weeklyHoursFromFirestore(stored), testHours);
    });
  });

  test('EmptyWineryRepository devolve lista vazia', () async {
    expect(await const EmptyWineryRepository().fetchAll(), isEmpty);
  });
}
