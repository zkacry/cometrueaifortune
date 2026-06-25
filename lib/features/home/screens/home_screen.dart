import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/consultation_repository.dart';
import 'package:myfortune/data/repositories/user_repository.dart';
import 'package:myfortune/data/services/claude_service.dart';
import 'package:myfortune/features/fortune/screens/fortune_type_screen.dart';
import 'package:myfortune/features/history/screens/history_screen.dart';
import 'package:myfortune/features/home/widgets/daily_fortune_card.dart';
import 'package:myfortune/features/settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile profile;
  const HomeScreen({super.key, required this.profile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserProfile _profile;
  int _selectedIndex = 0;
  DailyFortuneResult? _dailyFortune;
  bool _loadingFortune = true;
  String? _fortuneError;
  List<Consultation> _recent = [];

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _loadData();
  }

  Future<void> _loadData() async {
    // プロフィール再取得（月次カウントを最新化）
    try {
      final updated = await UserRepository().getProfile(_profile.uid);
      if (updated != null && mounted) setState(() => _profile = updated);
    } catch (e) {
      debugPrint('profile reload error: $e');
    }

    // 最近の相談を取得
    try {
      final recent = await ConsultationRepository().getRecent(_profile.uid);
      if (mounted) setState(() => _recent = recent);
    } catch (e) {
      debugPrint('getRecent error: $e');
    }

    // 今日の運勢を取得（Webは非対応）
    if (kIsWeb) {
      setState(() {
        _fortuneError = 'Web版では占いAPIは利用できません';
        _loadingFortune = false;
      });
      return;
    }

    try {
      final fortune = await ClaudeService().generateDailyFortune(
        profile: _profile,
      );
      if (mounted) {
        setState(() {
          _dailyFortune = fortune;
          _loadingFortune = false;
        });
      }
    } catch (e) {
      debugPrint('DailyFortune error: $e');
      if (mounted) {
        setState(() {
          _fortuneError = '運勢の取得に失敗しました\n${e.toString().replaceAll('Exception: ', '')}';
          _loadingFortune = false;
        });
      }
    }
  }

  void _goToFortune() async {
    if (!_profile.canUseReading) {
      _showUpgradeDialog();
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FortuneTypeScreen(
          profile: _profile,
          recentConsultations: _recent,
        ),
      ),
    );
    if (result == true && mounted) {
      // 即座にカウントを+1して表示（Firestore同期は非同期で行う）
      final newCount = _profile.monthlyReadingCount + 1;
      final updated = _profile.copyWith(monthlyReadingCount: newCount);
      setState(() => _profile = updated);
      // 上限に達したら有料プランを案内
      if (!updated.canUseReading) {
        _showUpgradeDialog();
      }
      // バックグラウンドでFirestoreから正確な値を再取得
      _loadData();
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('今月の占い回数を使い切りました ✨',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_profile.plan.displayName}プランの月${_profile.plan.monthlyReadingLimit}回をすべて使い切りました。',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💫 Light プラン  月680円',
                      style: TextStyle(color: AppTheme.accent, fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('月50回まで占い放題\n過去パターン分析・記憶型AI',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('来月まで待つ', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: アップグレード画面へ遷移
            },
            child: const Text('アップグレード'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M Y F O R T U N E'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _profile.plan == UserPlan.pro
                      ? AppTheme.proPlan.withValues(alpha: 0.2)
                      : _profile.plan == UserPlan.light
                          ? AppTheme.lightPlan.withValues(alpha: 0.2)
                          : AppTheme.freePlan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _profile.plan == UserPlan.pro
                        ? AppTheme.proPlan
                        : _profile.plan == UserPlan.light
                            ? AppTheme.lightPlan
                            : AppTheme.freePlan,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _profile.plan.displayName,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(
            profile: _profile,
            dailyFortune: _dailyFortune,
            loadingFortune: _loadingFortune,
            fortuneError: _fortuneError,
            recentConsultations: _recent,
            onStartFortune: _goToFortune,
          ),
          HistoryScreen(uid: _profile.uid),
          SettingsScreen(profile: _profile),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: [
          NavigationDestination(
            icon: _NavIcon(asset: 'assets/icons/icon_home.jpg', selected: false),
            selectedIcon: _NavIcon(asset: 'assets/icons/icon_home.jpg', selected: true),
            label: 'ホーム',
          ),
          NavigationDestination(
            icon: _NavIcon(asset: 'assets/icons/icon_record.jpg', selected: false),
            selectedIcon: _NavIcon(asset: 'assets/icons/icon_record.jpg', selected: true),
            label: '記録',
          ),
          NavigationDestination(
            icon: _NavIcon(asset: 'assets/icons/icon_settings.jpg', selected: false),
            selectedIcon: _NavIcon(asset: 'assets/icons/icon_settings.jpg', selected: true),
            label: '設定',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final UserProfile profile;
  final DailyFortuneResult? dailyFortune;
  final bool loadingFortune;
  final String? fortuneError;
  final List<Consultation> recentConsultations;
  final VoidCallback onStartFortune;

  const _HomeTab({
    required this.profile,
    required this.dailyFortune,
    required this.loadingFortune,
    required this.fortuneError,
    required this.recentConsultations,
    required this.onStartFortune,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 挨拶
          Text(
            'こんにちは、${profile.nickname}さん',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          Text(
            profile.zodiacSign,
            style: const TextStyle(
                color: AppTheme.accent, fontSize: 18, letterSpacing: 2),
          ),
          const SizedBox(height: 20),

          // 今日の運勢
          DailyFortuneCard(
            zodiacSign: profile.zodiacSign,
            fortune: dailyFortune,
            isLoading: loadingFortune,
            errorMsg: fortuneError,
          ),
          const SizedBox(height: 20),

          // 利用回数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Text('🔮', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                '今月のフル占い：${profile.monthlyReadingCount} / ${profile.plan.monthlyReadingLimit}回',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              if (!profile.canUseReading)
                const Text('上限', style: TextStyle(color: AppTheme.error, fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 20),

          // フル占いボタン
          GestureDetector(
            onTap: onStartFortune,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: profile.canUseReading
                      ? [const Color(0xFF3D2B6E), const Color(0xFF1E1040)]
                      : [const Color(0xFF2A2A40), const Color(0xFF1A1A2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: profile.canUseReading
                      ? AppTheme.accent.withValues(alpha: 0.4)
                      : AppTheme.divider,
                  width: 1,
                ),
              ),
              child: Column(children: [
                Text(
                  profile.canUseReading ? '🔮' : '🔒',
                  style: const TextStyle(fontSize: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  profile.canUseReading ? 'フル占いを始める' : '今月の回数上限に達しました',
                  style: TextStyle(
                    color: profile.canUseReading
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.canUseReading
                      ? 'タロット・数秘術から選べます'
                      : 'Lightプランで月50回に増やせます',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          // 最近の相談
          if (recentConsultations.isNotEmpty) ...[
            const Text(
              '最近の相談',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  letterSpacing: 1),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: recentConsultations
                  .take(4)
                  .map((c) => _RecentGridCard(c))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  final Consultation c;
  const _RecentCard(this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(c.fortuneType.emoji,
            style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                c.worry,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14),
              ),
              Text(
                '${c.createdAt.month}/${c.createdAt.day}  ${c.fortuneType.displayName}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        if (c.score != null)
          Text(
            '${c.score}点',
            style: TextStyle(
              color: c.score! >= 70
                  ? AppTheme.success
                  : c.score! >= 50
                      ? AppTheme.accentGold
                      : AppTheme.error,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
      ]),
    );
  }
}

class _RecentGridCard extends StatelessWidget {
  final Consultation c;
  const _RecentGridCard(this.c);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: c.score != null && c.score! >= 70
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.divider,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(c.fortuneType.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.fortuneType.displayName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Text(
            c.worry,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${c.createdAt.month}/${c.createdAt.day}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
              if (c.score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.score! >= 70
                        ? AppTheme.success.withValues(alpha: 0.2)
                        : c.score! >= 50
                            ? AppTheme.accentGold.withValues(alpha: 0.2)
                            : AppTheme.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${c.score}点',
                    style: TextStyle(
                      color: c.score! >= 70
                          ? AppTheme.success
                          : c.score! >= 50
                              ? AppTheme.accentGold
                              : AppTheme.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ボトムナビ用カスタムアイコン
class _NavIcon extends StatelessWidget {
  final String asset;
  final bool selected;
  const _NavIcon({required this.asset, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: selected
            ? Border.all(color: AppTheme.accent, width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: ColorFiltered(
          colorFilter: selected
              ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
              : ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.4), BlendMode.saturation),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
