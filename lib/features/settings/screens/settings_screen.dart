import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/user_repository.dart';
import 'package:myfortune/data/services/notification_service.dart';
import 'package:myfortune/data/services/usage_service.dart';
import 'package:myfortune/features/history/screens/monthly_report_screen.dart';
import 'package:myfortune/features/settings/screens/bug_report_screen.dart';
import 'package:myfortune/features/settings/screens/feature_request_screen.dart';
import 'package:myfortune/features/settings/screens/help_screen.dart';
import 'package:myfortune/features/settings/screens/my_reports_screen.dart';
import 'package:myfortune/features/settings/screens/upgrade_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile profile;
  const SettingsScreen({super.key, required this.profile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}


class _SettingsScreenState extends State<SettingsScreen> {
  int _localCount = 0;
  late bool _notificationEnabled;
  late int _notificationHour;
  bool _isSavingNotification = false;
  late AiPersona _selectedPersona;
  bool _isSavingPersona = false;
  bool _isSavingTraits = false;

  // 特性：自由記入 × 最大5件
  static const _maxTraits = 5;
  late final List<TextEditingController> _traitControllers;

  @override
  void initState() {
    super.initState();
    _notificationEnabled = widget.profile.notificationEnabled;
    _notificationHour = widget.profile.notificationHour;
    _selectedPersona = widget.profile.persona;
    // 既存の特性を各コントローラーにセット
    _traitControllers = List.generate(_maxTraits, (i) {
      final existing = widget.profile.personalityTraits;
      return TextEditingController(
          text: i < existing.length ? existing[i] : '');
    });
    UsageService.getCount().then((c) => setState(() => _localCount = c));
  }

  @override
  void dispose() {
    for (final c in _traitControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveNotificationSettings() async {
    setState(() => _isSavingNotification = true);

    try {
      // プロフィールを更新
      final updatedProfile = widget.profile.copyWith(
        notificationEnabled: _notificationEnabled,
        notificationHour: _notificationHour,
      );

      // Firestoreに保存
      await UserRepository().saveProfile(updatedProfile);

      // 通知を再スケジュール
      if (_notificationEnabled) {
        await NotificationService.scheduleDailyNotification(
          hour: _notificationHour,
          title: '運勢のお時間です',
          body: 'あなたの今日の運勢をチェックしましょう',
        );
      } else {
        await NotificationService.cancelDailyNotification();
      }

      if (mounted) {
        setState(() => _isSavingNotification = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('通知設定を保存しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingNotification = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定の保存に失敗しました'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      debugPrint('_saveNotificationSettings error: $e');
    }
  }

  String _personaDescription(AiPersona persona) {
    switch (persona) {
      case AiPersona.logica:
        return 'データと論理で分析・パターンと確率を重視';
      case AiPersona.insight:
        return '直感と洞察で読み取る・心理的背景を深掘り';
      case AiPersona.strategy:
        return '行動と結果を重視・具体的なステップを提案';
    }
  }

  Future<void> _savePersona() async {
    setState(() => _isSavingPersona = true);
    try {
      final updated = widget.profile.copyWith(persona: _selectedPersona);
      await UserRepository().saveProfile(updated);
      if (mounted) {
        setState(() => _isSavingPersona = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AIペルソナを変更しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSavingPersona = false);
      debugPrint('_savePersona error: $e');
    }
  }

  Future<void> _saveTraits() async {
    // コントローラーから空白除去して取得
    final traits = _traitControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    setState(() => _isSavingTraits = true);
    try {
      final updated = widget.profile.copyWith(personalityTraits: traits);
      await UserRepository().saveProfile(updated);
      if (mounted) {
        setState(() => _isSavingTraits = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('あなたの特性を保存しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isSavingTraits = false);
      debugPrint('_saveTraits error: $e');
    }
  }

  void _showTimePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int selectedHour = _notificationHour;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.card,
              title: const Text(
                '通知時間を設定',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${selectedHour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: selectedHour.toDouble(),
                      min: 0,
                      max: 23,
                      divisions: 23,
                      label: '${selectedHour.toString().padLeft(2, '0')}:00',
                      onChanged: (value) {
                        setState(() => selectedHour = value.toInt());
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickHourButton(
                          label: '9:00',
                          hour: 9,
                          isSelected: selectedHour == 9,
                          onTap: () => setState(() => selectedHour = 9),
                        ),
                        _QuickHourButton(
                          label: '12:00',
                          hour: 12,
                          isSelected: selectedHour == 12,
                          onTap: () => setState(() => selectedHour = 12),
                        ),
                        _QuickHourButton(
                          label: '18:00',
                          hour: 18,
                          isSelected: selectedHour == 18,
                          onTap: () => setState(() => selectedHour = 18),
                        ),
                        _QuickHourButton(
                          label: '21:00',
                          hour: 21,
                          isSelected: selectedHour == 21,
                          onTap: () => setState(() => selectedHour = 21),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('キャンセル',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Update parent state with selected hour
                    this.setState(() => _notificationHour = selectedHour);
                    Navigator.pop(context);
                  },
                  child: const Text('決定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // 通知設定セクション
          _SectionTitle('通知設定'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // 通知ON/OFF
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '毎日の運勢通知',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _notificationEnabled
                              ? '毎日${_notificationHour.toString().padLeft(2, '0')}:00に通知を受け取ります'
                              : '通知はオフです',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _notificationEnabled,
                      onChanged: (value) {
                        setState(() => _notificationEnabled = value);
                      },
                      activeColor: AppTheme.accent,
                    ),
                  ],
                ),
                if (_notificationEnabled) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.divider, height: 1),
                  const SizedBox(height: 16),
                  // 通知時間設定
                  GestureDetector(
                    onTap: _showTimePickerDialog,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '通知時間',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${_notificationHour.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit,
                                color: AppTheme.accent,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSavingNotification ? null : _saveNotificationSettings,
                    child: _isSavingNotification
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppTheme.accent),
                            ),
                          )
                        : const Text('通知設定を保存'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // プロフィール
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withValues(alpha: 0.2),
                  border: Border.all(color: AppTheme.accent, width: 1.5),
                ),
                child: const Center(
                  child: Text('✨', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  profile.nickname,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  profile.zodiacSign,
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 13),
                ),
                Text(
                  '${profile.birthdate.year}年${profile.birthdate.month}月${profile.birthdate.day}日生まれ',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ]),
            ]),
          ),

          const SizedBox(height: 20),

          // 現在のプラン
          _SectionTitle('現在のプラン'),
          _PlanCard(
            plan: profile.plan,
            readingCount: profile.monthlyReadingCount,
            localCount: _localCount,
          ),

          const SizedBox(height: 20),

          // プランアップグレード
          if (profile.plan != UserPlan.pro) ...[
            _SectionTitle('プランをアップグレード'),
            if (profile.plan == UserPlan.free)
              _UpgradeCard(
                plan: UserPlan.light,
                features: ['月50回フル占い', '記憶型パターン分析', '基本ジャーナル'],
                profile: profile,
              ),
            const SizedBox(height: 8),
            _UpgradeCard(
              plan: UserPlan.pro,
              features: ['月300回フル占い', 'AIペルソナ選択', '月間レポートPDF', '成功率スコア'],
              profile: profile,
            ),
            const SizedBox(height: 20),
          ],

          // AI ペルソナ設定
          _SectionTitle('AI ペルソナ'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _AppIcon('assets/icons/icon_ai.jpg', size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'AIの回答スタイルを選択',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (widget.profile.plan == UserPlan.free)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.proPlan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Pro限定',
                        style: TextStyle(
                            color: AppTheme.proPlan, fontSize: 10),
                      ),
                    ),
                ]),
                const SizedBox(height: 16),
                ...AiPersona.values.map((persona) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: widget.profile.plan != UserPlan.free
                            ? () => setState(() => _selectedPersona = persona)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _selectedPersona == persona
                                ? AppTheme.accent.withValues(alpha: 0.1)
                                : AppTheme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPersona == persona
                                  ? AppTheme.accent
                                  : AppTheme.divider,
                              width: _selectedPersona == persona ? 1.5 : 1,
                            ),
                          ),
                          child: Row(children: [
                            _AppIcon(persona.iconAsset, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    persona.displayName,
                                    style: TextStyle(
                                      color: _selectedPersona == persona
                                          ? AppTheme.accent
                                          : AppTheme.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _personaDescription(persona),
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedPersona == persona)
                              const Icon(Icons.check_circle,
                                  color: AppTheme.accent, size: 18),
                          ]),
                        ),
                      ),
                    )),
                if (widget.profile.plan != UserPlan.free) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isSavingPersona ? null : _savePersona,
                      child: _isSavingPersona
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.accent)),
                            )
                          : const Text('ペルソナを変更'),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Light・Proプランにアップグレードするとペルソナを選択できます',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // あなたの特性
          _SectionTitle('あなたの特性'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _AppIcon('assets/icons/icon_star.jpg', size: 24),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'あなたの性格や状況を教えてください',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ]),
                const SizedBox(height: 4),
                const Text(
                  '占い鑑定のパーソナライズに使われます（最大5つ）',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 14),
                ...List.generate(_maxTraits, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _traitControllers[i],
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: i == 0 ? '例: 慎重派、会社員、片思い中…' : '特性 ${i + 1}',
                      hintStyle: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                      prefixText: '${i + 1}. ',
                      prefixStyle: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                      isDense: true,
                    ),
                  ),
                )),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSavingTraits ? null : _saveTraits,
                    child: _isSavingTraits
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accent)),
                          )
                        : const Text('特性を保存'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 月間レポート
          _SectionTitle('レポート'),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _FeedbackRow(
              iconAsset: 'assets/icons/icon_report.jpg',
              label: '月間レポート',
              subtitle: '今月の占い傾向を分析',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthlyReportScreen(profile: profile),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // サポート・フィードバック
          _SectionTitle('サポート'),
          _FeedbackSection(profile: profile),
          const SizedBox(height: 20),

          // ヘルプ
          _SectionTitle('ヘルプ'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  const Text(
                    '❓',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'アプリの使い方',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '機能の説明やよくある質問を確認',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // バージョン情報
          const Center(
            child: Text(
              'AI Fortune v1.0.3',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Petit Works Apps',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            letterSpacing: 2),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final UserPlan plan;
  final int readingCount;
  final int localCount;

  const _PlanCard({
    required this.plan,
    required this.readingCount,
    required this.localCount,
  });

  @override
  Widget build(BuildContext context) {
    final color = plan == UserPlan.pro
        ? AppTheme.proPlan
        : plan == UserPlan.light
            ? AppTheme.lightPlan
            : AppTheme.freePlan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                plan.displayName,
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const Spacer(),
            Text(
              plan == UserPlan.free ? '無料' : '月${plan.monthlyPrice}円',
              style: TextStyle(color: color, fontSize: 13),
            ),
          ]),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: readingCount / plan.monthlyReadingLimit,
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation(color),
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 6),
          Text(
            '今月のフル占い：$readingCount / ${plan.monthlyReadingLimit}回',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final UserProfile profile;
  const _FeedbackSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        _FeedbackRow(
          iconAsset: 'assets/icons/icon_bugs.jpg',
          label: 'バグ報告',
          subtitle: 'アプリの不具合を報告',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BugReportScreen(userId: profile.uid),
            ),
          ),
        ),
        const Divider(color: AppTheme.divider, height: 1, indent: 16),
        _FeedbackRow(
          iconAsset: 'assets/icons/icon_idea.jpg',
          label: '改善要望',
          subtitle: 'こんな機能があると良い',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FeatureRequestScreen(userId: profile.uid),
            ),
          ),
        ),
        const Divider(color: AppTheme.divider, height: 1, indent: 16),
        _FeedbackRow(
          iconAsset: 'assets/icons/icon_log.jpg',
          label: '過去の報告を確認',
          subtitle: 'バグ・要望のステータスを確認',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyReportsScreen(userId: profile.uid),
            ),
          ),
        ),
      ]),
    );
  }
}

/// 設定画面共通アイコン画像ウィジェット
class _AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  const _AppIcon(this.asset, {this.size = 24});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            Icon(Icons.image_not_supported, size: size, color: AppTheme.textSecondary),
      ),
    );
  }
}

class _FeedbackRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _FeedbackRow({
    required this.iconAsset,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          _AppIcon(iconAsset, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppTheme.divider, size: 18),
        ]),
      ),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  final UserPlan plan;
  final List<String> features;
  final UserProfile profile;

  const _UpgradeCard({
    required this.plan,
    required this.features,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final color = plan == UserPlan.pro ? AppTheme.proPlan : AppTheme.lightPlan;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${plan.displayName}プラン',
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                features.map((f) => '✓ $f').join('  '),
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpgradeScreen(profile: profile),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: Text(
            '月${plan.monthlyPrice}円',
            style: const TextStyle(
                color: Colors.white, fontSize: 12),
          ),
        ),
      ]),
    );
  }
}

class _QuickHourButton extends StatelessWidget {
  final String label;
  final int hour;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickHourButton({
    required this.label,
    required this.hour,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accent.withValues(alpha: 0.2)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.divider,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
