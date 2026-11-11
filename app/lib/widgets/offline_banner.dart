import 'package:flutter/material.dart';
import 'package:winery_finder/data/connectivity_monitor.dart';

/// Aviso exibido enquanto o aparelho está sem rede (US19). Os dados vêm
/// do cache do Firestore e as fotos do cache de imagens.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({required this.connectivity, super.key});

  static const String message = 'Você está offline - mostrando dados salvos.';

  final ConnectivityMonitor connectivity;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  // Uma assinatura só, em vez de uma nova a cada rebuild.
  late Stream<bool> _online = widget.connectivity.online;

  @override
  void didUpdateWidget(OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.connectivity != widget.connectivity) {
      _online = widget.connectivity.online;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _online,
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data ?? true) {
          return const SizedBox.shrink();
        }
        final ColorScheme colors = Theme.of(context).colorScheme;
        return Material(
          color: colors.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                Icon(Icons.cloud_off, color: colors.onTertiaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    OfflineBanner.message,
                    style: TextStyle(color: colors.onTertiaryContainer),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
