import 'package:connectivity_plus/connectivity_plus.dart';

/// Diz se o aparelho tem conexão de rede (US19).
abstract interface class ConnectivityMonitor {
  /// Estado atual seguido de cada mudança.
  Stream<bool> get online;
}

/// Usado nos testes e quando não se quer monitorar a rede.
class AlwaysOnline implements ConnectivityMonitor {
  const AlwaysOnline();

  @override
  Stream<bool> get online => Stream<bool>.value(true);
}

class ConnectivityPlusMonitor implements ConnectivityMonitor {
  ConnectivityPlusMonitor([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Online quando há qualquer interface além de "nenhuma".
  static bool isOnline(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);

  @override
  Stream<bool> get online async* {
    yield isOnline(await _connectivity.checkConnectivity());
    yield* _connectivity.onConnectivityChanged.map(isOnline);
  }
}
