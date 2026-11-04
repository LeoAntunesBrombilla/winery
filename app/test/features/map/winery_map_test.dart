import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/nearby.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/map/winery_map.dart';
import 'package:winery_finder/features/map/winery_pin_card.dart';

import '../../support/winery_fixture.dart';

void main() {
  const Coordinates user = Coordinates(-29.1717, -51.5189);
  final Winery valduga = testWinery(distanceKm: 3.2, rating: 4.7);
  final Winery aurora = testWinery(id: 'aurora', name: 'Aurora');

  late MapViewConfig config;

  /// Mapa falso: guarda a configuração e desenha um botão por pin.
  Widget fakeMapView(MapViewConfig value) {
    config = value;
    return Column(
      children: <Widget>[
        for (final Winery w in value.pins)
          TextButton(
            onPressed: () => value.onPinTap(w),
            child: Text('pin ${w.id}'),
          ),
        TextButton(onPressed: value.onMapTap, child: const Text('fundo')),
      ],
    );
  }

  Future<List<Winery>> pumpMap(
    WidgetTester tester,
    NearbySelection selection,
  ) async {
    final List<Winery> opened = <Winery>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WineryMap(
            selection: selection,
            onOpenDetail: opened.add,
            mapView: fakeMapView,
            openUrl: (Uri uri) async => true,
          ),
        ),
      ),
    );
    return opened;
  }

  testWidgets('um pin por vinícola, centrado no usuário', (
    WidgetTester tester,
  ) async {
    await pumpMap(
      tester,
      NearbySelection(<Winery>[valduga, aurora], user, NearbyMode.nearUser),
    );

    expect(config.pins, <Winery>[valduga, aurora]);
    expect(config.center, user);
    expect(config.showMyLocation, isTrue);
    expect(config.zoom, 11);
  });

  testWidgets('sem localização não mostra o ponto azul', (
    WidgetTester tester,
  ) async {
    await pumpMap(
      tester,
      NearbySelection(<Winery>[valduga], bentoGoncalves, NearbyMode.noLocation),
    );

    expect(config.center, bentoGoncalves);
    expect(config.showMyLocation, isFalse);
  });

  testWidgets('tocar no pin mostra nome, distância e nota', (
    WidgetTester tester,
  ) async {
    await pumpMap(
      tester,
      NearbySelection(<Winery>[valduga, aurora], user, NearbyMode.nearUser),
    );
    expect(find.byType(WineryPinCard), findsNothing);

    await tester.tap(find.text('pin casa-valduga'));
    await tester.pump();

    expect(find.byType(WineryPinCard), findsOneWidget);
    expect(find.text('Casa Valduga'), findsOneWidget);
    expect(find.text('Bento Gonçalves · 3,2 km · ★ 4,7'), findsOneWidget);
  });

  testWidgets('Ver ficha abre a ficha da vinícola do pin', (
    WidgetTester tester,
  ) async {
    final List<Winery> opened = await pumpMap(
      tester,
      NearbySelection(<Winery>[valduga, aurora], user, NearbyMode.nearUser),
    );

    await tester.tap(find.text('pin aurora'));
    await tester.pump();
    await tester.tap(find.text('Ver ficha'));

    expect(opened, <Winery>[aurora]);
  });

  testWidgets('tocar fora dos pins fecha o card', (WidgetTester tester) async {
    await pumpMap(
      tester,
      NearbySelection(<Winery>[valduga], user, NearbyMode.nearUser),
    );

    await tester.tap(find.text('pin casa-valduga'));
    await tester.pump();
    await tester.tap(find.text('fundo'));
    await tester.pump();

    expect(find.byType(WineryPinCard), findsNothing);
  });
}
