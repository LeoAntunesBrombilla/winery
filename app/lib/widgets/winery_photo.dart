import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Foto do Storage com cache em disco (US19): imagens já vistas abrem sem
/// rede. Mostra um placeholder enquanto carrega e um ícone se falhar.
class WineryPhoto extends StatelessWidget {
  const WineryPhoto({required this.url, this.fit = BoxFit.cover, super.key});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      placeholder: (BuildContext context, String url) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (BuildContext context, String url, Object error) =>
          ColoredBox(
            color: colors.surfaceContainerHighest,
            child: Icon(Icons.broken_image_outlined, color: colors.outline),
          ),
    );
  }
}
