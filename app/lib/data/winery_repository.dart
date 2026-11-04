import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/weekly_hours.dart';
import 'package:winery_finder/domain/winery.dart';

/// Fonte das vinícolas exibidas no app.
abstract interface class WineryRepository {
  Future<List<Winery>> fetchAll();
}

/// Usado quando o Firebase não está configurado (e nos testes).
class EmptyWineryRepository implements WineryRepository {
  const EmptyWineryRepository();

  @override
  Future<List<Winery>> fetchAll() async => const <Winery>[];
}

/// Lê a coleção `wineries` gravada pela carga inicial (US32).
class FirestoreWineryRepository implements WineryRepository {
  FirestoreWineryRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<Winery>> fetchAll() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('wineries')
        .get();
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              wineryFromFirestore(doc.id, doc.data()),
        )
        .toList();
  }
}

/// Converte um documento de `wineries/{id}` no modelo do app. O formato
/// está documentado em docs/modelo-de-dados.md.
Winery wineryFromFirestore(String id, Map<String, dynamic> data) {
  final GeoPoint location = data['location'] as GeoPoint;
  final List<Object?> wineTypes =
      data['wineTypes'] as List<Object?>? ?? const <Object?>[];
  return Winery(
    id: id,
    name: data['name'] as String,
    city: data['city'] as String,
    address: data['address'] as String? ?? '',
    coordinates: Coordinates(location.latitude, location.longitude),
    wineTypes: <WineType>{
      for (final WineType type in WineType.values)
        if (wineTypes.contains(type.name)) type,
    },
    hours: weeklyHoursFromFirestore(data['openingHours']),
    rating: (data['rating'] as num?)?.toDouble(),
    tastingPriceCents: (data['tastingPriceCents'] as num).toInt(),
    requiresReservation: data['requiresReservation'] as bool,
    phone: _nonEmpty(data['phone']),
    website: _nonEmpty(data['website']),
    photoUrls: <String>[
      ...(data['photos'] as List<Object?>? ?? const <Object?>[])
          .whereType<String>(),
    ],
  );
}

/// Lê `openingHours`: um mapa `mon`..`sun` com `{open: "09:00",
/// close: "17:00"}` ou `null` para fechado.
WeeklyHours weeklyHoursFromFirestore(Object? raw) {
  if (raw is! Map<String, dynamic>) {
    return WeeklyHours.closed;
  }
  final Map<int, OpeningInterval> days = <int, OpeningInterval>{};
  for (int i = 0; i < WeeklyHours.keys.length; i++) {
    final Object? day = raw[WeeklyHours.keys[i]];
    if (day is! Map<String, dynamic>) {
      continue;
    }
    final int? opens = OpeningInterval.parseClock(day['open'] as String? ?? '');
    final int? closes = OpeningInterval.parseClock(
      day['close'] as String? ?? '',
    );
    if (opens != null && closes != null && opens < closes) {
      days[i + 1] = OpeningInterval(opens, closes);
    }
  }
  return WeeklyHours(days);
}

/// Formato de `openingHours` gravado no Firestore (inverso de
/// [weeklyHoursFromFirestore]).
Map<String, Map<String, String>?> weeklyHoursToFirestore(WeeklyHours hours) {
  return <String, Map<String, String>?>{
    for (int i = 0; i < WeeklyHours.keys.length; i++)
      WeeklyHours.keys[i]: switch (hours.on(i + 1)) {
        null => null,
        final OpeningInterval interval => <String, String>{
          'open': OpeningInterval.clock(interval.opensAt),
          'close': OpeningInterval.clock(interval.closesAt),
        },
      },
  };
}

String? _nonEmpty(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;
