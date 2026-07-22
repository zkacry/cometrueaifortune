import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリの表示言語（UI + AI鑑定文の生成言語）を管理する。
/// Riverpod の ProviderScope が未導入のため、ValueNotifier + シングルトンで実装。
class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_locale_code';

  /// 対応言語一覧（表示順）
  static const supportedLocales = [
    Locale('ja'),
    Locale('en'),
    Locale('zh'),
    Locale('ko'),
  ];

  static const Map<String, String> displayNames = {
    'ja': '日本語',
    'en': 'English',
    'zh': '简体中文',
    'ko': '한국어',
  };

  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('ja'));

  /// 起動時に保存済み言語 or デバイス言語を読み込む
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && displayNames.containsKey(saved)) {
      locale.value = Locale(saved);
      return;
    }

    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final matched = supportedLocales.firstWhere(
      (l) => l.languageCode == deviceCode,
      orElse: () => const Locale('ja'),
    );
    locale.value = matched;
  }

  Future<void> setLocale(Locale newLocale) async {
    locale.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, newLocale.languageCode);
  }
}
