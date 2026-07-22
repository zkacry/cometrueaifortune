import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myfortune/core/locale/locale_controller.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/l10n/app_localizations.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/user_repository.dart';
import 'package:myfortune/data/services/notification_service.dart';
import 'package:myfortune/data/services/purchase_service.dart';
import 'package:myfortune/features/home/screens/home_screen.dart';
import 'package:myfortune/features/onboarding/screens/onboarding_screen.dart';
import 'package:myfortune/features/splash/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

/// 通知タップ時のルーティング用グローバルキー
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load error: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  try {
    await LocaleController.instance.load();
  } catch (e) {
    debugPrint('LocaleController load error: $e');
  }

  try {
    await NotificationService.initialize(
      onNotificationTap: _onNotificationTap,
    );
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  // TODO: テスト環境ではAdMob初期化をスキップ
  // try {
  //   await MobileAds.instance.initialize();
  // } catch (e) {
  //   debugPrint('MobileAds init error: $e');
  // }

  runApp(const MyFortuneApp());

  // バックグラウンドで追加初期化を実行（ANR回避）
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _postFrameInitialization();
  });
}

Future<void> _postFrameInitialization() async {
  try {
    // PurchaseService は遅延初期化する
    // (ユーザープロフィール読み込み後に _StartupRouter で初期化)
  } catch (e) {
    debugPrint('Post-frame initialization error: $e');
  }
}

/// 通知タップ時の処理：ホーム画面（設定タブ0）に遷移
void _onNotificationTap(NotificationResponse response) {
  debugPrint('Notification tapped: ${response.payload}');
  // アプリがバックグラウンドにある場合でも画面を最前面に出す
  navigatorKey.currentState?.popUntil((route) => route.isFirst);
}

class MyFortuneApp extends StatelessWidget {
  const MyFortuneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'マイフォーチューン',
          theme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const _StartupRouter(),
        );
      },
    );
  }
}

class _StartupRouter extends StatefulWidget {
  const _StartupRouter();

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  late final Future<Widget> _future = _resolve();

  Future<Widget> _resolve() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('onboarding_complete') ?? false;
      if (!done) return const OnboardingScreen();

      final repo = UserRepository();
      if (!repo.isSignedIn) return const OnboardingScreen();

      // タイムアウト付きで Firestore からプロファイル取得（ANR対策）
      UserProfile? profile;
      try {
        profile = await repo.getProfile(repo.currentUid!).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Profile fetch timeout');
            return null;
          },
        );
      } catch (e) {
        debugPrint('Profile fetch error: $e');
      }

      if (profile == null) return const OnboardingScreen();

      // 課金リスナーを初期化
      PurchaseService.initialize(
        uid: profile.uid,
        onPlanUpdated: (plan) {
          debugPrint('Plan updated via purchase: ${plan.name}');
        },
      );

      // 通知を再スケジュール（エラーは無視）
      try {
        if (profile.notificationEnabled) {
          await NotificationService.scheduleDailyNotification(
            hour: profile.notificationHour,
            title: '運勢のお時間です',
            body: 'あなたの今日の運勢をチェックしましょう',
          ).timeout(const Duration(seconds: 5));
        } else {
          await NotificationService.cancelDailyNotification();
        }
      } catch (e) {
        debugPrint('Notification reschedule error: $e');
      }

      // 月が変わっていたらカウントリセット
      final now = DateTime.now();
      final currentMonthKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      if (profile.monthKey != currentMonthKey) {
        try {
          await repo.resetMonthlyCount(profile.uid, currentMonthKey).timeout(
            const Duration(seconds: 5),
            onTimeout: () => null,
          );
        } catch (e) {
          debugPrint('Reset monthly count error: $e');
        }
        return HomeScreen(
          profile: profile.copyWith(
            monthlyReadingCount: 0,
            monthKey: currentMonthKey,
          ),
        );
      }

      return HomeScreen(profile: profile);
    } catch (e, st) {
      debugPrint('_resolve error: $e\n$st');
      return const OnboardingScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const OnboardingScreen();
        }
        if (!snapshot.hasData) {
          return const SplashScreen();
        }
        return snapshot.data!;
      },
    );
  }
}
