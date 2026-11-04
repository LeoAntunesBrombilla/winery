import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:winery_finder/domain/coordinates.dart';
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

/// Converte um documento de `wineries/{id}` no modelo do app.
Winery wineryFromFirestore(String id, Map<String, dynamic> data) {
  final GeoPoint location = data['location'] as GeoPoint;
  final List<Object?> wineTypes =
      data['wineTypes'] as List<Object?>? ?? const <Object?>[];
  return Winery(
    id: id,
    name: data['name'] as String,
    city: data['city'] as String,
    coordinates: Coordinates(location.latitude, location.longitude),
    wineTypes: <WineType>{
      for (final WineType type in WineType.values)
        if (wineTypes.contains(type.name)) type,
    },
    rating: (data['rating'] as num?)?.toDouble() ?? 0,
    tastingPriceCents: (data['tastingPriceCents'] as num).toInt(),
    requiresReservation: data['requiresReservation'] as bool,
  );
}
