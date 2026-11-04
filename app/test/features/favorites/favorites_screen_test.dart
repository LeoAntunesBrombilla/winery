import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/app.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/favorites/favorites_screen.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/favorite_button.dart';

import '../../support/app_scope_harness.dart';
import '../../support/fakes.dart';
import '../../support/winery_fixture.dart';

void main() {
  const Coordinates user = Coordinates(-29.1717, -51.5189);
  final List<Winery> serra = <Winery>[
    testWinery(
      id: 'longe',
      name: 'Adega Longe',
      coordinates: const Coordinates(-29.30, -51.50),
      rating: 4.2,
    ),
    testWinery(
      id: 'perto',
      name: 'Vinícola Perto',
      coordinates: const Coordinates(-29.17, -51.52),
      rating: 4.8,
    ),
    testWinery(id: 'outra', name: 'Outra'),
  ];

  Future<FavoritesStore> pumpFavorites(
    WidgetTester tester, {
    List<String> ids = const <String>['longe', 'perto'],
  }) async {
    final FavoritesStore favorites = FavoritesStore(initial: ids);
    final WineryCatalog catalog = fakeCatalog(serra, user: user);
    await catalog.ensureLoaded();
    await tester.pumpWidget(
      withAppScope(
        FavoritesScreen(catalog: catalog, favorites: favorites),
        favorites: favorites,
        catalog: catalog,
      ),
    );
    await tester.pump();
    return favorites;
  }

  testWidgets('lista as favoritas com distância e nota', (
    WidgetTester tester,
  ) async {
    await pumpFavorites(tester);

    expect(find.text('Vinícola Perto'), findsOneWidget);
    expect(find.text('Adega Longe'), findsOneWidget);
    expect(find.text('Outra'), findsNothing);
    expect(find.text('Bento Gonçalves · 0,2 km'), findsOneWidget);
    expect(find.text('4,8'), findsOneWidget);
    expect(find.text('4,2'), findsOneWidget);
  });

  testWidgets('ordena da mais próxima para a mais longe', (
    WidgetTester tester,
  ) async {
    await pumpFavorites(tester);

    final List<String> order = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((ListTile t) => (t.title! as Text).data!)
        .toList();
    expect(order, <String>['Vinícola Perto', 'Adega Longe']);
  });

  testWidgets('tocar abre a ficha', (WidgetTester tester) async {
    await pumpFavorites(tester);

    await tester.tap(find.text('Adega Longe'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<WineryDetailScreen>(find.byType(WineryDetailScreen))
          .winery
          .id,
      'longe',
    );
  });

  testWidgets('remove direto da aba', (WidgetTester tester) async {
    final FavoritesStore favorites = await pumpFavorites(tester);

    await tester.tap(find.byType(FavoriteButton).first);
    await tester.pump();

    expect(favorites.ids, <String>['longe']);
    expect(find.text('Vinícola Perto'), findsNothing);
    expect(find.text('Vinícola Perto removida dos favoritos'), findsOneWidget);
  });

  testWidgets('sem favoritas explica como favoritar', (
    WidgetTester tester,
  ) async {
    await pumpFavorites(tester, ids: const <String>[]);

    expect(find.text(FavoritesScreen.emptyMessage), findsOneWidget);
    expect(find.textContaining('Toque no coração'), findsOneWidget);
  });

  testWidgets(
    'aba Favoritos na navegação mostra o que foi favoritado no mapa',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        WineryFinderApp(
          repository: FakeRepository(serra),
          location: const FixedLocation(user),
          favorites: FavoritesStore(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Vinícola Perto'),
          matching: find.byType(FavoriteButton),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Favoritos'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(FavoritesScreen),
          matching: find.text('Vinícola Perto'),
        ),
        findsOneWidget,
      );
    },
  );
}
