import 'package:flutter/material.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/features/home/home_shell.dart';

/// Raiz do aplicativo: tema e tela inicial.
class WineryFinderApp extends StatelessWidget {
  const WineryFinderApp({
    this.repository = const EmptyWineryRepository(),
    this.location = const NoLocationProvider(),
    super.key,
  });

  final WineryRepository repository;
  final LocationProvider location;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winery Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9184D9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomeShell(repository: repository, location: location),
    );
  }
}
