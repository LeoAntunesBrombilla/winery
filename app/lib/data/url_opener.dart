import 'package:url_launcher/url_launcher.dart';

/// Abre uma URL fora do app (discador, navegador, app de mapas); devolve
/// `false` se nenhum app puder abri-la. Injetável nos testes.
typedef UrlOpener = Future<bool> Function(Uri uri);

Future<bool> openExternally(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);
