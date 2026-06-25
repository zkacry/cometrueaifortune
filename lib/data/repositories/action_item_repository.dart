import 'package:myfortune/data/models/action_item.dart';
import 'package:myfortune/data/services/database_service.dart';

class ActionItemRepository {
  /// 複数アクションを一括保存（鑑定結果画面から呼ぶ）
  Future<List<int>> saveAll({
    required String uid,
    required int consultationId,
    required String fortuneType,
    required String worry,
    required List<String> actions,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final ids = <int>[];
    for (final action in actions) {
      final id = await db.insert('action_items', {
        'uid': uid,
        'consultationId': consultationId,
        'fortuneType': fortuneType,
        'worry': worry,
        'action': action,
        'status': ActionStatus.pending.name,
        'createdAt': now,
        'updatedAt': now,
      });
      ids.add(id);
    }
    return ids;
  }

  /// ユーザーの全アクションを新しい順に取得
  Future<List<ActionItem>> getAll(String uid) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'action_items',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'createdAt DESC',
    );
    return rows.map(ActionItem.fromMap).toList();
  }

  /// ステータスでフィルター
  Future<List<ActionItem>> getByStatus(String uid, ActionStatus status) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'action_items',
      where: 'uid = ? AND status = ?',
      whereArgs: [uid, status.name],
      orderBy: 'createdAt DESC',
    );
    return rows.map(ActionItem.fromMap).toList();
  }

  /// ステータス更新
  Future<void> updateStatus(int id, ActionStatus status) async {
    final db = await DatabaseService.database;
    await db.update(
      'action_items',
      {
        'status': status.name,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 件数サマリー {pending, done, failed}
  Future<Map<ActionStatus, int>> getCounts(String uid) async {
    final db = await DatabaseService.database;
    final rows = await db.rawQuery(
      'SELECT status, COUNT(*) as cnt FROM action_items WHERE uid = ? GROUP BY status',
      [uid],
    );
    final result = <ActionStatus, int>{
      ActionStatus.pending: 0,
      ActionStatus.done: 0,
      ActionStatus.failed: 0,
    };
    for (final row in rows) {
      final status = ActionStatus.values.firstWhere(
        (s) => s.name == row['status'],
        orElse: () => ActionStatus.pending,
      );
      result[status] = row['cnt'] as int;
    }
    return result;
  }

  /// 1件削除
  Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete('action_items', where: 'id = ?', whereArgs: [id]);
  }

  /// 相談IDに紐づくアクション一覧
  Future<List<ActionItem>> getByConsultation(int consultationId) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'action_items',
      where: 'consultationId = ?',
      whereArgs: [consultationId],
      orderBy: 'createdAt ASC',
    );
    return rows.map(ActionItem.fromMap).toList();
  }
}
