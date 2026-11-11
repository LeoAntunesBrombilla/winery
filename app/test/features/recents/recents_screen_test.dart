import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/data/recents_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/recents/recents_screen.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';

import '../../support/app_scope_harness.dart';
import '../../support/fakes.dart';
import '../../support/winery_fixture.dart';

void main() {
  final List<Winery> serra = <Winery>[
    testWinery(id: 'valduga', name: 'Casa Valduga'),
    testWinery(id: 'aurora', name: 'Aurora', city: 'Garibaldi'),
  ];

  Future<(RecentsStore, WineryCatalog)> pumpRecents(
    WidgetTester tester, {
    List<RecentVisit> initial = const <RecentVisit>[],
  }) async {
    final RecentsStore recents = RecentsStore(initial: initial);
    final WineryCatalog catalog = fakeCatalog(serra);
    await catalog.ensureLoaded();
    await tester.pumpWidget(
      withAppScope(
        RecentsScreen(catalog: catalog, recents: recents),
        recents: recents,
        catalog: catalog,
      ),
    );
    return (recents, catalog);
  }

  List<String> titles(WidgetTester tester) => tester
      .widgetList<ListTile>(find.byType(ListTile))
      .map((ListTile t) => (t.title! as Text).data!)
      .toList();

  test('formatDate usa dd/mm/aaaa', () {
    expect(RecentsScreen.formatDate(DateTime(2026, 3, 7)), '07/03/2026');
  });

  testWidgets('mostra as recentes com data, da mais recente', (
    WidgetTester tester,
  ) async {
    await pumpRecents(
      tester,
      initial: <RecentVisit>[
        RecentVisit('valduga', DateTime(2026, 11, 1)),
        RecentVisit('aurora', DateTime(2026, 11, 3)),
      ],
    );

    expect(titles(tester), <String>['Aurora', 'Casa Valduga']);
    expect(find.text('Garibaldi · 03/11/2026'), findsOneWidget);
    expect(find.text('Bento Gonçalves · 01/11/2026'), findsOneWidget);
  });

  testWidgets('abrir uma ficha registra e reabrir sobe sem duplicar', (
    WidgetTester tester,
  ) async {
    final (RecentsStore recents, _) = await pumpRecents(
      tester,
      initial: <RecentVisit>[
        RecentVisit('valduga', DateTime(2026, 11, 1)),
        RecentVisit('aurora', DateTime(2026, 11, 3)),
      ],
    );

    await tester.tap(find.text('Casa Valduga'));
    await tester.pumpAndSettle();
    expect(find.byType(WineryDetailScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(titles(tester), <String>['Casa Valduga', 'Aurora']);
    expect(recents.visits, hasLength(2));
  });

  testWidgets('a ficha registra a data em que foi aberta', (
    WidgetTester tester,
  ) async {
    final RecentsStore recents = RecentsStore();
    await tester.pumpWidget(
      withAppScope(
        WineryDetailScreen(
          winery: serra.first,
          now: () => DateTime(2026, 11, 5, 15, 30),
        ),
        recents: recents,
      ),
    );

    expect(
      recents.visits.single,
      RecentVisit('valduga', DateTime(2026, 11, 5, 15, 30)),
    );
  });

  testWidgets('limpar histórico pede confirmação', (WidgetTester tester) async {
    final (RecentsStore recents, _) = await pumpRecents(
      tester,
      initial: <RecentVisit>[RecentVisit('valduga', DateTime(2026, 11, 1))],
    );

    await tester.tap(find.byTooltip('Limpar histórico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(recents.visits, hasLength(1));

    await tester.tap(find.byTooltip('Limpar histórico'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpar'));
    await tester.pumpAndSettle();

    expect(recents.visits, isEmpty);
    expect(find.text(RecentsScreen.emptyMessage), findsOneWidget);
  });

  testWidgets('sem histórico mostra estado vazio', (WidgetTester tester) async {
    await pumpRecents(tester);

    expect(find.text(RecentsScreen.emptyMessage), findsOneWidget);
  });
}
