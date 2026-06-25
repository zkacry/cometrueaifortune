import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/user_repository.dart';

/// Google Play / App Store 商品ID
class ProductIds {
  static const lightMonthly = 'myfortune_light_monthly';
  static const proMonthly = 'myfortune_pro_monthly';

  static const all = {lightMonthly, proMonthly};

  static UserPlan planFor(String productId) {
    if (productId == proMonthly) return UserPlan.pro;
    if (productId == lightMonthly) return UserPlan.light;
    return UserPlan.free;
  }
}

class PurchaseService {
  static final _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// 利用可能かチェック
  static Future<bool> isAvailable() => _iap.isAvailable();

  /// 課金リスナーを初期化（main.dart で呼び出す）
  static void initialize({
    required String uid,
    required void Function(UserPlan plan) onPlanUpdated,
  }) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        await _handlePurchase(purchase, uid: uid, onPlanUpdated: onPlanUpdated);
      }
    });
  }

  /// リスナーを解放
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// 商品情報を取得
  static Future<List<ProductDetails>> loadProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return [];

    final response = await _iap.queryProductDetails(ProductIds.all);
    if (response.error != null) {
      debugPrint('Product query error: ${response.error}');
      return [];
    }

    final products = response.productDetails;
    products.sort((a, b) {
      final order = [ProductIds.lightMonthly, ProductIds.proMonthly];
      return order.indexOf(a.id).compareTo(order.indexOf(b.id));
    });
    return products;
  }

  /// 購入を開始
  static Future<void> purchase(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// 購入を復元（機種変更時など）
  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// 有効なサブスクリプションを確認
  static Future<UserPlan> getActivePlan(String uid) async {
    try {
      final profile = await UserRepository().getProfile(uid);
      if (profile.plan == UserPlan.free) {
        return UserPlan.free;
      }
      // 購読期限をチェック
      if (profile.subscriptionExpiresAt != null &&
          profile.subscriptionExpiresAt!.isBefore(DateTime.now())) {
        await UserRepository().updatePlan(uid, UserPlan.free);
        return UserPlan.free;
      }
      return profile.plan;
    } catch (e) {
      debugPrint('Get active plan error: $e');
      return UserPlan.free;
    }
  }

  /// 購入処理
  static Future<void> _handlePurchase(
    PurchaseDetails purchase, {
    required String uid,
    required void Function(UserPlan plan) onPlanUpdated,
  }) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      final plan = ProductIds.planFor(purchase.productID);
      try {
        // 購読期限を計算（今から30日後）
        final expiresAt = DateTime.now().add(const Duration(days: 30));

        // Firestore のプランを更新
        await UserRepository().updatePlan(uid, plan, expiresAt: expiresAt);
        onPlanUpdated(plan);

        debugPrint('✓ Plan updated: ${plan.name} (expires: $expiresAt)');
      } catch (e) {
        debugPrint('❌ Plan update error: $e');
      }

      // 購入を完了としてマーク
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    } else if (purchase.status == PurchaseStatus.pending) {
      debugPrint('⏳ Purchase pending: ${purchase.productID}');
    } else if (purchase.status == PurchaseStatus.error) {
      debugPrint('❌ Purchase error: ${purchase.error}');
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }
}
