import 'package:flutter/material.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/winery_form_screen.dart';
import 'package:winery_finder/domain/winery.dart';

/// Listagem do catálogo para o admin (US17): tocar edita, o botão
/// adiciona; a lista recarrega depois de salvar.
class AdminWineriesScreen extends StatefulWidget {
  const AdminWineriesScreen({
    required this.store,
    required this.onSignOut,
    this.trailingBuilder,
    super.key,
  });

  final AdminWineryStore store;
  final VoidCallback onSignOut;

  /// Ação extra em cada item (ex.: fotos, US18).
  final Widget Function(BuildContext context, Winery winery)? trailingBuilder;

  @override
  State<AdminWineriesScreen> createState() => _AdminWineriesScreenState();
}

class _AdminWineriesScreenState extends State<AdminWineriesScreen> {
  late Future<List<Winery>> _wineries = widget.store.list();

  Future<void> _openForm([Winery? editing]) async {
    final bool? saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) =>
            WineryFormScreen(store: widget.store, editing: editing),
      ),
    );
    if (saved ?? false) {
      // Bloco, não arrow: o setState não pode receber um Future de volta.
      setState(() {
        _wineries = widget.store.list();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vinícolas'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Sair',
            onPressed: widget.onSignOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('Nova vinícola'),
      ),
      body: FutureBuilder<List<Winery>>(
        future: _wineries,
        builder: (BuildContext context, AsyncSnapshot<List<Winery>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
          }
          final List<Winery>? wineries = snapshot.data;
          if (wineries == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (wineries.isEmpty) {
            return const Center(child: Text('Nenhuma vinícola cadastrada.'));
          }
          return ListView.separated(
            itemCount: wineries.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final Winery winery = wineries[index];
              return ListTile(
                title: Text(winery.name),
                subtitle: Text(winery.city),
                trailing: widget.trailingBuilder?.call(context, winery),
                onTap: () => _openForm(winery),
              );
            },
          );
        },
      ),
    );
  }
}
