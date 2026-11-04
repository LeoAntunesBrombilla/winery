import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/catalog/catalog_entry.dart';
import 'package:winery_finder/catalog/catalog_sheet.dart';
import 'package:winery_finder/catalog/firestore_rest.dart';

import 'catalog_fixture.dart';

void main() {
  final DateTime updatedAt = DateTime.utc(2026, 10, 26, 12);
  final CatalogEntry entry = CatalogSheet.parse(
    sheet(<String>[validRow()]),
    checkCount: false,
  ).entries.single;

  group('FirestoreRest.commitBody', () {
    test('grava cada vinícola no documento do seu id estável', () {
      final Map<String, Object> body = FirestoreRest.commitBody(
        'winery-dev',
        <CatalogEntry>[entry],
        updatedAt: updatedAt,
      );

      final List<Object> writes = body['writes']! as List<Object>;
      final Map<String, Object> update =
          (writes.single as Map<String, Object>)['update']!
              as Map<String, Object>;
      expect(
        update['name'],
        'projects/winery-dev/databases/(default)/documents/wineries/'
        'casa-valduga',
      );
    });

    test(
      'a mesma planilha gera as mesmas escritas (reimportar não duplica)',
      () {
        Map<String, Object> commit() => FirestoreRest.commitBody(
          'winery-dev',
          <CatalogEntry>[entry],
          updatedAt: updatedAt,
        );

        expect(commit(), commit());
      },
    );
  });

  group('FirestoreRest.fields', () {
    test('converte para os tipos do Firestore', () {
      final Map<String, Object> fields = FirestoreRest.fields(
        entry,
        updatedAt: updatedAt,
      );

      expect(fields['name'], <String, String>{'stringValue': 'Casa Valduga'});
      expect(fields['address'], <String, String>{
        'stringValue': 'Via Trento, 2355',
      });
      final Map<String, Object> days =
          ((fields['openingHours']! as Map<String, Object>)['mapValue']!
                  as Map<String, Object>)['fields']!
              as Map<String, Object>;
      expect(days.keys, <String>[
        'mon',
        'tue',
        'wed',
        'thu',
        'fri',
        'sat',
        'sun',
      ]);
      expect(days['sat'], <String, Object>{
        'mapValue': <String, Object>{
          'fields': <String, Object>{
            'open': <String, String>{'stringValue': '09:00'},
            'close': <String, String>{'stringValue': '17:00'},
          },
        },
      });
      expect(days['sun'], <String, Object?>{'nullValue': null});
      expect(fields['location'], <String, Object>{
        'geoPointValue': <String, double>{
          'latitude': -29.1756,
          'longitude': -51.5577,
        },
      });
      expect(fields['wineTypes'], <String, Object>{
        'arrayValue': <String, Object>{
          'values': <Object>[
            <String, String>{'stringValue': 'tinto'},
            <String, String>{'stringValue': 'espumante'},
          ],
        },
      });
      expect(fields['tastingPriceCents'], <String, String>{
        'integerValue': '8500',
      });
      expect(fields['requiresReservation'], <String, bool>{
        'booleanValue': true,
      });
      expect(fields['rating'], <String, double>{'doubleValue': 4.7});
      expect(fields['verification'], <String, Object>{
        'mapValue': <String, Object>{
          'fields': <String, Object>{
            'source': <String, String>{'stringValue': 'site'},
            'verifiedAt': <String, String>{
              'timestampValue': '2026-10-20T00:00:00.000Z',
            },
          },
        },
      });
      expect(fields.containsKey('photos'), isFalse);
      expect(fields['updatedAt'], <String, String>{
        'timestampValue': '2026-10-26T12:00:00.000Z',
      });
    });

    test('campos opcionais vazios viram null', () {
      final CatalogEntry bare = CatalogSheet.parse(
        sheet(<String>[
          'aurora,Aurora,Bento,Rua B,-29.16,-51.51,branco,9h-17h,9h-17h,9h-17h,'
              '9h-17h,9h-17h,fechado,fechado,0,não,,,,site,01/10/2026',
        ]),
        checkCount: false,
      ).entries.single;

      final Map<String, Object> fields = FirestoreRest.fields(
        bare,
        updatedAt: updatedAt,
      );

      for (final String name in <String>['phone', 'website', 'rating']) {
        expect(fields[name], <String, Object?>{
          'nullValue': null,
        }, reason: name);
      }
    });
  });

  group('FirestoreRest.missingRequiredFields', () {
    test('documento importado tem tudo preenchido', () {
      final Map<String, Object?> document = <String, Object?>{
        'fields': FirestoreRest.fields(entry, updatedAt: updatedAt),
      };

      expect(FirestoreRest.missingRequiredFields(document), isEmpty);
    });

    test('aponta horário incompleto, preço e reserva ausentes', () {
      final Map<String, Object?> document = <String, Object?>{
        'fields': <String, Object?>{
          'address': <String, Object?>{'stringValue': 'Rua A'},
          'openingHours': <String, Object?>{
            'mapValue': <String, Object?>{
              'fields': <String, Object?>{
                'mon': <String, Object?>{'nullValue': null},
              },
            },
          },
          'requiresReservation': <String, Object?>{'nullValue': null},
        },
      };

      expect(FirestoreRest.missingRequiredFields(document), <String>[
        'openingHours',
        'tastingPriceCents',
        'requiresReservation',
      ]);
    });

    test('documento sem campos falha em todos', () {
      expect(
        FirestoreRest.missingRequiredFields(<String, Object?>{}),
        FirestoreRest.requiredFields,
      );
    });
  });
}
