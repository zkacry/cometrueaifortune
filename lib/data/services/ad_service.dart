import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob広告管理サービス
/// 無料プランユーザーにバナー広告と全画面広告を表示
class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  // Google AdMob App ID
  static const String _admobAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy';

  // バナー広告ユニットID（テスト用）
  // 実本番時は実際のユニットIDに置き換え
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // テスト用

  // インタースティシャル広告ユニットID（テスト用）
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // テスト用

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  bool _isAdInitialized = false;

  /// AdMobの初期化
  Future<void> initialize() async {
    if (_isAdInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isAdInitialized = true;
      debugPrint('[AdService] AdMob initialized successfully');
    } catch (e) {
      debugPrint('[AdService] Failed to initialize AdMob: $e');
    }
  }

  /// バナー広告を読み込む
  Future<BannerAd?> loadBannerAd() async {
    if (!_isAdInitialized) {
      await initialize();
    }

    try {
      final bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('[AdService] Banner ad loaded');
            _bannerAd = ad as BannerAd;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('[AdService] Banner ad failed to load: $error');
            ad.dispose();
          },
          onAdOpened: (ad) {
            debugPrint('[AdService] Banner ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('[AdService] Banner ad closed');
          },
          onAdImpression: (ad) {
            debugPrint('[AdService] Banner ad impression');
          },
          onAdClicked: (ad) {
            debugPrint('[AdService] Banner ad clicked');
          },
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      debugPrint('[AdService] Error loading banner ad: $e');
      return null;
    }
  }

  /// インタースティシャル広告を読み込む
  Future<InterstitialAd?> loadInterstitialAd() async {
    if (!_isAdInitialized) {
      await initialize();
    }

    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[AdService] Interstitial ad loaded');
            _interstitialAd = ad;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[AdService] Interstitial ad failed to load: $error');
          },
        ),
      );

      return _interstitialAd;
    } catch (e) {
      debugPrint('[AdService] Error loading interstitial ad: $e');
      return null;
    }
  }

  /// インタースティシャル広告を表示
  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      debugPrint('[AdService] Interstitial ad not loaded');
      return;
    }

    try {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('[AdService] Interstitial ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('[AdService] Interstitial ad dismissed');
          ad.dispose();
          _interstitialAd = null;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('[AdService] Interstitial ad failed to show: $error');
          ad.dispose();
          _interstitialAd = null;
        },
        onAdImpression: (ad) {
          debugPrint('[AdService] Interstitial ad impression');
        },
        onAdClicked: (ad) {
          debugPrint('[AdService] Interstitial ad clicked');
        },
      );

      await _interstitialAd?.show();
    } catch (e) {
      debugPrint('[AdService] Error showing interstitial ad: $e');
    }
  }

  /// バナー広告を取得
  BannerAd? get bannerAd => _bannerAd;

  /// バナー広告を破棄
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  /// インタースティシャル広告を破棄
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }

  /// すべての広告をクリア
  void disposeAll() {
    disposeBannerAd();
    disposeInterstitialAd();
  }
}
