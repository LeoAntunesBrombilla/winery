import 'package:flutter/foundation.dart';

/// Monta o link que abre a rota até um destino no app de navegação do
/// aparelho: Apple Maps no iOS, Google Maps nos demais.
abstract final class RouteLink {
  static Uri directions({
    required double latitude,
    required double longitude,
    required TargetPlatform platform,
  }) {
    final String destination = '$latitude,$longitude';
    if (platform == TargetPlatform.iOS) {
      return Uri.https('maps.apple.com', '/', <String, String>{
        'daddr': destination,
        'dirflg': 'd',
      });
    }
    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'destination': destination,
      'travelmode': 'driving',
    });
  }
}
