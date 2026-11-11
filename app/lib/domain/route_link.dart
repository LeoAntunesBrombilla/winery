import 'package:flutter/foundation.dart';
import 'package:winery_finder/data/url_opener.dart';
import 'package:winery_finder/domain/coordinates.dart';

/// Links que abrem a rota até a vinícola partindo da localização atual
/// (US10). Sem origem no link, os apps de mapas usam a posição do aparelho.
abstract final class RouteLink {
  /// Links em ordem de preferência: app de mapas do aparelho e, por último,
  /// o Google Maps no navegador, que sempre abre.
  ///
  /// - Android: navegação do Google Maps.
  /// - iOS: Google Maps se instalado, senão Apple Maps.
  static List<Uri> candidates(
    Coordinates destination,
    TargetPlatform platform,
  ) {
    final String latLng = '${destination.latitude},${destination.longitude}';
    return <Uri>[
      if (platform == TargetPlatform.android)
        Uri.parse('google.navigation:q=$latLng&mode=d'),
      if (platform == TargetPlatform.iOS) ...<Uri>[
        Uri.parse('comgooglemaps://?daddr=$latLng&directionsmode=driving'),
        Uri.parse('maps://?daddr=$latLng&dirflg=d'),
      ],
      browser(destination),
    ];
  }

  /// Rota no Google Maps pelo navegador.
  static Uri browser(Coordinates destination) {
    return Uri.https('www.google.com', '/maps/dir/', <String, String>{
      'api': '1',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'driving',
    });
  }

  /// Tenta cada link de [candidates] até um abrir. Devolve `false` se
  /// nenhum abriu.
  static Future<bool> open(
    UrlOpener openUrl,
    Coordinates destination,
    TargetPlatform platform,
  ) async {
    for (final Uri uri in candidates(destination, platform)) {
      try {
        if (await openUrl(uri)) {
          return true;
        }
      } on Object {
        // App ausente: segue para o próximo link.
      }
    }
    return false;
  }
}
