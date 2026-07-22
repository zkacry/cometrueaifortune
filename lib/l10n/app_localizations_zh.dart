// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'MyFortune 命运';

  @override
  String get navHome => '首页';

  @override
  String get navHistory => '记录';

  @override
  String get navSettings => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageDescription => '选择应用显示语言以及AI占卜结果的生成语言';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageKorean => '한국어';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确定';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonNext => '下一步';

  @override
  String get commonBack => '返回';

  @override
  String get commonRetry => '请重试';

  @override
  String get commonOk => 'OK';

  @override
  String get commonUpgrade => '升级';

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
    return '你好，$nickname';
  }

  @override
  String homeMonthlyUsage(Object count, Object limit) {
    return '本月完整占卜次数：$count / $limit次';
  }

  @override
  String get homeLimitBadge => '已达上限';

  @override
  String get homeStartFullReading => '开始完整占卜';

  @override
  String get homeLimitReached => '本月次数已用完';

  @override
  String get homeStartSubtitle1 => '可选择塔罗牌或生命灵数占卜';

  @override
  String get homeStartSubtitle2 => '升级Light套餐可增至每月50次';

  @override
  String get homeRecentConsultations => '最近的咨询';

  @override
  String get homeLimitDialogTitle => '本月占卜次数已用完 ✨';

  @override
  String homeLimitDialogBody(Object plan, Object limit) {
    return '您已用完$plan套餐本月$limit次的占卜额度。';
  }

  @override
  String get homePromoTitle => '💫 Light 套餐 每月¥680';

  @override
  String get homePromoSubtitle => '每月最多50次占卜\n历史模式分析・记忆型AI';

  @override
  String get homeWaitNextMonth => '等到下个月';

  @override
  String get homeWebNotSupported => '网页版无法使用占卜API';

  @override
  String get homeFetchFailed => '获取运势失败';

  @override
  String get onboardingEnterNickname => '请输入昵称';

  @override
  String get onboardingNotificationTitle => '该看运势啦';

  @override
  String onboardingNotificationBody(Object nickname) {
    return '$nickname，来看看今天的运势吧 ✨';
  }

  @override
  String get onboardingGenericError => '发生错误，请重试。';

  @override
  String get onboardingWelcomeTitle => '✨ MyFortune';

  @override
  String get onboardingHeading => '请告诉我们\n关于你的信息';

  @override
  String get onboardingSubtitle => '30秒了解今天的运势';

  @override
  String get onboardingNicknameLabel => '昵称';

  @override
  String get onboardingNicknameHint => '小明';

  @override
  String get onboardingBirthdateLabel => '出生日期';

  @override
  String get onboardingStartButton => '立即占卜 ✨';

  @override
  String get worryPrompt => '你现在在烦恼什么？';

  @override
  String get worryHint => '请告诉我们你在烦恼的事情…';

  @override
  String get worryEmptyError => '请输入你的烦恼';

  @override
  String get errorGenericReading => '占卜过程中发生错误，请重试。';

  @override
  String get errorWebNotSupported => '请使用安卓应用';

  @override
  String get errorApiAuth => 'API认证失败，请检查设置。';

  @override
  String get errorTimeout => '连接超时，请检查网络。';

  @override
  String get errorNoInternet => '请检查您的网络连接。';

  @override
  String get worryCategoryLove => '💕 恋爱・伴侣';

  @override
  String get worryCategoryWork => '💼 工作・事业';

  @override
  String get worryCategoryRelationship => '👥 人际关系';

  @override
  String get worryCategoryMoney => '💰 金钱・未来';

  @override
  String get worryCategoryFamily => '🏠 家庭';

  @override
  String get worryCategoryHealth => '🌿 健康・心理';

  @override
  String get worryCategoryPath => '🌟 人生方向・转折';

  @override
  String get worryCategoryOther => '✏️ 其他';

  @override
  String get tarotAppBarTitle => '塔罗牌占卜';

  @override
  String get tarotSubtitle => '请选择主题并抽取卡牌。';

  @override
  String get tarotDrawButton => '抽卡 🃏';

  @override
  String get tarotCardsRevealed => '已抽出3张卡牌';

  @override
  String get tarotReversed => '逆位';

  @override
  String get tarotUpright => '正位';

  @override
  String get tarotReadingButton => '开始占卜 ✨';

  @override
  String get tarotLoading => '卡牌正在诉说…';

  @override
  String get positionPast => '过去';

  @override
  String get positionPresent => '现在';

  @override
  String get positionFuture => '未来';

  @override
  String get numerologyAppBarTitle => '生命灵数占卜';

  @override
  String get numerologyLoading => '数字正在诉说…';

  @override
  String get numerologyLifePath => '生命灵数';

  @override
  String get numerologySubtitle => '请选择主题，向数字提问。';

  @override
  String get numerologyButton => '询问数字 🔢';

  @override
  String get simpleAutoProfileReading => '（根据个人资料占卜）';

  @override
  String simpleLoadingFormat(Object type) {
    return '正在通过$type占卜…';
  }

  @override
  String simpleReadingButton(Object emoji) {
    return '$emoji 开始占卜';
  }

  @override
  String get bloodTypeQuestion => '你的血型是？';

  @override
  String get dreamQuestion => '你做了什么梦？';

  @override
  String get dreamSubtitle => '关键词或详细描述都可以';

  @override
  String get dreamHint => '例如：在天上飞、在水中、遇见了陌生人…';

  @override
  String get fourPillarsBirthTimeLabel => '出生时间（如果知道的话）';

  @override
  String get fourPillarsBirthTimeHint => '例如：上午8点30分（不清楚可留空）';

  @override
  String get resultAppBarTitle => '占卜结果';

  @override
  String get resultAutoSaved => '已自动保存至记录';

  @override
  String get resultHitQuestion => '✨ 这次占卜准了吗？';

  @override
  String get hitYes => '准了';

  @override
  String get hitUnknown => '还不确定';

  @override
  String get hitNo => '不准';

  @override
  String get resultActionsHeading => '✨ 推荐行动';

  @override
  String get resultActionsSubtitle => '勾选想尝试的行动，会自动记录';

  @override
  String resultActionsCommitted(Object count) {
    return '$count项进行中';
  }

  @override
  String get resultActionsAddedHeading => '🎯 已添加到行动列表';

  @override
  String get resultActionsAddedHint => '可在记录标签 → 行动 中管理进度';

  @override
  String scorePoints(Object score) {
    return '$score分';
  }

  @override
  String get compatibilityAppBarTitle => '💕 相性占卜';

  @override
  String get compatibilityYou => '你';

  @override
  String get compatibilityPartner => '对方';

  @override
  String get compatibilityPartnerNameHint => '对方的名字（昵称也可以）';

  @override
  String get compatibilityEnterPartnerName => '请输入对方的名字';

  @override
  String get compatibilityStartButton => '占卜相性 💕';

  @override
  String get compatibilityLoading => '正在分析两人的相性...';

  @override
  String get compatibilityError => '占卜失败，请重试。';

  @override
  String get compatibilityRetryButton => '再占卜一次';

  @override
  String compatibilityResultTitle(Object name) {
    return '与$name的相性';
  }

  @override
  String get compatibilityLove => '💝 恋爱相性';

  @override
  String get compatibilityFriendship => '🤝 友情相性';

  @override
  String get compatibilityWork => '💼 工作相性';

  @override
  String get compatibilityAdvice => '💡 建议';

  @override
  String get compatScoreBest => '最佳相性 ✨';

  @override
  String get compatScoreGreat => '相性绝佳 💕';

  @override
  String get compatScoreGood => '相性良好 😊';

  @override
  String get compatScoreAverage => '相性一般 🌱';

  @override
  String get compatScoreEffort => '需要努力 💪';

  @override
  String get omikujiErrorFetch => '抽签失败';

  @override
  String get omikujiAppBarTitle => '抽签占卜';

  @override
  String get omikujiLoading => '正在抽签…';

  @override
  String get omikujiRetryButton => '再抽一次';

  @override
  String omikujiIntro(Object nickname) {
    return '$nickname，\n来抽一下今天的运势吧';
  }

  @override
  String get omikujiDrawButton => '🎋 抽签';

  @override
  String get fortuneTypeAppBarTitle => '选择占卜方式';

  @override
  String get fortuneTypeFreeSection => '✨ 随时免费';

  @override
  String get fortuneTypeLightSection => '🌙 Light套餐以上';

  @override
  String get fortuneTypeProSection => '🏮 仅限Pro套餐';

  @override
  String fortuneTypeRemaining(Object count) {
    return '本月剩余$count次';
  }

  @override
  String fortuneTypeUpgradeDialogTitle(Object type, Object plan) {
    return '$type需要$plan套餐';
  }

  @override
  String fortuneTypeUpgradeDialogBody(Object price) {
    return '每月¥$price即可解锁此占卜方式及全部功能。';
  }
}
