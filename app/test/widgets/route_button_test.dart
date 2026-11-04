import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/widgets/route_button.dart';

void main() {
  const Coordinates valduga = Coordinates(-29.1756, -51.5577);

  Future<List<Uri>> tapRoute(
    WidgetTester tester, {
    required TargetPlatform platform,
    required bool Function(Uri uri) opens,
  }) async {
    final List<Uri> tried = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: RouteButton(
            destination: valduga,
            openUrl: (Uri uri) async {
              tried.add(uri);
              return opens(uri);
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Como chegar'));
    await tester.pump();
    return tried;
  }

  testWidgets('Android abre o Google Maps', (WidgetTester tester) async {
    final List<Uri> tried = await tapRoute(
      tester,
      platform: TargetPlatform.android,
      opens: (Uri uri) => true,
    );

    expect(tried.single.scheme, 'google.navigation');
  });

  testWidgets('iOS sem Google Maps abre o Apple Maps', (
    WidgetTester tester,
  ) async {
    final List<Uri> tried = await tapRoute(
      tester,
      platform: TargetPlatform.iOS,
      opens: (Uri uri) => uri.scheme != 'comgooglemaps',
    );

    expect(tried.map((Uri u) => u.scheme), <String>['comgooglemaps', 'maps']);
  });

  testWidgets('sem app de mapas abre no navegador', (
    WidgetTester tester,
  ) async {
    final List<Uri> tried = await tapRoute(
      tester,
      platform: TargetPlatform.iOS,
      opens: (Uri uri) => uri.scheme == 'https',
    );

    expect(tried.last.host, 'www.google.com');
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('avisa quando nada abre', (WidgetTester tester) async {
    await tapRoute(
      tester,
      platform: TargetPlatform.android,
      opens: (Uri uri) => false,
    );

    expect(find.text('Não foi possível abrir a rota.'), findsOneWidget);
  });
}
