import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uma ficha aberta e quando.
@immutable
class RecentVisit {
  const RecentVisit(this.wineryId, this.openedAt);

  final String wineryId;
  final DateTime openedAt;

  /// Formato salvo no aparelho: "id|milissegundos".
  String encode() => '$wineryId|${openedAt.millisecondsSinceEpoch}';

  static RecentVisit? decode(String raw) {
    final int separator = raw.lastIndexOf('|');
    if (separator <= 0) {
      return null;
    }
    final int? millis = int.tryParse(raw.substring(separator + 1));
    if (millis == null) {
      return null;
    }
    return RecentVisit(
      raw.substring(0, separator),
      DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is RecentVisit &&
      other.wineryId == wineryId &&
      other.openedAt == openedAt;

  @override
  int get hashCode => Object.hash(wineryId, openedAt);
}

/// Histórico das fichas abertas (US13), no aparelho: as últimas
/// [maxEntries], da mais recente para a mais antiga, sem repetir vinícola.
class RecentsStore extends ChangeNotifier {
  RecentsStore({
    Iterable<RecentVisit> initial = const <RecentVisit>[],
    Future<void> Function(List<String> encoded)? save,
  }) : _visits = _normalize(initial),
       _save = save ?? _keepInMemory;

  factory RecentsStore.fromPreferences(SharedPreferences preferences) {
    return RecentsStore(
      initial: (preferences.getStringList(preferencesKey) ?? const <String>[])
          .map(RecentVisit.decode)
          .nonNulls,
      save: (List<String> encoded) =>
          preferences.setStringList(preferencesKey, encoded),
    );
  }

  static const String preferencesKey = 'recents';
  static const int maxEntries = 20;

  List<RecentVisit> _visits;
  final Future<void> Function(List<String> encoded) _save;

  static Future<void> _keepInMemory(List<String> encoded) async {}

  /// Mais recente primeiro, uma por vinícola, no máximo [maxEntries].
  static List<RecentVisit> _normalize(Iterable<RecentVisit> visits) {
    final List<RecentVisit> sorted = visits.toList()
      ..sort(
        (RecentVisit a, RecentVisit b) => b.openedAt.compareTo(a.openedAt),
      );
    final Set<String> seen = <String>{};
    return sorted
        .where((RecentVisit v) => seen.add(v.wineryId))
        .take(maxEntries)
        .toList();
  }

  List<RecentVisit> get visits => List<RecentVisit>.unmodifiable(_visits);

  /// Registra a abertura da ficha; reabrir atualiza a data sem duplicar.
  Future<void> record(String wineryId, DateTime openedAt) async {
    _visits = _normalize(<RecentVisit>[
      RecentVisit(wineryId, openedAt),
      ..._visits.where((RecentVisit v) => v.wineryId != wineryId),
    ]);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _visits = <RecentVisit>[];
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() =>
      _save(_visits.map((RecentVisit v) => v.encode()).toList());
}
