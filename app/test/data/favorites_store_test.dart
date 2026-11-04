import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winery_finder/data/favorites_store.dart';

void main() {
  group('FavoritesStore', () {
    test('toggle alterna e devolve o novo estado', () async {
      final FavoritesStore store = FavoritesStore();

      expect(await store.toggle('valduga'), isTrue);
      expect(store.contains('valduga'), isTrue);
      expect(await store.toggle('valduga'), isFalse);
      expect(store.contains('valduga'), isFalse);
    });

    test('mantém a ordem em que foram favoritadas', () async {
      final FavoritesStore store = FavoritesStore();
      await store.toggle('b');
      await store.toggle('a');
      await store.toggle('c');

      expect(store.ids, <String>['b', 'a', 'c']);
    });

    test('avisa os ouvintes a cada mudança', () async {
      final FavoritesStore store = FavoritesStore();
      int notifications = 0;
      store.addListener(() => notifications++);

      await store.toggle('a');
      await store.remove('a');
      await store.remove('a');

      expect(notifications, 2);
    });

    test('grava cada mudança', () async {
      final List<List<String>> saved = <List<String>>[];
      final FavoritesStore store = FavoritesStore(
        save: (List<String> ids) async => saved.add(ids),
      );

      await store.toggle('a');
      await store.toggle('b');
      await store.remove('a');

      expect(saved, <List<String>>[
        <String>['a'],
        <String>['a', 'b'],
        <String>['b'],
      ]);
    });
  });

  group('FavoritesStore.fromPreferences', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('persiste depois de "fechar o app"', () async {
      final FavoritesStore first = FavoritesStore.fromPreferences(
        await SharedPreferences.getInstance(),
      );
      await first.toggle('valduga');
      await first.toggle('aurora');

      // Novo store lendo o mesmo armazenamento, como na próxima abertura.
      final FavoritesStore reopened = FavoritesStore.fromPreferences(
        await SharedPreferences.getInstance(),
      );

      expect(reopened.ids, <String>['valduga', 'aurora']);
    });

    test('começa vazio sem nada salvo', () async {
      final FavoritesStore store = FavoritesStore.fromPreferences(
        await SharedPreferences.getInstance(),
      );

      expect(store.ids, isEmpty);
    });
  });
}
