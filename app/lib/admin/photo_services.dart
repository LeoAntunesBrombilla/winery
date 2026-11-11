import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:winery_finder/admin/admin_services.dart';
import 'package:winery_finder/admin/photo_rules.dart';

/// Foto escolhida no aparelho, já reduzida.
class PickedPhoto {
  const PickedPhoto({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

/// Escolhe uma foto da galeria; `null` se o admin cancelar.
abstract interface class PhotoPicker {
  Future<PickedPhoto?> pick();
}

/// Envia e remove fotos de uma vinícola (US18).
abstract interface class PhotoStore {
  /// Grava no Storage e acrescenta a URL em `photos`; devolve a URL.
  Future<String> upload(String wineryId, PickedPhoto photo);

  /// Remove o arquivo do Storage e a URL de `photos`.
  Future<void> delete(String wineryId, String url);
}

/// Galeria via image_picker, que já reduz para no máximo 1280 px no lado
/// maior antes de devolver os bytes.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pick() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: PhotoRules.maxDimension,
      maxHeight: PhotoRules.maxDimension,
      imageQuality: 85,
    );
    if (file == null) {
      return null;
    }
    return PickedPhoto(name: file.name, bytes: await file.readAsBytes());
  }
}

class FirebasePhotoStore implements PhotoStore {
  FirebasePhotoStore(this._storage, this._firestore);

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  /// `wineries/{id}/{milissegundos}.{ext}`, coberto pelo storage.rules.
  static String storagePath(String wineryId, String fileName, DateTime now) {
    final String extension = fileName.toLowerCase().endsWith('.png')
        ? 'png'
        : 'jpg';
    return 'wineries/$wineryId/${now.millisecondsSinceEpoch}.$extension';
  }

  @override
  Future<String> upload(String wineryId, PickedPhoto photo) async {
    final Reference ref = _storage.ref(
      storagePath(wineryId, photo.name, DateTime.now()),
    );
    try {
      await ref.putData(
        photo.bytes,
        SettableMetadata(contentType: PhotoRules.contentType(photo.name)),
      );
      final String url = await ref.getDownloadURL();
      await _firestore.doc('wineries/$wineryId').update(<String, Object>{
        'photos': FieldValue.arrayUnion(<String>[url]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return url;
    } on FirebaseException catch (error) {
      throw AdminException('Não foi possível enviar a foto (${error.code}).');
    }
  }

  @override
  Future<void> delete(String wineryId, String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } on FirebaseException catch (error) {
      // Arquivo já apagado: segue para tirar a URL do documento.
      if (error.code != 'object-not-found') {
        throw AdminException(
          'Não foi possível excluir a foto (${error.code}).',
        );
      }
    }
    await _firestore.doc('wineries/$wineryId').update(<String, Object>{
      'photos': FieldValue.arrayRemove(<String>[url]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
