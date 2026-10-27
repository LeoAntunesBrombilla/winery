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

  testWidgets('selo de reserva aparece sem rolar a tela', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WineryDetailScreen(winery: testWinery(requiresReservation: true)),
      ),
    );

    final Finder badge = find.text('Reserva obrigatória');
    expect(badge, findsOneWidget);
    expect(find.byType(Scrollable), findsNothing);
    final Rect screen =
        Offset.zero & tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(screen.contains(tester.getBottomRight(badge)), isTrue);
  });

  testWidgets('mostra Sem necessidade de reserva', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: WineryDetailScreen(winery: testWinery())),
    );

    expect(find.text('Sem necessidade de reserva'), findsOneWidget);
  });
}
