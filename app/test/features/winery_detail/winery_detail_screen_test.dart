import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';

import '../../support/winery_fixture.dart';

void main() {
  Future<void> pumpDetail(WidgetTester tester, {required int priceCents}) {
    return tester.pumpWidget(
      MaterialApp(
        home: WineryDetailScreen(
          winery: testWinery(tastingPriceCents: priceCents),
        ),
      ),
    );
  }

  testWidgets('mostra nome, cidade e preço por pessoa', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, priceCents: 8500);

    expect(find.text('Casa Valduga'), findsOneWidget);
    expect(find.text('Bento Gonçalves'), findsOneWidget);
    expect(find.text(r'Degustação: R$ 85,00 por pessoa'), findsOneWidget);
  });

  testWidgets('preço zero mostra degustação gratuita', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, priceCents: 0);

    expect(find.text('Degustação gratuita'), findsOneWidget);
  });
}
