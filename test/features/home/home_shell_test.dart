import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/app.dart';
import 'package:winery_finder/data/auth_repository.dart';

void main() {
  setUp(() {
    AuthRepository.instance.login(email: 'admin@winery.com', password: 'Winery123@@@!!!');
  });

  testWidgets('abre na aba Mapa', (WidgetTester tester) async {
    await tester.pumpWidget(const WineryFinderApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Winery Finder'), findsOneWidget);
  });

  testWidgets('navega para Favoritos e Recentes', (WidgetTester tester) async {
    await tester.pumpWidget(const WineryFinderApp());

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(
      find.text('Você ainda não salvou nenhuma vinícola.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Recentes'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma vinícola visitada ainda.'), findsOneWidget);
  });
}
