import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/services/claude_service.dart';

class DailyFortuneCard extends StatelessWidget {
  final String zodiacSign;
  final DailyFortuneResult? fortune;
  final bool isLoading;
  final String? errorMsg;

  const DailyFortuneCard({
    super.key,
    required this.zodiacSign,
    this.fortune,
    this.isLoading = false,
    this.errorMsg,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1030), Color(0xFF0F0F20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('✨', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              '${now.month}月${now.day}日の運勢 / $zodiacSign',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
          ]),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Column(children: [
                CircularProgressIndicator(
                    color: AppTheme.accent, strokeWidth: 2),
                SizedBox(height: 12),
                Text('運勢を読み取っています…',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ]),
            )
          else if (fortune != null) ...[
            Row(children: [
              Expanded(
                child: _ScoreRow(label: '総合', score: fortune!.overallScore),
              ),
              Expanded(
                child: _ScoreRow(label: '恋愛', score: fortune!.loveScore),
              ),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Expanded(
                child: _ScoreRow(label: '仕事', score: fortune!.workScore),
              ),
              Expanded(
                child: _ScoreRow(label: '金運', score: fortune!.moneyScore),
              ),
            ]),
            if (fortune!.warning.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Text('⚠️', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fortune!.warning,
                      style: const TextStyle(
                          color: AppTheme.accentGold, fontSize: 12),
                    ),
                  ),
                ]),
              ),
            ],
          ] else
            Text(
              errorMsg ?? '今日の運勢を取得できませんでした',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14),
            ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;
  const _ScoreRow({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final filled = (score / 20).round().clamp(0, 5);
    return Row(children: [
      Text(
        '$label：',
        style: const TextStyle(
            color: AppTheme.textSecondary, fontSize: 12),
      ),
      Text(
        '★' * filled + '☆' * (5 - filled),
        style: const TextStyle(color: AppTheme.accentGold, fontSize: 13),
      ),
    ]);
  }
}
