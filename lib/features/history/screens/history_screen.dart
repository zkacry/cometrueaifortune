import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/action_item.dart';
import 'package:myfortune/data/repositories/action_item_repository.dart';
import 'package:myfortune/data/repositories/consultation_repository.dart';
import 'package:myfortune/data/services/database_service.dart';
import 'package:myfortune/features/actions/screens/action_list_screen.dart';

class HistoryScreen extends StatefulWidget {
  final String uid;
  const HistoryScreen({super.key, required this.uid});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Consultation> _consultations = [];
  bool _loading = true;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {})); // バッジ再描画
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final list =
          await ConsultationRepository().getRecent(widget.uid, limit: 50);
      // 取り組み中件数をバッジ表示
      final counts = await ActionItemRepository().getCounts(widget.uid);
      if (mounted) {
        setState(() {
          _consultations = list;
          _pendingCount = counts[ActionStatus.pending] ?? 0;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openDetail(Consultation c) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DetailScreen(consultation: c)),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // タブバー
        Container(
          color: AppTheme.background,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.accent,
            indicatorWeight: 2,
            labelColor: AppTheme.accent,
            unselectedLabelColor: AppTheme.textSecondary,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: [
              const Tab(text: '占い履歴'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('アクション'),
                    if (_pendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$_pendingCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // タブコンテンツ
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ── 占い履歴タブ ──
              _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.accent, strokeWidth: 2))
                  : _consultations.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('📖', style: TextStyle(fontSize: 48)),
                              SizedBox(height: 16),
                              Text(
                                'まだ記録がありません\nフル占いをして記録をつけましょう',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    height: 1.6),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          color: AppTheme.accent,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _consultations.length,
                            itemBuilder: (_, i) {
                              final c = _consultations[i];
                              final scoreColor = c.score == null
                                  ? AppTheme.textSecondary
                                  : c.score! >= 70
                                      ? AppTheme.success
                                      : c.score! >= 50
                                          ? AppTheme.accentGold
                                          : AppTheme.error;

                              return GestureDetector(
                                onTap: () => _openDetail(c),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.card,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                    Column(children: [
                                      Text(c.fortuneType.emoji,
                                          style: const TextStyle(fontSize: 24)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${c.createdAt.month}/${c.createdAt.day}',
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 10),
                                      ),
                                    ]),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.worry,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            c.fortuneType.displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (c.score != null)
                                            Text(
                                              '${c.score}点',
                                              style: TextStyle(
                                                color: scoreColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          const SizedBox(height: 2),
                                          const Icon(Icons.chevron_right,
                                              color: AppTheme.divider, size: 16),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          ),
                        ),

              // ── アクションタブ ──
              ActionListScreen(uid: widget.uid),
            ],
          ),
        ),
      ],
    );
  }
}

// ── 詳細画面 ─────────────────────────────────────────
class _DetailScreen extends StatefulWidget {
  final Consultation consultation;
  const _DetailScreen({required this.consultation});

  @override
  State<_DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<_DetailScreen> {
  List<Map<String, dynamic>> _actionLogs = [];
  bool _loadingLogs = true;

  @override
  void initState() {
    super.initState();
    _loadActionLogs();
  }

  Future<void> _loadActionLogs() async {
    if (widget.consultation.id == null) {
      setState(() => _loadingLogs = false);
      return;
    }
    try {
      final db = await DatabaseService.database;
      final logs = await db.query(
        'action_logs',
        where: 'consultationId = ?',
        whereArgs: [widget.consultation.id],
        orderBy: 'executedAt ASC',
      );
      setState(() {
        _actionLogs = logs;
        _loadingLogs = false;
      });
    } catch (e) {
      setState(() => _loadingLogs = false);
    }
  }

  Future<void> _markSuccess(int logId, bool success) async {
    try {
      final db = await DatabaseService.database;
      await db.update(
        'action_logs',
        {'success': success ? 1 : 0},
        where: 'id = ?',
        whereArgs: [logId],
      );
      await _loadActionLogs();
    } catch (e) {
      debugPrint('mark success error: $e');
    }
  }

  Color get _scoreColor {
    final s = widget.consultation.score ?? 60;
    if (s >= 75) return AppTheme.success;
    if (s >= 50) return AppTheme.accentGold;
    return AppTheme.error;
  }

  String get _scoreLabel {
    final s = widget.consultation.score ?? 60;
    if (s >= 80) return '大吉';
    if (s >= 65) return '吉';
    if (s >= 50) return '中吉';
    if (s >= 35) return '小吉';
    return '凶';
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.consultation;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(c.fortuneType.displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(c.fortuneType.emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      '${c.createdAt.year}/${c.createdAt.month}/${c.createdAt.day}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const Spacer(),
                    if (c.score != null) ...[
                      Text(
                        _scoreLabel,
                        style: TextStyle(
                            color: _scoreColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      Text('${c.score}点',
                          style:
                              TextStyle(color: _scoreColor, fontSize: 13)),
                    ],
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    c.worry,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionTitle(title: '📖 鑑定内容'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                c.reading,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14, height: 1.9),
              ),
            ),
            const SizedBox(height: 16),

            if (c.suggestedActions.isNotEmpty) ...[
              _SectionTitle(title: '✨ アクション候補'),
              const SizedBox(height: 8),
              ...c.suggestedActions.map((a) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Text('• ',
                          style: TextStyle(
                              color: AppTheme.accent, fontSize: 16)),
                      Expanded(
                        child: Text(a,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                height: 1.5)),
                      ),
                    ]),
                  )),
              const SizedBox(height: 16),
            ],

            if (!_loadingLogs && _actionLogs.isNotEmpty) ...[
              _SectionTitle(title: '🎯 取り組んだアクション'),
              const SizedBox(height: 4),
              const Text(
                'タップして達成状況を記録できます',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 10),
              ..._actionLogs.map((log) {
                final success = (log['success'] as int? ?? 0) == 1;
                final logId = log['id'] as int;
                return GestureDetector(
                  onTap: () => _markSuccess(logId, !success),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: success
                          ? AppTheme.success.withValues(alpha: 0.08)
                          : AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: success
                            ? AppTheme.success.withValues(alpha: 0.4)
                            : AppTheme.divider,
                      ),
                    ),
                    child: Row(children: [
                      Icon(
                        success
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: success
                            ? AppTheme.success
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          log['action'] as String,
                          style: TextStyle(
                            color: success
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                            decoration: success
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Text(
                        success ? '達成 ✓' : '未達成',
                        style: TextStyle(
                          color: success
                              ? AppTheme.success
                              : AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            if (c.decision != null && c.decision!.isNotEmpty) ...[
              _SectionTitle(title: '💡 決断メモ'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.3)),
                ),
                child: Text(
                  c.decision!,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      height: 1.6),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
    );
  }
}
