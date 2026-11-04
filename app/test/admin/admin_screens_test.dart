import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/admin/admin_app.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/winery_form_data.dart';
import 'package:winery_finder/admin/winery_form_screen.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

import '../support/fake_admin.dart';
import '../support/winery_fixture.dart';

void main() {
  // O ListView do formulário (cada campo de texto tem o seu Scrollable).
  final Finder form = find.byType(Scrollable).first;

  Future<void> fill(WidgetTester tester, String label, String text) async {
    final Finder field = find.widgetWithText(TextFormField, label);
    await tester.scrollUntilVisible(field, 100, scrollable: form);
    await tester.enterText(field, text);
  }

  Future<void> tapSave(WidgetTester tester) async {
    final Finder save = find.widgetWithText(FilledButton, 'Salvar');
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
  }

  Future<void> fillRequired(WidgetTester tester) async {
    await fill(tester, 'Nome *', 'Casa Nova');
    await fill(tester, 'Cidade *', 'Garibaldi');
    await fill(tester, 'Endereço *', 'Rua A, 10');
    await fill(tester, 'Latitude *', '-29,25');
    await fill(tester, 'Longitude *', '-51,53');
    for (final String day in WeeklyHours.labels.take(6)) {
      await fill(tester, day, '09:00-17:00');
    }
    await fill(tester, 'Domingo', 'fechado');
    await fill(tester, r'Degustação por pessoa (R$) *', '60');
  }

  group('formulário de vinícola', () {
    testWidgets('obrigatórios vazios impedem salvar e mostram mensagem', (
      WidgetTester tester,
    ) async {
      final FakeAdminStore store = FakeAdminStore();
      await tester.pumpWidget(
        MaterialApp(home: WineryFormScreen(store: store)),
      );

      await tapSave(tester);

      expect(store.created, isEmpty);
      // Inclusive os campos que estavam fora da tela ao salvar.
      expect(
        find.text('Obrigatório (09:00-17:00 ou fechado)'),
        findsNWidgets(7),
      );
      await tester.scrollUntilVisible(
        find.text('Nome *'),
        -200,
        scrollable: form,
      );
      expect(find.text('Obrigatório'), findsWidgets);
    });

    testWidgets('com os obrigatórios preenchidos, salva a nova vinícola', (
      WidgetTester tester,
    ) async {
      final FakeAdminStore store = FakeAdminStore();
      await tester.pumpWidget(
        MaterialApp(home: WineryFormScreen(store: store)),
      );

      await fillRequired(tester);
      await tester.ensureVisible(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tapSave(tester);

      final WineryFormData data = store.created.single;
      expect(data.name, 'Casa Nova');
      expect(data.location.latitude, -29.25);
      expect(data.hours.on(DateTime.sunday), isNull);
      expect(data.hours.on(DateTime.monday), const OpeningInterval(540, 1020));
      expect(data.tastingPriceCents, 6000);
      expect(data.requiresReservation, isTrue);
      expect(data.rating, isNull);
    });

    testWidgets('edição abre preenchida e atualiza', (
      WidgetTester tester,
    ) async {
      final FakeAdminStore store = FakeAdminStore();
      await tester.pumpWidget(
        MaterialApp(
          home: WineryFormScreen(store: store, editing: testWinery()),
        ),
      );
      expect(find.text('Editar vinícola'), findsOneWidget);
      expect(find.text('Casa Valduga'), findsOneWidget);

      await fill(tester, r'Degustação por pessoa (R$) *', '90,00');
      await tapSave(tester);

      expect(store.updated.keys, <String>['casa-valduga']);
      expect(store.updated['casa-valduga']!.tastingPriceCents, 9000);
      expect(store.updated['casa-valduga']!.hours, testHours);
    });

    testWidgets('sem permissão mostra a mensagem das regras', (
      WidgetTester tester,
    ) async {
      final FakeAdminStore store = FakeAdminStore()
        ..failure = const AdminException(
          'Sua conta não tem permissão para gravar no catálogo.',
        );
      await tester.pumpWidget(
        MaterialApp(home: WineryFormScreen(store: store)),
      );

      await fillRequired(tester);
      await tapSave(tester);

      expect(
        find.text('Sua conta não tem permissão para gravar no catálogo.'),
        findsOneWidget,
      );
      expect(find.byType(WineryFormScreen), findsOneWidget);
    });
  });

  group('app do admin', () {
    testWidgets('login com erro mostra a mensagem', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        AdminApp(
          auth: FakeAdminAuth(
            failure: const AdminException('Esta conta não é administradora.'),
          ),
          store: FakeAdminStore(),
          photos: FakePhotoStore(),
          picker: FakePhotoPicker(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'turista@example.com',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'x');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Esta conta não é administradora.'), findsOneWidget);
    });

    testWidgets('admin logado cadastra e a vinícola aparece na listagem', (
      WidgetTester tester,
    ) async {
      final FakeAdminStore store = FakeAdminStore(<Winery>[testWinery()]);
      await tester.pumpWidget(
        AdminApp(
          auth: FakeAdminAuth(),
          store: store,
          photos: FakePhotoStore(),
          picker: FakePhotoPicker(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'admin@example.com',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'x');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Casa Valduga'), findsOneWidget);

      await tester.tap(find.text('Nova vinícola'));
      await tester.pumpAndSettle();
      await fillRequired(tester);
      await tapSave(tester);

      await tester.pumpAndSettle();

      expect(store.created.single.name, 'Casa Nova');
      expect(find.text('Vinícolas'), findsOneWidget);
      expect(find.text('Casa Nova'), findsOneWidget);
    });

    testWidgets('sair volta para o login', (WidgetTester tester) async {
      final FakeAdminAuth auth = FakeAdminAuth();
      await tester.pumpWidget(
        AdminApp(
          auth: auth,
          store: FakeAdminStore(),
          photos: FakePhotoStore(),
          picker: FakePhotoPicker(),
        ),
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'a');
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'b');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Sair'));
      await tester.pumpAndSettle();

      expect(auth.signOuts, 1);
      expect(find.text('Entrar'), findsOneWidget);
    });
  });
}
