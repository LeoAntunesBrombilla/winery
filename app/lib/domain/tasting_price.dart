/// Texto do preço da degustação por pessoa exibido na ficha (US06).
abstract final class TastingPrice {
  /// "Degustação: R$ 85,00 por pessoa", ou "Degustação gratuita" quando o
  /// preço é zero.
  static String label(int cents) {
    if (cents == 0) {
      return 'Degustação gratuita';
    }
    return 'Degustação: ${formatBrl(cents)} por pessoa';
  }

  /// Formata centavos em reais: 123456 → "R$ 1.234,56".
  static String formatBrl(int cents) {
    assert(cents >= 0, 'preço negativo: $cents');
    final String reais = (cents ~/ 100).toString();
    final StringBuffer grouped = StringBuffer();
    for (int i = 0; i < reais.length; i++) {
      if (i > 0 && (reais.length - i) % 3 == 0) {
        grouped.write('.');
      }
      grouped.write(reais[i]);
    }
    final String centavos = (cents % 100).toString().padLeft(2, '0');
    return 'R\$ $grouped,$centavos';
  }
}
