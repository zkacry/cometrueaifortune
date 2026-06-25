/// アクションログ：占い後の行動と結果を記録
class ActionLog {
  final int? id;
  final String uid;
  final int consultationId;
  final String action; // 実行したアクション
  final DateTime executedAt;
  final String? outcome; // 結果（返信をくれた / 既読スルー / 待ち中）
  final int? feeling; // 気持ちスコア 1-10
  final bool success; // 成功 / 失敗

  const ActionLog({
    this.id,
    required this.uid,
    required this.consultationId,
    required this.action,
    required this.executedAt,
    this.outcome,
    this.feeling,
    this.success = false,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'consultationId': consultationId,
        'action': action,
        'executedAt': executedAt.millisecondsSinceEpoch,
        'outcome': outcome,
        'feeling': feeling,
        'success': success ? 1 : 0,
      };

  factory ActionLog.fromMap(Map<String, dynamic> map) => ActionLog(
        id: map['id'] as int?,
        uid: map['uid'] as String,
        consultationId: map['consultationId'] as int,
        action: map['action'] as String,
        executedAt: DateTime.fromMillisecondsSinceEpoch(
            map['executedAt'] as int),
        outcome: map['outcome'] as String?,
        feeling: map['feeling'] as int?,
        success: (map['success'] as int? ?? 0) == 1,
      );
}
