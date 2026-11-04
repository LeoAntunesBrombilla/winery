import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/features/winery_detail/photo_carousel.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/winery_photo.dart';

import '../../support/winery_fixture.dart';

void main() {
  Widget fakePhoto(String url, BoxFit fit) => Text('foto $url ${fit.name}');

  Future<void> pumpCarousel(WidgetTester tester, List<String> urls) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PhotoCarousel(urls: urls, photoBuilder: fakePhoto),
        ),
      ),
    );
  }

  testWidgets('sem fotos exibe a imagem padrão', (WidgetTester tester) async {
    await pumpCarousel(tester, const <String>[]);

    expect(find.byType(DefaultWineryImage), findsOneWidget);
    expect(find.text('Sem fotos ainda'), findsOneWidget);
  });

  testWidgets('mostra a primeira foto e desliza para a próxima', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester, const <String>['a', 'b', 'c']);

    expect(find.text('foto a cover'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('dot-2')), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('foto b cover'), findsOneWidget);
  });

  testWidgets('uma foto só não mostra os pontinhos', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester, const <String>['a']);

    expect(find.byKey(const ValueKey<String>('dot-0')), findsNothing);
  });

  testWidgets('tocar abre em tela cheia na mesma foto', (
    WidgetTester tester,
  ) async {
    await pumpCarousel(tester, const <String>['a', 'b']);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();

    await tester.tap(find.text('foto b cover'));
    await tester.pumpAndSettle();

    expect(find.byType(FullscreenPhotos), findsOneWidget);
    expect(find.text('foto b contain'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('WineryPhoto mostra placeholder enquanto carrega', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WineryPhoto(url: 'https://storage.test/lenta.jpg'),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('carrossel fica no topo da ficha', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WineryDetailScreen(
          winery: testWinery(photoUrls: <String>['a', 'b']),
          photoBuilder: fakePhoto,
        ),
      ),
    );

    final double carouselTop = tester.getTopLeft(find.byType(PhotoCarousel)).dy;
    final double cityTop = tester.getTopLeft(find.text('Bento Gonçalves')).dy;
    expect(carouselTop, lessThan(cityTop));
    expect(find.text('foto a cover'), findsOneWidget);
  });
}
