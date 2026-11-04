import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/map/winery_list.dart';

import '../../support/winery_fixture.dart';

void main() {
  testWidgets('cada item mostra nome, cidade, distância e nota', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WineryList(
            wineries: <Winery>[testWinery(distanceKm: 12.44, rating: 4.7)],
            onSelected: (Winery w) {},
          ),
        ),
      ),
    );

    expect(find.text('Casa Valduga'), findsOneWidget);
    expect(find.text('Bento Gonçalves · 12,4 km'), findsOneWidget);
    expect(find.text('4,7'), findsOneWidget);
  });

  testWidgets('sem localização mostra só a cidade', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WineryList(
            wineries: <Winery>[testWinery()],
            onSelected: (Winery w) {},
          ),
        ),
      ),
    );

    expect(find.text('Bento Gonçalves'), findsOneWidget);
  });

  testWidgets('tocar num item devolve a vinícola', (WidgetTester tester) async {
    final List<Winery> selected = <Winery>[];
    final Winery aurora = testWinery(id: 'aurora', name: 'Aurora');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WineryList(
            wineries: <Winery>[testWinery(), aurora],
            onSelected: selected.add,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Aurora'));

    expect(selected, <Winery>[aurora]);
  });
}
