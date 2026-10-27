import 'package:flutter/material.dart';
import 'package:winery_finder/widgets/placeholder_screen.dart';

/// Aba Mapa: busca, filtros por tipo de vinho e lista de vinícolas próximas.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Mapa',
      message: 'Vinícolas próximas aparecerão aqui.',
      icon: Icons.map_outlined,
    );
  }
}
