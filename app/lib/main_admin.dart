import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:winery_finder/admin/admin_app.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/bootstrap.dart';

/// App do admin do catálogo (US17): `flutter run -t lib/main_admin.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!await initFirebase()) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Configure o Firebase (veja app/README.md).'),
          ),
        ),
      ),
    );
    return;
  }
  runApp(
    AdminApp(
      auth: FirebaseAdminAuth(
        FirebaseAuth.instance,
        FirebaseFirestore.instance,
      ),
      store: FirestoreAdminWineryStore(FirebaseFirestore.instance),
    ),
  );
}
