// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'マイフォーチューン';

  @override
  String get navHome => 'ホーム';

  @override
  String get navHistory => '記録';

  @override
  String get navSettings => '設定';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageDescription => 'アプリの表示言語とAI鑑定文の生成言語を選択します';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageKorean => '한국어';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonConfirm => '決定';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonNext => '次へ';

  @override
  String get commonBack => '戻る';

  @override
  String get commonRetry => 'もう一度お試しください';

  @override
  String get commonOk => 'OK';

  @override
  String get commonUpgrade => 'アップグレード';

  @override
  String get rankDaikichi => '大吉';

  @override
  String get rankKichi => '吉';

  @override
  String get rankChukichi => '中吉';

  @override
  String get rankShokichi => '小吉';

  @override
  String get rankKyo => '凶';

  @override
  String get homeAppBarTitle => 'M Y F O R T U N E';

  @override
  String homeGreeting(Object nickname) {
    return 'こんにちは、$nicknameさん';
  }

  @override
  String homeMonthlyUsage(Object count, Object limit) {
    return '今月のフル占い：$count / $limit回';
  }

  @override
  String get homeLimitBadge => '上限';

  @override
  String get homeStartFullReading => 'フル占いを始める';

  @override
  String get homeLimitReached => '今月の回数上限に達しました';

  @override
  String get homeStartSubtitle1 => 'タロット・数秘術から選べます';

  @override
  String get homeStartSubtitle2 => 'Lightプランで月50回に増やせます';

  @override
  String get homeRecentConsultations => '最近の相談';

  @override
  String get homeLimitDialogTitle => '今月の占い回数を使い切りました ✨';

  @override
  String homeLimitDialogBody(Object plan, Object limit) {
    return '$planプランの月$limit回をすべて使い切りました。';
  }

  @override
  String get homePromoTitle => '💫 Light プラン  月680円';

  @override
  String get homePromoSubtitle => '月50回まで占い放題\n過去パターン分析・記憶型AI';

  @override
  String get homeWaitNextMonth => '来月まで待つ';

  @override
  String get homeWebNotSupported => 'Web版では占いAPIは利用できません';

  @override
  String get homeFetchFailed => '運勢の取得に失敗しました';

  @override
  String get onboardingEnterNickname => 'ニックネームを入力してください';

  @override
  String get onboardingNotificationTitle => '運勢のお時間です';

  @override
  String onboardingNotificationBody(Object nickname) {
    return '$nicknameさん、今日の運勢をチェックしましょう ✨';
  }

  @override
  String get onboardingGenericError => 'エラーが発生しました。もう一度お試しください。';

  @override
  String get onboardingWelcomeTitle => '✨ マイフォーチューン';

  @override
  String get onboardingHeading => 'あなたのことを\n教えてください';

  @override
  String get onboardingSubtitle => '30秒で今日の運勢がわかります';

  @override
  String get onboardingNicknameLabel => 'ニックネーム';

  @override
  String get onboardingNicknameHint => 'あいこ';

  @override
  String get onboardingBirthdateLabel => '生年月日';

  @override
  String get onboardingStartButton => '今すぐ占う ✨';

  @override
  String get worryPrompt => '今、何が気になっていますか？';

  @override
  String get worryHint => '気になっていることを教えてください…';

  @override
  String get worryEmptyError => '悩みを入力してください';

  @override
  String get errorGenericReading => '鑑定中にエラーが発生しました。もう一度お試しください。';

  @override
  String get errorWebNotSupported => 'Androidアプリをご使用ください';

  @override
  String get errorApiAuth => 'APIの認証に失敗しました。設定を確認してください。';

  @override
  String get errorTimeout => '接続がタイムアウトしました。ネットワークを確認してください。';

  @override
  String get errorNoInternet => 'インターネット接続を確認してください。';

  @override
  String get worryCategoryLove => '💕 恋愛・パートナー';

  @override
  String get worryCategoryWork => '💼 仕事・キャリア';

  @override
  String get worryCategoryRelationship => '👥 人間関係';

  @override
  String get worryCategoryMoney => '💰 お金・将来';

  @override
  String get worryCategoryFamily => '🏠 家族';

  @override
  String get worryCategoryHealth => '🌿 健康・メンタル';

  @override
  String get worryCategoryPath => '🌟 進路・転換期';

  @override
  String get worryCategoryOther => '✏️ その他';

  @override
  String get tarotAppBarTitle => 'タロット占い';

  @override
  String get tarotSubtitle => 'テーマを選んでカードを引いてください。';

  @override
  String get tarotDrawButton => 'カードを引く 🃏';

  @override
  String get tarotCardsRevealed => '3枚のカードが出ました';

  @override
  String get tarotReversed => '逆位置';

  @override
  String get tarotUpright => '正位置';

  @override
  String get tarotReadingButton => '鑑定してもらう ✨';

  @override
  String get tarotLoading => 'カードが語りかけています…';

  @override
  String get positionPast => '過去';

  @override
  String get positionPresent => '現在';

  @override
  String get positionFuture => '未来';

  @override
  String get numerologyAppBarTitle => '数秘術占い';

  @override
  String get numerologyLoading => '数字が語りかけています…';

  @override
  String get numerologyLifePath => 'ライフパス';

  @override
  String get numerologySubtitle => 'テーマを選んで数字に聞いてみましょう。';

  @override
  String get numerologyButton => '数字に聞く 🔢';

  @override
  String get simpleAutoProfileReading => '（プロフィール情報から鑑定）';

  @override
  String simpleLoadingFormat(Object type) {
    return '$typeで鑑定中…';
  }

  @override
  String simpleReadingButton(Object emoji) {
    return '$emoji 鑑定する';
  }

  @override
  String get bloodTypeQuestion => 'あなたの血液型は？';

  @override
  String get dreamQuestion => 'どんな夢を見ましたか？';

  @override
  String get dreamSubtitle => 'キーワードでも、詳細でも構いません';

  @override
  String get dreamHint => '例：空を飛んでいた、水の中にいた、知らない人に会った…';

  @override
  String get fourPillarsBirthTimeLabel => '出生時刻（わかれば）';

  @override
  String get fourPillarsBirthTimeHint => '例：午前8時30分（不明の場合は空欄でOK）';

  @override
  String get resultAppBarTitle => '鑑定結果';

  @override
  String get resultAutoSaved => '記録に自動保存済み';

  @override
  String get resultHitQuestion => '✨ この占い、当たりましたか？';

  @override
  String get hitYes => '当たった';

  @override
  String get hitUnknown => 'わからない';

  @override
  String get hitNo => '外れた';

  @override
  String get resultActionsHeading => '✨ 今後のアクション候補';

  @override
  String get resultActionsSubtitle => '取り組みたいアクションにチェックを入れると自動記録されます';

  @override
  String resultActionsCommitted(Object count) {
    return '$count件取り組む';
  }

  @override
  String get resultActionsAddedHeading => '🎯 アクションリストに追加しました';

  @override
  String get resultActionsAddedHint => '記録タブ → アクション で進捗を管理できます';

  @override
  String scorePoints(Object score) {
    return '$score点';
  }

  @override
  String get compatibilityAppBarTitle => '💕 相性占い';

  @override
  String get compatibilityYou => 'あなた';

  @override
  String get compatibilityPartner => '相手';

  @override
  String get compatibilityPartnerNameHint => '相手の名前（ニックネーム可）';

  @override
  String get compatibilityEnterPartnerName => '相手の名前を入力してください';

  @override
  String get compatibilityStartButton => '相性を占う 💕';

  @override
  String get compatibilityLoading => '二人の相性を分析中...';

  @override
  String get compatibilityError => '占いに失敗しました。もう一度お試しください。';

  @override
  String get compatibilityRetryButton => 'もう一度占う';

  @override
  String compatibilityResultTitle(Object name) {
    return '$nameさんとの相性';
  }

  @override
  String get compatibilityLove => '💝 恋愛相性';

  @override
  String get compatibilityFriendship => '🤝 友情相性';

  @override
  String get compatibilityWork => '💼 仕事相性';

  @override
  String get compatibilityAdvice => '💡 アドバイス';

  @override
  String get compatScoreBest => '最高の相性 ✨';

  @override
  String get compatScoreGreat => '相性抜群 💕';

  @override
  String get compatScoreGood => '良い相性 😊';

  @override
  String get compatScoreAverage => '普通の相性 🌱';

  @override
  String get compatScoreEffort => '要努力 💪';

  @override
  String get omikujiErrorFetch => 'おみくじの取得に失敗しました';

  @override
  String get omikujiAppBarTitle => 'おみくじ';

  @override
  String get omikujiLoading => 'おみくじを引いています…';

  @override
  String get omikujiRetryButton => 'もう一度引く';

  @override
  String omikujiIntro(Object nickname) {
    return '$nicknameさん、\n今日の運勢を引いてみましょう';
  }

  @override
  String get omikujiDrawButton => '🎋 おみくじを引く';

  @override
  String get fortuneTypeAppBarTitle => '占術を選ぶ';

  @override
  String get fortuneTypeFreeSection => '✨ いつでも無料';

  @override
  String get fortuneTypeLightSection => '🌙 Light以上';

  @override
  String get fortuneTypeProSection => '🏮 Pro限定';

  @override
  String fortuneTypeRemaining(Object count) {
    return '今月残り$count回';
  }

  @override
  String fortuneTypeUpgradeDialogTitle(Object type, Object plan) {
    return '$typeは$planプランから';
  }

  @override
  String fortuneTypeUpgradeDialogBody(Object price) {
    return '月$price円でこの占術を含む全機能が解放されます。';
  }
}
