import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/action_item.dart';
import 'package:myfortune/data/repositories/action_item_repository.dart';

class ActionListScreen extends StatefulWidget {
  final String uid;
  const ActionListScreen({super.key, required this.uid});

  @override
  State<ActionListScreen> createState() => _ActionListScreenState();
}

class _ActionListScreenState extends State<ActionListScreen> {
  final _repo = ActionItemRepository();
  List<ActionItem> _items = [];
  bool _loading = true;
  ActionStatus? _filterStatus; // null = すべて

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = _filterStatus == null
          ? await _repo.getAll(widget.uid)
          : await _repo.getByStatus(widget.uid, _filterStatus!);
      if (mounted) setState(() { _items = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(ActionItem item, ActionStatus newStatus) async {
    await _repo.updateStatus(item.id!, newStatus);
    await _load();
  }

  Future<void> _delete(ActionItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('削除しますか？',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        content: Text(
          item.action,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _repo.delete(item.id!);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _items.where((i) => i.status == ActionStatus.pending).length;
    final done    = _items.where((i) => i.status == ActionStatus.done).length;
    final failed  = _items.where((i) => i.status == ActionStatus.failed).length;

    return Column(
      children: [
        // ── サマリーバー ──
        if (_items.isNotEmpty)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryChip(emoji: '🔄', label: '取り組み中', count: pending,
                    color: AppTheme.accent),
                _divider(),
                _SummaryChip(emoji: '✅', label: '達成', count: done,
                    color: AppTheme.success),
                _divider(),
                _SummaryChip(emoji: '❌', label: 'できなかった', count: failed,
                    color: AppTheme.error),
              ],
            ),
          ),

        // ── フィルターチップ ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              _FilterChip(
                label: 'すべて',
                selected: _filterStatus == null,
                onTap: () { setState(() => _filterStatus = null); _load(); },
              ),
              const SizedBox(width: 8),
              ...ActionStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: '${s.emoji} ${s.label}',
                  selected: _filterStatus == s,
                  onTap: () { setState(() => _filterStatus = s); _load(); },
                ),
              )),
            ],
          ),
        ),

        // ── リスト ──
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 2))
              : _items.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: AppTheme.accent,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                        itemCount: _items.length,
                        itemBuilder: (_, i) => _ActionCard(
                          item: _items[i],
                          onStatusTap: (s) => _updateStatus(_items[i], s),
                          onDelete: () => _delete(_items[i]),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    final msg = _filterStatus == null
        ? 'アクションはまだありません\n占い結果でアクションを追加しましょう'
        : '${_filterStatus!.emoji} ${_filterStatus!.label}\nのアクションはありません';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _filterStatus == null ? '📋' : _filterStatus!.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1, height: 28,
        color: AppTheme.divider,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

// ── カード ──────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final ActionItem item;
  final ValueChanged<ActionStatus> onStatusTap;
  final VoidCallback onDelete;

  const _ActionCard({
    required this.item,
    required this.onStatusTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone   = item.status == ActionStatus.done;
    final isFailed = item.status == ActionStatus.failed;

    final borderColor = isDone
        ? AppTheme.success.withValues(alpha: 0.5)
        : isFailed
            ? AppTheme.error.withValues(alpha: 0.4)
            : AppTheme.divider;

    final bgColor = isDone
        ? AppTheme.success.withValues(alpha: 0.06)
        : isFailed
            ? AppTheme.error.withValues(alpha: 0.05)
            : AppTheme.card;

    // FortuneType emoji
    String typeEmoji = '🔮';
    try {
      typeEmoji = FortuneType.values
          .firstWhere((t) => t.name == item.fortuneType)
          .emoji;
    } catch (_) {}

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.error, size: 22),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false; // ダイアログで制御するので自動削除しない
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ステータスボタン（タップで切替）
                GestureDetector(
                  onTap: () => _showStatusMenu(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppTheme.success.withValues(alpha: 0.15)
                          : isFailed
                              ? AppTheme.error.withValues(alpha: 0.12)
                              : AppTheme.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(item.status.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // メインコンテンツ
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.action,
                        style: TextStyle(
                          color: isDone || isFailed
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.5,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text(typeEmoji,
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${item.createdAt.month}/${item.createdAt.day}  '
                          '${_truncate(item.worry, 16)}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ]),
                    ],
                  ),
                ),

                // ステータスラベル
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showStatusMenu(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppTheme.success.withValues(alpha: 0.12)
                          : isFailed
                              ? AppTheme.error.withValues(alpha: 0.1)
                              : AppTheme.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.status.label,
                      style: TextStyle(
                        color: isDone
                            ? AppTheme.success
                            : isFailed
                                ? AppTheme.error
                                : AppTheme.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.action,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Text(
                'ステータスを変更',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...ActionStatus.values.map((s) {
                final isCurrent = item.status == s;
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    if (!isCurrent) onStatusTap(s);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.accent.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.accent.withValues(alpha: 0.4)
                            : AppTheme.divider,
                      ),
                    ),
                    child: Row(children: [
                      Text(s.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(
                        s.label,
                        style: TextStyle(
                          color: isCurrent
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isCurrent) ...[
                        const Spacer(),
                        const Icon(Icons.check,
                            color: AppTheme.accent, size: 18),
                      ],
                    ]),
                  ),
                );
              }),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  String _truncate(String s, int len) =>
      s.length > len ? '${s.substring(0, len)}…' : s;
}

// ── サマリーチップ ──────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _SummaryChip({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        '$emoji $count',
        style: TextStyle(
            color: count > 0 ? color : AppTheme.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 10)),
    ]);
  }
}

// ── フィルターチップ ────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.15)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.accent : AppTheme.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.accent : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
