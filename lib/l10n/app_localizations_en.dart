// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyFortune';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDescription =>
      'Choose the app display language and the language used for AI readings';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageKorean => '한국어';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonRetry => 'Please try again';

  @override
  String get commonOk => 'OK';

  @override
  String get commonUpgrade => 'Upgrade';

  @override
  String get rankDaikichi => 'Great Blessing';

  @override
  String get rankKichi => 'Blessing';

  @override
  String get rankChukichi => 'Medium Blessing';

  @override
  String get rankShokichi => 'Small Blessing';

  @override
  String get rankKyo => 'Misfortune';

  @override
  String get homeAppBarTitle => 'M Y F O R T U N E';

  @override
  String homeGreeting(Object nickname) {
    return 'Hi, $nickname';
  }

  @override
  String homeMonthlyUsage(Object count, Object limit) {
    return 'Full readings this month: $count / $limit';
  }

  @override
  String get homeLimitBadge => 'Limit';

  @override
  String get homeStartFullReading => 'Start a full reading';

  @override
  String get homeLimitReached => 'You\'ve reached this month\'s limit';

  @override
  String get homeStartSubtitle1 => 'Choose from Tarot or Numerology';

  @override
  String get homeStartSubtitle2 => 'Upgrade to Light for 50 readings a month';

  @override
  String get homeRecentConsultations => 'Recent consultations';

  @override
  String get homeLimitDialogTitle =>
      'You\'ve used all your readings this month ✨';

  @override
  String homeLimitDialogBody(Object plan, Object limit) {
    return 'You\'ve used all $limit readings included in the $plan plan this month.';
  }

  @override
  String get homePromoTitle => '💫 Light Plan — ¥680/month';

  @override
  String get homePromoSubtitle =>
      'Up to 50 readings a month\nPast pattern analysis & memory-based AI';

  @override
  String get homeWaitNextMonth => 'Wait until next month';

  @override
  String get homeWebNotSupported =>
      'The fortune API is not available on the web version';

  @override
  String get homeFetchFailed => 'Failed to fetch your fortune';

  @override
  String get onboardingEnterNickname => 'Please enter a nickname';

  @override
  String get onboardingNotificationTitle => 'Time for your fortune';

  @override
  String onboardingNotificationBody(Object nickname) {
    return '$nickname, check your fortune for today ✨';
  }

  @override
  String get onboardingGenericError => 'An error occurred. Please try again.';

  @override
  String get onboardingWelcomeTitle => '✨ MyFortune';

  @override
  String get onboardingHeading => 'Tell us\nabout yourself';

  @override
  String get onboardingSubtitle => 'Get today\'s fortune in 30 seconds';

  @override
  String get onboardingNicknameLabel => 'Nickname';

  @override
  String get onboardingNicknameHint => 'Alex';

  @override
  String get onboardingBirthdateLabel => 'Date of birth';

  @override
  String get onboardingStartButton => 'Get started ✨';

  @override
  String get worryPrompt => 'What\'s on your mind right now?';

  @override
  String get worryHint => 'Tell us what\'s on your mind…';

  @override
  String get worryEmptyError => 'Please enter what\'s on your mind';

  @override
  String get errorGenericReading =>
      'An error occurred during the reading. Please try again.';

  @override
  String get errorWebNotSupported => 'Please use the Android app';

  @override
  String get errorApiAuth =>
      'API authentication failed. Please check your settings.';

  @override
  String get errorTimeout => 'Connection timed out. Please check your network.';

  @override
  String get errorNoInternet => 'Please check your internet connection.';

  @override
  String get worryCategoryLove => '💕 Love & Relationships';

  @override
  String get worryCategoryWork => '💼 Work & Career';

  @override
  String get worryCategoryRelationship => '👥 Relationships';

  @override
  String get worryCategoryMoney => '💰 Money & Future';

  @override
  String get worryCategoryFamily => '🏠 Family';

  @override
  String get worryCategoryHealth => '🌿 Health & Wellness';

  @override
  String get worryCategoryPath => '🌟 Path & Transitions';

  @override
  String get worryCategoryOther => '✏️ Other';

  @override
  String get tarotAppBarTitle => 'Tarot Reading';

  @override
  String get tarotSubtitle => 'Choose a theme and draw your cards.';

  @override
  String get tarotDrawButton => 'Draw Cards 🃏';

  @override
  String get tarotCardsRevealed => '3 cards drawn';

  @override
  String get tarotReversed => 'Reversed';

  @override
  String get tarotUpright => 'Upright';

  @override
  String get tarotReadingButton => 'Get Your Reading ✨';

  @override
  String get tarotLoading => 'The cards are speaking…';

  @override
  String get positionPast => 'Past';

  @override
  String get positionPresent => 'Present';

  @override
  String get positionFuture => 'Future';

  @override
  String get numerologyAppBarTitle => 'Numerology Reading';

  @override
  String get numerologyLoading => 'The numbers are speaking…';

  @override
  String get numerologyLifePath => 'Life Path';

  @override
  String get numerologySubtitle => 'Choose a theme and ask the numbers.';

  @override
  String get numerologyButton => 'Ask the Numbers 🔢';

  @override
  String get simpleAutoProfileReading => '(Based on your profile)';

  @override
  String simpleLoadingFormat(Object type) {
    return 'Reading with $type…';
  }

  @override
  String simpleReadingButton(Object emoji) {
    return '$emoji Get Reading';
  }

  @override
  String get bloodTypeQuestion => 'What\'s your blood type?';

  @override
  String get dreamQuestion => 'What did you dream about?';

  @override
  String get dreamSubtitle => 'Keywords or details are both fine';

  @override
  String get dreamHint =>
      'e.g. I was flying, I was underwater, I met a stranger…';

  @override
  String get fourPillarsBirthTimeLabel => 'Birth time (if known)';

  @override
  String get fourPillarsBirthTimeHint =>
      'e.g. 8:30 AM (leave blank if unknown)';

  @override
  String get resultAppBarTitle => 'Reading Result';

  @override
  String get resultAutoSaved => 'Automatically saved to your history';

  @override
  String get resultHitQuestion => '✨ Did this reading come true?';

  @override
  String get hitYes => 'It came true';

  @override
  String get hitUnknown => 'Not sure yet';

  @override
  String get hitNo => 'It didn\'t';

  @override
  String get resultActionsHeading => '✨ Suggested actions';

  @override
  String get resultActionsSubtitle =>
      'Check the actions you\'d like to try — they\'re saved automatically';

  @override
  String resultActionsCommitted(Object count) {
    return '$count in progress';
  }

  @override
  String get resultActionsAddedHeading => '🎯 Added to your action list';

  @override
  String get resultActionsAddedHint =>
      'Track your progress from History → Actions';

  @override
  String scorePoints(Object score) {
    return '$score pts';
  }

  @override
  String get compatibilityAppBarTitle => '💕 Compatibility Reading';

  @override
  String get compatibilityYou => 'You';

  @override
  String get compatibilityPartner => 'Partner';

  @override
  String get compatibilityPartnerNameHint =>
      'Partner\'s name (nickname is fine)';

  @override
  String get compatibilityEnterPartnerName =>
      'Please enter your partner\'s name';

  @override
  String get compatibilityStartButton => 'Check Compatibility 💕';

  @override
  String get compatibilityLoading => 'Analyzing your compatibility...';

  @override
  String get compatibilityError => 'The reading failed. Please try again.';

  @override
  String get compatibilityRetryButton => 'Try again';

  @override
  String compatibilityResultTitle(Object name) {
    return 'Compatibility with $name';
  }

  @override
  String get compatibilityLove => '💝 Love';

  @override
  String get compatibilityFriendship => '🤝 Friendship';

  @override
  String get compatibilityWork => '💼 Work';

  @override
  String get compatibilityAdvice => '💡 Advice';

  @override
  String get compatScoreBest => 'Best match ✨';

  @override
  String get compatScoreGreat => 'Great match 💕';

  @override
  String get compatScoreGood => 'Good match 😊';

  @override
  String get compatScoreAverage => 'Average match 🌱';

  @override
  String get compatScoreEffort => 'Needs work 💪';

  @override
  String get omikujiErrorFetch => 'Failed to draw your fortune';

  @override
  String get omikujiAppBarTitle => 'Omikuji';

  @override
  String get omikujiLoading => 'Drawing your fortune…';

  @override
  String get omikujiRetryButton => 'Draw again';

  @override
  String omikujiIntro(Object nickname) {
    return '$nickname, let\'s see\nwhat today has in store for you';
  }

  @override
  String get omikujiDrawButton => '🎋 Draw Your Fortune';

  @override
  String get fortuneTypeAppBarTitle => 'Choose a Reading';

  @override
  String get fortuneTypeFreeSection => '✨ Always Free';

  @override
  String get fortuneTypeLightSection => '🌙 Light and above';

  @override
  String get fortuneTypeProSection => '🏮 Pro only';

  @override
  String fortuneTypeRemaining(Object count) {
    return '$count left this month';
  }

  @override
  String fortuneTypeUpgradeDialogTitle(Object type, Object plan) {
    return '$type requires the $plan plan';
  }

  @override
  String fortuneTypeUpgradeDialogBody(Object price) {
    return 'For ¥$price/month, unlock this reading along with everything else.';
  }
}
