import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/feature_request.dart';
import 'package:myfortune/data/repositories/feedback_repository.dart';

class FeatureRequestScreen extends StatefulWidget {
  final String userId;
  const FeatureRequestScreen({super.key, required this.userId});

  @override
  State<FeatureRequestScreen> createState() => _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends State<FeatureRequestScreen> {
  String _category = 'new_feature';
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _useCaseController = TextEditingController();
  final Set<String> _targetPlans = {'light'};
  bool _submitting = false;
  bool _loadingTop = true;
  List<FeatureRequest> _topRequests = [];

  static const _categories = [
    ('new_feature', '新機能の追加'),
    ('improvement', '既存機能の改善'),
    ('ui', 'UI/UXの改善'),
    ('performance', 'パフォーマンス向上'),
    ('other', 'その他'),
  ];

  @override
  void initState() {
    super.initState();
    _loadTop();
  }

  Future<void> _loadTop() async {
    try {
      final list = await FeedbackRepository().getTopFeatureRequests(limit: 5);
      if (mounted) setState(() { _topRequests = list; _loadingTop = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTop = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _useCaseController.dispose();
    super.dispose();
  }

  Future<void> _vote(FeatureRequest req) async {
    try {
      if (req.hasVoted(widget.userId)) {
        await FeedbackRepository().unvoteFeatureRequest(req.id!, widget.userId);
      } else {
        await FeedbackRepository().voteFeatureRequest(req.id!, widget.userId);
      }
      await _loadTop();
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('タイトルと詳細を入力してください')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final req = FeatureRequest(
        userId: widget.userId,
        category: _category,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        useCase: _useCaseController.text.trim(),
        targetPlan: _targetPlans.toList(),
        createdAt: DateTime.now(),
      );
      final id = await FeedbackRepository().submitFeatureRequest(req);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.card,
            title: const Text('要望を受け付けました',
                style: TextStyle(color: AppTheme.textPrimary)),
            content: Text(
              '要望 ID：${id.substring(0, 8).toUpperCase()}\n\n他のユーザーも同じ要望に投票できます。',
              style: const TextStyle(color: AppTheme.textSecondary, height: 1.6),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK',
                    style: TextStyle(color: AppTheme.accent)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = '送信に失敗しました。もう一度お試しください。';
        debugPrint('Feature request submission error: $e');

        if (e.toString().contains('Permission denied') || e.toString().contains('PERMISSION_DENIED')) {
          errorMsg = 'Firebaseの権限がありません。アプリを再起動してお試しください。';
        } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
          errorMsg = 'ネットワーク接続を確認してください。';
        } else if (e.toString().contains('timeout')) {
          errorMsg = '接続がタイムアウトしました。もう一度お試しください。';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), duration: const Duration(seconds: 4)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 改善要望'),
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
            // 人気の要望
            if (!_loadingTop && _topRequests.isNotEmpty) ...[
              const Text('人気の要望',
                  style: TextStyle(
                      color: AppTheme.accent, fontSize: 12, letterSpacing: 1)),
              const SizedBox(height: 8),
              ..._topRequests.map((r) => _TopRequestCard(
                    request: r,
                    userId: widget.userId,
                    onVote: () => _vote(r),
                  )),
              const SizedBox(height: 24),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 24),
            ],

            const Text(
              'どんな改善があると嬉しいですか？',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 24),

            // カテゴリ
            _Label('カテゴリ（必須）'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _categories.map((c) {
                final selected = _category == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _category = c.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.accent.withValues(alpha: 0.2)
                          : AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected
                              ? AppTheme.accent
                              : AppTheme.divider),
                    ),
                    child: Text(c.$2,
                        style: TextStyle(
                            color: selected
                                ? AppTheme.accent
                                : AppTheme.textSecondary,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // タイトル
            _Label('タイトル（必須）'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: '友人と占い結果をシェアしたい',
              ),
            ),
            const SizedBox(height: 20),

            // 詳細
            _Label('詳細（必須）'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.7),
              decoration: const InputDecoration(
                hintText: 'LINE や SNS に占い結果を共有できると良いと思います…',
              ),
            ),
            const SizedBox(height: 20),

            // ユースケース
            _Label('ユースケース（あれば）'),
            const SizedBox(height: 8),
            TextField(
              controller: _useCaseController,
              maxLines: 2,
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.7),
              decoration: const InputDecoration(
                hintText: '彼との相性を占った結果を友人に見せたい',
              ),
            ),
            const SizedBox(height: 20),

            // 対象プラン
            _Label('どのプランで実装希望？'),
            const SizedBox(height: 8),
            Row(children: [
              for (final p in [
                ('free', 'Free'),
                ('light', 'Light'),
                ('pro', 'Pro')
              ]) ...[
                _CheckChip(
                  label: p.$2,
                  selected: _targetPlans.contains(p.$1),
                  onTap: () => setState(() {
                    if (_targetPlans.contains(p.$1)) {
                      _targetPlans.remove(p.$1);
                    } else {
                      _targetPlans.add(p.$1);
                    }
                  }),
                ),
                const SizedBox(width: 8),
              ]
            ]),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('送信する',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            color: AppTheme.accent, fontSize: 12, letterSpacing: 1),
      );
}

class _CheckChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _CheckChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.card,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? AppTheme.accent : AppTheme.divider),
        ),
        child: Text(label,
            style: TextStyle(
                color:
                    selected ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 13)),
      ),
    );
  }
}

class _TopRequestCard extends StatelessWidget {
  final FeatureRequest request;
  final String userId;
  final VoidCallback onVote;

  const _TopRequestCard({
    required this.request,
    required this.userId,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final voted = request.hasVoted(userId);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                '${request.statusEmoji} ${request.statusLabel}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: request.id != null ? onVote : null,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: voted
                  ? AppTheme.accent.withValues(alpha: 0.2)
                  : AppTheme.divider.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: voted ? AppTheme.accent : AppTheme.divider),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(voted ? Icons.star : Icons.star_border,
                  size: 14,
                  color: voted ? AppTheme.accent : AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('${request.votes}',
                  style: TextStyle(
                      color:
                          voted ? AppTheme.accent : AppTheme.textSecondary,
                      fontSize: 12)),
            ]),
          ),
        ),
      ]),
    );
  }
}
