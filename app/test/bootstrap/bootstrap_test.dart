import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/bootstrap.dart';

void main() {
  group('initFirebase', () {
    test('devolve true quando o Firebase inicializa', () async {
      int calls = 0;

      final bool ok = await initFirebase(
        initialize: () async {
          calls++;
          return Future<FirebaseApp>.value(_FakeApp());
        },
      );

      expect(ok, isTrue);
      expect(calls, 1);
    });

    test('devolve false em vez de lançar sem configuração', () async {
      final bool ok = await initFirebase(
        initialize: () => Future<FirebaseApp>.error(
          FirebaseException(plugin: 'core', code: 'not-initialized'),
        ),
      );

      expect(ok, isFalse);
    });
  });
}

class _FakeApp extends Fake implements FirebaseApp {}
