import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/widgets/reservation_badge.dart';

void main() {
  Future<void> pumpBadge(WidgetTester tester, {required bool required}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ReservationBadge(requiresReservation: required)),
      ),
    );
  }

  testWidgets('mostra Reserva obrigatória', (WidgetTester tester) async {
    await pumpBadge(tester, required: true);

    expect(find.text('Reserva obrigatória'), findsOneWidget);
    expect(find.byIcon(Icons.event_busy), findsOneWidget);
  });

  testWidgets('mostra Sem necessidade de reserva', (WidgetTester tester) async {
    await pumpBadge(tester, required: false);

    expect(find.text('Sem necessidade de reserva'), findsOneWidget);
    expect(find.byIcon(Icons.event_available), findsOneWidget);
  });
}
