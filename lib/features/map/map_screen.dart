import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/favorites_repository.dart';
import 'package:winery_finder/data/wine_repository.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/features/admin/admin_dashboard_screen.dart';
import 'package:winery_finder/features/map/register_winery_dialog.dart';
import 'package:winery_finder/features/map/winery_products_panel.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Aba Mapa: exibe o mapa interativo, busca, filtros, lista, detalhes e vinhos à venda.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String _searchQuery = '';
  final Set<WineType> _selectedTypes = <WineType>{};
  final MapController _mapController = MapController();
  Winery? _selectedWinery;

  void _showWineryDetails(Winery winery) {
    setState(() => _selectedWinery = winery);
    _mapController.move(LatLng(winery.latitude, winery.longitude), 14.0);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final currentUserEmail = AuthRepository.instance.currentUser?.email;
        final bool canModify = currentUserEmail == winery.creatorEmail || currentUserEmail == 'admin@winery.com';

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return AnimatedBuilder(
              animation: WineRepository.instance,
              builder: (context, _) {
                final wineryWines = WineRepository.instance.getWinesForWinery(winery.id);

                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: winery.logoUrl.isNotEmpty
                                ? ClipOval(
                                    child: winery.logoUrl.startsWith('http')
                                        ? Image.network(
                                            winery.logoUrl,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.wine_bar, size: 28),
                                          )
                                        : Image.file(
                                            File(winery.logoUrl),
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, stack) => const Icon(Icons.wine_bar, size: 28),
                                          ),
                                  )
                                : const Icon(Icons.wine_bar, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(winery.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(winery.city, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                              ],
                            ),
                          ),
                          AnimatedBuilder(
                            animation: FavoritesRepository.instance,
                            builder: (context, _) {
                              final isFav = FavoritesRepository.instance.isFavorite(winery.id);
                              return IconButton(
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : null,
                                  size: 28,
                                ),
                                onPressed: () {
                                  FavoritesRepository.instance.toggleFavorite(winery.id);
                                },
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(winery.rating.toStringAsFixed(1), style: theme.textTheme.titleMedium),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      if (winery.address.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Endereço: ${winery.address}', style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          const Icon(Icons.directions_car_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text('Distância: ${WineryFilter.formatDistance(winery.distanceKm)}', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.account_circle_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text('Cadastrado por: ${winery.creatorEmail}', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (winery.responsibleName.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 20),
                            const SizedBox(width: 8),
                            Text('Responsável: ${winery.responsibleName}', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (winery.sommelierName.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.local_bar_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text('Sommelier: ${winery.sommelierName}', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (winery.cultivatedGrapes.isNotEmpty) ...[
                        Text('Uvas Cultivadas:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: winery.cultivatedGrapes.map((g) => Chip(label: Text(g))).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text('Tipos de Vinho:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: winery.wineTypes.map((t) => Chip(label: Text(t.label), backgroundColor: theme.colorScheme.primaryContainer)).toList(),
                      ),
                      const Divider(height: 24),
                      // Seção de Vinhos à Venda
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Vinhos & Preços para Venda:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          if (canModify)
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => WineryProductsPanel(winery: winery),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.inventory, size: 18),
                              label: const Text('Painel de Produtos'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (wineryWines.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Nenhum vinho postado para venda por esta vinícola ainda.'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: wineryWines.length,
                          itemBuilder: (context, i) {
                            final wine = wineryWines[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Foto do vinho
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: wine.imageUrl.isNotEmpty
                                              ? (wine.imageUrl.startsWith('http')
                                                  ? Image.network(
                                                      wine.imageUrl,
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (ctx, err, stack) => Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: const Color(0xFF722F37),
                                                        child: const Icon(Icons.wine_bar, color: Colors.white),
                                                      ),
                                                    )
                                                  : Image.file(
                                                      File(wine.imageUrl),
                                                      width: 60,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (ctx, err, stack) => Container(
                                                        width: 60,
                                                        height: 60,
                                                        color: const Color(0xFF722F37),
                                                        child: const Icon(Icons.wine_bar, color: Colors.white),
                                                      ),
                                                    ))
                                              : Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: const Color(0xFF722F37),
                                                  child: const Icon(Icons.wine_bar, color: Colors.white),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(wine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${wine.type.label} • Safra: ${wine.vintage}${wine.grape.isNotEmpty ? " • Uva: ${wine.grape}" : ""}',
                                                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                                              ),
                                              const SizedBox(height: 6),
                                              if (wine.description.isNotEmpty)
                                                Text(wine.description, style: theme.textTheme.bodyMedium),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'R\$ ${wine.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (wine.paymentLink.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Link de pagamento: ${wine.paymentLink}')),
                                            );
                                          },
                                          icon: const Icon(Icons.payment, size: 18),
                                          label: const Text('Comprar / Pagamento Direct'),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      if (winery.photoUrls.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Fotos:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: winery.photoUrls.length,
                            itemBuilder: (context, i) {
                              final photoPath = winery.photoUrls[i];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: photoPath.startsWith('http')
                                      ? Image.network(
                                          photoPath,
                                          width: 140,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            width: 140,
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        )
                                      : Image.file(
                                          File(photoPath),
                                          width: 140,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Container(
                                            width: 140,
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: AuthRepository.instance,
      builder: (context, _) {
        final isAdmin = AuthRepository.instance.currentUser?.email == 'admin@winery.com';

        return AnimatedBuilder(
          animation: WineryRepository.instance,
          builder: (context, child) {
            final allWineries = WineryRepository.instance.wineries;
            final filteredWineries = WineryFilter.apply(
              allWineries,
              query: _searchQuery,
              types: _selectedTypes,
            );

            return Scaffold(
              appBar: AppBar(
                title: const Row(
                  children: [
                    WineryLogo(size: 32, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Winery Finder'),
                  ],
                ),
                actions: [
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      tooltip: 'Painel do Administrador',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.add_location_alt_outlined),
                    tooltip: 'Cadastrar Vinícola',
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => const RegisterWineryDialog(),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Sair da Conta',
                    onPressed: AuthRepository.instance.logout,
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Search & Filter bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar vinícola ou cidade...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: WineType.values.map((type) {
                              final isSelected = _selectedTypes.contains(type);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(type.label),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedTypes.add(type);
                                      } else {
                                        _selectedTypes.remove(type);
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Map View
                  Expanded(
                    flex: 3,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(-29.1683, -51.5204), // Vale dos Vinhedos
                        initialZoom: 11.5,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.winery.winery_finder',
                        ),
                        MarkerLayer(
                          markers: filteredWineries.map((winery) {
                            final isSelected = _selectedWinery?.id == winery.id;
                            return Marker(
                              point: LatLng(winery.latitude, winery.longitude),
                              width: 40,
                              height: 40,
                              child: GestureDetector(
                                onTap: () => _showWineryDetails(winery),
                                child: Icon(
                                  Icons.location_on,
                                  size: isSelected ? 46 : 36,
                                  color: isSelected ? Colors.amber : const Color(0xFF722F37),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  // Wineries List View
                  Expanded(
                    flex: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                            child: Text(
                              'Vinícolas Próximas (${filteredWineries.length})',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: filteredWineries.isEmpty
                                ? const Center(child: Text('Nenhuma vinícola encontrada.'))
                                : ListView.builder(
                                    itemCount: filteredWineries.length,
                                    itemBuilder: (context, index) {
                                      final winery = filteredWineries[index];
                                      final isSelected = _selectedWinery?.id == winery.id;
                                      return Material(
                                        color: Colors.transparent,
                                        child: ListTile(
                                          selected: isSelected,
                                          selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
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
                                          title: Text(winery.name),
                                          subtitle: Text('${winery.city} • ${WineryFilter.formatDistance(winery.distanceKm)}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AnimatedBuilder(
                                                animation: FavoritesRepository.instance,
                                                builder: (context, _) {
                                                  final isFav = FavoritesRepository.instance.isFavorite(winery.id);
                                                  return IconButton(
                                                    icon: Icon(
                                                      isFav ? Icons.favorite : Icons.favorite_border,
                                                      color: isFav ? Colors.redAccent : null,
                                                      size: 22,
                                                    ),
                                                    onPressed: () {
                                                      FavoritesRepository.instance.toggleFavorite(winery.id);
                                                    },
                                                  );
                                                },
                                              ),
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(winery.rating.toStringAsFixed(1)),
                                            ],
                                          ),
                                          onTap: () => _showWineryDetails(winery),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => const RegisterWineryDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar Vinícola'),
              ),
            );
          },
        );
      },
    );
  }
}
