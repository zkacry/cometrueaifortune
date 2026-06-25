import 'package:flutter_test/flutter_test.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/core/constants/fortune_config.dart';

void main() {
  group('Consultation Model', () {
    test('consultation can be created with all fields', () {
      final consultation = Consultation(
        id: 1,
        uid: 'user123',
        fortuneType: FortuneType.tarot,
        worry: '仕事について',
        reading: 'あなたの運勢は...',
        suggestedActions: ['行動1', '行動2'],
        score: 75,
        createdAt: DateTime.now(),
      );

      expect(consultation.id, 1);
      expect(consultation.uid, 'user123');
      expect(consultation.fortuneType, FortuneType.tarot);
      expect(consultation.worry, '仕事について');
      expect(consultation.reading, 'あなたの運勢は...');
      expect(consultation.suggestedActions.length, 2);
      expect(consultation.score, 75);
    });

    test('consultation score can be null', () {
      final consultation = Consultation(
        id: 1,
        uid: 'user123',
        fortuneType: FortuneType.tarot,
        worry: '仕事について',
        reading: '鑑定文',
        suggestedActions: [],
        score: null,
        createdAt: DateTime.now(),
      );

      expect(consultation.score, isNull);
    });

    test('suggested actions can be empty list', () {
      final consultation = Consultation(
        id: 1,
        uid: 'user123',
        fortuneType: FortuneType.tarot,
        worry: '仕事について',
        reading: '鑑定文',
        suggestedActions: [],
        score: 60,
        createdAt: DateTime.now(),
      );

      expect(consultation.suggestedActions.isEmpty, true);
    });

    test('toMap and fromMap round-trip', () {
      final now = DateTime.now();
      final original = Consultation(
        id: 1,
        uid: 'user123',
        fortuneType: FortuneType.tarot,
        worry: 'テスト',
        reading: '読み取り',
        suggestedActions: ['アクション'],
        score: 80,
        createdAt: now,
      );

      final map = original.toMap();
      // Note: id is not included in toMap, so we manually add it
      map['id'] = 1;

      final restored = Consultation.fromMap(map);
      expect(restored.uid, original.uid);
      expect(restored.fortuneType, original.fortuneType);
      expect(restored.worry, original.worry);
      expect(restored.score, original.score);
    });
  });
}
