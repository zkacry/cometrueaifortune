import 'package:flutter_test/flutter_test.dart';
import 'package:myfortune/data/models/action_log.dart';

void main() {
  group('ActionLog Model', () {
    test('action_log can be created with all fields', () {
      final now = DateTime.now();
      final actionLog = ActionLog(
        uid: 'user123',
        consultationId: 1,
        action: '毎日瞑想する',
        executedAt: now,
      );

      expect(actionLog.uid, 'user123');
      expect(actionLog.consultationId, 1);
      expect(actionLog.action, '毎日瞑想する');
      expect(actionLog.executedAt, now);
    });

    test('toMap converts action_log to map correctly', () {
      final now = DateTime.now();
      final actionLog = ActionLog(
        uid: 'user123',
        consultationId: 1,
        action: '毎日瞑想する',
        executedAt: now,
      );

      final map = actionLog.toMap();
      expect(map['uid'], 'user123');
      expect(map['consultationId'], 1);
      expect(map['action'], '毎日瞑想する');
      expect(map['executedAt'], isNotNull);
    });

    test('fromMap creates action_log from map', () {
      final now = DateTime.now();
      final map = {
        'uid': 'user123',
        'consultationId': 1,
        'action': '毎日瞑想する',
        'executedAt': now.millisecondsSinceEpoch,
      };

      final actionLog = ActionLog.fromMap(map);
      expect(actionLog.uid, 'user123');
      expect(actionLog.consultationId, 1);
      expect(actionLog.action, '毎日瞑想する');
    });
  });
}
