import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/winery_form_data.dart';
import 'package:winery_finder/domain/winery.dart';

/// Admin em memória: guarda o que foi gravado.
class FakeAdminStore implements AdminWineryStore {
  FakeAdminStore([List<Winery>? wineries]) : wineries = <Winery>[...?wineries];

  final List<Winery> wineries;
  final List<WineryFormData> created = <WineryFormData>[];
  final Map<String, WineryFormData> updated = <String, WineryFormData>{};
  AdminException? failure;

  @override
  Future<List<Winery>> list() async => List<Winery>.of(wineries);

  @override
  Future<void> create(WineryFormData data) async {
    if (failure != null) {
      throw failure!;
    }
    created.add(data);
    wineries.add(
      Winery(
        id: wineryIdFor(data.name),
        name: data.name,
        city: data.city,
        address: data.address,
        coordinates: data.location,
        wineTypes: data.wineTypes,
        hours: data.hours,
        rating: data.rating,
        tastingPriceCents: data.tastingPriceCents,
        requiresReservation: data.requiresReservation,
      ),
    );
  }

  @override
  Future<void> update(String id, WineryFormData data) async {
    if (failure != null) {
      throw failure!;
    }
    updated[id] = data;
  }
}

class FakeAdminAuth implements AdminAuth {
  FakeAdminAuth({this.failure});

  final AdminException? failure;
  int signOuts = 0;

  @override
  Future<void> signIn(String email, String password) async {
    if (failure != null) {
      throw failure!;
    }
  }

  @override
  Future<void> signOut() async => signOuts++;
}
