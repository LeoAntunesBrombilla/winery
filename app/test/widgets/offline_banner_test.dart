import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/app.dart';
import 'package:winery_finder/data/connectivity_monitor.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/widgets/offline_banner.dart';

import '../support/fakes.dart';
import '../support/winery_fixture.dart';

class _FakeConnectivity implements ConnectivityMonitor {
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  Future<void> close() => controller.close();

  @override
  Stream<bool> get online => controller.stream;
}

void main() {
  test('ConnectivityPlusMonitor.isOnline', () {
    expect(
      ConnectivityPlusMonitor.isOnline(<ConnectivityResult>[
        ConnectivityResult.none,
      ]),
      isFalse,
    );
    expect(ConnectivityPlusMonitor.isOnline(<ConnectivityResult>[]), isFalse);
    expect(
      ConnectivityPlusMonitor.isOnline(<ConnectivityResult>[
        ConnectivityResult.mobile,
      ]),
      isTrue,
    );
    expect(
      ConnectivityPlusMonitor.isOnline(<ConnectivityResult>[
        ConnectivityResult.wifi,
        ConnectivityResult.vpn,
      ]),
      isTrue,
    );
  });

  testWidgets('aparece sem rede e some quando a rede volta', (
    WidgetTester tester,
  ) async {
    final _FakeConnectivity connectivity = _FakeConnectivity();
    addTearDown(connectivity.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OfflineBanner(connectivity: connectivity)),
      ),
    );
    expect(find.text(OfflineBanner.message), findsNothing);

    connectivity.controller.add(false);
    await tester.pump();
    await tester.pump();
    expect(
      find.text('Você está offline - mostrando dados salvos.'),
      findsOneWidget,
    );

    connectivity.controller.add(true);
    await tester.pump();
    await tester.pump();
    expect(find.text(OfflineBanner.message), findsNothing);
  });

  testWidgets('offline o app mostra o aviso e as vinícolas salvas', (
    WidgetTester tester,
  ) async {
    final _FakeConnectivity connectivity = _FakeConnectivity();
    addTearDown(connectivity.close);
    await tester.pumpWidget(
      WineryFinderApp(
        // O repositório devolve o que o Firestore tem em cache.
        repository: FakeRepository(<Winery>[testWinery()]),
        connectivity: connectivity,
      ),
    );
    connectivity.controller.add(false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();

    expect(find.text(OfflineBanner.message), findsOneWidget);
    expect(find.text('Casa Valduga'), findsOneWidget);
  });
}
