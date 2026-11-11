import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/winery_form_data.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

import '../support/winery_fixture.dart';

void main() {
  group('WineryFormValidators', () {
    test('obrigatórios', () {
      expect(WineryFormValidators.required(null), 'Obrigatório');
      expect(WineryFormValidators.required('   '), 'Obrigatório');
      expect(WineryFormValidators.required('Casa Valduga'), isNull);
    });

    test('coordenadas', () {
      expect(WineryFormValidators.latitude(''), 'Obrigatório');
      expect(WineryFormValidators.latitude('-29,1756'), isNull);
      expect(WineryFormValidators.latitude('-95'), isNotNull);
      expect(WineryFormValidators.longitude('-51.5577'), isNull);
      expect(WineryFormValidators.longitude('abc'), isNotNull);
    });

    test('cada dia: intervalo ou fechado', () {
      expect(WineryFormValidators.day(''), startsWith('Obrigatório'));
      expect(WineryFormValidators.day('09:00-17:00'), isNull);
      expect(WineryFormValidators.day('Fechado'), isNull);
      expect(WineryFormValidators.day('cedo'), 'Use 09:00-17:00 ou fechado');
    });

    test('preço obrigatório em reais', () {
      expect(WineryFormValidators.price(''), 'Obrigatório');
      expect(WineryFormValidators.price('85,00'), isNull);
      expect(WineryFormValidators.price('0'), isNull);
      expect(WineryFormValidators.price('grátis'), isNotNull);
    });

    test('nota opcional de 0 a 5', () {
      expect(WineryFormValidators.rating(''), isNull);
      expect(WineryFormValidators.rating('4,7'), isNull);
      expect(WineryFormValidators.rating('6'), 'Nota de 0 a 5');
    });

    test('dayInput volta ao formato do campo', () {
      expect(
        WineryFormValidators.dayInput(const OpeningInterval(540, 1020)),
        '09:00-17:00',
      );
      expect(WineryFormValidators.dayInput(null), 'fechado');
    });
  });

  test('wineryIdFor gera o mesmo slug da planilha', () {
    expect(wineryIdFor('Casa Valduga'), 'casa-valduga');
    expect(
      wineryIdFor('  Vinícola Família Geisse! '),
      'vinicola-familia-geisse',
    );
    expect(wineryIdFor('Dal Pizzol & Cia.'), 'dal-pizzol-cia');
  });

  group('gravação no Firestore', () {
    final WineryFormData data = WineryFormData(
      name: 'Casa Valduga',
      city: 'Bento Gonçalves',
      address: 'Via Trento, 2355',
      location: const Coordinates(-29.1756, -51.5577),
      wineTypes: <WineType>{WineType.tinto},
      hours: testHours,
      tastingPriceCents: 8500,
      requiresReservation: true,
      rating: 4.7,
    );

    test('campos no formato de docs/modelo-de-dados.md', () {
      final Map<String, Object?> fields =
          FirestoreAdminWineryStore.firestoreFields(data);

      expect(fields['location'], const GeoPoint(-29.1756, -51.5577));
      expect(fields['wineTypes'], <String>['tinto']);
      expect(
        (fields['openingHours']! as Map<String, Object?>)['mon'],
        <String, String>{'open': '09:00', 'close': '17:00'},
      );
      expect((fields['openingHours']! as Map<String, Object?>)['sun'], isNull);
      expect(fields['tastingPriceCents'], 8500);
      expect(fields['requiresReservation'], isTrue);
      expect(fields['rating'], 4.7);
      expect(fields['phone'], isNull);
    });

    test('toda gravação atualiza o updatedAt e não mexe nas fotos', () {
      final Map<String, Object?> fields =
          FirestoreAdminWineryStore.firestoreFields(data);

      expect(fields['updatedAt'], isA<FieldValue>());
      expect(fields.containsKey('photos'), isFalse);
    });
  });

  test('FirebaseAdminAuth.authMessage', () {
    expect(
      FirebaseAdminAuth.authMessage('invalid-credential'),
      'E-mail ou senha incorretos.',
    );
    expect(FirebaseAdminAuth.authMessage('invalid-email'), 'E-mail inválido.');
    expect(FirebaseAdminAuth.authMessage('outro'), contains('outro'));
  });
}
