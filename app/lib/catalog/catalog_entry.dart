import 'package:winery_finder/domain/winery.dart';

/// Como a informação da vinícola foi conferida antes da carga.
enum VerificationSource {
  site('site'),
  telefone('telefone');

  const VerificationSource(this.value);

  /// Valor usado na planilha e no Firestore.
  final String value;
}

/// Uma linha validada da planilha de carga inicial (US32), pronta para virar
/// um documento em `wineries/{id}` no Firestore.
class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.name,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.wineTypes,
    required this.openingHours,
    required this.tastingPriceCents,
    required this.requiresReservation,
    required this.verificationSource,
    required this.verifiedAt,
    this.phone,
    this.website,
    this.rating,
  });

  /// Id estável (slug), usado como id do documento: reimportar a mesma
  /// planilha atualiza o documento em vez de duplicar.
  final String id;
  final String name;
  final String city;
  final double latitude;
  final double longitude;
  final Set<WineType> wineTypes;

  /// Horário de funcionamento como texto livre, ex.: "Seg a sáb, 9h às 17h".
  final String openingHours;

  /// Preço da degustação por pessoa, em centavos. Zero = gratuita.
  final int tastingPriceCents;
  final bool requiresReservation;
  final VerificationSource verificationSource;

  /// Data em que horário, preço e reserva foram conferidos.
  final DateTime verifiedAt;
  final String? phone;
  final String? website;

  /// Avaliação média de 0 a 5, se já conhecida.
  final double? rating;
}
