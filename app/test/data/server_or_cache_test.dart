import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/data/winery_repository.dart';

void main() {
  const Duration timeout = Duration(seconds: 4);

  group('serverOrCache', () {
    test('com rede usa o servidor', () async {
      final String result = await serverOrCache(
        server: () async => 'servidor',
        cache: () async => 'cache',
        timeout: timeout,
      );

      expect(result, 'servidor');
    });

    test('sem rede cai no cache', () async {
      final String result = await serverOrCache(
        server: () => Future<String>.error(Exception('unavailable')),
        cache: () async => 'cache',
        timeout: timeout,
      );

      expect(result, 'cache');
    });

    test('rede lenta: abre do cache em menos de 5 s', () {
      fakeAsync((FakeAsync async) {
        String? result;
        serverOrCache(
          server: () => Future<String>.delayed(
            const Duration(seconds: 30),
            () => 'servidor',
          ),
          cache: () async => 'cache',
          timeout: timeout,
        ).then((String value) => result = value);

        async.elapse(const Duration(milliseconds: 3900));
        expect(result, isNull);
        async.elapse(const Duration(milliseconds: 200));
        expect(result, 'cache');
        expect(async.elapsed, lessThan(const Duration(seconds: 5)));
      });
    });
  });
}
