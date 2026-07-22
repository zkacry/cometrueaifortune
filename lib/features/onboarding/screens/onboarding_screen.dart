import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfortune/core/constants/tarot_data.dart';
import 'package:myfortune/core/locale/locale_controller.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/user_repository.dart';
import 'package:myfortune/data/services/notification_service.dart';
import 'package:myfortune/features/home/screens/home_screen.dart';
import 'package:myfortune/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 最小限オンボーディング：名前 + 生年月日だけで30秒以内に完了
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime(1995, 1, 1);
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: LocaleController.instance.locale.value,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.card,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _start() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.onboardingEnterNickname)),
      );
      return;
    }

    setState(() => _loading = true);
    final t = AppLocalizations.of(context)!;

    try {
      final repo = UserRepository();
      final user = await repo.signInAnonymously();

      final profile = UserProfile(
        uid: user.uid,
        nickname: name,
        birthdate: _selectedDate,
      );

      await repo.saveProfile(profile);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);

      // 通知権限をリクエストして初回スケジュールを設定
      await NotificationService.requestPermissions();
      await NotificationService.scheduleDailyNotification(
        hour: profile.notificationHour, // デフォルト 9時
        title: t.onboardingNotificationTitle,
        body: t.onboardingNotificationBody(profile.nickname),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(profile: profile)),
        );
      }
    } catch (e) {
      debugPrint('Onboarding error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.onboardingGenericError)),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final zodiac = getZodiacSign(_selectedDate);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                t.onboardingWelcomeTitle,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                t.onboardingHeading,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.onboardingSubtitle,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 40),

              // ニックネーム
              Text(
                t.onboardingNicknameLabel,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18),
                decoration: InputDecoration(
                  hintText: t.onboardingNicknameHint,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),

              const SizedBox(height: 24),

              // 生年月日
              Text(
                t.onboardingBirthdateLabel,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat.yMMMMd(
                                LocaleController.instance.locale.value.languageCode)
                            .format(_selectedDate),
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 18),
                      ),
                      const Spacer(),
                      Text(
                        zodiac,
                        style: const TextStyle(
                            color: AppTheme.accent, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // 開始ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _start,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.accent,
                    disabledBackgroundColor:
                        AppTheme.accent.withValues(alpha: 0.5),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          t.onboardingStartButton,
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 2,
                              color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
