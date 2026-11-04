import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/weekly_hours.dart';

import '../support/winery_fixture.dart';

void main() {
  group('OpeningInterval.tryParse', () {
    test('aceita os formatos da planilha', () {
      const OpeningInterval nineToFive = OpeningInterval(540, 1020);
      expect(OpeningInterval.tryParse('09:00-17:00'), nineToFive);
      expect(OpeningInterval.tryParse('9h-17h'), nineToFive);
      expect(OpeningInterval.tryParse('9h às 17h'), nineToFive);
      expect(OpeningInterval.tryParse('9:00 – 17:00'), nineToFive);
      expect(
        OpeningInterval.tryParse('10h30 a 18h45'),
        const OpeningInterval(630, 1125),
      );
    });

    test('recusa textos e intervalos inválidos', () {
      for (final String raw in <String>[
        '',
        'fechado',
        '17:00-09:00',
        '09:00-09:00',
        '25:00-26:00',
        '09:70-10:00',
      ]) {
        expect(OpeningInterval.tryParse(raw), isNull, reason: raw);
      }
    });
  });

  test('format usa HH:MM', () {
    expect(const OpeningInterval(540, 1020).format(), '09:00 – 17:00');
    expect(OpeningInterval.clock(5), '00:05');
  });

  group('WeeklyHours', () {
    test('dia sem intervalo é fechado', () {
      expect(testHours.on(DateTime.sunday), isNull);
      expect(testHours.on(DateTime.monday), const OpeningInterval(540, 1020));
    });

    test('isOpenAt considera o dia e o horário', () {
      // 03/11/2026 é uma terça; 08/11/2026, domingo.
      expect(testHours.isOpenAt(DateTime(2026, 11, 3, 9)), isTrue);
      expect(testHours.isOpenAt(DateTime(2026, 11, 3, 16, 59)), isTrue);
      expect(testHours.isOpenAt(DateTime(2026, 11, 3, 17)), isFalse);
      expect(testHours.isOpenAt(DateTime(2026, 11, 3, 8, 59)), isFalse);
      expect(testHours.isOpenAt(DateTime(2026, 11, 8, 12)), isFalse);
    });

    test('igualdade compara todos os dias', () {
      expect(
        const WeeklyHours(<int, OpeningInterval>{1: OpeningInterval(1, 2)}),
        const WeeklyHours(<int, OpeningInterval>{1: OpeningInterval(1, 2)}),
      );
      expect(testHours, isNot(WeeklyHours.closed));
    });
  });
}
