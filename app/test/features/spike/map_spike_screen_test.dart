import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:winery_finder/features/spike/map_spike_screen.dart';

void main() {
  Widget fakeMap(LatLng pin, String label) => Text('pin: $label');

  Future<void> pumpSpike(WidgetTester tester, UrlOpener openUrl) {
    return tester.pumpWidget(
      MaterialApp(
        home: MapSpikeScreen(openUrl: openUrl, mapBuilder: fakeMap),
      ),
    );
  }

  testWidgets('mostra o mapa com o pin', (WidgetTester tester) async {
    await pumpSpike(tester, (Uri uri) async => true);

    expect(find.text('pin: Casa Valduga'), findsOneWidget);
  });

  testWidgets('Traçar rota abre o link de navegação até o pin', (
    WidgetTester tester,
  ) async {
    final List<Uri> opened = <Uri>[];
    await pumpSpike(tester, (Uri uri) async {
      opened.add(uri);
      return true;
    });

    await tester.tap(find.text('Traçar rota'));
    await tester.pump();

    expect(opened.single.queryParameters['destination'], '-29.1756,-51.5577');
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('avisa quando nenhum app consegue abrir a rota', (
    WidgetTester tester,
  ) async {
    await pumpSpike(tester, (Uri uri) async => false);

    await tester.tap(find.text('Traçar rota'));
    await tester.pump();

    expect(
      find.text('Não foi possível abrir o app de navegação.'),
      findsOneWidget,
    );
  });
}
