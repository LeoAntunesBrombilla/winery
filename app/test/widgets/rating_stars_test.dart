import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winery_finder/widgets/rating_stars.dart';

void main() {
  group('RatingStars.icons', () {
    test('estrelas cheias, meias e vazias', () {
      expect(RatingStars.icons(5), List<IconData>.filled(5, Icons.star));
      expect(RatingStars.icons(0), List<IconData>.filled(5, Icons.star_border));
      expect(RatingStars.icons(4.7), <IconData>[
        Icons.star,
        Icons.star,
        Icons.star,
        Icons.star,
        Icons.star_half,
      ]);
      expect(RatingStars.icons(4.8), List<IconData>.filled(5, Icons.star));
      expect(RatingStars.icons(3.5), <IconData>[
        Icons.star,
        Icons.star,
        Icons.star,
        Icons.star_half,
        Icons.star_border,
      ]);
      expect(RatingStars.icons(4.2), <IconData>[
        Icons.star,
        Icons.star,
        Icons.star,
        Icons.star,
        Icons.star_border,
      ]);
    });
  });

  testWidgets('desenha cinco ícones', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RatingStars(rating: 2.5)));

    expect(find.byIcon(Icons.star), findsNWidgets(2));
    expect(find.byIcon(Icons.star_half), findsOneWidget);
    expect(find.byIcon(Icons.star_border), findsNWidgets(2));
  });
}
