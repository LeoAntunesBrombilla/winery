import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winery_finder/data/recents_store.dart';

void main() {
  DateTime day(int d) => DateTime(2026, 11, d, 10);

  List<String> ids(RecentsStore store) =>
      store.visits.map((RecentVisit v) => v.wineryId).toList();

  group('RecentsStore', () {
    test('mais recente primeiro', () async {
      final RecentsStore store = RecentsStore();
      await store.record('a', day(1));
      await store.record('b', day(2));
      await store.record('c', day(3));

      expect(ids(store), <String>['c', 'b', 'a']);
    });

    test('reabrir atualiza a data sem duplicar', () async {
      final RecentsStore store = RecentsStore();
      await store.record('a', day(1));
      await store.record('b', day(2));
      await store.record('a', day(3));

      expect(ids(store), <String>['a', 'b']);
      expect(store.visits.first.openedAt, day(3));
    });

    test('guarda só as últimas 20', () async {
      final RecentsStore store = RecentsStore();
      for (int i = 1; i <= 25; i++) {
        await store.record(
          'v$i',
          DateTime(2026, 11, 1).add(Duration(hours: i)),
        );
      }

      expect(store.visits, hasLength(20));
      expect(store.visits.first.wineryId, 'v25');
      expect(store.visits.last.wineryId, 'v6');
    });

    test('limpar apaga o histórico', () async {
      final RecentsStore store = RecentsStore();
      await store.record('a', day(1));

      await store.clear();

      expect(store.visits, isEmpty);
    });

    test('estado inicial é normalizado', () {
      final RecentsStore store = RecentsStore(
        initial: <RecentVisit>[
          RecentVisit('a', day(1)),
          RecentVisit('b', day(3)),
          RecentVisit('a', day(2)),
        ],
      );

      expect(ids(store), <String>['b', 'a']);
      expect(store.visits.last.openedAt, day(2));
    });
  });

  group('RecentVisit.encode/decode', () {
    test('ida e volta', () {
      final RecentVisit visit = RecentVisit('casa-valduga', day(3));

      expect(RecentVisit.decode(visit.encode()), visit);
    });

    test('ignora registros corrompidos', () {
      expect(RecentVisit.decode('sem-data'), isNull);
      expect(RecentVisit.decode('|123'), isNull);
      expect(RecentVisit.decode('x|abc'), isNull);
    });
  });

  test('persiste no aparelho', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final RecentsStore first = RecentsStore.fromPreferences(
      await SharedPreferences.getInstance(),
    );
    await first.record('a', day(1));
    await first.record('b', day(2));

    final RecentsStore reopened = RecentsStore.fromPreferences(
      await SharedPreferences.getInstance(),
    );

    expect(ids(reopened), <String>['b', 'a']);
    expect(reopened.visits.first.openedAt, day(2));
  });
}
