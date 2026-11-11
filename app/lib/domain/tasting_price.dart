/// Texto do preço da degustação por pessoa exibido na ficha (US06).
abstract final class TastingPrice {
  static final RegExp _price = RegExp(r'^\d+([.,]\d{1,2})?$');

  /// Lê o preço digitado em reais: "85", "85,5", "85,50" e "R\$ 85" viram
  /// 8500, 8550, 8550 e 8500 centavos. `null` se inválido.
  static int? parseCents(String raw) {
    final String value = raw.trim().replaceFirst(RegExp(r'^R\$\s*'), '');
    if (!_price.hasMatch(value)) {
      return null;
    }
    final List<String> parts = value.split(RegExp('[.,]'));
    final int reais = int.parse(parts.first);
    final int cents = parts.length == 1
        ? 0
        : int.parse(parts[1].padRight(2, '0'));
    return reais * 100 + cents;
  }

  /// Centavos no formato do campo de edição: 8550 → "85,50".
  static String formatInput(int cents) =>
      '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';

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
