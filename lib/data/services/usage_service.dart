import 'package:shared_preferences/shared_preferences.dart';

/// 月次利用回数をローカルで管理（Firestoreと二重管理）
class UsageService {
  static const _countKey = 'monthly_reading_count';
  static const _monthKey = 'reading_month_key';

  static String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  static Future<int> getCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMonth = prefs.getString(_monthKey) ?? '';
    final currentMonth = _currentMonthKey();

    // 月が変わったらリセット
    if (savedMonth != currentMonth) {
      await prefs.setInt(_countKey, 0);
      await prefs.setString(_monthKey, currentMonth);
      return 0;
    }
    return prefs.getInt(_countKey) ?? 0;
  }

  static Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCount();
    await prefs.setInt(_countKey, current + 1);
    await prefs.setString(_monthKey, _currentMonthKey());
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, 0);
    await prefs.setString(_monthKey, _currentMonthKey());
  }
}
