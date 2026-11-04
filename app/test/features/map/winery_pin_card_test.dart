import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/features/map/winery_pin_card.dart';

import '../../support/winery_fixture.dart';

void main() {
  testWidgets('card do pin mostra nome, cidade e selo de reserva', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WineryPinCard(winery: testWinery(requiresReservation: true)),
        ),
      ),
    );

    expect(find.text('Casa Valduga'), findsOneWidget);
    expect(find.text('Bento Gonçalves'), findsOneWidget);
    expect(find.text('Reserva obrigatória'), findsOneWidget);
  });

  testWidgets('tocar no card chama onTap', (WidgetTester tester) async {
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WineryPinCard(winery: testWinery(), onTap: () => taps++),
        ),
      ),
    );

    await tester.tap(find.byType(WineryPinCard));

    expect(taps, 1);
  });
}
