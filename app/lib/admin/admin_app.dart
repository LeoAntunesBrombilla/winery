import 'package:flutter/material.dart';
import 'package:winery_finder/admin/admin_login_screen.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/admin_wineries_screen.dart';

/// App do admin do catálogo (US17): login e, depois, a listagem.
class AdminApp extends StatefulWidget {
  const AdminApp({required this.auth, required this.store, super.key});

  final AdminAuth auth;
  final AdminWineryStore store;

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
          ? AdminWineriesScreen(store: widget.store, onSignOut: _signOut)
          : AdminLoginScreen(
              auth: widget.auth,
              onSignedIn: () => setState(() => _signedIn = true),
            ),
    );
  }
}
