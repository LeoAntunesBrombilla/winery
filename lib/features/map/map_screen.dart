import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winery_finder/data/auth_repository.dart';
import 'package:winery_finder/data/favorites_repository.dart';
import 'package:winery_finder/data/wine_repository.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/winery.dart';
import 'package:winery_finder/domain/winery_filter.dart';
import 'package:winery_finder/features/admin/admin_dashboard_screen.dart';
import 'package:winery_finder/features/map/edit_winery_dialog.dart';
import 'package:winery_finder/features/map/register_winery_dialog.dart';
import 'package:winery_finder/features/map/winery_products_panel.dart';
import 'package:winery_finder/widgets/winery_logo.dart';

/// Aba Mapa: exibe o mapa interativo no topo, busca, trajeto real passo a passo pelas ruas/rodovias e navegação.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultOrigin = LatLng(-29.1683, -51.5204); // Ponto padrão (Bento Gonçalves, RS)

  String _searchQuery = '';
  final Set<WineType> _selectedTypes = <WineType>{};
  final MapController _mapController = MapController();
  Winery? _selectedWinery;
  Winery? _routeWinery; // Vinícola com rota ativa
  List<LatLng> _routePoints = <LatLng>[]; // Pontos das curvas reais das ruas/rodovias (NUNCA linha reta)
  List<String> _routeStepsInstructions = <String>[]; // Passo a passo dos nomes das ruas e avenidas
  LatLng _routeOriginPoint = _defaultOrigin; // Coordenadas do endereço do usuário
  String _routeInfoText = ''; // Distância e tempo do trajeto real

  /// Busca e desenha estritamente o trajeto curvo pelas ruas e rodovias (sem linhas retas)
  Future<void> _fetchRealRoadRoute(Winery winery) async {
    final userAddress = AuthRepository.instance.currentUser?.address ?? '';

    setState(() {
      _routeWinery = winery;
      _selectedWinery = winery;
      _routePoints = <LatLng>[]; // Garante que não exibe linha reta enquanto carrega
      _routeStepsInstructions = <String>[];
      _routeInfoText = 'Mapeando ruas e avenidas a partir de ${userAddress.isNotEmpty ? userAddress : "Seu Endereço"}...';
    });

    LatLng originPoint = _defaultOrigin;

    // 1. Geocodifica o endereço do usuário via OpenStreetMap Nominatim
    if (userAddress.isNotEmpty) {
      try {
        final geoUrl = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(userAddress)}&format=json&limit=1',
        );
        final client = HttpClient();
        client.userAgent = 'WineryFinderApp/1.0';
        final request = await client.getUrl(geoUrl);
        final response = await request.close();

        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final List<dynamic> geoData = jsonDecode(responseBody) as List<dynamic>;
          if (geoData.isNotEmpty) {
            final Map<String, dynamic> firstGeo = Map<String, dynamic>.from(geoData[0] as Map);
            final lat = double.parse(firstGeo['lat'].toString());
            final lon = double.parse(firstGeo['lon'].toString());
            originPoint = LatLng(lat, lon);
          }
        }
      } catch (e) {
        debugPrint('Erro ao geolocalizar endereço: $e');
      }
    }

    final destination = LatLng(winery.latitude, winery.longitude);

    // 2. Busca o trajeto real com geometria detalhada e passos das ruas (OSRM Routing)
    final osrmEndpoints = [
      'https://router.project-osrm.org/route/v1/driving/${originPoint.longitude},${originPoint.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson&steps=true',
      'https://routing.openstreetmap.de/routed-car/route/v1/driving/${originPoint.longitude},${originPoint.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson&steps=true',
    ];

    for (final endpoint in osrmEndpoints) {
      try {
        final url = Uri.parse(endpoint);
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 8);
        final request = await client.getUrl(url);
        final response = await request.close();

        if (response.statusCode == 200) {
          final responseBody = await response.transform(utf8.decoder).join();
          final Map<String, dynamic> data = jsonDecode(responseBody) as Map<String, dynamic>;
          final List<dynamic>? routes = data['routes'] as List<dynamic>?;

          if (routes != null && routes.isNotEmpty) {
            final Map<String, dynamic> routeData = Map<String, dynamic>.from(routes[0] as Map);
            final Map<String, dynamic> geometry = Map<String, dynamic>.from(routeData['geometry'] as Map);
            final List<dynamic> coordinates = geometry['coordinates'] as List<dynamic>;

            final points = coordinates.map((coord) {
              final list = coord as List<dynamic>;
              return LatLng((list[1] as num).toDouble(), (list[0] as num).toDouble());
            }).toList();

            // Extrai o passo a passo dos nomes de ruas e rodovias
            final List<String> stepsList = <String>[];
            if (routeData.containsKey('legs')) {
              final List<dynamic> legs = routeData['legs'] as List<dynamic>;
              if (legs.isNotEmpty) {
                final Map<String, dynamic> firstLeg = Map<String, dynamic>.from(legs[0] as Map);
                if (firstLeg.containsKey('steps')) {
                  final List<dynamic> steps = firstLeg['steps'] as List<dynamic>;
                  for (final stepItem in steps) {
                    final Map<String, dynamic> stepMap = Map<String, dynamic>.from(stepItem as Map);
                    final String streetName = (stepMap['name'] as String? ?? '').trim();
                    final num stepDist = (stepMap['distance'] as num?) ?? 0;
                    if (streetName.isNotEmpty && stepDist > 10) {
                      final String formattedDist = stepDist >= 1000
                          ? '${(stepDist / 1000).toStringAsFixed(1)} km'
                          : '${stepDist.round()} m';
                      if (!stepsList.contains('Siga por $streetName ($formattedDist)')) {
                        stepsList.add('Siga por $streetName ($formattedDist)');
                      }
                    }
                  }
                }
              }
            }

            final num distanceMeters = routeData['distance'] as num;
            final num durationSeconds = routeData['duration'] as num;
            final durationMinutes = (durationSeconds / 60).round();
            final distKm = (distanceMeters / 1000).toStringAsFixed(1);

            // Apenas atribui os pontos se forem mais de 2 coordenadas (curvas das ruas reais)
            if (mounted && points.length > 2) {
              setState(() {
                _routePoints = points;
                _routeOriginPoint = originPoint;
                _routeStepsInstructions = stepsList;
                _routeInfoText = 'Trajeto pelas Ruas: $distKm km • ~$durationMinutes min';
              });

              final bounds = LatLngBounds.fromPoints(points);
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(55.0),
                ),
              );
              return;
            }
          }
        }
      } catch (e) {
        debugPrint('Erro no servidor OSRM ($endpoint): $e');
      }
    }

    // Caso ocorra falha de rede, zera os pontos para NUNCA exibir linha reta
    if (mounted) {
      setState(() {
        _routeOriginPoint = originPoint;
        _routePoints = <LatLng>[]; // NUNCA exibe linha reta
        _routeInfoText = 'Trajeto direto no Google Maps (${WineryFilter.formatDistance(winery.distanceKm)})';
      });
    }
  }

  /// Abre o Google Maps traçando a rota direto do endereço do usuário cadastrado até a vinícola
  Future<void> _openGoogleMapsRoute(Winery winery) async {
    await _fetchRealRoadRoute(winery);

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    final userAddress = AuthRepository.instance.currentUser?.address ?? '';
    final String originParam = userAddress.isNotEmpty ? Uri.encodeComponent(userAddress) : '';
    final String destinationParam = Uri.encodeComponent('${winery.name}, ${winery.address}');

    final String mapsUrlString = originParam.isNotEmpty
        ? 'https://www.google.com/maps/dir/?api=1&origin=$originParam&destination=${winery.latitude},${winery.longitude}&destination_place_id=$destinationParam&travelmode=driving'
        : 'https://www.google.com/maps/dir/?api=1&destination=${winery.latitude},${winery.longitude}&destination_place_id=$destinationParam&travelmode=driving';

    final Uri googleMapsUri = Uri.parse(mapsUrlString);

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(googleMapsUri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abrindo rota no Google Maps de ${userAddress.isNotEmpty ? userAddress : "seu endereço"} para ${winery.name}...'),
          ),
        );
      }
    }
  }

  void _selectWinery(Winery winery) {
    setState(() => _selectedWinery = winery);
    _mapController.move(LatLng(winery.latitude, winery.longitude), 13.5);
  }

  /// Painel Inferior de Navegação e Seguir Rota no Google Maps com Passo a Passo das Ruas (Exibido abaixo do mapa)
  Widget _buildRouteNavigationPanel(Winery winery, ThemeData theme) {
    final userAddress = AuthRepository.instance.currentUser?.address ?? '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.alt_route, color: Color(0xFF722F37), size: 26),
                    const SizedBox(width: 8),
                    Text(
                      'Navegação & Trajeto Real',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  tooltip: 'Limpar Rota',
                  onPressed: () => setState(() {
                    _routeWinery = null;
                    _routePoints = <LatLng>[];
                    _routeStepsInstructions = <String>[];
                  }),
                ),
              ],
            ),
            const Divider(height: 12),
            Row(
              children: [
                const Icon(Icons.my_location, color: Colors.blueAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'De: ${userAddress.isNotEmpty ? userAddress : "Seu Endereço Cadastrado"}',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.greenAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Para: ${winery.name} (${winery.city})',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, size: 16, color: Color(0xFF722F37)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _routeInfoText,
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Exibição do Passo a Passo das Ruas, Avenidas e Rodovias
            if (_routeStepsInstructions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Ruas e Rodovias do Percurso:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _routeStepsInstructions.length,
                  itemBuilder: (context, sIdx) {
                    final stepText = _routeStepsInstructions[sIdx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.turn_right_outlined, size: 16, color: Color(0xFF722F37)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stepText,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Spacer(),
            const SizedBox(height: 8),
            // Botão Principal em Destaque: Seguir Rota GPS no Google Maps
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton.icon(
                onPressed: () => _openGoogleMapsRoute(winery),
                icon: const Icon(Icons.navigation, size: 20),
                label: const Text(
                  'Seguir Rota com GPS no Google Maps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Painel Inferior de Detalhes da Vinícola (NÃO COBRE O MAPA)
  Widget _buildWineryDetailsPanel(Winery winery, ThemeData theme) {
    final currentUserEmail = AuthRepository.instance.currentUser?.email;
    final bool canModify = currentUserEmail == winery.creatorEmail || currentUserEmail == 'admin@winery.com';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: WineRepository.instance,
        builder: (context, _) {
          final wineryWines = WineRepository.instance.getWinesForWinery(winery.id);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barra superior do painel com botão de voltar à lista
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _selectedWinery = null),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Voltar à Lista de Vinícolas'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _selectedWinery = null),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: winery.logoUrl.isNotEmpty
                          ? ClipOval(
                              child: winery.logoUrl.startsWith('http')
                                  ? Image.network(
                                      winery.logoUrl,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(Icons.wine_bar, size: 26),
                                    )
                                  : Image.file(
                                      File(winery.logoUrl),
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => const Icon(Icons.wine_bar, size: 26),
                                    ),
                            )
                          : const Icon(Icons.wine_bar, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(winery.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(winery.city, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
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
                            size: 24,
                          ),
                          onPressed: () {
                            FavoritesRepository.instance.toggleFavorite(winery.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Botões de Trajeto e Navegação
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _fetchRealRoadRoute(winery),
                        icon: const Icon(Icons.alt_route, size: 18),
                        label: const Text('Trajeto Real no Mapa', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => _openGoogleMapsRoute(winery),
                      icon: const Icon(Icons.map, size: 20),
                      tooltip: 'Abrir no Google Maps',
                    ),
                  ],
                ),
                if (canModify) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (_) => EditWineryDialog(winery: winery),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar Vinícola'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent, size: 20),
                        tooltip: 'Excluir Vinícola',
                        onPressed: () {
                          WineryRepository.instance.deleteWinery(winery.id);
                          setState(() => _selectedWinery = null);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Vinícola "${winery.name}" foi excluída.')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
                const Divider(height: 16),
                if (winery.address.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('Endereço: ${winery.address}', style: theme.textTheme.bodySmall),
                  ),
                Text('Distância: ${WineryFilter.formatDistance(winery.distanceKm)}', style: theme.textTheme.bodySmall),
                if (winery.responsibleName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Responsável: ${winery.responsibleName}', style: theme.textTheme.bodySmall),
                  ),
                if (winery.sommelierName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Sommelier: ${winery.sommelierName}', style: theme.textTheme.bodySmall),
                  ),
                if (winery.cultivatedGrapes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: winery.cultivatedGrapes.map((g) => Chip(label: Text(g, style: const TextStyle(fontSize: 11)), padding: EdgeInsets.zero)).toList(),
                  ),
                ],
                // Seção do Painel de Produtos para a Vinícola Criadora
                if (canModify) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WineryProductsPanel(winery: winery),
                          ),
                        );
                      },
                      icon: const Icon(Icons.inventory, size: 16),
                      label: const Text('Painel de Produtos'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (wineryWines.isNotEmpty) ...[
                  Text('Vinhos Disponíveis:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wineryWines.length,
                    itemBuilder: (context, i) {
                      final wine = wineryWines[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(wine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('R\$ ${wine.price.toStringAsFixed(2)} • ${wine.type.label}'),
                          trailing: wine.paymentLink.isNotEmpty
                              ? TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Link de pagamento: ${wine.paymentLink}')),
                                    );
                                  },
                                  child: const Text('Comprar'),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Painel Inferior com Lista de Vinícolas Próximas
  Widget _buildWineriesListPanel(List<Winery> filteredWineries, ThemeData theme) {
    return DecoratedBox(
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
                          title: Text(winery.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${winery.city} • ${WineryFilter.formatDistance(winery.distanceKm)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.alt_route, color: Color(0xFF722F37)),
                                tooltip: 'Trajeto Real do Seu Endereço',
                                onPressed: () => _fetchRealRoadRoute(winery),
                              ),
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
                            ],
                          ),
                          onTap: () => _selectWinery(winery),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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
                  // Barra de Busca e Filtros
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
                  // Visão do Mapa com Margem Elegante (100% LIVRE NO TOPO, NUNCA É COBERTA)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: FlutterMap(
                            mapController: _mapController,
                            options: const MapOptions(
                              initialCenter: _defaultOrigin, // Vale dos Vinhedos
                              initialZoom: 11.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.winery.winery_finder',
                              ),
                              // Trajeto Real pelas Ruas DESTACADO (PolylineLayer - Apenas quando houver mais de 2 pontos de curvas reais)
                              if (_routeWinery != null && _routePoints.length > 2)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _routePoints,
                                      strokeWidth: 11.0,
                                      color: Colors.amberAccent,
                                    ),
                                    Polyline(
                                      points: _routePoints,
                                      strokeWidth: 6.0,
                                      color: const Color(0xFF722F37),
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  if (_routeWinery != null)
                                    Marker(
                                      point: _routeOriginPoint,
                                      width: 44,
                                      height: 44,
                                      child: const Icon(Icons.my_location, size: 38, color: Colors.blueAccent),
                                    ),
                                  ...filteredWineries.map((winery) {
                                    final isSelected = _selectedWinery?.id == winery.id;
                                    final isRouteTarget = _routeWinery?.id == winery.id;
                                    return Marker(
                                      point: LatLng(winery.latitude, winery.longitude),
                                      width: 48,
                                      height: 48,
                                      child: GestureDetector(
                                        onTap: () => _selectWinery(winery),
                                        child: Icon(
                                          Icons.location_on,
                                          size: isRouteTarget ? 50 : (isSelected ? 44 : 36),
                                          color: isRouteTarget
                                              ? Colors.greenAccent
                                              : (isSelected ? Colors.amber : const Color(0xFF722F37)),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Painel Inferior Dividido (ABAIXO DO MAPA): Caixa de Rota, Detalhes ou Lista de Vinícolas
                  Expanded(
                    flex: 2,
                    child: _routeWinery != null
                        ? _buildRouteNavigationPanel(_routeWinery!, theme)
                        : (_selectedWinery != null
                            ? _buildWineryDetailsPanel(_selectedWinery!, theme)
                            : _buildWineriesListPanel(filteredWineries, theme)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
