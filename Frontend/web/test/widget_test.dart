import 'package:flutter_test/flutter_test.dart';
import 'package:web/shared/models/kit_model.dart';
import 'package:web/shared/models/review_model.dart';

void main() {
  test('KitModel.fromJson maps kit details API shape', () {
    final kit = KitModel.fromJson({
      'id': 1,
      'name': 'Botanist Discovery Kit',
      'description': 'A great kit',
      'price': 84.0,
      'imageURL': 'https://example.com/img.png',
      'rating': 4,
      'age': 6,
      'kitItems': ['Magnifier', 'Journal'],
      'type': 'PHYSICAL',
      'mindset': {
        'id': 1,
        'name': 'Scientist',
        'description': 'Curious mind',
        'criteria': [
          {'id': 1, 'name': 'Observation'},
        ],
      },
    });

    expect(kit.id, 1);
    expect(kit.name, 'Botanist Discovery Kit');
    expect(kit.price, 84.0);
    expect(kit.rating, 4);
    expect(kit.age, 6);
    expect(kit.kitItems, ['Magnifier', 'Journal']);
    expect(kit.type, 'PHYSICAL');
    expect(kit.mindset?.criteria.length, 1);
    expect(kit.mindset?.criteria.first.name, 'Observation');
  });

  test('ReviewModel and KitRatingSummary parse review payloads', () {
    final review = ReviewModel.fromJson({
      'id': 10,
      'rating': 5,
      'comment': 'Loved it',
      'parentName': 'Alex',
      'createdAt': '2024-06-01T12:00:00Z',
    });

    expect(review.rating, 5);
    expect(review.parentName, 'Alex');
    expect(review.createdAt, isNotNull);

    final summary = KitRatingSummary.fromJson({
      'averageRating': 4.5,
      'totalReviews': 12,
    });

    expect(summary.averageRating, 4.5);
    expect(summary.totalReviews, 12);
  });
}
