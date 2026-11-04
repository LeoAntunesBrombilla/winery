import 'package:flutter/material.dart';
import 'package:winery_finder/features/spike/map_spike_screen.dart';

/// Ponto de entrada do spike de mapa e rota (TT01):
/// `flutter run -t lib/main_spike.dart`.
void main() {
  runApp(
    const MaterialApp(
      title: 'Winery Finder — spike',
      debugShowCheckedModeBanner: false,
      home: MapSpikeScreen(),
    ),
  );
}
