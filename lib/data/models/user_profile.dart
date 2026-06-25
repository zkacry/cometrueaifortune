import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/constants/tarot_data.dart';

class UserProfile {
  final String uid;
  final String nickname;
  final DateTime birthdate;
  final String? gender;
  final UserPlan plan;
  final AiPersona persona;
  final int monthlyReadingCount;
  final String monthKey; // "2026-05" 形式
  final bool notificationEnabled;
  final int notificationHour; // 0-23
  final List<String> personalityTraits; // 性格・ライフスタイル特性
  final DateTime createdAt; // アカウント作成日（初月判定用）
  final DateTime? subscriptionExpiresAt; // 購読期限

  UserProfile({
    required this.uid,
    required this.nickname,
    required this.birthdate,
    this.gender,
    this.plan = UserPlan.free,
    this.persona = AiPersona.insight,
    this.monthlyReadingCount = 0,
    String? monthKey,
    this.notificationEnabled = true,
    this.notificationHour = 9,
    this.personalityTraits = const [],
    DateTime? createdAt,
    this.subscriptionExpiresAt,
  })  : monthKey = monthKey ?? _currentMonthKey(),
        createdAt = createdAt ?? DateTime.now();

  String get zodiacSign => getZodiacSign(birthdate);

  /// 今月が初月かどうか（アカウント作成月）
  bool get isFirstMonth {
    final now = DateTime.now();
    final createdYear = createdAt.year;
    final createdMonth = createdAt.month;
    return now.year == createdYear && now.month == createdMonth;
  }

  /// このプランの月間上限読み数を取得（初月かどうかを考慮）
  int get effectiveMonthlyReadingLimit {
    switch (plan) {
      case UserPlan.free:
        return isFirstMonth ? 10 : 3;
      case UserPlan.light:
        return 50;
      case UserPlan.pro:
        return 300;
    }
  }

  bool get canUseReading => monthlyReadingCount < effectiveMonthlyReadingLimit;

  int get remainingReadings =>
      effectiveMonthlyReadingLimit - monthlyReadingCount;

  static String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toFirestore() => {
        'nickname': nickname,
        'birthdate': birthdate.toIso8601String(),
        'gender': gender,
        'plan': plan.name,
        'persona': persona.name,
        'monthlyReadingCount': monthlyReadingCount,
        'monthKey': monthKey,
        'notificationEnabled': notificationEnabled,
        'notificationHour': notificationHour,
        'personalityTraits': personalityTraits,
        'createdAt': createdAt.toIso8601String(),
        if (subscriptionExpiresAt != null)
          'subscriptionExpiresAt': subscriptionExpiresAt!.toIso8601String(),
      };

  factory UserProfile.fromFirestore(
      String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      nickname: data['nickname'] as String? ?? '',
      birthdate: DateTime.parse(data['birthdate'] as String),
      gender: data['gender'] as String?,
      plan: UserPlan.values.firstWhere(
        (p) => p.name == data['plan'],
        orElse: () => UserPlan.free,
      ),
      persona: AiPersona.values.firstWhere(
        (p) => p.name == data['persona'],
        orElse: () => AiPersona.insight,
      ),
      monthlyReadingCount: data['monthlyReadingCount'] as int? ?? 0,
      monthKey: data['monthKey'] as String? ?? _currentMonthKey(),
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      notificationHour: data['notificationHour'] as int? ?? 9,
      personalityTraits: (data['personalityTraits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'] as String)
          : DateTime.now(),
      subscriptionExpiresAt: data['subscriptionExpiresAt'] != null
          ? DateTime.parse(data['subscriptionExpiresAt'] as String)
          : null,
    );
  }

  UserProfile copyWith({
    String? nickname,
    DateTime? birthdate,
    String? gender,
    UserPlan? plan,
    AiPersona? persona,
    int? monthlyReadingCount,
    String? monthKey,
    bool? notificationEnabled,
    int? notificationHour,
    List<String>? personalityTraits,
    DateTime? createdAt,
    DateTime? subscriptionExpiresAt,
  }) {
    return UserProfile(
      uid: uid,
      nickname: nickname ?? this.nickname,
      birthdate: birthdate ?? this.birthdate,
      gender: gender ?? this.gender,
      plan: plan ?? this.plan,
      persona: persona ?? this.persona,
      monthlyReadingCount: monthlyReadingCount ?? this.monthlyReadingCount,
      monthKey: monthKey ?? this.monthKey,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      createdAt: createdAt ?? this.createdAt,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }
}
