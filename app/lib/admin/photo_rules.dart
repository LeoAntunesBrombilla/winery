/// Regras das fotos enviadas pelo admin (US18), as mesmas do
/// firebase/storage.rules.
abstract final class PhotoRules {
  static const int maxPhotos = 5;
  static const int maxBytes = 5 * 1024 * 1024;

  /// Lado maior depois da redução feita no aparelho antes do envio.
  static const double maxDimension = 1280;

  /// Tipo do arquivo pelo nome, ou `null` se não for JPG/PNG.
  static String? contentType(String fileName) {
    final String name = fileName.toLowerCase();
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (name.endsWith('.png')) {
      return 'image/png';
    }
    return null;
  }

  /// Mensagem de erro, ou `null` se a foto pode ser enviada.
  static String? validate({
    required String fileName,
    required int sizeBytes,
    required int currentCount,
  }) {
    if (currentCount >= maxPhotos) {
      return 'Limite de $maxPhotos fotos por vinícola.';
    }
    if (contentType(fileName) == null) {
      return 'Envie uma foto JPG ou PNG.';
    }
    if (sizeBytes > maxBytes) {
      return 'A foto passa de 5 MB.';
    }
    return null;
  }
}
