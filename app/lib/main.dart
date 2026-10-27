import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:winery_finder/app.dart';
import 'package:winery_finder/bootstrap.dart';
import 'package:winery_finder/data/location_provider.dart';
import 'package:winery_finder/data/winery_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool firebaseReady = await initFirebase();
  runApp(
    WineryFinderApp(
      repository: firebaseReady
          ? FirestoreWineryRepository(FirebaseFirestore.instance)
          : const EmptyWineryRepository(),
      location: const GeolocatorLocationProvider(),
    ),
  );
}
