import 'package:flutter_test/flutter_test.dart';
import 'package:myfortune/data/services/ad_service.dart';

void main() {
  group('AdService', () {
    late AdService adService;

    setUp(() {
      adService = AdService();
    });

    test('singleton pattern returns same instance', () {
      final instance1 = AdService();
      final instance2 = AdService();
      expect(identical(instance1, instance2), true);
    });

    test('bannerAd getter returns null initially', () {
      expect(adService.bannerAd, isNull);
    });

    test('disposeBannerAd clears banner ad', () async {
      adService.disposeBannerAd();
      expect(adService.bannerAd, isNull);
    });

    test('disposeAll clears all ads', () async {
      adService.disposeAll();
      expect(adService.bannerAd, isNull);
    });
  });
}
