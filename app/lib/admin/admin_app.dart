import 'package:flutter/material.dart';
import 'package:winery_finder/admin/admin_login_screen.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/admin_wineries_screen.dart';
import 'package:winery_finder/admin/photo_services.dart';
import 'package:winery_finder/admin/winery_photos_screen.dart';
import 'package:winery_finder/domain/winery.dart';

/// App do admin do catálogo (US17): login e, depois, a listagem.
class AdminApp extends StatefulWidget {
  const AdminApp({
    required this.auth,
    required this.store,
    required this.photos,
    required this.picker,
    super.key,
  });

  final AdminAuth auth;
  final AdminWineryStore store;
  final PhotoStore photos;
  final PhotoPicker picker;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  bool _signedIn = false;

  Future<void> _signOut() async {
    await widget.auth.signOut();
    setState(() => _signedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winery Finder — Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9184D9)),
        useMaterial3: true,
      ),
      home: _signedIn
          ? AdminWineriesScreen(
              store: widget.store,
              onSignOut: _signOut,
              trailingBuilder: (BuildContext context, Winery winery) =>
                  IconButton(
                    tooltip: 'Fotos',
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => WineryPhotosScreen(
                          winery: winery,
                          store: widget.photos,
                          picker: widget.picker,
                        ),
                      ),
                    ),
                  ),
            )
          : AdminLoginScreen(
              auth: widget.auth,
              onSignedIn: () => setState(() => _signedIn = true),
            ),
    );
  }
}
