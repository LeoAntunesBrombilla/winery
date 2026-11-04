import 'package:winery_finder/catalog/catalog_entry.dart';
import 'package:winery_finder/domain/winery.dart';

/// Conversão da carga inicial para o formato JSON da API REST do Firestore,
/// usado pelo script `tool/import_wineries.dart`.
abstract final class FirestoreRest {
  static const String collection = 'wineries';

  /// Campos que precisam estar preenchidos em toda vinícola importada.
  static const List<String> requiredFields = <String>[
    'openingHours',
    'tastingPriceCents',
    'requiresReservation',
  ];

  static String documentName(String projectId, String id) =>
      'projects/$projectId/databases/(default)/documents/$collection/$id';

  /// Corpo do `documents:commit`. Cada escrita é um upsert pelo id estável,
  /// então rodar a importação de novo não duplica vinícolas.
  static Map<String, Object> commitBody(
    String projectId,
    Iterable<CatalogEntry> entries, {
    required DateTime importedAt,
  }) {
    return <String, Object>{
      'writes': <Object>[
        for (final CatalogEntry entry in entries)
          <String, Object>{
            'update': <String, Object>{
              'name': documentName(projectId, entry.id),
              'fields': fields(entry, importedAt: importedAt),
            },
          },
      ],
    };
  }

  static Map<String, Object> fields(
    CatalogEntry entry, {
    required DateTime importedAt,
  }) {
    return <String, Object>{
      'name': _string(entry.name),
      'city': _string(entry.city),
      'location': <String, Object>{
        'geoPointValue': <String, double>{
          'latitude': entry.latitude,
          'longitude': entry.longitude,
        },
      },
      'wineTypes': <String, Object>{
        'arrayValue': <String, Object>{
          'values': <Object>[
            for (final WineType wineType in entry.wineTypes)
              _string(wineType.name),
          ],
        },
      },
      'openingHours': _string(entry.openingHours),
      'tastingPriceCents': <String, String>{
        'integerValue': '${entry.tastingPriceCents}',
      },
      'requiresReservation': <String, bool>{
        'booleanValue': entry.requiresReservation,
      },
      'phone': _nullableString(entry.phone),
      'website': _nullableString(entry.website),
      'rating': entry.rating == null
          ? _null
          : <String, double>{'doubleValue': entry.rating!},
      'verification': <String, Object>{
        'mapValue': <String, Object>{
          'fields': <String, Object>{
            'source': _string(entry.verificationSource.value),
            'verifiedAt': _timestamp(entry.verifiedAt),
          },
        },
      },
      'importedAt': _timestamp(importedAt),
    };
  }

  /// Conferência pós-importação: nomes dos campos obrigatórios ausentes ou
  /// vazios num documento lido de volta do Firestore.
  static List<String> missingRequiredFields(Map<String, Object?> document) {
    final Object? rawFields = document['fields'];
    final Map<String, Object?> fields = rawFields is Map<String, Object?>
        ? rawFields
        : const <String, Object?>{};
    return requiredFields.where((String name) {
      final Object? value = fields[name];
      if (value is! Map<String, Object?>) {
        return true;
      }
      final Object? content =
          value['stringValue'] ??
          value['integerValue'] ??
          value['booleanValue'];
      return content == null || (content is String && content.trim().isEmpty);
    }).toList();
  }

  static const Map<String, Object?> _null = <String, Object?>{
    'nullValue': null,
  };

  static Map<String, String> _string(String value) => <String, String>{
    'stringValue': value,
  };

  static Map<String, Object?> _nullableString(String? value) =>
      value == null ? _null : _string(value);

  static Map<String, String> _timestamp(DateTime value) => <String, String>{
    'timestampValue': value.toUtc().toIso8601String(),
  };
}
