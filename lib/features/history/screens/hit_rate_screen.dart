import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/repositories/consultation_repository.dart';

class HitRateScreen extends StatefulWidget {
  final String uid;
  const HitRateScreen({super.key, required this.uid});

  @override
  State<HitRateScreen> createState() => _HitRateScreenState();
}

class _HitRateScreenState extends State<HitRateScreen> {
  late Future<Map<String, int>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = ConsultationRepository().getHitRateStats(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadStats(),
      color: AppTheme.accent,
      child: FutureBuilder<Map<String, int>>(
        future: _statsFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'データの読み込みに失敗しました',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          final stats = snapshot.data ?? {'hits': 0, 'total': 0};
          final hits = stats['hits'] ?? 0;
          final total = stats['total'] ?? 0;
          final rate = total == 0 ? 0.0 : (hits / total);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 的中率メインカード ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent.withValues(alpha: 0.15),
                        AppTheme.card,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '当たった率',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(rate * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$hits / $total 件',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── プログレスバー（アニメーション付き） ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '的中状況',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 12,
                          backgroundColor:
                              AppTheme.divider.withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            rate > 0.7
                                ? AppTheme.success
                                : rate > 0.5
                                    ? AppTheme.accentGold
                                    : AppTheme.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatBadge(
                            label: '当たった',
                            count: '$hits',
                            emoji: '🎯',
                            color: AppTheme.success,
                          ),
                          _StatBadge(
                            label: '外れた',
                            count: '${total - hits}',
                            emoji: '✗',
                            color: AppTheme.error,
                          ),
                          _StatBadge(
                            label: '判定数',
                            count: '$total',
                            emoji: '📊',
                            color: AppTheme.accent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── 説明テキスト ──
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Text(
                    '💡 ヒント: 占い結果を確認した際に「当たった？」で判定すると、この的中率が更新されます。継続的に記録することで、あなたの運勢パターンが見えてきます。',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 統計バッジコンポーネント
class _StatBadge extends StatelessWidget {
  final String label;
  final String count;
  final String emoji;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
