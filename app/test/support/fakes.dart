import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_catalog.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';

class FakeRepository implements WineryRepository {
  const FakeRepository(this.wineries);

  final List<Winery> wineries;

  @override
  Future<List<Winery>> fetchAll() async => wineries;
}

class FixedLocation implements LocationProvider {
  const FixedLocation(this.coordinates);

  final Coordinates? coordinates;

  @override
  Future<Coordinates?> current() async => coordinates;
}

/// Catálogo com [wineries] e o usuário em [user] (ou sem localização).
WineryCatalog fakeCatalog(List<Winery> wineries, {Coordinates? user}) {
  return WineryCatalog(
    repository: FakeRepository(wineries),
    location: FixedLocation(user),
  );
}
