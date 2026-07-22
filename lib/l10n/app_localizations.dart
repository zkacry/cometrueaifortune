import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'マイフォーチューン'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In ja, this message translates to:
  /// **'記録'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get navSettings;

  /// No description provided for @settingsLanguage.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDescription.
  ///
  /// In ja, this message translates to:
  /// **'アプリの表示言語とAI鑑定文の生成言語を選択します'**
  String get settingsLanguageDescription;

  /// No description provided for @languageJapanese.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In ja, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In ja, this message translates to:
  /// **'简体中文'**
  String get languageChineseSimplified;

  /// No description provided for @languageKorean.
  ///
  /// In ja, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @commonCancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ja, this message translates to:
  /// **'決定'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get commonClose;

  /// No description provided for @commonNext.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In ja, this message translates to:
  /// **'もう一度お試しください'**
  String get commonRetry;

  /// No description provided for @commonOk.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonUpgrade.
  ///
  /// In ja, this message translates to:
  /// **'アップグレード'**
  String get commonUpgrade;

  /// No description provided for @rankDaikichi.
  ///
  /// In ja, this message translates to:
  /// **'大吉'**
  String get rankDaikichi;

  /// No description provided for @rankKichi.
  ///
  /// In ja, this message translates to:
  /// **'吉'**
  String get rankKichi;

  /// No description provided for @rankChukichi.
  ///
  /// In ja, this message translates to:
  /// **'中吉'**
  String get rankChukichi;

  /// No description provided for @rankShokichi.
  ///
  /// In ja, this message translates to:
  /// **'小吉'**
  String get rankShokichi;

  /// No description provided for @rankKyo.
  ///
  /// In ja, this message translates to:
  /// **'凶'**
  String get rankKyo;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'M Y F O R T U N E'**
  String get homeAppBarTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In ja, this message translates to:
  /// **'こんにちは、{nickname}さん'**
  String homeGreeting(Object nickname);

  /// No description provided for @homeMonthlyUsage.
  ///
  /// In ja, this message translates to:
  /// **'今月のフル占い：{count} / {limit}回'**
  String homeMonthlyUsage(Object count, Object limit);

  /// No description provided for @homeLimitBadge.
  ///
  /// In ja, this message translates to:
  /// **'上限'**
  String get homeLimitBadge;

  /// No description provided for @homeStartFullReading.
  ///
  /// In ja, this message translates to:
  /// **'フル占いを始める'**
  String get homeStartFullReading;

  /// No description provided for @homeLimitReached.
  ///
  /// In ja, this message translates to:
  /// **'今月の回数上限に達しました'**
  String get homeLimitReached;

  /// No description provided for @homeStartSubtitle1.
  ///
  /// In ja, this message translates to:
  /// **'タロット・数秘術から選べます'**
  String get homeStartSubtitle1;

  /// No description provided for @homeStartSubtitle2.
  ///
  /// In ja, this message translates to:
  /// **'Lightプランで月50回に増やせます'**
  String get homeStartSubtitle2;

  /// No description provided for @homeRecentConsultations.
  ///
  /// In ja, this message translates to:
  /// **'最近の相談'**
  String get homeRecentConsultations;

  /// No description provided for @homeLimitDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'今月の占い回数を使い切りました ✨'**
  String get homeLimitDialogTitle;

  /// No description provided for @homeLimitDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'{plan}プランの月{limit}回をすべて使い切りました。'**
  String homeLimitDialogBody(Object plan, Object limit);

  /// No description provided for @homePromoTitle.
  ///
  /// In ja, this message translates to:
  /// **'💫 Light プラン  月680円'**
  String get homePromoTitle;

  /// No description provided for @homePromoSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'月50回まで占い放題\n過去パターン分析・記憶型AI'**
  String get homePromoSubtitle;

  /// No description provided for @homeWaitNextMonth.
  ///
  /// In ja, this message translates to:
  /// **'来月まで待つ'**
  String get homeWaitNextMonth;

  /// No description provided for @homeWebNotSupported.
  ///
  /// In ja, this message translates to:
  /// **'Web版では占いAPIは利用できません'**
  String get homeWebNotSupported;

  /// No description provided for @homeFetchFailed.
  ///
  /// In ja, this message translates to:
  /// **'運勢の取得に失敗しました'**
  String get homeFetchFailed;

  /// No description provided for @onboardingEnterNickname.
  ///
  /// In ja, this message translates to:
  /// **'ニックネームを入力してください'**
  String get onboardingEnterNickname;

  /// No description provided for @onboardingNotificationTitle.
  ///
  /// In ja, this message translates to:
  /// **'運勢のお時間です'**
  String get onboardingNotificationTitle;

  /// No description provided for @onboardingNotificationBody.
  ///
  /// In ja, this message translates to:
  /// **'{nickname}さん、今日の運勢をチェックしましょう ✨'**
  String onboardingNotificationBody(Object nickname);

  /// No description provided for @onboardingGenericError.
  ///
  /// In ja, this message translates to:
  /// **'エラーが発生しました。もう一度お試しください。'**
  String get onboardingGenericError;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In ja, this message translates to:
  /// **'✨ マイフォーチューン'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingHeading.
  ///
  /// In ja, this message translates to:
  /// **'あなたのことを\n教えてください'**
  String get onboardingHeading;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'30秒で今日の運勢がわかります'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingNicknameLabel.
  ///
  /// In ja, this message translates to:
  /// **'ニックネーム'**
  String get onboardingNicknameLabel;

  /// No description provided for @onboardingNicknameHint.
  ///
  /// In ja, this message translates to:
  /// **'あいこ'**
  String get onboardingNicknameHint;

  /// No description provided for @onboardingBirthdateLabel.
  ///
  /// In ja, this message translates to:
  /// **'生年月日'**
  String get onboardingBirthdateLabel;

  /// No description provided for @onboardingStartButton.
  ///
  /// In ja, this message translates to:
  /// **'今すぐ占う ✨'**
  String get onboardingStartButton;

  /// No description provided for @worryPrompt.
  ///
  /// In ja, this message translates to:
  /// **'今、何が気になっていますか？'**
  String get worryPrompt;

  /// No description provided for @worryHint.
  ///
  /// In ja, this message translates to:
  /// **'気になっていることを教えてください…'**
  String get worryHint;

  /// No description provided for @worryEmptyError.
  ///
  /// In ja, this message translates to:
  /// **'悩みを入力してください'**
  String get worryEmptyError;

  /// No description provided for @errorGenericReading.
  ///
  /// In ja, this message translates to:
  /// **'鑑定中にエラーが発生しました。もう一度お試しください。'**
  String get errorGenericReading;

  /// No description provided for @errorWebNotSupported.
  ///
  /// In ja, this message translates to:
  /// **'Androidアプリをご使用ください'**
  String get errorWebNotSupported;

  /// No description provided for @errorApiAuth.
  ///
  /// In ja, this message translates to:
  /// **'APIの認証に失敗しました。設定を確認してください。'**
  String get errorApiAuth;

  /// No description provided for @errorTimeout.
  ///
  /// In ja, this message translates to:
  /// **'接続がタイムアウトしました。ネットワークを確認してください。'**
  String get errorTimeout;

  /// No description provided for @errorNoInternet.
  ///
  /// In ja, this message translates to:
  /// **'インターネット接続を確認してください。'**
  String get errorNoInternet;

  /// No description provided for @worryCategoryLove.
  ///
  /// In ja, this message translates to:
  /// **'💕 恋愛・パートナー'**
  String get worryCategoryLove;

  /// No description provided for @worryCategoryWork.
  ///
  /// In ja, this message translates to:
  /// **'💼 仕事・キャリア'**
  String get worryCategoryWork;

  /// No description provided for @worryCategoryRelationship.
  ///
  /// In ja, this message translates to:
  /// **'👥 人間関係'**
  String get worryCategoryRelationship;

  /// No description provided for @worryCategoryMoney.
  ///
  /// In ja, this message translates to:
  /// **'💰 お金・将来'**
  String get worryCategoryMoney;

  /// No description provided for @worryCategoryFamily.
  ///
  /// In ja, this message translates to:
  /// **'🏠 家族'**
  String get worryCategoryFamily;

  /// No description provided for @worryCategoryHealth.
  ///
  /// In ja, this message translates to:
  /// **'🌿 健康・メンタル'**
  String get worryCategoryHealth;

  /// No description provided for @worryCategoryPath.
  ///
  /// In ja, this message translates to:
  /// **'🌟 進路・転換期'**
  String get worryCategoryPath;

  /// No description provided for @worryCategoryOther.
  ///
  /// In ja, this message translates to:
  /// **'✏️ その他'**
  String get worryCategoryOther;

  /// No description provided for @tarotAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'タロット占い'**
  String get tarotAppBarTitle;

  /// No description provided for @tarotSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'テーマを選んでカードを引いてください。'**
  String get tarotSubtitle;

  /// No description provided for @tarotDrawButton.
  ///
  /// In ja, this message translates to:
  /// **'カードを引く 🃏'**
  String get tarotDrawButton;

  /// No description provided for @tarotCardsRevealed.
  ///
  /// In ja, this message translates to:
  /// **'3枚のカードが出ました'**
  String get tarotCardsRevealed;

  /// No description provided for @tarotReversed.
  ///
  /// In ja, this message translates to:
  /// **'逆位置'**
  String get tarotReversed;

  /// No description provided for @tarotUpright.
  ///
  /// In ja, this message translates to:
  /// **'正位置'**
  String get tarotUpright;

  /// No description provided for @tarotReadingButton.
  ///
  /// In ja, this message translates to:
  /// **'鑑定してもらう ✨'**
  String get tarotReadingButton;

  /// No description provided for @tarotLoading.
  ///
  /// In ja, this message translates to:
  /// **'カードが語りかけています…'**
  String get tarotLoading;

  /// No description provided for @positionPast.
  ///
  /// In ja, this message translates to:
  /// **'過去'**
  String get positionPast;

  /// No description provided for @positionPresent.
  ///
  /// In ja, this message translates to:
  /// **'現在'**
  String get positionPresent;

  /// No description provided for @positionFuture.
  ///
  /// In ja, this message translates to:
  /// **'未来'**
  String get positionFuture;

  /// No description provided for @numerologyAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'数秘術占い'**
  String get numerologyAppBarTitle;

  /// No description provided for @numerologyLoading.
  ///
  /// In ja, this message translates to:
  /// **'数字が語りかけています…'**
  String get numerologyLoading;

  /// No description provided for @numerologyLifePath.
  ///
  /// In ja, this message translates to:
  /// **'ライフパス'**
  String get numerologyLifePath;

  /// No description provided for @numerologySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'テーマを選んで数字に聞いてみましょう。'**
  String get numerologySubtitle;

  /// No description provided for @numerologyButton.
  ///
  /// In ja, this message translates to:
  /// **'数字に聞く 🔢'**
  String get numerologyButton;

  /// No description provided for @simpleAutoProfileReading.
  ///
  /// In ja, this message translates to:
  /// **'（プロフィール情報から鑑定）'**
  String get simpleAutoProfileReading;

  /// No description provided for @simpleLoadingFormat.
  ///
  /// In ja, this message translates to:
  /// **'{type}で鑑定中…'**
  String simpleLoadingFormat(Object type);

  /// No description provided for @simpleReadingButton.
  ///
  /// In ja, this message translates to:
  /// **'{emoji} 鑑定する'**
  String simpleReadingButton(Object emoji);

  /// No description provided for @bloodTypeQuestion.
  ///
  /// In ja, this message translates to:
  /// **'あなたの血液型は？'**
  String get bloodTypeQuestion;

  /// No description provided for @dreamQuestion.
  ///
  /// In ja, this message translates to:
  /// **'どんな夢を見ましたか？'**
  String get dreamQuestion;

  /// No description provided for @dreamSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'キーワードでも、詳細でも構いません'**
  String get dreamSubtitle;

  /// No description provided for @dreamHint.
  ///
  /// In ja, this message translates to:
  /// **'例：空を飛んでいた、水の中にいた、知らない人に会った…'**
  String get dreamHint;

  /// No description provided for @fourPillarsBirthTimeLabel.
  ///
  /// In ja, this message translates to:
  /// **'出生時刻（わかれば）'**
  String get fourPillarsBirthTimeLabel;

  /// No description provided for @fourPillarsBirthTimeHint.
  ///
  /// In ja, this message translates to:
  /// **'例：午前8時30分（不明の場合は空欄でOK）'**
  String get fourPillarsBirthTimeHint;

  /// No description provided for @resultAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'鑑定結果'**
  String get resultAppBarTitle;

  /// No description provided for @resultAutoSaved.
  ///
  /// In ja, this message translates to:
  /// **'記録に自動保存済み'**
  String get resultAutoSaved;

  /// No description provided for @resultHitQuestion.
  ///
  /// In ja, this message translates to:
  /// **'✨ この占い、当たりましたか？'**
  String get resultHitQuestion;

  /// No description provided for @hitYes.
  ///
  /// In ja, this message translates to:
  /// **'当たった'**
  String get hitYes;

  /// No description provided for @hitUnknown.
  ///
  /// In ja, this message translates to:
  /// **'わからない'**
  String get hitUnknown;

  /// No description provided for @hitNo.
  ///
  /// In ja, this message translates to:
  /// **'外れた'**
  String get hitNo;

  /// No description provided for @resultActionsHeading.
  ///
  /// In ja, this message translates to:
  /// **'✨ 今後のアクション候補'**
  String get resultActionsHeading;

  /// No description provided for @resultActionsSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'取り組みたいアクションにチェックを入れると自動記録されます'**
  String get resultActionsSubtitle;

  /// No description provided for @resultActionsCommitted.
  ///
  /// In ja, this message translates to:
  /// **'{count}件取り組む'**
  String resultActionsCommitted(Object count);

  /// No description provided for @resultActionsAddedHeading.
  ///
  /// In ja, this message translates to:
  /// **'🎯 アクションリストに追加しました'**
  String get resultActionsAddedHeading;

  /// No description provided for @resultActionsAddedHint.
  ///
  /// In ja, this message translates to:
  /// **'記録タブ → アクション で進捗を管理できます'**
  String get resultActionsAddedHint;

  /// No description provided for @scorePoints.
  ///
  /// In ja, this message translates to:
  /// **'{score}点'**
  String scorePoints(Object score);

  /// No description provided for @compatibilityAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'💕 相性占い'**
  String get compatibilityAppBarTitle;

  /// No description provided for @compatibilityYou.
  ///
  /// In ja, this message translates to:
  /// **'あなた'**
  String get compatibilityYou;

  /// No description provided for @compatibilityPartner.
  ///
  /// In ja, this message translates to:
  /// **'相手'**
  String get compatibilityPartner;

  /// No description provided for @compatibilityPartnerNameHint.
  ///
  /// In ja, this message translates to:
  /// **'相手の名前（ニックネーム可）'**
  String get compatibilityPartnerNameHint;

  /// No description provided for @compatibilityEnterPartnerName.
  ///
  /// In ja, this message translates to:
  /// **'相手の名前を入力してください'**
  String get compatibilityEnterPartnerName;

  /// No description provided for @compatibilityStartButton.
  ///
  /// In ja, this message translates to:
  /// **'相性を占う 💕'**
  String get compatibilityStartButton;

  /// No description provided for @compatibilityLoading.
  ///
  /// In ja, this message translates to:
  /// **'二人の相性を分析中...'**
  String get compatibilityLoading;

  /// No description provided for @compatibilityError.
  ///
  /// In ja, this message translates to:
  /// **'占いに失敗しました。もう一度お試しください。'**
  String get compatibilityError;

  /// No description provided for @compatibilityRetryButton.
  ///
  /// In ja, this message translates to:
  /// **'もう一度占う'**
  String get compatibilityRetryButton;

  /// No description provided for @compatibilityResultTitle.
  ///
  /// In ja, this message translates to:
  /// **'{name}さんとの相性'**
  String compatibilityResultTitle(Object name);

  /// No description provided for @compatibilityLove.
  ///
  /// In ja, this message translates to:
  /// **'💝 恋愛相性'**
  String get compatibilityLove;

  /// No description provided for @compatibilityFriendship.
  ///
  /// In ja, this message translates to:
  /// **'🤝 友情相性'**
  String get compatibilityFriendship;

  /// No description provided for @compatibilityWork.
  ///
  /// In ja, this message translates to:
  /// **'💼 仕事相性'**
  String get compatibilityWork;

  /// No description provided for @compatibilityAdvice.
  ///
  /// In ja, this message translates to:
  /// **'💡 アドバイス'**
  String get compatibilityAdvice;

  /// No description provided for @compatScoreBest.
  ///
  /// In ja, this message translates to:
  /// **'最高の相性 ✨'**
  String get compatScoreBest;

  /// No description provided for @compatScoreGreat.
  ///
  /// In ja, this message translates to:
  /// **'相性抜群 💕'**
  String get compatScoreGreat;

  /// No description provided for @compatScoreGood.
  ///
  /// In ja, this message translates to:
  /// **'良い相性 😊'**
  String get compatScoreGood;

  /// No description provided for @compatScoreAverage.
  ///
  /// In ja, this message translates to:
  /// **'普通の相性 🌱'**
  String get compatScoreAverage;

  /// No description provided for @compatScoreEffort.
  ///
  /// In ja, this message translates to:
  /// **'要努力 💪'**
  String get compatScoreEffort;

  /// No description provided for @omikujiErrorFetch.
  ///
  /// In ja, this message translates to:
  /// **'おみくじの取得に失敗しました'**
  String get omikujiErrorFetch;

  /// No description provided for @omikujiAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'おみくじ'**
  String get omikujiAppBarTitle;

  /// No description provided for @omikujiLoading.
  ///
  /// In ja, this message translates to:
  /// **'おみくじを引いています…'**
  String get omikujiLoading;

  /// No description provided for @omikujiRetryButton.
  ///
  /// In ja, this message translates to:
  /// **'もう一度引く'**
  String get omikujiRetryButton;

  /// No description provided for @omikujiIntro.
  ///
  /// In ja, this message translates to:
  /// **'{nickname}さん、\n今日の運勢を引いてみましょう'**
  String omikujiIntro(Object nickname);

  /// No description provided for @omikujiDrawButton.
  ///
  /// In ja, this message translates to:
  /// **'🎋 おみくじを引く'**
  String get omikujiDrawButton;

  /// No description provided for @fortuneTypeAppBarTitle.
  ///
  /// In ja, this message translates to:
  /// **'占術を選ぶ'**
  String get fortuneTypeAppBarTitle;

  /// No description provided for @fortuneTypeFreeSection.
  ///
  /// In ja, this message translates to:
  /// **'✨ いつでも無料'**
  String get fortuneTypeFreeSection;

  /// No description provided for @fortuneTypeLightSection.
  ///
  /// In ja, this message translates to:
  /// **'🌙 Light以上'**
  String get fortuneTypeLightSection;

  /// No description provided for @fortuneTypeProSection.
  ///
  /// In ja, this message translates to:
  /// **'🏮 Pro限定'**
  String get fortuneTypeProSection;

  /// No description provided for @fortuneTypeRemaining.
  ///
  /// In ja, this message translates to:
  /// **'今月残り{count}回'**
  String fortuneTypeRemaining(Object count);

  /// No description provided for @fortuneTypeUpgradeDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'{type}は{plan}プランから'**
  String fortuneTypeUpgradeDialogTitle(Object type, Object plan);

  /// No description provided for @fortuneTypeUpgradeDialogBody.
  ///
  /// In ja, this message translates to:
  /// **'月{price}円でこの占術を含む全機能が解放されます。'**
  String fortuneTypeUpgradeDialogBody(Object price);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
