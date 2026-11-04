import 'package:winery_finder/catalog/catalog_entry.dart';
import 'package:winery_finder/catalog/csv_reader.dart';
import 'package:winery_finder/domain/tasting_price.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

/// Problema encontrado numa linha da planilha. `line` é a linha no arquivo
/// (1 = cabeçalho), igual à numeração do Excel/Google Sheets.
class CatalogIssue {
  const CatalogIssue(this.line, this.message);

  final int line;
  final String message;

  @override
  String toString() => 'linha $line: $message';
}

/// Resultado da leitura: só importe quando [issues] estiver vazio.
class CatalogSheetResult {
  const CatalogSheetResult(this.entries, this.issues);

  final List<CatalogEntry> entries;
  final List<CatalogIssue> issues;

  bool get isValid => issues.isEmpty;
}

/// Lê e valida a planilha padrão da carga inicial (US32), exportada em CSV.
abstract final class CatalogSheet {
  static const int minWineries = 15;
  static const int maxWineries = 20;

  /// Colunas da planilha padrão, nesta ordem.
  static const List<String> columns = <String>[
    'id',
    'nome',
    'cidade',
    'endereco',
    'latitude',
    'longitude',
    'tipos_vinho',
    ...dayColumns,
    'preco_degustacao',
    'reserva_obrigatoria',
    'telefone',
    'site',
    'nota',
    'fonte_verificacao',
    'data_verificacao',
  ];

  /// Uma coluna de horário por dia, de segunda a domingo: "09:00-17:00"
  /// ou "fechado".
  static const List<String> dayColumns = <String>[
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sab',
    'dom',
  ];

  static const Set<String> _optional = <String>{'telefone', 'site', 'nota'};

  static final RegExp _slug = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
  static final RegExp _date = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

  /// Valida a planilha inteira. Com [checkCount], exige entre
  /// [minWineries] e [maxWineries] vinícolas (desligue durante a coleta).
  static CatalogSheetResult parse(String csv, {bool checkCount = true}) {
    final List<List<String>> rows = CsvReader.parse(csv);
    if (rows.isEmpty) {
      return const CatalogSheetResult(<CatalogEntry>[], <CatalogIssue>[
        CatalogIssue(1, 'planilha vazia'),
      ]);
    }

    final List<String> header = rows.first
        .map((String c) => c.trim().toLowerCase())
        .toList();
    final List<String> missing = columns
        .where((String c) => !header.contains(c))
        .toList();
    if (missing.isNotEmpty) {
      return CatalogSheetResult(<CatalogEntry>[], <CatalogIssue>[
        CatalogIssue(1, 'faltam as colunas: ${missing.join(', ')}'),
      ]);
    }

    final List<CatalogEntry> entries = <CatalogEntry>[];
    final List<CatalogIssue> issues = <CatalogIssue>[];
    final Map<String, int> seenIds = <String, int>{};

    for (int i = 1; i < rows.length; i++) {
      final int line = i + 1;
      final Map<String, String> cells = <String, String>{
        for (int c = 0; c < header.length; c++)
          header[c]: c < rows[i].length ? rows[i][c].trim() : '',
      };
      final List<String> errors = <String>[];
      final CatalogEntry? entry = _parseRow(cells, errors);

      final String id = cells['id']!;
      final int? firstLine = seenIds[id];
      if (id.isNotEmpty && firstLine != null) {
        errors.add('id "$id" repetido (já usado na linha $firstLine)');
      } else {
        seenIds[id] = line;
      }

      issues.addAll(errors.map((String e) => CatalogIssue(line, e)));
      if (entry != null && errors.isEmpty) {
        entries.add(entry);
      }
    }

    final int count = rows.length - 1;
    if (checkCount && (count < minWineries || count > maxWineries)) {
      issues.add(
        CatalogIssue(
          1,
          'a carga inicial precisa ter de $minWineries a $maxWineries '
          'vinícolas (tem $count)',
        ),
      );
    }
    return CatalogSheetResult(entries, issues);
  }

  static CatalogEntry? _parseRow(
    Map<String, String> cells,
    List<String> errors,
  ) {
    for (final String column in columns) {
      if (!_optional.contains(column) && cells[column]!.isEmpty) {
        errors.add('"$column" não preenchido');
      }
    }
    if (errors.isNotEmpty) {
      return null;
    }

    final String id = cells['id']!;
    if (!_slug.hasMatch(id)) {
      errors.add('id "$id" deve ser minúsculo, sem acento, com hífens');
    }

    final double? latitude = _parseDecimal(cells['latitude']!);
    final double? longitude = _parseDecimal(cells['longitude']!);
    if (latitude == null || latitude < -90 || latitude > 90) {
      errors.add('latitude inválida');
    }
    if (longitude == null || longitude < -180 || longitude > 180) {
      errors.add('longitude inválida');
    }

    final Set<WineType> wineTypes = <WineType>{};
    for (final String raw in cells['tipos_vinho']!.split(';')) {
      final WineType? type = _wineType(raw);
      if (type == null) {
        errors.add('tipo de vinho "${raw.trim()}" desconhecido');
      } else {
        wineTypes.add(type);
      }
    }

    final Map<int, OpeningInterval> days = <int, OpeningInterval>{};
    for (int i = 0; i < dayColumns.length; i++) {
      final String raw = cells[dayColumns[i]]!;
      if (raw.toLowerCase() == 'fechado') {
        continue;
      }
      final OpeningInterval? interval = OpeningInterval.tryParse(raw);
      if (interval == null) {
        errors.add(
          '${dayColumns[i]}: horário "$raw" inválido (use 09:00-17:00 ou '
          'fechado)',
        );
      } else {
        days[i + 1] = interval;
      }
    }

    final int? priceCents = TastingPrice.parseCents(cells['preco_degustacao']!);
    if (priceCents == null) {
      errors.add('preço "${cells['preco_degustacao']}" inválido (use 85,00)');
    }

    final bool? requiresReservation = _parseYesNo(
      cells['reserva_obrigatoria']!,
    );
    if (requiresReservation == null) {
      errors.add('reserva_obrigatoria deve ser "sim" ou "não"');
    }

    double? rating;
    if (cells['nota']!.isNotEmpty) {
      rating = _parseDecimal(cells['nota']!);
      if (rating == null || rating < 0 || rating > 5) {
        errors.add('nota deve estar entre 0 e 5');
      }
    }

    final VerificationSource? source = _source(cells['fonte_verificacao']!);
    if (source == null) {
      errors.add('fonte_verificacao deve ser "site" ou "telefone"');
    }

    final DateTime? verifiedAt = _parseDate(cells['data_verificacao']!);
    if (verifiedAt == null) {
      errors.add('data_verificacao deve estar em dd/mm/aaaa');
    }

    if (errors.isNotEmpty) {
      return null;
    }
    return CatalogEntry(
      id: id,
      name: cells['nome']!,
      city: cells['cidade']!,
      address: cells['endereco']!,
      latitude: latitude!,
      longitude: longitude!,
      wineTypes: wineTypes,
      openingHours: WeeklyHours(days),
      tastingPriceCents: priceCents!,
      requiresReservation: requiresReservation!,
      verificationSource: source!,
      verifiedAt: verifiedAt!,
      phone: _nullIfEmpty(cells['telefone']!),
      website: _nullIfEmpty(cells['site']!),
      rating: rating,
    );
  }

  static double? _parseDecimal(String raw) =>
      double.tryParse(raw.replaceAll(',', '.'));

  static bool? _parseYesNo(String raw) {
    switch (raw.toLowerCase()) {
      case 'sim':
        return true;
      case 'não':
      case 'nao':
        return false;
    }
    return null;
  }

  static WineType? _wineType(String raw) {
    final String value = raw.trim().toLowerCase();
    for (final WineType type in WineType.values) {
      if (type.name == value || type.label.toLowerCase() == value) {
        return type;
      }
    }
    return null;
  }

  static VerificationSource? _source(String raw) {
    for (final VerificationSource source in VerificationSource.values) {
      if (source.value == raw.toLowerCase()) {
        return source;
      }
    }
    return null;
  }

  static DateTime? _parseDate(String raw) {
    final RegExpMatch? match = _date.firstMatch(raw);
    if (match == null) {
      return null;
    }
    final int day = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int year = int.parse(match.group(3)!);
    final DateTime date = DateTime.utc(year, month, day);
    // Rejeita datas que o DateTime "corrige", como 31/02.
    if (date.day != day || date.month != month) {
      return null;
    }
    return date;
  }

  static String? _nullIfEmpty(String value) => value.isEmpty ? null : value;
}
