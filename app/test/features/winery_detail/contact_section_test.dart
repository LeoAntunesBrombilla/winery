import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/features/winery_detail/contact_section.dart';

void main() {
  Future<List<Uri>> pumpContact(
    WidgetTester tester, {
    String? phone,
    String? website,
    bool opens = true,
  }) async {
    final List<Uri> opened = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContactSection(
            phone: phone,
            website: website,
            openUrl: (Uri uri) async {
              opened.add(uri);
              return opens;
            },
          ),
        ),
      ),
    );
    return opened;
  }

  testWidgets('Ligar abre o discador com o número', (
    WidgetTester tester,
  ) async {
    final List<Uri> opened = await pumpContact(
      tester,
      phone: '(54) 2105-3122',
      website: 'https://casavalduga.com.br',
    );

    await tester.tap(find.text('Ligar'));
    await tester.pump();

    expect(opened.single.toString(), 'tel:5421053122');
  });

  testWidgets('Site abre o navegador', (WidgetTester tester) async {
    final List<Uri> opened = await pumpContact(
      tester,
      website: 'casavalduga.com.br',
    );

    await tester.tap(find.text('Site'));
    await tester.pump();

    expect(opened.single.toString(), 'https://casavalduga.com.br');
  });

  testWidgets('esconde o botão do dado que não existe', (
    WidgetTester tester,
  ) async {
    await pumpContact(tester, phone: '(54) 2105-3122');

    expect(find.text('Ligar'), findsOneWidget);
    expect(find.text('Site'), findsNothing);
  });

  testWidgets('sem telefone e site não mostra nada', (
    WidgetTester tester,
  ) async {
    await pumpContact(tester);

    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('avisa quando não consegue abrir', (WidgetTester tester) async {
    await pumpContact(tester, phone: '5421053122', opens: false);

    await tester.tap(find.text('Ligar'));
    await tester.pump();

    expect(find.text('Não foi possível abrir o discador.'), findsOneWidget);
  });
}
