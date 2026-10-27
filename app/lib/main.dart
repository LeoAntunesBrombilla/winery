import 'package:flutter/material.dart';
import 'package:winery_finder/app.dart';
import 'package:winery_finder/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  runApp(const WineryFinderApp());
}
