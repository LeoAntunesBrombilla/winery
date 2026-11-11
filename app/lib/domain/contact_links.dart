/// Links de contato da vinícola (US08).
abstract final class ContactLinks {
  /// `tel:` só com dígitos (e `+`), aceito pelos discadores do Android e
  /// do iOS: "(54) 2105-3122" → `tel:5421053122`. `null` se não houver
  /// número.
  static Uri? phone(String? raw) {
    final String digits = (raw ?? '').replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.replaceAll('+', '').isEmpty) {
      return null;
    }
    return Uri(scheme: 'tel', path: digits);
  }

  /// Site com `https://` quando a planilha trouxe só o domínio. `null` se
  /// vazio ou inválido.
  static Uri? website(String? raw) {
    final String value = (raw ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    final Uri? uri = Uri.tryParse(
      value.contains('://') ? value : 'https://$value',
    );
    if (uri == null ||
        !uri.hasAuthority ||
        !uri.isScheme('http') && !uri.isScheme('https')) {
      return null;
    }
    return uri;
  }
}
