import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/services/purchase_service.dart';

class UpgradeScreen extends StatefulWidget {
  final UserProfile profile;
  final void Function(UserPlan plan)? onPlanUpdated;

  const UpgradeScreen({
    super.key,
    required this.profile,
    this.onPlanUpdated,
  });

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String? _purchasingId;
  bool _isAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await PurchaseService.isAvailable();
    if (!mounted) return;

    if (!available) {
      setState(() {
        _isAvailable = false;
        _isLoading = false;
      });
      return;
    }

    final products = await PurchaseService.loadProducts();
    if (mounted) {
      setState(() {
        _isAvailable = true;
        _products = products;
        _isLoading = false;
      });
    }
  }

  Future<void> _purchase(ProductDetails product) async {
    setState(() => _purchasingId = product.id);
    try {
      await PurchaseService.purchase(product);
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入処理に失敗しました。もう一度お試しください。')),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasingId = null);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      await PurchaseService.restorePurchases();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('購入を復元しました')),
        );
      }
    } catch (e) {
      debugPrint('Restore error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プランをアップグレード'),
        actions: [
          TextButton(
            onPressed: _restore,
            child: const Text(
              '購入を復元',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在のプラン
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                const Text('現在のプラン',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  widget.profile.plan.displayName,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // プラン比較表
            _PlanComparisonTable(currentPlan: widget.profile.plan),
            const SizedBox(height: 24),

            // 占い種類の詳細比較
            _FortuneTypeComparisonSection(),
            const SizedBox(height: 24),

            // 購入ボタン
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.accent),
                ),
              )
            else if (!_isAvailable)
              _UnavailableCard()
            else if (_products.isEmpty)
              _UnavailableCard(
                  message: '商品情報を取得できませんでした。\nGoogle Play Consoleで商品を登録してください。')
            else
              ..._products.map((product) {
                final plan = ProductIds.planFor(product.id);
                final isCurrentPlan = widget.profile.plan == plan;
                final isHigherPlan =
                    plan.index <= widget.profile.plan.index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PurchaseCard(
                    product: product,
                    plan: plan,
                    isCurrentPlan: isCurrentPlan,
                    isDisabled: isHigherPlan,
                    isPurchasing: _purchasingId == product.id,
                    onPurchase: () => _purchase(product),
                  ),
                );
              }),

            const SizedBox(height: 16),
            const Text(
              '• サブスクリプションはGoogle Playアカウントに請求されます\n'
              '• 更新日の24時間前までにキャンセルしない限り自動更新されます\n'
              '• 購入後すぐにプレミアム機能が利用可能になります',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ウィジェット群 ──────────────────────────────────

class _PlanComparisonTable extends StatelessWidget {
  final UserPlan currentPlan;
  const _PlanComparisonTable({required this.currentPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _HeaderRow(),
          const Divider(color: AppTheme.divider, height: 1),
          _FeatureRow('毎日の運勢', true, true, true),
          _FeatureRow('フル占い（月）', '初月10回\n以降3回', '50回', '300回'),
          _FeatureRow('AIペルソナ', false, true, true),
          _FeatureRow('占いパターン分析', false, true, true),
          _FeatureRow('月間レポート（AI）', false, false, true),
          _FeatureRow('月額料金', '無料', '¥680', '¥1,500'),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(children: [
        const Expanded(child: SizedBox()),
        _PlanHeader('Free', AppTheme.freePlan),
        _PlanHeader('Light', AppTheme.lightPlan),
        _PlanHeader('Pro', AppTheme.proPlan),
      ]),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _PlanHeader(this.label, this.color);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 60,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
}

class _FeatureRow extends StatelessWidget {
  final String feature;
  final dynamic free;
  final dynamic light;
  final dynamic pro;

  const _FeatureRow(this.feature, this.free, this.light, this.pro);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Expanded(
          child: Text(feature,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12)),
        ),
        _Cell(free, AppTheme.freePlan),
        _Cell(light, AppTheme.lightPlan),
        _Cell(pro, AppTheme.proPlan),
      ]),
    );
  }
}

class _Cell extends StatelessWidget {
  final dynamic value;
  final Color color;
  const _Cell(this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Center(
        child: value is bool
            ? Icon(
                value ? Icons.check_circle : Icons.remove,
                color: value ? color : AppTheme.divider,
                size: 16,
              )
            : Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 11),
              ),
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  // TODO: in_app_purchase disabled
  // final ProductDetails product;
  final dynamic product;
  final UserPlan plan;
  final bool isCurrentPlan;
  final bool isDisabled;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  const _PurchaseCard({
    required this.product,
    required this.plan,
    required this.isCurrentPlan,
    required this.isDisabled,
    required this.isPurchasing,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        plan == UserPlan.pro ? AppTheme.proPlan : AppTheme.lightPlan;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isCurrentPlan ? 0.3 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.card,
              AppTheme.card.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPlan ? color : color.withValues(alpha: 0.3),
            width: isCurrentPlan ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  plan.displayName,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (isCurrentPlan) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color, width: 1),
                    ),
                    child: Text(
                      '✓ 現在',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            // TODO: in_app_purchase disabled
            /*
            Row(
              baseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ 月',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            */
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  'N/A',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '/ 月',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isDisabled)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPurchasing ? null : onPurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isPurchasing
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          isCurrentPlan ? '現在のプラン' : '今すぐ購入',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'アップグレード不可',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableCard extends StatelessWidget {
  final String message;
  const _UnavailableCard(
      {this.message = '現在この端末ではアプリ内購入を利用できません。\nGoogle Playストアにサインインしているか確認してください。'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        const Text('🛒', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 13, height: 1.6),
        ),
      ]),
    );
  }
}

// ── 占い種類の比較セクション ──────────────────────────
class _FortuneTypeComparisonSection extends StatelessWidget {
  const _FortuneTypeComparisonSection();

  @override
  Widget build(BuildContext context) {
    // 各プランで利用可能な占い種類をフィルタリング
    final allTypes = FortuneType.values.where((t) => !t.isHidden).toList();
    final freeTypes = allTypes.where((t) => t.requiredPlan == UserPlan.free).toList();
    final lightTypes = allTypes.where((t) => t.requiredPlan.index <= UserPlan.light.index).toList();
    final proTypes = allTypes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '利用できる占い種類',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _FortuneTypeList('Free', freeTypes, AppTheme.freePlan),
          const SizedBox(height: 12),
          _FortuneTypeList('Light', lightTypes, AppTheme.lightPlan),
          const SizedBox(height: 12),
          _FortuneTypeList('Pro', proTypes, AppTheme.proPlan),
        ],
      ),
    );
  }
}

class _FortuneTypeList extends StatelessWidget {
  final String planName;
  final List<FortuneType> types;
  final Color color;

  const _FortuneTypeList(this.planName, this.types, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          planName,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: types.map((type) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${type.emoji} ${type.displayName}',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
