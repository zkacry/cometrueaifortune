import 'package:flutter_test/flutter_test.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/providers/subscription_provider.dart';

// UserProfile を作成するためのヘルパー
UserProfile createTestUserProfile({
  String uid = 'test-uid',
  UserPlan plan = UserPlan.free,
}) {
  return UserProfile(
    uid: uid,
    nickname: 'Test User',
    birthdate: DateTime(1990, 1, 1),
    plan: plan,
  );
}

void main() {
  group('SubscriptionInfo', () {
    test('free プランの SubscriptionInfo を作成できる', () {
      final info = SubscriptionInfo(
        plan: UserPlan.free,
        isFreeUser: true,
        isLightUser: false,
        isProUser: false,
      );

      expect(info.isFreeUser, true);
      expect(info.isLightUser, false);
      expect(info.isProUser, false);
      expect(info.plan, UserPlan.free);
      expect(info.planName, 'Free');
      expect(info.monthlyReadingLimit, 10);
    });

    test('light プランの SubscriptionInfo を作成できる', () {
      final info = SubscriptionInfo(
        plan: UserPlan.light,
        isFreeUser: false,
        isLightUser: true,
        isProUser: false,
      );

      expect(info.isFreeUser, false);
      expect(info.isLightUser, true);
      expect(info.isProUser, false);
      expect(info.plan, UserPlan.light);
      expect(info.planName, 'Light');
      expect(info.monthlyReadingLimit, 50);
    });

    test('pro プランの SubscriptionInfo を作成できる', () {
      final info = SubscriptionInfo(
        plan: UserPlan.pro,
        isFreeUser: false,
        isLightUser: false,
        isProUser: true,
      );

      expect(info.isFreeUser, false);
      expect(info.isLightUser, false);
      expect(info.isProUser, true);
      expect(info.plan, UserPlan.pro);
      expect(info.planName, 'Pro');
      expect(info.monthlyReadingLimit, 300);
    });
  });

  group('UserProfile plan detection', () {
    test('UserProfile から plan を正しく取得できる', () {
      final freeProfile = createTestUserProfile(plan: UserPlan.free);
      final lightProfile = createTestUserProfile(plan: UserPlan.light);
      final proProfile = createTestUserProfile(plan: UserPlan.pro);

      expect(freeProfile.plan, UserPlan.free);
      expect(lightProfile.plan, UserPlan.light);
      expect(proProfile.plan, UserPlan.pro);
    });

    test('デフォルトプランは free', () {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'Test User',
        birthdate: DateTime(1990, 1, 1),
      );

      expect(profile.plan, UserPlan.free);
    });
  });
}
