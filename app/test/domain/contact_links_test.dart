import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/domain/contact_links.dart';

void main() {
  group('ContactLinks.phone', () {
    test('mantém só dígitos e +', () {
      expect(ContactLinks.phone('(54) 2105-3122').toString(), 'tel:5421053122');
      expect(
        ContactLinks.phone('+55 54 2105-3122').toString(),
        'tel:+555421053122',
      );
    });

    test('sem número devolve null', () {
      expect(ContactLinks.phone(null), isNull);
      expect(ContactLinks.phone(''), isNull);
      expect(ContactLinks.phone('ramal'), isNull);
      expect(ContactLinks.phone('+'), isNull);
    });
  });

  group('ContactLinks.website', () {
    test('mantém URLs completas', () {
      expect(
        ContactLinks.website('https://casavalduga.com.br/visitas').toString(),
        'https://casavalduga.com.br/visitas',
      );
      expect(
        ContactLinks.website('http://miolo.com.br').toString(),
        'http://miolo.com.br',
      );
    });

    test('completa com https quando vem só o domínio', () {
      expect(
        ContactLinks.website(' vinicolaaurora.com.br ').toString(),
        'https://vinicolaaurora.com.br',
      );
    });

    test('vazio ou inválido devolve null', () {
      expect(ContactLinks.website(null), isNull);
      expect(ContactLinks.website('  '), isNull);
      expect(ContactLinks.website('ftp://x.com'), isNull);
    });
  });
}
