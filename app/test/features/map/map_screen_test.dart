import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/map/map_screen.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';

import '../../support/winery_fixture.dart';

class _FakeRepository implements WineryRepository {
  const _FakeRepository(this.wineries);

  final List<Winery> wineries;

  @override
  Future<List<Winery>> fetchAll() async => wineries;
}

class _FixedLocation implements LocationProvider {
  const _FixedLocation(this.coordinates);

  final Coordinates? coordinates;

  @override
  Future<Coordinates?> current() async => coordinates;
}

void main() {
  // Usuário no centro de Bento Gonçalves.
  const Coordinates user = Coordinates(-29.1717, -51.5189);
  final List<Winery> catalog = <Winery>[
    testWinery(
      id: 'longe',
      name: 'Adega Longe',
      coordinates: const Coordinates(-29.30, -51.50),
    ),
    testWinery(
      id: 'perto',
      name: 'Vinícola Perto',
      coordinates: const Coordinates(-29.17, -51.52),
    ),
  ];

  List<String> visibleOrder(WidgetTester tester) => tester
      .widgetList<ListTile>(find.byType(ListTile))
      .map((ListTile tile) => (tile.title! as Text).data!)
      .toList();

  /// Mapa falso que lista os nomes na ordem recebida.
  Widget fakeMap(
    BuildContext context,
    List<Winery> wineries,
    ValueChanged<Winery> onSelected,
  ) {
    return Column(
      children: <Widget>[
        for (final Winery w in wineries)
          TextButton(
            key: ValueKey<String>('pin-${w.id}'),
            onPressed: () => onSelected(w),
            child: Text('pin ${w.name}'),
          ),
      ],
    );
  }

  Future<void> pumpMap(
    WidgetTester tester, {
    Coordinates? location,
    List<Winery>? wineries,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(
          repository: _FakeRepository(wineries ?? catalog),
          location: _FixedLocation(location),
          mapBuilder: fakeMap,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> showList(WidgetTester tester) async {
    await tester.tap(find.text('Lista'));
    await tester.pumpAndSettle();
  }

  testWidgets('lista ordenada por distância crescente', (
    WidgetTester tester,
  ) async {
    await pumpMap(tester, location: user);
    await showList(tester);

    expect(visibleOrder(tester), <String>['Vinícola Perto', 'Adega Longe']);
    expect(find.text('Bento Gonçalves · 0,2 km'), findsOneWidget);
  });

  testWidgets('sem localização ordena por nome', (WidgetTester tester) async {
    await pumpMap(tester);
    await showList(tester);

    expect(visibleOrder(tester), <String>['Adega Longe', 'Vinícola Perto']);
    expect(find.textContaining('km'), findsNothing);
  });

  testWidgets('mapa e lista mostram o mesmo conjunto', (
    WidgetTester tester,
  ) async {
    await pumpMap(tester, location: user);
    expect(find.text('pin Vinícola Perto'), findsOneWidget);
    expect(find.text('pin Adega Longe'), findsOneWidget);

    await showList(tester);
    expect(visibleOrder(tester), hasLength(2));

    await tester.tap(find.text('Mapa').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('pin '), findsNWidgets(2));
  });

  testWidgets('tocar num item da lista abre a ficha', (
    WidgetTester tester,
  ) async {
    await pumpMap(tester, location: user);
    await showList(tester);

    await tester.tap(find.text('Adega Longe'));
    await tester.pumpAndSettle();

    expect(find.byType(WineryDetailScreen), findsOneWidget);
    expect(
      tester
          .widget<WineryDetailScreen>(find.byType(WineryDetailScreen))
          .winery
          .id,
      'longe',
    );
  });

  testWidgets('tocar num pin abre a ficha', (WidgetTester tester) async {
    await pumpMap(tester, location: user);

    await tester.tap(find.byKey(const ValueKey<String>('pin-perto')));
    await tester.pumpAndSettle();

    expect(find.byType(WineryDetailScreen), findsOneWidget);
  });

  testWidgets('sem vinícolas mostra o estado vazio', (
    WidgetTester tester,
  ) async {
    await pumpMap(tester, wineries: const <Winery>[]);

    expect(find.text('Vinícolas próximas aparecerão aqui.'), findsOneWidget);
  });
}
