// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'MyFortune';

  @override
  String get navHome => '홈';

  @override
  String get navHistory => '기록';

  @override
  String get navSettings => '설정';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageDescription => '앱 표시 언어와 AI 운세 생성 언어를 선택하세요';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChineseSimplified => '简体中文';

  @override
  String get languageKorean => '한국어';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonSave => '저장';

  @override
  String get commonClose => '닫기';

  @override
  String get commonNext => '다음';

  @override
  String get commonBack => '뒤로';

  @override
  String get commonRetry => '다시 시도해 주세요';

  @override
  String get commonOk => 'OK';

  @override
  String get commonUpgrade => '업그레이드';

  @override
  String get rankDaikichi => '대길';

  @override
  String get rankKichi => '길';

  @override
  String get rankChukichi => '중길';

  @override
  String get rankShokichi => '소길';

  @override
  String get rankKyo => '흉';

  @override
  String get homeAppBarTitle => 'M Y F O R T U N E';

  @override
  String homeGreeting(Object nickname) {
    return '안녕하세요, $nickname님';
  }

  @override
  String homeMonthlyUsage(Object count, Object limit) {
    return '이번 달 전체 운세: $count / $limit회';
  }

  @override
  String get homeLimitBadge => '한도 초과';

  @override
  String get homeStartFullReading => '전체 운세 시작하기';

  @override
  String get homeLimitReached => '이번 달 이용 횟수를 모두 사용했습니다';

  @override
  String get homeStartSubtitle1 => '타로・수비학 중에서 선택할 수 있어요';

  @override
  String get homeStartSubtitle2 => 'Light 플랜으로 업그레이드하면 월 50회로 늘어나요';

  @override
  String get homeRecentConsultations => '최근 상담';

  @override
  String get homeLimitDialogTitle => '이번 달 운세 이용 횟수를 모두 사용했습니다 ✨';

  @override
  String homeLimitDialogBody(Object plan, Object limit) {
    return '$plan 플랜의 월 $limit회를 모두 사용했습니다.';
  }

  @override
  String get homePromoTitle => '💫 Light 플랜  월 680엔';

  @override
  String get homePromoSubtitle => '월 50회까지 무제한 운세\n과거 패턴 분석・기억형 AI';

  @override
  String get homeWaitNextMonth => '다음 달까지 기다리기';

  @override
  String get homeWebNotSupported => '웹 버전에서는 운세 API를 사용할 수 없습니다';

  @override
  String get homeFetchFailed => '운세를 가져오지 못했습니다';

  @override
  String get onboardingEnterNickname => '닉네임을 입력해 주세요';

  @override
  String get onboardingNotificationTitle => '운세를 확인할 시간이에요';

  @override
  String onboardingNotificationBody(Object nickname) {
    return '$nickname님, 오늘의 운세를 확인해 보세요 ✨';
  }

  @override
  String get onboardingGenericError => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get onboardingWelcomeTitle => '✨ MyFortune';

  @override
  String get onboardingHeading => '당신에 대해\n알려주세요';

  @override
  String get onboardingSubtitle => '30초 만에 오늘의 운세를 확인하세요';

  @override
  String get onboardingNicknameLabel => '닉네임';

  @override
  String get onboardingNicknameHint => '민준';

  @override
  String get onboardingBirthdateLabel => '생년월일';

  @override
  String get onboardingStartButton => '지금 바로 시작 ✨';

  @override
  String get worryPrompt => '지금 무엇이 궁금하신가요?';

  @override
  String get worryHint => '궁금한 점을 알려주세요…';

  @override
  String get worryEmptyError => '고민을 입력해 주세요';

  @override
  String get errorGenericReading => '감정 중 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorWebNotSupported => '안드로이드 앱을 이용해 주세요';

  @override
  String get errorApiAuth => 'API 인증에 실패했습니다. 설정을 확인해 주세요.';

  @override
  String get errorTimeout => '연결 시간이 초과되었습니다. 네트워크를 확인해 주세요.';

  @override
  String get errorNoInternet => '인터넷 연결을 확인해 주세요.';

  @override
  String get worryCategoryLove => '💕 연애・파트너';

  @override
  String get worryCategoryWork => '💼 일・커리어';

  @override
  String get worryCategoryRelationship => '👥 인간관계';

  @override
  String get worryCategoryMoney => '💰 돈・미래';

  @override
  String get worryCategoryFamily => '🏠 가족';

  @override
  String get worryCategoryHealth => '🌿 건강・멘탈';

  @override
  String get worryCategoryPath => '🌟 진로・전환기';

  @override
  String get worryCategoryOther => '✏️ 기타';

  @override
  String get tarotAppBarTitle => '타로 점';

  @override
  String get tarotSubtitle => '주제를 선택하고 카드를 뽑아주세요.';

  @override
  String get tarotDrawButton => '카드 뽑기 🃏';

  @override
  String get tarotCardsRevealed => '카드 3장이 나왔습니다';

  @override
  String get tarotReversed => '역위치';

  @override
  String get tarotUpright => '정위치';

  @override
  String get tarotReadingButton => '감정 받기 ✨';

  @override
  String get tarotLoading => '카드가 말을 걸고 있어요…';

  @override
  String get positionPast => '과거';

  @override
  String get positionPresent => '현재';

  @override
  String get positionFuture => '미래';

  @override
  String get numerologyAppBarTitle => '수비학 점';

  @override
  String get numerologyLoading => '숫자가 말을 걸고 있어요…';

  @override
  String get numerologyLifePath => '라이프패스 넘버';

  @override
  String get numerologySubtitle => '주제를 선택하고 숫자에게 물어보세요.';

  @override
  String get numerologyButton => '숫자에게 묻기 🔢';

  @override
  String get simpleAutoProfileReading => '(프로필 정보로 감정)';

  @override
  String simpleLoadingFormat(Object type) {
    return '$type(으)로 감정 중…';
  }

  @override
  String simpleReadingButton(Object emoji) {
    return '$emoji 감정하기';
  }

  @override
  String get bloodTypeQuestion => '당신의 혈액형은?';

  @override
  String get dreamQuestion => '어떤 꿈을 꾸셨나요?';

  @override
  String get dreamSubtitle => '키워드나 자세한 내용 모두 괜찮아요';

  @override
  String get dreamHint => '예: 하늘을 날고 있었다, 물속에 있었다, 낯선 사람을 만났다…';

  @override
  String get fourPillarsBirthTimeLabel => '출생 시각（아시면）';

  @override
  String get fourPillarsBirthTimeHint => '예: 오전 8시 30분（모르면 비워두세요）';

  @override
  String get resultAppBarTitle => '감정 결과';

  @override
  String get resultAutoSaved => '기록에 자동 저장됨';

  @override
  String get resultHitQuestion => '✨ 이 점이 맞았나요?';

  @override
  String get hitYes => '맞았어요';

  @override
  String get hitUnknown => '아직 몰라요';

  @override
  String get hitNo => '틀렸어요';

  @override
  String get resultActionsHeading => '✨ 추천 행동';

  @override
  String get resultActionsSubtitle => '도전하고 싶은 행동에 체크하면 자동으로 기록됩니다';

  @override
  String resultActionsCommitted(Object count) {
    return '$count건 진행 중';
  }

  @override
  String get resultActionsAddedHeading => '🎯 행동 목록에 추가되었습니다';

  @override
  String get resultActionsAddedHint => '기록 탭 → 행동 에서 진행 상황을 관리할 수 있어요';

  @override
  String scorePoints(Object score) {
    return '$score점';
  }

  @override
  String get compatibilityAppBarTitle => '💕 궁합 점';

  @override
  String get compatibilityYou => '나';

  @override
  String get compatibilityPartner => '상대방';

  @override
  String get compatibilityPartnerNameHint => '상대방 이름（닉네임 가능）';

  @override
  String get compatibilityEnterPartnerName => '상대방의 이름을 입력해 주세요';

  @override
  String get compatibilityStartButton => '궁합 보기 💕';

  @override
  String get compatibilityLoading => '두 사람의 궁합을 분석 중...';

  @override
  String get compatibilityError => '점괘를 가져오지 못했습니다. 다시 시도해 주세요.';

  @override
  String get compatibilityRetryButton => '다시 보기';

  @override
  String compatibilityResultTitle(Object name) {
    return '$name님과의 궁합';
  }

  @override
  String get compatibilityLove => '💝 연애 궁합';

  @override
  String get compatibilityFriendship => '🤝 우정 궁합';

  @override
  String get compatibilityWork => '💼 업무 궁합';

  @override
  String get compatibilityAdvice => '💡 조언';

  @override
  String get compatScoreBest => '최고의 궁합 ✨';

  @override
  String get compatScoreGreat => '훌륭한 궁합 💕';

  @override
  String get compatScoreGood => '좋은 궁합 😊';

  @override
  String get compatScoreAverage => '보통의 궁합 🌱';

  @override
  String get compatScoreEffort => '노력이 필요해요 💪';

  @override
  String get omikujiErrorFetch => '운세를 가져오지 못했습니다';

  @override
  String get omikujiAppBarTitle => '오미쿠지';

  @override
  String get omikujiLoading => '운세를 뽑고 있어요…';

  @override
  String get omikujiRetryButton => '다시 뽑기';

  @override
  String omikujiIntro(Object nickname) {
    return '$nickname님,\n오늘의 운세를 뽑아볼까요';
  }

  @override
  String get omikujiDrawButton => '🎋 운세 뽑기';

  @override
  String get fortuneTypeAppBarTitle => '점술 선택';

  @override
  String get fortuneTypeFreeSection => '✨ 언제나 무료';

  @override
  String get fortuneTypeLightSection => '🌙 Light 이상';

  @override
  String get fortuneTypeProSection => '🏮 Pro 전용';

  @override
  String fortuneTypeRemaining(Object count) {
    return '이번 달 남은 횟수 $count회';
  }

  @override
  String fortuneTypeUpgradeDialogTitle(Object type, Object plan) {
    return '$type은(는) $plan 플랜부터';
  }

  @override
  String fortuneTypeUpgradeDialogBody(Object price) {
    return '월 $price엔으로 이 점술을 포함한 모든 기능이 열립니다.';
  }
}
