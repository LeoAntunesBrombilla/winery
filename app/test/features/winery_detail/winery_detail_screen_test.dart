import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/rating_stars.dart';

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
    expect(find.text('Via Trento, 2355'), findsOneWidget);
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

  group('horário de funcionamento (US05)', () {
    // 07/11/2026 é um sábado.
    DateTime saturday() => DateTime(2026, 11, 7, 10);

    Future<void> pumpHours(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WineryDetailScreen(winery: testWinery(), now: saturday),
        ),
      );
      await tester.scrollUntilVisible(find.text('Domingo'), 100);
    }

    testWidgets('lista os sete dias com o horário de cada um', (
      WidgetTester tester,
    ) async {
      await pumpHours(tester);

      for (final String day in <String>[
        'Segunda',
        'Terça',
        'Quarta',
        'Quinta',
        'Sexta',
        'Domingo',
      ]) {
        expect(find.text(day), findsOneWidget, reason: day);
      }
      expect(find.text('09:00 – 17:00'), findsNWidgets(6));
    });

    testWidgets('dia sem funcionamento aparece como Fechado', (
      WidgetTester tester,
    ) async {
      await pumpHours(tester);

      final Finder sunday = find.byKey(const ValueKey<int>(DateTime.sunday));
      expect(
        find.descendant(of: sunday, matching: find.text('Fechado')),
        findsOneWidget,
      );
    });

    testWidgets('destaca o dia de hoje', (WidgetTester tester) async {
      await pumpHours(tester);

      expect(find.text('Sábado (hoje)'), findsOneWidget);
      expect(find.text('Sábado'), findsNothing);
      final Text today = tester.widget<Text>(find.text('Sábado (hoje)'));
      expect(today.style?.fontWeight, FontWeight.bold);
      final Text monday = tester.widget<Text>(find.text('Segunda'));
      expect(monday.style?.fontWeight, isNot(FontWeight.bold));
    });
  });

  group('nota da equipe (US15)', () {
    testWidgets('mostra a nota com uma casa decimal e estrelas', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: WineryDetailScreen(winery: testWinery(rating: 3.5))),
      );

      expect(find.text('3,5'), findsOneWidget);
      expect(find.byType(RatingStars), findsOneWidget);
      expect(find.text('Nota da equipe Winery Finder'), findsOneWidget);
    });

    testWidgets('vinícola sem nota mostra Sem nota', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: WineryDetailScreen(winery: testWinery(rating: null))),
      );

      expect(find.text('Sem nota'), findsOneWidget);
      expect(find.byType(RatingStars), findsNothing);
    });
  });
}
