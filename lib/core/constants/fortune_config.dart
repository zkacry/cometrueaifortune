/// プランと利用制限の設定
enum UserPlan { free, light, pro }

extension UserPlanX on UserPlan {
  String get displayName {
    switch (this) {
      case UserPlan.free:  return 'Free';
      case UserPlan.light: return 'Light';
      case UserPlan.pro:   return 'Pro';
    }
  }

  int get monthlyReadingLimit {
    switch (this) {
      case UserPlan.free:  return 10;
      case UserPlan.light: return 50;
      case UserPlan.pro:   return 300;
    }
  }

  int get monthlyPrice {
    switch (this) {
      case UserPlan.free:  return 0;
      case UserPlan.light: return 680;
      case UserPlan.pro:   return 1500;
    }
  }

  bool get hasDailyFortune        => true;
  bool get hasPatternRecognition  => this != UserPlan.free;
  bool get hasMonthlyReport       => this == UserPlan.pro;
  bool get hasPersonaCustomization => this == UserPlan.pro;
}

/// 占術の種類
enum FortuneType {
  // ── Free ──────────────────────────────
  tarot,
  numerology,
  compatibility,
  dream,
  bloodType,
  omikuji,
  // ── Light以上 ─────────────────────────
  rune,
  pastLife,
  horoscope,
  // ── Pro限定 ───────────────────────────
  fourPillars,
  auspiciousCalendar,
}

extension FortuneTypeX on FortuneType {
  String get displayName {
    switch (this) {
      case FortuneType.tarot:             return 'タロット';
      case FortuneType.numerology:        return '数秘術';
      case FortuneType.compatibility:     return '相性占い';
      case FortuneType.dream:             return '夢占い';
      case FortuneType.bloodType:         return '血液型占い';
      case FortuneType.omikuji:           return 'おみくじ';
      case FortuneType.rune:              return 'ルーン占い';
      case FortuneType.pastLife:          return '前世占い';
      case FortuneType.horoscope:         return 'ホロスコープ';
      case FortuneType.fourPillars:       return '四柱推命';
      case FortuneType.auspiciousCalendar:return '縁起カレンダー';
    }
  }

  String get emoji {
    switch (this) {
      case FortuneType.tarot:             return '🃏';
      case FortuneType.numerology:        return '🔢';
      case FortuneType.compatibility:     return '💕';
      case FortuneType.dream:             return '🌙';
      case FortuneType.bloodType:         return '🩸';
      case FortuneType.omikuji:           return '🎋';
      case FortuneType.rune:              return '᚛';
      case FortuneType.pastLife:          return '🌀';
      case FortuneType.horoscope:         return '⭐';
      case FortuneType.fourPillars:       return '🏮';
      case FortuneType.auspiciousCalendar:return '📅';
    }
  }

  String get description {
    switch (this) {
      case FortuneType.tarot:             return '3枚のカードが今のあなたを語ります';
      case FortuneType.numerology:        return '生年月日の数字から運命を読み解きます';
      case FortuneType.compatibility:     return '相手との相性を多角的に分析します';
      case FortuneType.dream:             return '昨夜の夢に隠されたメッセージを読み解きます';
      case FortuneType.bloodType:         return '血液型から今のあなたの運勢を占います';
      case FortuneType.omikuji:           return '今日の運勢をおみくじで引いてみましょう';
      case FortuneType.rune:              return '古代北欧のルーン石があなたに語りかけます';
      case FortuneType.pastLife:          return '前世のあなたの姿と今世の使命を読み解きます';
      case FortuneType.horoscope:         return '天体の配置からあなたの星座運を詳しく分析します';
      case FortuneType.fourPillars:       return '生年月日時の干支から運命と年運を読みます';
      case FortuneType.auspiciousCalendar:return '今月の吉日・凶日・行動の吉方位を提示します';
    }
  }

  /// このアイコン画像のアセットパス（なければ null → emoji を使う）
  String? get iconAsset {
    switch (this) {
      case FortuneType.tarot:              return 'assets/icons/icon_tarot.jpg';
      case FortuneType.numerology:         return 'assets/icons/icon_number.jpg';
      case FortuneType.compatibility:      return 'assets/icons/icon_aishou.jpg';
      case FortuneType.bloodType:          return 'assets/icons/icon_bloodtype.jpg';
      case FortuneType.omikuji:            return 'assets/icons/icon_omikuji.jpg';
      case FortuneType.rune:               return 'assets/icons/icon_rune.jpg';
      case FortuneType.pastLife:           return 'assets/icons/icon_pastlife.jpg';
      case FortuneType.horoscope:          return 'assets/icons/icon_horoscope.jpg';
      case FortuneType.fourPillars:        return 'assets/icons/icon_fourpillars.jpg';
      case FortuneType.auspiciousCalendar: return 'assets/icons/icon_calendar.jpg';
      default:                             return null;
    }
  }

  /// 利用に必要な最低プラン
  UserPlan get requiredPlan {
    switch (this) {
      case FortuneType.tarot:
      case FortuneType.compatibility:
      case FortuneType.bloodType:
      case FortuneType.omikuji:
        return UserPlan.free;
      case FortuneType.numerology: // Free → Light に変更
      case FortuneType.dream:
      case FortuneType.rune:
      case FortuneType.pastLife:
      case FortuneType.horoscope:
        return UserPlan.light;
      case FortuneType.fourPillars:
      case FortuneType.auspiciousCalendar:
        return UserPlan.pro;
    }
  }

  /// 非表示（無効化）フラグ
  bool get isHidden {
    switch (this) {
      case FortuneType.dream:
        return true;
      default:
        return false;
    }
  }

  bool isAvailableFor(UserPlan plan) =>
      plan.index >= requiredPlan.index;
}

/// AIペルソナ（Light以上）
enum AiPersona { logica, insight, strategy }

extension AiPersonaX on AiPersona {
  String get displayName {
    switch (this) {
      case AiPersona.logica:    return 'Logica（分析者）';
      case AiPersona.insight:   return 'Insight（観察者）';
      case AiPersona.strategy:  return 'Strategy（戦略家）';
    }
  }

  String get iconAsset {
    switch (this) {
      case AiPersona.logica:   return 'assets/icons/icon_brain.jpg';
      case AiPersona.insight:  return 'assets/icons/icon_kansatsu.jpg';
      case AiPersona.strategy: return 'assets/icons/icon_senryakuka.jpg';
    }
  }

  String get systemPromptStyle {
    switch (this) {
      case AiPersona.logica:
        return '論理的・データ重視のスタイルで、パターンと確率を中心に分析してください。';
      case AiPersona.insight:
        return '洞察的・直感的なスタイルで、潜在意識や心理的背景を読み取ってください。';
      case AiPersona.strategy:
        return '実践的・行動指向のスタイルで、具体的な次のステップを提案してください。';
    }
  }
}
