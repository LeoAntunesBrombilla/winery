import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Inicializa o Firebase (Firestore, Storage e Auth) a partir dos arquivos
/// nativos gerados pelo `flutterfire configure` (veja app/README.md).
///
/// Devolve `false` em vez de lançar quando o Firebase ainda não foi
/// configurado na máquina, para o app continuar abrindo durante o setup.
Future<bool> initFirebase({
  Future<FirebaseApp> Function() initialize = Firebase.initializeApp,
}) async {
  try {
    await initialize();
    return true;
  } on Object catch (error) {
    debugPrint('Firebase não inicializado: $error');
    return false;
  }
}
