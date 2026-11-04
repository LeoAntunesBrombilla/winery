import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/map/winery_list.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/favorite_button.dart';

import '../support/app_scope_harness.dart';
import '../support/winery_fixture.dart';

void main() {
  final Winery valduga = testWinery();

  testWidgets('coração na ficha favorita e confirma', (
    WidgetTester tester,
  ) async {
    final FavoritesStore favorites = FavoritesStore();
    await tester.pumpWidget(
      withAppScope(WineryDetailScreen(winery: valduga), favorites: favorites),
    );
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton));
    await tester.pump();

    expect(favorites.contains('casa-valduga'), isTrue);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('Casa Valduga adicionada aos favoritos'), findsOneWidget);
  });

  testWidgets('segundo toque remove e confirma', (WidgetTester tester) async {
    final FavoritesStore favorites = FavoritesStore(
      initial: <String>['casa-valduga'],
    );
    await tester.pumpWidget(
      withAppScope(WineryDetailScreen(winery: valduga), favorites: favorites),
    );
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    await tester.tap(find.byType(FavoriteButton));
    await tester.pump();

    expect(favorites.contains('casa-valduga'), isFalse);
    expect(find.text('Casa Valduga removida dos favoritos'), findsOneWidget);
  });

  testWidgets('coração em cada item da lista', (WidgetTester tester) async {
    final FavoritesStore favorites = FavoritesStore();
    final Winery aurora = testWinery(id: 'aurora', name: 'Aurora');
    await tester.pumpWidget(
      withAppScope(
        Scaffold(
          body: WineryList(
            wineries: <Winery>[valduga, aurora],
            onSelected: (Winery w) {},
          ),
        ),
        favorites: favorites,
      ),
    );

    expect(find.byType(FavoriteButton), findsNWidgets(2));
    await tester.tap(find.byType(FavoriteButton).last);
    await tester.pump();

    expect(favorites.ids, <String>['aurora']);
    expect(find.text('Aurora adicionada aos favoritos'), findsOneWidget);
  });

  testWidgets('favoritar pela lista reflete na ficha', (
    WidgetTester tester,
  ) async {
    final FavoritesStore favorites = FavoritesStore();
    await tester.pumpWidget(
      withAppScope(
        Builder(
          builder: (BuildContext context) => Scaffold(
            body: WineryList(
              wineries: <Winery>[valduga],
              onSelected: (Winery w) => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      WineryDetailScreen(winery: w),
                ),
              ),
            ),
          ),
        ),
        favorites: favorites,
      ),
    );

    await tester.tap(find.byType(FavoriteButton));
    await tester.tap(find.text('Casa Valduga'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });

  testWidgets('fora do app não mostra o coração', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FavoriteButton(winery: valduga)),
      ),
    );

    expect(find.byType(IconButton), findsNothing);
  });
}
