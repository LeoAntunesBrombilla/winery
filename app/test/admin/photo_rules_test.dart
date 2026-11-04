import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/admin/photo_rules.dart';
import 'package:winery_finder/admin/photo_services.dart';

void main() {
  group('PhotoRules.validate', () {
    String? check(String name, int size, int count) => PhotoRules.validate(
      fileName: name,
      sizeBytes: size,
      currentCount: count,
    );

    test('aceita JPG e PNG de até 5 MB', () {
      expect(check('a.jpg', 1000, 0), isNull);
      expect(check('B.JPEG', 1000, 0), isNull);
      expect(check('c.png', PhotoRules.maxBytes, 4), isNull);
    });

    test('recusa a sexta foto', () {
      expect(check('a.jpg', 1000, 5), 'Limite de 5 fotos por vinícola.');
    });

    test('recusa outros formatos', () {
      expect(check('a.heic', 1000, 0), 'Envie uma foto JPG ou PNG.');
      expect(check('a.gif', 1000, 0), 'Envie uma foto JPG ou PNG.');
    });

    test('recusa acima de 5 MB', () {
      expect(
        check('a.jpg', PhotoRules.maxBytes + 1, 0),
        'A foto passa de 5 MB.',
      );
    });
  });

  test('contentType', () {
    expect(PhotoRules.contentType('x.jpg'), 'image/jpeg');
    expect(PhotoRules.contentType('x.png'), 'image/png');
    expect(PhotoRules.contentType('x.webp'), isNull);
  });

  test('redução para no máximo 1280 px antes do envio', () {
    expect(PhotoRules.maxDimension, 1280);
  });

  test('storagePath fica dentro de wineries/{id}', () {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    expect(
      FirebasePhotoStore.storagePath('casa-valduga', 'IMG_1.JPG', now),
      'wineries/casa-valduga/1700000000000.jpg',
    );
    expect(
      FirebasePhotoStore.storagePath('casa-valduga', 'foto.png', now),
      'wineries/casa-valduga/1700000000000.png',
    );
  });
}
