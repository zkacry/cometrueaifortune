/// チャレンジの進行状況を追跡
enum ChallengeStatus { notStarted, inProgress, completed, failed }

extension ChallengeStatusX on ChallengeStatus {
  String get label {
    switch (this) {
      case ChallengeStatus.notStarted:
        return '未開始';
      case ChallengeStatus.inProgress:
        return '進行中';
      case ChallengeStatus.completed:
        return '完了';
      case ChallengeStatus.failed:
        return '失敗';
    }
  }

  String get emoji {
    switch (this) {
      case ChallengeStatus.notStarted:
        return '⏳';
      case ChallengeStatus.inProgress:
        return '🔄';
      case ChallengeStatus.completed:
        return '✅';
      case ChallengeStatus.failed:
        return '❌';
    }
  }
}

/// アチーブメント獲得タイプ
enum AchievementType {
  streakMilestone,      // ストリーク達成（例：7日、30日）
  challengeCompletion,  // チャレンジ完了
  consistencyBonus,     // 継続ボーナス
  seasonalEvent,        // 季節イベント
  customGoal,           // カスタムゴール
}

extension AchievementTypeX on AchievementType {
  String get label {
    switch (this) {
      case AchievementType.streakMilestone:
        return 'ストリーク達成';
      case AchievementType.challengeCompletion:
        return 'チャレンジ完了';
      case AchievementType.consistencyBonus:
        return '継続ボーナス';
      case AchievementType.seasonalEvent:
        return '季節イベント';
      case AchievementType.customGoal:
        return 'カスタムゴール';
    }
  }

  String get emoji {
    switch (this) {
      case AchievementType.streakMilestone:
        return '🔥';
      case AchievementType.challengeCompletion:
        return '🏆';
      case AchievementType.consistencyBonus:
        return '⭐';
      case AchievementType.seasonalEvent:
        return '🎉';
      case AchievementType.customGoal:
        return '🎯';
    }
  }
}

/// 単一のアチーブメント
class Achievement {
  final String id;
  final String uid;
  final AchievementType type;
  final String title;
  final String description;
  final String badgeUrl;  // バッジ画像URL
  final int points;       // 獲得ポイント
  final DateTime unlockedAt;
  final Map<String, dynamic> metadata;  // 追加情報（例：streakDay: 7）

  const Achievement({
    required this.id,
    required this.uid,
    required this.type,
    required this.title,
    required this.description,
    required this.badgeUrl,
    this.points = 0,
    required this.unlockedAt,
    this.metadata = const {},
  });

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'title': title,
        'description': description,
        'badgeUrl': badgeUrl,
        'points': points,
        'unlockedAt': unlockedAt.toIso8601String(),
        'metadata': metadata,
      };

  factory Achievement.fromFirestore(
      String uid, String id, Map<String, dynamic> data) {
    return Achievement(
      id: id,
      uid: uid,
      type: AchievementType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => AchievementType.customGoal,
      ),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      badgeUrl: data['badgeUrl'] as String? ?? '',
      points: data['points'] as int? ?? 0,
      unlockedAt: data['unlockedAt'] != null
          ? DateTime.parse(data['unlockedAt'] as String)
          : DateTime.now(),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Achievement copyWith({
    String? title,
    String? description,
    String? badgeUrl,
    int? points,
    DateTime? unlockedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id,
      uid: uid,
      type: type,
      title: title ?? this.title,
      description: description ?? this.description,
      badgeUrl: badgeUrl ?? this.badgeUrl,
      points: points ?? this.points,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// 単一のチャレンジ進行状況
class ChallengeProgress {
  final String id;
  final String uid;
  final String challengeName;
  final String description;
  final int targetValue;         // 目標値（例：7日、100ポイント）
  final int currentValue;        // 現在の値
  final ChallengeStatus status;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? deadline;      // オプション：期限
  final int rewardPoints;        // 達成時の報酬ポイント
  final Map<String, dynamic> details;  // チャレンジ詳細情報

  const ChallengeProgress({
    required this.id,
    required this.uid,
    required this.challengeName,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    this.status = ChallengeStatus.notStarted,
    required this.startedAt,
    this.completedAt,
    this.deadline,
    this.rewardPoints = 0,
    this.details = const {},
  });

  /// 進捗率（0.0～1.0）
  double get progressPercentage {
    if (targetValue <= 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// チャレンジが完了したかどうか
  bool get isCompleted => status == ChallengeStatus.completed;

  /// チャレンジが失敗したかどうか
  bool get isFailed => status == ChallengeStatus.failed;

  /// 期限超過したかどうか
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  Map<String, dynamic> toFirestore() => {
        'challengeName': challengeName,
        'description': description,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'status': status.name,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'rewardPoints': rewardPoints,
        'details': details,
      };

  factory ChallengeProgress.fromFirestore(
      String uid, String id, Map<String, dynamic> data) {
    return ChallengeProgress(
      id: id,
      uid: uid,
      challengeName: data['challengeName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      targetValue: data['targetValue'] as int? ?? 0,
      currentValue: data['currentValue'] as int? ?? 0,
      status: ChallengeStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ChallengeStatus.notStarted,
      ),
      startedAt: data['startedAt'] != null
          ? DateTime.parse(data['startedAt'] as String)
          : DateTime.now(),
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'] as String)
          : null,
      deadline: data['deadline'] != null
          ? DateTime.parse(data['deadline'] as String)
          : null,
      rewardPoints: data['rewardPoints'] as int? ?? 0,
      details: (data['details'] as Map<String, dynamic>?) ?? {},
    );
  }

  ChallengeProgress copyWith({
    String? challengeName,
    String? description,
    int? targetValue,
    int? currentValue,
    ChallengeStatus? status,
    DateTime? completedAt,
    DateTime? deadline,
    int? rewardPoints,
    Map<String, dynamic>? details,
  }) {
    return ChallengeProgress(
      id: id,
      uid: uid,
      challengeName: challengeName ?? this.challengeName,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      startedAt: startedAt,
      completedAt: completedAt ?? this.completedAt,
      deadline: deadline ?? this.deadline,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      details: details ?? this.details,
    );
  }
}

/// 成長タイムラインの単一エントリ
class GrowthEntry {
  final String id;
  final String uid;
  final String milestone;         // マイルストーン説明
  final DateTime achievedAt;
  final int pointsGained;
  final String category;          // 'streak', 'challenge', 'consistency', etc.
  final Map<String, dynamic> metadata;

  const GrowthEntry({
    required this.id,
    required this.uid,
    required this.milestone,
    required this.achievedAt,
    this.pointsGained = 0,
    required this.category,
    this.metadata = const {},
  });

  Map<String, dynamic> toFirestore() => {
        'milestone': milestone,
        'achievedAt': achievedAt.toIso8601String(),
        'pointsGained': pointsGained,
        'category': category,
        'metadata': metadata,
      };

  factory GrowthEntry.fromFirestore(
      String uid, String id, Map<String, dynamic> data) {
    return GrowthEntry(
      id: id,
      uid: uid,
      milestone: data['milestone'] as String? ?? '',
      achievedAt: data['achievedAt'] != null
          ? DateTime.parse(data['achievedAt'] as String)
          : DateTime.now(),
      pointsGained: data['pointsGained'] as int? ?? 0,
      category: data['category'] as String? ?? 'other',
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  GrowthEntry copyWith({
    String? milestone,
    DateTime? achievedAt,
    int? pointsGained,
    String? category,
    Map<String, dynamic>? metadata,
  }) {
    return GrowthEntry(
      id: id,
      uid: uid,
      milestone: milestone ?? this.milestone,
      achievedAt: achievedAt ?? this.achievedAt,
      pointsGained: pointsGained ?? this.pointsGained,
      category: category ?? this.category,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// ユーザーのエンゲージメント指標を一元管理
class EngagementMetrics {
  final String uid;
  final int streakDays;              // 現在のストリーク日数
  final int longestStreak;           // 最長ストリーク日数
  final int dailyCheckins;           // 総チェックイン数
  final DateTime lastCheckinDate;    // 最後のチェックイン日
  final List<ChallengeProgress> challengeProgress;  // 進行中のチャレンジ
  final List<Achievement> achievementList;         // 獲得したアチーブメント
  final List<GrowthEntry> growthTimeline;          // 成長タイムライン
  final int totalPoints;             // 累計ポイント
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;  // ユーザー定義の追加情報

  const EngagementMetrics({
    required this.uid,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.dailyCheckins = 0,
    required this.lastCheckinDate,
    this.challengeProgress = const [],
    this.achievementList = const [],
    this.growthTimeline = const [],
    this.totalPoints = 0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  /// ストリークが有効か（昨日または今日チェックインされたか）
  bool get isStreakActive {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final lastCheckin = DateTime(
      lastCheckinDate.year,
      lastCheckinDate.month,
      lastCheckinDate.day,
    );
    final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
    final todayDate = DateTime.now();

    return lastCheckin == yesterdayDate || lastCheckin == todayDate;
  }

  /// 進行中のチャレンジ数
  int get activeChallengesCount {
    return challengeProgress
        .where((c) => c.status == ChallengeStatus.inProgress)
        .length;
  }

  /// 完了したチャレンジ数
  int get completedChallengesCount {
    return challengeProgress
        .where((c) => c.status == ChallengeStatus.completed)
        .length;
  }

  /// 失敗したチャレンジ数
  int get failedChallengesCount {
    return challengeProgress.where((c) => c.status == ChallengeStatus.failed).length;
  }

  /// 獲得したアチーブメント数
  int get totalAchievements => achievementList.length;

  /// カテゴリ別のアチーブメント数
  int achievementCountByType(AchievementType type) {
    return achievementList.where((a) => a.type == type).length;
  }

  Map<String, dynamic> toFirestore() => {
        'streakDays': streakDays,
        'longestStreak': longestStreak,
        'dailyCheckins': dailyCheckins,
        'lastCheckinDate': lastCheckinDate.toIso8601String(),
        'challengeProgress': challengeProgress
            .map((c) => {'id': c.id, ...c.toFirestore()})
            .toList(),
        'achievementList': achievementList
            .map((a) => {'id': a.id, ...a.toFirestore()})
            .toList(),
        'growthTimeline': growthTimeline
            .map((g) => {'id': g.id, ...g.toFirestore()})
            .toList(),
        'totalPoints': totalPoints,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'metadata': metadata,
      };

  factory EngagementMetrics.fromFirestore(
      String uid, Map<String, dynamic> data) {
    final List<ChallengeProgress> challenges = [];
    if (data['challengeProgress'] is List) {
      for (var item in data['challengeProgress'] as List) {
        final id = item['id'] as String? ?? 'challenge_${DateTime.now().millisecondsSinceEpoch}';
        challenges.add(
          ChallengeProgress.fromFirestore(
            uid,
            id,
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    final List<Achievement> achievements = [];
    if (data['achievementList'] is List) {
      for (var item in data['achievementList'] as List) {
        final id = item['id'] as String? ?? 'achievement_${DateTime.now().millisecondsSinceEpoch}';
        achievements.add(
          Achievement.fromFirestore(
            uid,
            id,
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    final List<GrowthEntry> timeline = [];
    if (data['growthTimeline'] is List) {
      for (var item in data['growthTimeline'] as List) {
        final id = item['id'] as String? ?? 'growth_${DateTime.now().millisecondsSinceEpoch}';
        timeline.add(
          GrowthEntry.fromFirestore(
            uid,
            id,
            Map<String, dynamic>.from(item),
          ),
        );
      }
    }

    return EngagementMetrics(
      uid: uid,
      streakDays: data['streakDays'] as int? ?? 0,
      longestStreak: data['longestStreak'] as int? ?? 0,
      dailyCheckins: data['dailyCheckins'] as int? ?? 0,
      lastCheckinDate: data['lastCheckinDate'] != null
          ? DateTime.parse(data['lastCheckinDate'] as String)
          : DateTime.now(),
      challengeProgress: challenges,
      achievementList: achievements,
      growthTimeline: timeline,
      totalPoints: data['totalPoints'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? DateTime.parse(data['updatedAt'] as String)
          : DateTime.now(),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  EngagementMetrics copyWith({
    int? streakDays,
    int? longestStreak,
    int? dailyCheckins,
    DateTime? lastCheckinDate,
    List<ChallengeProgress>? challengeProgress,
    List<Achievement>? achievementList,
    List<GrowthEntry>? growthTimeline,
    int? totalPoints,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return EngagementMetrics(
      uid: uid,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      dailyCheckins: dailyCheckins ?? this.dailyCheckins,
      lastCheckinDate: lastCheckinDate ?? this.lastCheckinDate,
      challengeProgress: challengeProgress ?? this.challengeProgress,
      achievementList: achievementList ?? this.achievementList,
      growthTimeline: growthTimeline ?? this.growthTimeline,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      metadata: metadata ?? this.metadata,
    );
  }

  /// チャレンジを追加
  EngagementMetrics addChallenge(ChallengeProgress challenge) {
    final updated = List<ChallengeProgress>.from(challengeProgress)
      ..add(challenge);
    return copyWith(challengeProgress: updated);
  }

  /// チャレンジを更新
  EngagementMetrics updateChallenge(String challengeId, ChallengeProgress updatedChallenge) {
    final updated = challengeProgress
        .map((c) => c.id == challengeId ? updatedChallenge : c)
        .toList();
    return copyWith(challengeProgress: updated);
  }

  /// アチーブメントを追加
  EngagementMetrics addAchievement(Achievement achievement) {
    final updated = List<Achievement>.from(achievementList)..add(achievement);
    final newPoints = totalPoints + achievement.points;
    return copyWith(
      achievementList: updated,
      totalPoints: newPoints,
    );
  }

  /// グロース エントリを追加
  EngagementMetrics addGrowthEntry(GrowthEntry entry) {
    final updated = List<GrowthEntry>.from(growthTimeline)..add(entry);
    return copyWith(growthTimeline: updated);
  }

  /// チェックインを記録（ストリーク更新ロジック）
  EngagementMetrics recordCheckin() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckin = DateTime(
      lastCheckinDate.year,
      lastCheckinDate.month,
      lastCheckinDate.day,
    );
    final yesterday = today.subtract(const Duration(days: 1));

    int newStreak = streakDays;
    int newLongest = longestStreak;

    // 昨日チェックインされていればストリーク継続
    if (lastCheckin == yesterday) {
      newStreak = streakDays + 1;
    }
    // 昨日チェックインなければストリーク開始
    else if (lastCheckin != today) {
      newStreak = 1;
    }

    // 最長ストリーク更新
    if (newStreak > longestStreak) {
      newLongest = newStreak;
    }

    return copyWith(
      streakDays: newStreak,
      longestStreak: newLongest,
      dailyCheckins: dailyCheckins + 1,
      lastCheckinDate: now,
    );
  }
}
