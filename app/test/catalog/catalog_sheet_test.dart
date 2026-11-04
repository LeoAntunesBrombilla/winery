import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/catalog/catalog_entry.dart';
import 'package:winery_finder/catalog/catalog_sheet.dart';
import 'package:winery_finder/domain/winery.dart';

import 'catalog_fixture.dart';

void main() {
  List<String> messages(CatalogSheetResult result) =>
      result.issues.map((CatalogIssue i) => i.toString()).toList();

  group('CatalogSheet.parse', () {
    test('converte uma linha válida', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[validRow()]),
        checkCount: false,
      );

      expect(result.isValid, isTrue);
      final CatalogEntry entry = result.entries.single;
      expect(entry.id, 'casa-valduga');
      expect(entry.city, 'Bento Gonçalves');
      expect(entry.latitude, -29.1756);
      expect(entry.wineTypes, <WineType>{WineType.tinto, WineType.espumante});
      expect(entry.openingHours, 'Seg a sáb, 9h às 17h');
      expect(entry.tastingPriceCents, 8500);
      expect(entry.requiresReservation, isTrue);
      expect(entry.rating, 4.7);
      expect(entry.verificationSource, VerificationSource.site);
      expect(entry.verifiedAt, DateTime.utc(2026, 10, 20));
    });

    test('aceita de 15 a 20 vinícolas', () {
      expect(CatalogSheet.parse(sheet(validRows(15))).isValid, isTrue);
      expect(CatalogSheet.parse(sheet(validRows(20))).isValid, isTrue);
    });

    test('recusa menos de 15 ou mais de 20, salvo carga parcial', () {
      expect(messages(CatalogSheet.parse(sheet(validRows(14)))), <String>[
        'linha 1: a carga inicial precisa ter de 15 a 20 vinícolas (tem 14)',
      ]);
      expect(CatalogSheet.parse(sheet(validRows(21))).isValid, isFalse);
      expect(
        CatalogSheet.parse(sheet(validRows(3)), checkCount: false).isValid,
        isTrue,
      );
    });

    test('exige horário, preço e reserva preenchidos', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[
          'casa-valduga,Casa Valduga,Bento Gonçalves,-29.1,-51.5,tinto,,,,,,,'
              'site,20/10/2026',
        ]),
        checkCount: false,
      );

      expect(result.entries, isEmpty);
      expect(messages(result), <String>[
        'linha 2: "horario" não preenchido',
        'linha 2: "preco_degustacao" não preenchido',
        'linha 2: "reserva_obrigatoria" não preenchido',
      ]);
    });

    test('recusa id repetido para não duplicar no Firestore', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[validRow(), validRow()]),
        checkCount: false,
      );

      expect(result.entries, hasLength(1));
      expect(messages(result), <String>[
        'linha 3: id "casa-valduga" repetido (já usado na linha 2)',
      ]);
    });

    test('recusa id fora do formato slug', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[validRow(id: 'Casa Valduga')]),
        checkCount: false,
      );

      expect(messages(result).single, contains('id "Casa Valduga"'));
    });

    test('converte preços em centavos', () {
      int cents(String price) => CatalogSheet.parse(
        sheet(<String>[validRow(price: price)]),
        checkCount: false,
      ).entries.single.tastingPriceCents;

      expect(cents('0'), 0);
      expect(cents('85'), 8500);
      expect(cents('85,5'), 8550);
      expect(cents('120,90'), 12090);
      expect(cents(r'R$ 60'), 6000);
    });

    test('recusa preço inválido', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[validRow(price: 'grátis')]),
        checkCount: false,
      );

      expect(messages(result).single, contains('preço "grátis" inválido'));
    });

    test('aceita "não" com e sem acento na reserva', () {
      for (final String value in <String>['não', 'nao', 'NÃO']) {
        final CatalogSheetResult result = CatalogSheet.parse(
          sheet(<String>[validRow(reservation: value)]),
          checkCount: false,
        );
        expect(result.entries.single.requiresReservation, isFalse);
      }
    });

    test('aponta cada campo inválido da linha', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[
          'x,X,Y,-95,200,tinto;laranja,9h,10,talvez,,,7,email,31/02/2026',
        ]),
        checkCount: false,
      );

      expect(messages(result), <String>[
        'linha 2: latitude inválida',
        'linha 2: longitude inválida',
        'linha 2: tipo de vinho "laranja" desconhecido',
        'linha 2: reserva_obrigatoria deve ser "sim" ou "não"',
        'linha 2: nota deve estar entre 0 e 5',
        'linha 2: fonte_verificacao deve ser "site" ou "telefone"',
        'linha 2: data_verificacao deve estar em dd/mm/aaaa',
      ]);
    });

    test('telefone, site e nota são opcionais', () {
      final CatalogSheetResult result = CatalogSheet.parse(
        sheet(<String>[
          'aurora,Aurora,Bento Gonçalves,-29.16,-51.51,branco,9h às 18h,0,não,'
              ',,,telefone,01/10/2026',
        ]),
        checkCount: false,
      );

      final CatalogEntry entry = result.entries.single;
      expect(entry.phone, isNull);
      expect(entry.website, isNull);
      expect(entry.rating, isNull);
      expect(entry.verificationSource, VerificationSource.telefone);
    });

    test('recusa planilha sem as colunas padrão', () {
      expect(
        messages(CatalogSheet.parse('id,nome\nx,y')).single,
        startsWith('linha 1: faltam as colunas: cidade'),
      );
      expect(messages(CatalogSheet.parse('')), <String>[
        'linha 1: planilha vazia',
      ]);
    });

    test('a planilha modelo do repositório tem o cabeçalho padrão', () {
      // O flutter test roda a partir da raiz do app.
      final String template = File('tool/catalog/vinicolas.csv')
          .readAsStringSync();

      expect(CatalogSheet.parse(template, checkCount: false).isValid, isTrue);
    });
  });
}
