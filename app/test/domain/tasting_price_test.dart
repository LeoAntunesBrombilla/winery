import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/tasting_price.dart';

void main() {
  group('TastingPrice.label', () {
    test('mostra o preço por pessoa em reais', () {
      expect(TastingPrice.label(8500), r'Degustação: R$ 85,00 por pessoa');
    });

    test('preço zero mostra degustação gratuita', () {
      expect(TastingPrice.label(0), 'Degustação gratuita');
    });
  });

  group('TastingPrice.formatBrl', () {
    test('usa vírgula nos centavos e ponto no milhar', () {
      expect(TastingPrice.formatBrl(5), r'R$ 0,05');
      expect(TastingPrice.formatBrl(12090), r'R$ 120,90');
      expect(TastingPrice.formatBrl(100000), r'R$ 1.000,00');
      expect(TastingPrice.formatBrl(123456789), r'R$ 1.234.567,89');
    });
  });
}
