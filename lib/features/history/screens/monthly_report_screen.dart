import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/consultation_repository.dart';
import 'package:myfortune/data/services/claude_service.dart';

class MonthlyReportScreen extends StatefulWidget {
  final UserProfile profile;

  const MonthlyReportScreen({super.key, required this.profile});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late DateTime _selectedMonth;
  List<Consultation> _consultations = [];
  bool _isLoading = true;
  String? _aiSummary;
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _loadData();
  }

  String get _monthKey =>
      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _aiSummary = null;
    });
    try {
      final list = await ConsultationRepository()
          .getByMonth(widget.profile.uid, _monthKey);
      if (mounted) setState(() => _consultations = list);
    } catch (e) {
      debugPrint('MonthlyReport loadData error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadData();
  }

  void _nextMonth() {
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    if (next.isAfter(DateTime.now())) return;
    setState(() => _selectedMonth = next);
    _loadData();
  }

  Future<void> _generateAiSummary() async {
    if (_consultations.isEmpty) return;
    setState(() => _isLoadingAi = true);

    try {
      final summary = await ClaudeService().generateMonthlySummary(
        profile: widget.profile,
        consultations: _consultations,
        monthKey: _monthKey,
      );
      if (mounted) setState(() => _aiSummary = summary);
    } catch (e) {
      debugPrint('AI summary error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI分析に失敗しました')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAi = false);
    }
  }

  // ── 集計ロジック ──────────────────────────────────
  int get _totalCount => _consultations.length;

  double get _avgScore {
    final scored = _consultations.where((c) => c.score != null).toList();
    if (scored.isEmpty) return 0;
    return scored.map((c) => c.score!).reduce((a, b) => a + b) /
        scored.length;
  }

  int get _maxScore => _consultations
      .where((c) => c.score != null)
      .map((c) => c.score!)
      .fold(0, (a, b) => a > b ? a : b);

  Map<FortuneType, int> get _typeCount {
    final map = <FortuneType, int>{};
    for (final c in _consultations) {
      map[c.fortuneType] = (map[c.fortuneType] ?? 0) + 1;
    }
    return map;
  }

  List<String> get _topWorries {
    final words = <String, int>{};
    for (final c in _consultations) {
      final w = c.worry.trim();
      if (w.isNotEmpty) words[w] = (words[w] ?? 0) + 1;
    }
    final sorted = words.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  List<String> get _topCards {
    final cards = <String, int>{};
    for (final c in _consultations) {
      for (final card in c.cards) {
        if (card.isNotEmpty) cards[card] = (cards[card] ?? 0) + 1;
      }
    }
    final sorted = cards.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((e) => e.key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isPro = widget.profile.plan == UserPlan.pro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('月間レポート'),
      ),
      body: Column(
        children: [
          // 月切り替えヘッダー
          Container(
            color: AppTheme.card,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: AppTheme.textPrimary),
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_selectedMonth.year}年${_selectedMonth.month}月',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.chevron_right,
                    color: DateTime(_selectedMonth.year,
                                    _selectedMonth.month + 1, 1)
                                .isAfter(DateTime.now())
                        ? AppTheme.divider
                        : AppTheme.textPrimary,
                  ),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // コンテンツ
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    ),
                  )
                : _consultations.isEmpty
                    ? _EmptyReport(month: _selectedMonth)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // サマリーカード
                            _SummaryCard(
                              total: _totalCount,
                              avgScore: _avgScore,
                              maxScore: _maxScore,
                            ),
                            const SizedBox(height: 16),

                            // 占術内訳
                            _SectionTitle('占術の内訳'),
                            _TypeBreakdown(typeCount: _typeCount),
                            const SizedBox(height: 16),

                            // よく悩んだこと
                            if (_topWorries.isNotEmpty) ...[
                              _SectionTitle('今月の悩みテーマ'),
                              _TagList(items: _topWorries, emoji: '💭'),
                              const SizedBox(height: 16),
                            ],

                            // よく出たカード
                            if (_topCards.isNotEmpty) ...[
                              _SectionTitle('今月よく出たカード'),
                              _TagList(items: _topCards, emoji: '🃏'),
                              const SizedBox(height: 16),
                            ],

                            // AI月間サマリー（Pro限定）
                            _SectionTitle('AI月間サマリー'),
                            if (!isPro)
                              _ProLockCard()
                            else if (_aiSummary != null)
                              _AiSummaryCard(summary: _aiSummary!)
                            else
                              _GenerateAiButton(
                                isLoading: _isLoadingAi,
                                onTap: _generateAiSummary,
                              ),
                            const SizedBox(height: 24),

                            // 相談リスト
                            _SectionTitle('今月の相談一覧（$_totalCount件）'),
                            ..._consultations
                                .map((c) => _ConsultationTile(c: c)),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ── ウィジェット群 ──────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      );
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final double avgScore;
  final int maxScore;

  const _SummaryCard({
    required this.total,
    required this.avgScore,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2B6E), Color(0xFF1E1040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem('相談回数', '$total回', '📊'),
          _Divider(),
          _StatItem('平均スコア', '${avgScore.round()}点', '⭐'),
          _Divider(),
          _StatItem('最高スコア', '$maxScore点', '🏆'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _StatItem(this.label, this.value, this.emoji);

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 40,
        width: 1,
        color: Colors.white24,
      );
}

class _TypeBreakdown extends StatelessWidget {
  final Map<FortuneType, int> typeCount;

  const _TypeBreakdown({required this.typeCount});

  @override
  Widget build(BuildContext context) {
    final total = typeCount.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: FortuneType.values.map((type) {
          final count = typeCount[type] ?? 0;
          final ratio = total > 0 ? count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Text(type.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: Text(
                  type.displayName,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: AppTheme.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.accent),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count回',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _TagList extends StatelessWidget {
  final List<String> items;
  final String emoji;

  const _TagList({required this.items, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$emoji $item',
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 12),
                ),
              ))
          .toList(),
    );
  }
}

class _ProLockCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.proPlan.withValues(alpha: 0.4)),
      ),
      child: Column(children: [
        const Text('🔒', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        const Text(
          'Proプラン限定機能',
          style: TextStyle(
              color: AppTheme.proPlan,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'AIが今月の占いパターンを分析し\n傾向とアドバイスをお届けします',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.proPlan),
          child: const Text('Proにアップグレード',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ]),
    );
  }
}

class _GenerateAiButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GenerateAiButton(
      {required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(children: [
        const Text('✨', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        const Text(
          '今月の占いをAIが総合分析',
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          '悩みのパターン・スコアの傾向・\n来月へのアドバイスを生成します',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: isLoading ? null : onTap,
          child: isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accent)),
                )
              : const Text('AI月間分析を生成'),
        ),
      ]),
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  final String summary;
  const _AiSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Text('✨', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Text(
            'AI月間サマリー',
            style: TextStyle(
                color: AppTheme.accent,
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ]),
        const SizedBox(height: 12),
        Text(
          summary,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            height: 1.7,
          ),
        ),
      ]),
    );
  }
}

class _ConsultationTile extends StatelessWidget {
  final Consultation c;
  const _ConsultationTile({required this.c});

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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              c.worry,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${c.createdAt.month}/${c.createdAt.day}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
            ),
          ]),
        ),
        if (c.score != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _scoreColor(c.score!).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${c.score}点',
              style: TextStyle(
                  color: _scoreColor(c.score!),
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
      ]),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 75) return AppTheme.accent;
    if (score >= 50) return Colors.orange;
    return AppTheme.error;
  }
}

class _EmptyReport extends StatelessWidget {
  final DateTime month;
  const _EmptyReport({required this.month});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            '${month.year}年${month.month}月の記録はありません',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
