import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/catalog/csv_reader.dart';

void main() {
  group('CsvReader.parse', () {
    test('separa linhas e colunas', () {
      expect(CsvReader.parse('a,b\n1,2\n'), <List<String>>[
        <String>['a', 'b'],
        <String>['1', '2'],
      ]);
    });

    test('aceita aspas com vírgula, quebra de linha e aspas escapadas', () {
      expect(
        CsvReader.parse('"Seg, 9h","linha 1\nlinha 2","diz ""oi"""'),
        <List<String>>[
          <String>['Seg, 9h', 'linha 1\nlinha 2', 'diz "oi"'],
        ],
      );
    });

    test('ignora CRLF, BOM e linhas em branco', () {
      expect(CsvReader.parse('﻿a,b\r\n\r\n1,2'), <List<String>>[
        <String>['a', 'b'],
        <String>['1', '2'],
      ]);
    });

    test('mantém campos vazios', () {
      expect(CsvReader.parse('a,,c'), <List<String>>[
        <String>['a', '', 'c'],
      ]);
    });
  });
}
