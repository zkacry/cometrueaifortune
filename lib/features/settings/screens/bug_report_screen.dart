import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/bug_report.dart';
import 'package:myfortune/data/repositories/feedback_repository.dart';

class BugReportScreen extends StatefulWidget {
  final String userId;
  const BugReportScreen({super.key, required this.userId});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  String _category = 'display';
  String _priority = 'medium';
  final _descController = TextEditingController();
  final _stepsController = TextEditingController();
  bool _submitting = false;

  static const _categories = [
    ('display', '占い結果が表示されない'),
    ('crash', 'アプリがクラッシュ'),
    ('calculation', '計算が間違っている'),
    ('navigation', '画面遷移がおかしい'),
    ('other', 'その他'),
  ];

  static const _priorities = [
    ('high', '高（使えない）'),
    ('medium', '中（不便だが使える）'),
    ('low', '低（軽微）'),
  ];

  @override
  void dispose() {
    _descController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('バグの内容を入力してください')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final report = BugReport(
        userId: widget.userId,
        category: _category,
        description: _descController.text.trim(),
        steps: _stepsController.text.trim(),
        priority: _priority,
        createdAt: DateTime.now(),
      );
      final id = await FeedbackRepository().submitBugReport(report);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.card,
            title: const Text('報告を受け付けました',
                style: TextStyle(color: AppTheme.textPrimary)),
            content: Text(
              '報告 ID：${id.substring(0, 8).toUpperCase()}\n\nステータスは「設定 > 過去の報告」から確認できます。',
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
        String errorMessage = '送信に失敗しました。もう一度お試しください。';
        debugPrint('Bug report submission error: $e');

        if (e.toString().contains('Permission denied') || e.toString().contains('permission')) {
          errorMessage = 'Firebaseの権限がありません。開発者に連絡してください。';
        } else if (e.toString().contains('network') || e.toString().contains('Connection')) {
          errorMessage = 'ネットワーク接続を確認してください。';
        } else if (e.toString().contains('timeout')) {
          errorMessage = '接続がタイムアウトしました。もう一度お試しください。';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 バグ報告'),
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
            const Text(
              'バグの内容を教えてください',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 24),

            // カテゴリ
            _Label('カテゴリ（必須）'),
            const SizedBox(height: 8),
            ..._categories.map((c) => _SelectRow(
                  label: c.$2,
                  selected: _category == c.$1,
                  onTap: () => setState(() => _category = c.$1),
                )),
            const SizedBox(height: 20),

            // 詳細
            _Label('バグの詳細（必須）'),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 5,
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.7),
              decoration: const InputDecoration(
                hintText: '占ったら結果が表示されずグレーのままです…',
              ),
            ),
            const SizedBox(height: 20),

            // 再現手順
            _Label('再現手順（あれば）'),
            const SizedBox(height: 8),
            TextField(
              controller: _stepsController,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary, height: 1.7),
              decoration: const InputDecoration(
                hintText: '1. タロットを選択\n2. 「占う」をタップ\n3. グレーで止まる',
              ),
            ),
            const SizedBox(height: 20),

            // 優先度
            _Label('優先度'),
            const SizedBox(height: 8),
            ..._priorities.map((p) => _SelectRow(
                  label: p.$2,
                  selected: _priority == p.$1,
                  onTap: () => setState(() => _priority = p.$1),
                )),
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
                    : const Text('報告する',
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

class _SelectRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppTheme.accent : AppTheme.divider,
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accent,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color:
                      selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontSize: 14)),
        ]),
      ),
    );
  }
}
