import 'package:flutter/foundation.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

/// 過去の占い履歴をコンパクトなサマリーにまとめてキャッシュするサービス。
/// AIへ渡すコンテキストを軽量に保ちながら、傾向や変化を伝える。
class FortuneSummaryService {
  /// 現在の月キーを返す ("2026-05" 形式)
  static String get _currentMonthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// キャッシュ済みサマリーを取得。なければ null。
  static Future<String?> getCachedSummary(String uid) async {
    try {
      final db = await DatabaseService.database;
      final rows = await db.query(
        'fortune_summaries',
        where: 'uid = ? AND monthKey = ?',
        whereArgs: [uid, _currentMonthKey],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      return rows.first['summary'] as String?;
    } catch (e) {
      debugPrint('FortuneSummaryService.getCachedSummary error: $e');
      return null;
    }
  }

  /// 占い履歴からローカルでサマリーを生成してキャッシュ。
  /// AIを呼ばずにクライアントサイドで行うため、コストゼロ。
  static Future<String> buildAndCacheSummary(
    String uid,
    List<Consultation> consultations,
  ) async {
    final summary = _buildLocalSummary(consultations);
    try {
      final db = await DatabaseService.database;
      await db.insert(
        'fortune_summaries',
        {
          'uid': uid,
          'monthKey': _currentMonthKey,
          'summary': summary,
          'consultationCount': consultations.length,
          'generatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('FortuneSummaryService.buildAndCacheSummary error: $e');
    }
    return summary;
  }

  /// サマリーを取得。キャッシュがあればそれを返す。
  /// consultations が5件以上あればキャッシュを再生成する。
  static Future<String?> getSummaryForPrompt(
    String uid,
    List<Consultation> consultations,
  ) async {
    if (consultations.length < 3) return null; // 少なすぎる場合はスキップ

    // 5件以上あれば常に最新サマリーを生成・更新
    if (consultations.length >= 5) {
      return await buildAndCacheSummary(uid, consultations);
    }

    // 3〜4件はキャッシュがあればそれを使う
    final cached = await getCachedSummary(uid);
    if (cached != null) return cached;
    return await buildAndCacheSummary(uid, consultations);
  }

  /// クライアントサイドでサマリーテキストを構築（AIなし）。
  static String _buildLocalSummary(List<Consultation> list) {
    if (list.isEmpty) return '';

    // スコア統計
    final scored = list.where((c) => c.score != null).toList();
    final avgScore = scored.isEmpty
        ? null
        : scored.map((c) => c.score!).reduce((a, b) => a + b) ~/ scored.length;

    // 占術別カウント
    final typeCount = <String, int>{};
    for (final c in list) {
      typeCount[c.fortuneType.displayName] =
          (typeCount[c.fortuneType.displayName] ?? 0) + 1;
    }
    final typeStr = typeCount.entries
        .map((e) => '${e.key}${e.value}回')
        .join('、');

    // 悩みキーワード集計（先頭12文字でグループ化）
    final worryMap = <String, int>{};
    for (final c in list) {
      final key = c.worry.length > 12 ? c.worry.substring(0, 12) : c.worry;
      worryMap[key] = (worryMap[key] ?? 0) + 1;
    }
    final topWorries = (worryMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(3)
        .map((e) => e.value >= 2 ? '「${e.key}」(${e.value}回)' : '「${e.key}」')
        .join('、');

    // スコアトレンド（最新3件）
    String trendStr = '';
    if (scored.length >= 2) {
      final recent = scored.take(3).map((c) => c.score!).toList();
      final oldest = scored.last.score!;
      final newest = scored.first.score!;
      if (newest > oldest + 5) {
        trendStr = '最近スコアが上昇傾向。';
      } else if (newest < oldest - 5) {
        trendStr = '最近スコアがやや低下傾向。';
      } else {
        trendStr = 'スコアは安定。';
      }
      trendStr += '直近スコア: ${recent.join('→')}点。';
    }

    final buf = StringBuffer();
    buf.write('【過去の占い傾向サマリー（直近${list.length}件）】\n');
    if (avgScore != null) buf.write('平均スコア: $avgScore点。');
    buf.write(' 占術: $typeStr。');
    if (topWorries.isNotEmpty) buf.write(' 主な悩み: $topWorries。');
    if (trendStr.isNotEmpty) buf.write(' $trendStr');

    return buf.toString();
  }
}
