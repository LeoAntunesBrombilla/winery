import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/tasting_price.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';

/// Campos do cadastro de vinícola já validados (US17).
class WineryFormData {
  const WineryFormData({
    required this.name,
    required this.city,
    required this.address,
    required this.location,
    required this.wineTypes,
    required this.hours,
    required this.tastingPriceCents,
    required this.requiresReservation,
    this.rating,
    this.phone,
    this.website,
  });

  final String name;
  final String city;
  final String address;
  final Coordinates location;
  final Set<WineType> wineTypes;
  final WeeklyHours hours;
  final int tastingPriceCents;
  final bool requiresReservation;
  final double? rating;
  final String? phone;
  final String? website;

  /// Campos gravados em `wineries/{id}` (docs/modelo-de-dados.md), sem
  /// `updatedAt` e `photos`, que o store controla. `location` vai como
  /// [Coordinates] e o store converte para GeoPoint.
  Map<String, Object?> toFields() => <String, Object?>{
    'name': name,
    'city': city,
    'address': address,
    'location': location,
    'wineTypes': <String>[for (final WineType t in wineTypes) t.name],
    'openingHours': weeklyHoursToFirestore(hours),
    'tastingPriceCents': tastingPriceCents,
    'requiresReservation': requiresReservation,
    'rating': rating,
    'phone': phone,
    'website': website,
  };
}

/// Validação dos campos do formulário. Cada função devolve a mensagem
/// exibida no campo, ou `null` se o valor é válido.
abstract final class WineryFormValidators {
  static const String requiredMessage = 'Obrigatório';

  static String? required(String? value) =>
      (value ?? '').trim().isEmpty ? requiredMessage : null;

  static String? latitude(String? value) =>
      required(value) ??
      (_coordinate(value!, 90) == null ? 'Latitude entre -90 e 90' : null);

  static String? longitude(String? value) =>
      required(value) ??
      (_coordinate(value!, 180) == null ? 'Longitude entre -180 e 180' : null);

  /// Cada dia é obrigatório: "09:00-17:00" ou "fechado".
  static String? day(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Obrigatório (09:00-17:00 ou fechado)';
    }
    return parseDay(value!) == null && !isClosed(value)
        ? 'Use 09:00-17:00 ou fechado'
        : null;
  }

  static String? price(String? value) =>
      required(value) ??
      (TastingPrice.parseCents(value!) == null
          ? r'Valor em reais, ex.: 85,00 (0 = gratuita)'
          : null);

  /// Nota é opcional; se preenchida, de 0 a 5.
  static String? rating(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return null;
    }
    final double? rating = parseDecimal(value!);
    return rating == null || rating < 0 || rating > 5 ? 'Nota de 0 a 5' : null;
  }

  static bool isClosed(String value) => value.trim().toLowerCase() == 'fechado';

  static OpeningInterval? parseDay(String value) =>
      OpeningInterval.tryParse(value);

  static double? parseDecimal(String value) =>
      double.tryParse(value.trim().replaceAll(',', '.'));

  static double? _coordinate(String value, double limit) {
    final double? number = parseDecimal(value);
    return number == null || number.abs() > limit ? null : number;
  }

  /// Texto do dia no formulário: "09:00-17:00" ou "fechado".
  static String dayInput(OpeningInterval? interval) => interval == null
      ? 'fechado'
      : '${OpeningInterval.clock(interval.opensAt)}-'
            '${OpeningInterval.clock(interval.closesAt)}';
}

/// Id estável do documento a partir do nome: "Casa Valduga" →
/// "casa-valduga" (mesmo formato da planilha da US32).
String wineryIdFor(String name) {
  return WineryFilter.normalize(name.trim())
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}
