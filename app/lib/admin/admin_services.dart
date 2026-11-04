import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:winery_finder/admin/winery_form_data.dart';
import 'package:winery_finder/data/winery_repository.dart';
import 'package:winery_finder/domain/coordinates.dart';
import 'package:winery_finder/domain/winery.dart';

/// Falha mostrada ao admin como mensagem.
class AdminException implements Exception {
  const AdminException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Login dos administradores do catálogo.
abstract interface class AdminAuth {
  /// Entra e confirma que a conta é admin; lança [AdminException].
  Future<void> signIn(String email, String password);

  Future<void> signOut();
}

/// Leitura e gravação do catálogo pelo admin (US17).
abstract interface class AdminWineryStore {
  Future<List<Winery>> list();

  /// Cria `wineries/{wineryIdFor(name)}`; lança [AdminException] se o id
  /// já existe ou se a conta não pode gravar.
  Future<void> create(WineryFormData data);

  /// Atualiza os campos e o `updatedAt`, preservando as fotos.
  Future<void> update(String id, WineryFormData data);
}

class FirebaseAdminAuth implements AdminAuth {
  FirebaseAdminAuth(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<void> signIn(String email, String password) async {
    final UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AdminException(authMessage(error.code));
    }
    final DocumentSnapshot<Map<String, dynamic>> admin = await _firestore
        .doc('admins/${credential.user!.uid}')
        .get();
    if (!admin.exists) {
      await _auth.signOut();
      throw const AdminException('Esta conta não é administradora.');
    }
  }

  /// Mensagem para cada erro do Firebase Auth.
  static String authMessage(String code) => switch (code) {
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'E-mail ou senha incorretos.',
    'invalid-email' => 'E-mail inválido.',
    'too-many-requests' => 'Muitas tentativas. Tente de novo mais tarde.',
    'network-request-failed' => 'Sem conexão com a internet.',
    _ => 'Não foi possível entrar ($code).',
  };

  @override
  Future<void> signOut() => _auth.signOut();
}

class FirestoreAdminWineryStore implements AdminWineryStore {
  FirestoreAdminWineryStore(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _wineries =>
      _firestore.collection('wineries');

  /// Converte [WineryFormData.toFields] para o Firestore e marca o
  /// `updatedAt` com o horário do servidor.
  static Map<String, Object?> firestoreFields(WineryFormData data) {
    final Map<String, Object?> fields = data.toFields();
    final Coordinates location = fields['location']! as Coordinates;
    return <String, Object?>{
      ...fields,
      'location': GeoPoint(location.latitude, location.longitude),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  Future<List<Winery>> list() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _wineries
        .orderBy('name')
        .get();
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              wineryFromFirestore(doc.id, doc.data()),
        )
        .toList();
  }

  @override
  Future<void> create(WineryFormData data) async {
    final String id = wineryIdFor(data.name);
    final DocumentReference<Map<String, dynamic>> doc = _wineries.doc(id);
    await _write(() async {
      if ((await doc.get()).exists) {
        throw AdminException('Já existe uma vinícola com o id "$id".');
      }
      await doc.set(<String, Object?>{
        ...firestoreFields(data),
        'photos': <String>[],
      });
    });
  }

  @override
  Future<void> update(String id, WineryFormData data) {
    return _write(
      () =>
          _wineries.doc(id).set(firestoreFields(data), SetOptions(merge: true)),
    );
  }

  /// As regras do Firestore recusam quem não é admin (permission-denied).
  static Future<void> _write(Future<void> Function() write) async {
    try {
      await write();
    } on FirebaseException catch (error) {
      throw AdminException(
        error.code == 'permission-denied'
            ? 'Sua conta não tem permissão para gravar no catálogo.'
            : 'Não foi possível salvar (${error.code}).',
      );
    }
  }
}
