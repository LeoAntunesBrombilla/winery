import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/admin/photo_services.dart';
import 'package:winery_finder/admin/winery_photos_screen.dart';

import '../support/fake_admin.dart';
import '../support/winery_fixture.dart';

void main() {
  PickedPhoto photo(String name, [int size = 10]) =>
      PickedPhoto(name: name, bytes: Uint8List(size));

  Future<FakePhotoStore> pumpPhotos(
    WidgetTester tester, {
    required FakePhotoPicker picker,
    List<String> urls = const <String>[],
  }) async {
    final FakePhotoStore store = FakePhotoStore();
    await tester.pumpWidget(
      MaterialApp(
        home: WineryPhotosScreen(
          winery: testWinery(photoUrls: urls),
          store: store,
          picker: picker,
          photoBuilder: (String url) => Text('foto $url'),
        ),
      ),
    );
    return store;
  }

  testWidgets('envia a foto escolhida e mostra na grade', (
    WidgetTester tester,
  ) async {
    final FakePhotoStore store = await pumpPhotos(
      tester,
      picker: FakePhotoPicker(photo('vinhedo.jpg')),
    );
    expect(find.text('Nenhuma foto ainda.'), findsOneWidget);

    await tester.tap(find.text('Adicionar (0/5)'));
    await tester.pumpAndSettle();

    expect(store.uploaded, <String>[
      'https://storage.test/casa-valduga/vinhedo.jpg',
    ]);
    expect(
      find.text('foto https://storage.test/casa-valduga/vinhedo.jpg'),
      findsOneWidget,
    );
    expect(find.text('Adicionar (1/5)'), findsOneWidget);
    expect(find.text('Foto enviada.'), findsOneWidget);
  });

  testWidgets('recusa formato errado sem enviar', (WidgetTester tester) async {
    final FakePhotoStore store = await pumpPhotos(
      tester,
      picker: FakePhotoPicker(photo('vinhedo.heic')),
    );

    await tester.tap(find.text('Adicionar (0/5)'));
    await tester.pumpAndSettle();

    expect(store.uploaded, isEmpty);
    expect(find.text('Envie uma foto JPG ou PNG.'), findsOneWidget);
  });

  testWidgets('com 5 fotos o botão de adicionar fica desativado', (
    WidgetTester tester,
  ) async {
    await pumpPhotos(
      tester,
      picker: FakePhotoPicker(photo('x.jpg')),
      urls: <String>['u1', 'u2', 'u3', 'u4', 'u5'],
    );

    final FloatingActionButton fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    expect(fab.onPressed, isNull);
    expect(find.text('Adicionar (5/5)'), findsOneWidget);
  });

  testWidgets('excluir remove a foto do Storage e da grade', (
    WidgetTester tester,
  ) async {
    final FakePhotoStore store = await pumpPhotos(
      tester,
      picker: FakePhotoPicker(),
      urls: <String>['u1', 'u2'],
    );

    await tester.tap(find.byTooltip('Excluir foto').first);
    await tester.pumpAndSettle();

    expect(store.deleted, <String>['u1']);
    expect(find.text('foto u1'), findsNothing);
    expect(find.text('foto u2'), findsOneWidget);
  });

  testWidgets('cancelar a galeria não faz nada', (WidgetTester tester) async {
    final FakePhotoStore store = await pumpPhotos(
      tester,
      picker: FakePhotoPicker(),
    );

    await tester.tap(find.text('Adicionar (0/5)'));
    await tester.pumpAndSettle();

    expect(store.uploaded, isEmpty);
    expect(find.byType(SnackBar), findsNothing);
  });
}
