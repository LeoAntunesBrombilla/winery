import 'package:flutter/material.dart';
import 'package:winery_finder/data/recents_store.dart';
import 'package:winery_finder/data/winery_catalog.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/features/winery_detail/winery_detail_screen.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Aba Recentes (US13): as últimas fichas abertas, da mais recente para a
/// mais antiga, com a data; tocar reabre a ficha.
class RecentsScreen extends StatelessWidget {
  const RecentsScreen({
    required this.catalog,
    required this.recents,
    super.key,
  });

  final WineryCatalog catalog;
  final RecentsStore recents;

  static const String emptyMessage = 'Nenhuma vinícola visitada ainda.';

  /// "03/11/2026".
  static String formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _confirmClear(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text('As vinícolas recentes serão apagadas.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await recents.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[catalog, recents]),
      builder: (BuildContext context, Widget? child) {
        final List<(Winery, DateTime)> items = <(Winery, DateTime)>[
          for (final RecentVisit visit in recents.visits)
            if (catalog.byId(visit.wineryId) case final Winery winery)
              (winery, visit.openedAt),
        ];
        if (recents.visits.isEmpty || (catalog.isLoaded && items.isEmpty)) {
          return const PlaceholderScreen(
            title: 'Recentes',
            message: emptyMessage,
            icon: Icons.history,
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recentes'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Limpar histórico',
                onPressed: () => _confirmClear(context),
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
            ],
          ),
          body: !catalog.isLoaded
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final (Winery winery, DateTime openedAt) = items[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(winery.name),
                      subtitle: Text(
                        '${winery.city} · ${formatDate(openedAt)}',
                      ),
                      onTap: () => openWineryDetail(context, winery),
                    );
                  },
                ),
        );
      },
    );
  }
}
