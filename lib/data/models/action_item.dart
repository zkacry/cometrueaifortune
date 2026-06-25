/// アクションアイテム：占い結果から生まれた行動タスクを追跡
enum ActionStatus { pending, done, failed }

extension ActionStatusX on ActionStatus {
  String get label {
    switch (this) {
      case ActionStatus.pending: return '取り組み中';
      case ActionStatus.done:    return '達成';
      case ActionStatus.failed:  return 'できなかった';
    }
  }

  String get emoji {
    switch (this) {
      case ActionStatus.pending: return '🔄';
      case ActionStatus.done:    return '✅';
      case ActionStatus.failed:  return '❌';
    }
  }

  /// 次にタップしたときに遷移するステータス
  /// pending → done → failed → pending
  ActionStatus get next {
    switch (this) {
      case ActionStatus.pending: return ActionStatus.done;
      case ActionStatus.done:    return ActionStatus.failed;
      case ActionStatus.failed:  return ActionStatus.pending;
    }
  }
}

class ActionItem {
  final int? id;
  final String uid;
  final int consultationId;
  final String fortuneType;  // FortuneType.name
  final String worry;        // 相談内容（表示用）
  final String action;       // アクション本文
  final ActionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActionItem({
    this.id,
    required this.uid,
    required this.consultationId,
    required this.fortuneType,
    required this.worry,
    required this.action,
    this.status = ActionStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'consultationId': consultationId,
        'fortuneType': fortuneType,
        'worry': worry,
        'action': action,
        'status': status.name,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  factory ActionItem.fromMap(Map<String, dynamic> map) => ActionItem(
        id: map['id'] as int?,
        uid: map['uid'] as String,
        consultationId: map['consultationId'] as int,
        fortuneType: map['fortuneType'] as String,
        worry: map['worry'] as String,
        action: map['action'] as String,
        status: ActionStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => ActionStatus.pending,
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      );

  ActionItem copyWith({ActionStatus? status}) => ActionItem(
        id: id,
        uid: uid,
        consultationId: consultationId,
        fortuneType: fortuneType,
        worry: worry,
        action: action,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: status != null ? DateTime.now() : updatedAt,
      );
}
