import 'package:flutter/material.dart';
import 'package:winery_finder/app_scope.dart';
import 'package:winery_finder/data/favorites_store.dart';
import 'package:winery_finder/domain/winery.dart';

/// Coração que favorita a vinícola com um toque e confirma com uma
/// mensagem (US11). Não aparece fora de um [AppScope].
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({required this.winery, super.key});

  final Winery winery;

  static String message(Winery winery, {required bool favorite}) => favorite
      ? '${winery.name} adicionada aos favoritos'
      : '${winery.name} removida dos favoritos';

  Future<void> _toggle(BuildContext context, FavoritesStore favorites) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final bool favorite = await favorites.toggle(winery.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message(winery, favorite: favorite)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final FavoritesStore? favorites = AppScope.maybeOf(context)?.favorites;
    if (favorites == null) {
      return const SizedBox.shrink();
    }
    return ListenableBuilder(
      listenable: favorites,
      builder: (BuildContext context, Widget? child) {
        final bool favorite = favorites.contains(winery.id);
        return IconButton(
          tooltip: favorite ? 'Remover dos favoritos' : 'Favoritar',
          isSelected: favorite,
          onPressed: () => _toggle(context, favorites),
          icon: const Icon(Icons.favorite_border),
          selectedIcon: Icon(
            Icons.favorite,
            color: Theme.of(context).colorScheme.error,
          ),
        );
      },
    );
  }
}
