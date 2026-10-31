import 'dart:io';
import 'package:flutter/material.dart';
import 'package:winery_finder/data/favorites_repository.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Aba Favoritos: exibe a lista de vinícolas favoritadas pelo usuário com o ícone de coração.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Vinícolas Favoritas'),
      ),
      body: AnimatedBuilder(
        animation: FavoritesRepository.instance,
        builder: (context, _) {
          final favoriteWineries = FavoritesRepository.instance.getFavoriteWineries();

          if (favoriteWineries.isEmpty) {
            return const PlaceholderScreen(
              title: 'Favoritos',
              message: 'Você ainda não salvou nenhuma vinícola.',
              icon: Icons.favorite_outline,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteWineries.length,
            itemBuilder: (context, index) {
              final winery = favoriteWineries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: winery.logoUrl.isNotEmpty
                        ? ClipOval(
                            child: winery.logoUrl.startsWith('http')
                                ? Image.network(
                                    winery.logoUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.wine_bar),
                                  )
                                : Image.file(
                                    File(winery.logoUrl),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => const Icon(Icons.wine_bar),
                                  ),
                          )
                        : const Icon(Icons.wine_bar),
                  ),
                  title: Text(winery.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${winery.city} • ${WineryFilter.formatDistance(winery.distanceKm)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.redAccent),
                        tooltip: 'Remover dos Favoritos',
                        onPressed: () {
                          FavoritesRepository.instance.toggleFavorite(winery.id);
                        },
                      ),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(winery.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
