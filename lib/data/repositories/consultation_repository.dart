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
}
