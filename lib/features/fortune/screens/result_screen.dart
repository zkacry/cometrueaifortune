import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myfortune/core/constants/tarot_data.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/action_log.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/providers/subscription_provider.dart';
import 'package:myfortune/data/repositories/action_item_repository.dart';
import 'package:myfortune/data/services/ad_service.dart';
import 'package:myfortune/data/services/database_service.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final Consultation consultation;
  final List<TarotCard> cards;
  final List<bool> reversed;

  const ResultScreen({
    super.key,
    required this.consultation,
    required this.cards,
    required this.reversed,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  // アクションのコミット状態（チェック済み = 取り組む宣言）
  late List<bool> _committed;
  // 保存済みアクションID（重複保存防止）
  final Set<int> _savedActionIndices = {};

  // 広告関連
  final AdService _adService = AdService();
  late InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _committed = List.filled(widget.consultation.suggestedActions.length, false);
  }

  /// 広告の初期化（無料ユーザーの場合のみ広告をロード）
  Future<void> _initializeAds(bool isFreeUser) async {
    if (!mounted) return;

    if (isFreeUser) {
      // バナー広告とインタースティシャル広告をロード
      await _adService.loadBannerAd();
      _interstitialAd = await _adService.loadInterstitialAd();

      // UI更新をトリガー
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _adService.disposeBannerAd();
    if (_interstitialAd != null) {
      _adService.disposeInterstitialAd();
    }
    super.dispose();
  }

  /// 画面を閉じる（無料ユーザーの場合は広告を表示）
  Future<void> _closeScreenWithAd(bool isFreeUser) async {
    if (isFreeUser && _interstitialAd != null) {
      await _adService.showInterstitialAd();
    }
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  /// CloseボタンのonPressedハンドラ
  void _onClosePressed() {
    final subscriptionAsync = ref.watch(subscriptionProvider);
    subscriptionAsync.whenData((subscription) {
      unawaited(_closeScreenWithAd(subscription.isFreeUser));
    });
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

  /// アクションをチェックしたとき自動保存
  Future<void> _toggleAction(int index, bool checked) async {
    setState(() => _committed[index] = checked);

    if (checked && !_savedActionIndices.contains(index)) {
      _savedActionIndices.add(index);
      if (widget.consultation.id != null) {
        try {
          // 既存の action_logs に保存（後方互換）
          final db = await DatabaseService.database;
          final log = ActionLog(
            uid: widget.consultation.uid,
            consultationId: widget.consultation.id!,
            action: widget.consultation.suggestedActions[index],
            executedAt: DateTime.now(),
          );
          await db.insert('action_logs', log.toMap());

          // 新しい action_items にも保存（ステータス管理用）
          await ActionItemRepository().saveAll(
            uid: widget.consultation.uid,
            consultationId: widget.consultation.id!,
            fortuneType: widget.consultation.fortuneType.name,
            worry: widget.consultation.worry,
            actions: [widget.consultation.suggestedActions[index]],
          );
        } catch (e) {
          debugPrint('action save error: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultation = widget.consultation;
    final committedCount = _committed.where((c) => c).length;

    // 購読情報を取得
    final subscriptionAsync = ref.watch(subscriptionProvider);

    // 初回マウント時に広告を初期化
    subscriptionAsync.whenData((subscription) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAds(subscription.isFreeUser);
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('鑑定結果'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onClosePressed,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 自動保存済みバッジ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.success.withValues(alpha: 0.3)),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.check_circle_outline,
                    color: AppTheme.success, size: 14),
                SizedBox(width: 5),
                Text('記録に自動保存済み',
                    style: TextStyle(
                        color: AppTheme.success, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 16),

            // スコア
            Center(
              child: Column(children: [
                Text(
                  _scoreLabel,
                  style: TextStyle(
                    color: _scoreColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                Text(
                  '${consultation.score ?? "?"}点',
                  style: TextStyle(color: _scoreColor, fontSize: 14),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // 引いたカード（タロットのみ）
            if (widget.cards.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (i) {
                  final positions = ['過去', '現在', '未来'];
                  return Column(children: [
                    Text(positions[i],
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 11)),
                    const SizedBox(height: 4),
                    RotatedBox(
                      quarterTurns: widget.reversed[i] ? 2 : 0,
                      child: Text(widget.cards[i].emoji,
                          style: const TextStyle(fontSize: 28)),
                    ),
                    Text(
                      widget.cards[i].nameJp,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 11),
                    ),
                  ]);
                }),
              ),
              const SizedBox(height: 16),
            ],

            // 鑑定文
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                consultation.reading,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14, height: 1.9),
              ),
            ),
            const SizedBox(height: 24),

            // 推奨アクション
            if (consultation.suggestedActions.isNotEmpty) ...[
              Row(children: [
                const Text(
                  '✨ 今後のアクション候補',
                  style: TextStyle(
                      color: AppTheme.accent,
                      fontSize: 13,
                      letterSpacing: 1),
                ),
                const Spacer(),
                if (committedCount > 0)
                  Text(
                    '$committedCount件取り組む',
                    style: const TextStyle(
                        color: AppTheme.success, fontSize: 12),
                  ),
              ]),
              const SizedBox(height: 6),
              const Text(
                '取り組みたいアクションにチェックを入れると自動記録されます',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              const SizedBox(height: 10),
              ...consultation.suggestedActions.asMap().entries.map(
                    (e) => _ActionItem(
                      action: e.value,
                      committed: _committed[e.key],
                      onToggle: (v) => _toggleAction(e.key, v),
                    ),
                  ),
              const SizedBox(height: 8),
            ],

            // コミット済みの場合のメッセージ
            if (committedCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🎯 アクションリストに追加しました',
                        style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ...consultation.suggestedActions
                        .asMap()
                        .entries
                        .where((e) => _committed[e.key])
                        .map((e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2),
                              child: Text('• ${e.value}',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12)),
                            )),
                    const SizedBox(height: 6),
                    const Text(
                      '記録タブ → アクション で進捗を管理できます',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _onClosePressed,
                child: const Text('閉じる',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
          ],
        ),
            ),
          ),
          // バナー広告（無料ユーザーの場合のみ表示）
          subscriptionAsync.when(
            data: (subscription) {
              if (!subscription.isFreeUser) {
                return const SizedBox.shrink();
              }

              return Container(
                color: Colors.black87,
                padding: const EdgeInsets.all(4),
                child: SizedBox(
                  height: 50,
                  child: Center(
                    child: _adService.bannerAd != null
                        ? SizedBox(
                            width: _adService.bannerAd!.size.width.toDouble(),
                            height: _adService.bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _adService.bannerAd!),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String action;
  final bool committed;
  final ValueChanged<bool> onToggle;

  const _ActionItem({
    required this.action,
    required this.committed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!committed),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: committed
              ? AppTheme.accent.withValues(alpha: 0.08)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: committed
                ? AppTheme.accent.withValues(alpha: 0.4)
                : AppTheme.divider,
          ),
        ),
        child: Row(children: [
          Icon(
            committed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: committed ? AppTheme.accent : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                color: committed
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
