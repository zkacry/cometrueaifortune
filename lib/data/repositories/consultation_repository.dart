import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/services/database_service.dart';

class ConsultationRepository {
  Future<int> save(Consultation c) async {
    final db = await DatabaseService.database;
    return db.insert('consultations', c.toMap());
  }

  Future<List<Consultation>> getRecent(String uid, {int limit = 10}) async {
    final db = await DatabaseService.database;
    final rows = await db.query(
      'consultations',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return rows.map(Consultation.fromMap).toList();
  }

  Future<List<Consultation>> getByMonth(String uid, String monthKey) async {
    final db = await DatabaseService.database;
    final start = DateTime.parse('$monthKey-01').millisecondsSinceEpoch;
    final end = DateTime.parse(
            '${monthKey.substring(0, 4)}-${(int.parse(monthKey.substring(5)) + 1).toString().padLeft(2, '0')}-01')
        .millisecondsSinceEpoch;
    final rows = await db.query(
      'consultations',
      where: 'uid = ? AND createdAt >= ? AND createdAt < ?',
      whereArgs: [uid, start, end],
      orderBy: 'createdAt DESC',
    );
    return rows.map(Consultation.fromMap).toList();
  }

  Future<void> updateDecision(int id, String decision) async {
    final db = await DatabaseService.database;
    await db.update(
      'consultations',
      {'decision': decision},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 類似した過去の相談を検索（記憶型）
  Future<List<Consultation>> findSimilar(String uid, String worry,
      {int limit = 3}) async {
    final db = await DatabaseService.database;
    final keywords = worry.split('').take(10).join('');
    final rows = await db.query(
      'consultations',
      where: 'uid = ? AND worry LIKE ?',
      whereArgs: [uid, '%$keywords%'],
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    return rows.map(Consultation.fromMap).toList();
  }

  /// 的中判定を更新（null可: 未判定に戻す）
  Future<void> updateWasTrueJudgement(int id, bool? wasTrueJudgement) async {
    final db = await DatabaseService.database;
    await db.update(
      'consultations',
      {'wasTrueJudgement': wasTrueJudgement == null ? null : (wasTrueJudgement ? 1 : 0)},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 的中率を計算: (当たった数 / 判定済み総数)
  Future<Map<String, int>> getHitRateStats(String uid, {String? monthKey}) async {
    final db = await DatabaseService.database;

    String where = 'uid = ? AND wasTrueJudgement IS NOT NULL';
    List<dynamic> whereArgs = [uid];

    if (monthKey != null) {
      final start = DateTime.parse('$monthKey-01').millisecondsSinceEpoch;
      final nextMonth = int.parse(monthKey.substring(5)) + 1;
      final nextMonthStr = nextMonth > 12 ? '01' : nextMonth.toString().padLeft(2, '0');
      final nextYear = nextMonth > 12 ? (int.parse(monthKey.substring(0, 4)) + 1).toString() : monthKey.substring(0, 4);
      final end = DateTime.parse('$nextYear-$nextMonthStr-01').millisecondsSinceEpoch;
      where += ' AND createdAt >= ? AND createdAt < ?';
      whereArgs.addAll([start, end]);
    }

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM consultations WHERE $where',
      whereArgs,
    );
    final total = (totalResult.first['total'] as int?) ?? 0;

    final hitResult = await db.rawQuery(
      'SELECT COUNT(*) as hits FROM consultations WHERE $where AND wasTrueJudgement = 1',
      whereArgs,
    );
    final hits = (hitResult.first['hits'] as int?) ?? 0;

    return {'hits': hits, 'total': total};
  }
}
