// Carga inicial de vinícolas no Firestore (US32).
//
//   dart run tool/import_wineries.dart --projeto <id-do-projeto> \
//     --credenciais <service-account.json> [--planilha <arquivo.csv>]
//
// Opções: --simular só valida a planilha; --parcial aceita menos de 15
// vinícolas (durante a coleta); --conferir lê de volta a coleção e lista
// vinícolas sem horário, preço ou reserva. Veja tool/catalog/README.md.
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:winery_finder/catalog/catalog_sheet.dart';
import 'package:winery_finder/catalog/firestore_rest.dart';

const String _firestore = 'https://firestore.googleapis.com/v1';

Future<void> main(List<String> arguments) async {
  final ArgParser parser = ArgParser()
    ..addOption('planilha', defaultsTo: 'tool/catalog/vinicolas.csv')
    ..addOption('projeto')
    ..addOption('credenciais')
    ..addFlag('simular', negatable: false)
    ..addFlag('parcial', negatable: false)
    ..addFlag('conferir', negatable: false);
  final ArgResults args = parser.parse(arguments);

  CatalogSheetResult? sheet;
  if (!args.flag('conferir')) {
    sheet = CatalogSheet.parse(
      File(args.option('planilha')!).readAsStringSync(),
      checkCount: !args.flag('parcial'),
    );
    if (!sheet.isValid) {
      stderr.writeln('Planilha com problemas, nada foi importado:');
      sheet.issues.forEach(stderr.writeln);
      exit(1);
    }
    stdout.writeln('Planilha OK: ${sheet.entries.length} vinícolas.');
    if (args.flag('simular')) {
      return;
    }
  }

  final String? projectId = args.option('projeto');
  final String? credentials = args.option('credenciais');
  if (projectId == null || credentials == null) {
    stderr.writeln('Informe --projeto e --credenciais.\n${parser.usage}');
    exit(64);
  }

  final AutoRefreshingAuthClient client = await clientViaServiceAccount(
    ServiceAccountCredentials.fromJson(File(credentials).readAsStringSync()),
    <String>['https://www.googleapis.com/auth/datastore'],
  );
  try {
    if (args.flag('conferir')) {
      await _audit(client, projectId);
    } else {
      await _import(client, projectId, sheet!);
    }
  } finally {
    client.close();
  }
}

Future<void> _import(
  http.Client client,
  String projectId,
  CatalogSheetResult sheet,
) async {
  final http.Response response = await client.post(
    Uri.parse(
      '$_firestore/projects/$projectId/databases/(default)/documents:commit',
    ),
    headers: <String, String>{'content-type': 'application/json'},
    body: jsonEncode(
      FirestoreRest.commitBody(
        projectId,
        sheet.entries,
        importedAt: DateTime.now(),
      ),
    ),
  );
  if (response.statusCode != 200) {
    stderr.writeln('Falha na importação (${response.statusCode}):');
    stderr.writeln(response.body);
    exit(1);
  }
  stdout.writeln(
    '${sheet.entries.length} vinícolas gravadas em ${FirestoreRest.collection}.',
  );
  await _audit(client, projectId);
}

Future<void> _audit(http.Client client, String projectId) async {
  final List<Map<String, Object?>> documents = <Map<String, Object?>>[];
  String? pageToken;
  do {
    final http.Response response = await client.get(
      Uri.parse(
        '$_firestore/projects/$projectId/databases/(default)/documents/'
        '${FirestoreRest.collection}',
      ).replace(
        queryParameters: <String, String>{
          'pageSize': '300',
          'pageToken': ?pageToken,
        },
      ),
    );
    if (response.statusCode != 200) {
      stderr.writeln('Falha na conferência (${response.statusCode}):');
      stderr.writeln(response.body);
      exit(1);
    }
    final Map<String, Object?> page =
        jsonDecode(response.body) as Map<String, Object?>;
    final Object? pageDocuments = page['documents'];
    if (pageDocuments is List<Object?>) {
      documents.addAll(pageDocuments.whereType<Map<String, Object?>>());
    }
    pageToken = page['nextPageToken'] as String?;
  } while (pageToken != null);

  int incomplete = 0;
  for (final Map<String, Object?> document in documents) {
    final List<String> missing = FirestoreRest.missingRequiredFields(document);
    if (missing.isNotEmpty) {
      incomplete++;
      stderr.writeln('${document['name']}: falta ${missing.join(', ')}');
    }
  }
  stdout.writeln(
    'Conferência: ${documents.length - incomplete} de ${documents.length} '
    'vinícolas com horário, preço e reserva preenchidos.',
  );
  if (incomplete > 0) {
    exit(1);
  }
}
