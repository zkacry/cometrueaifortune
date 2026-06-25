import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/data/models/user_profile.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUid => _auth.currentUser?.uid;
  bool get isSignedIn => _auth.currentUser != null;

  Future<User> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(profile.toFirestore());
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final profile = UserProfile.fromFirestore(uid, doc.data()!);
    // テストビルド用: --dart-define=TEST_PLAN=free/light/pro でプランを上書き
    const testPlan = String.fromEnvironment('TEST_PLAN');
    if (testPlan.isNotEmpty) {
      final overridePlan = UserPlan.values.firstWhere(
        (p) => p.name == testPlan,
        orElse: () => profile.plan,
      );
      return profile.copyWith(plan: overridePlan);
    }
    return profile;
  }

  Future<void> incrementReadingCount(String uid) async {
    await _db.collection('users').doc(uid).update({
      'monthlyReadingCount': FieldValue.increment(1),
    });
  }

  Future<void> resetMonthlyCount(String uid, String newMonthKey) async {
    await _db.collection('users').doc(uid).update({
      'monthlyReadingCount': 0,
      'monthKey': newMonthKey,
    });
  }

  Future<void> updatePlan(
    String uid,
    UserPlan plan, {
    DateTime? expiresAt,
  }) async {
    await _db.collection('users').doc(uid).update({
      'plan': plan.name,
      if (expiresAt != null) 'subscriptionExpiresAt': expiresAt.toIso8601String(),
    });
  }

  Future<void> updateNotificationSettings(
    String uid, {
    required bool enabled,
    required int hour,
  }) async {
    await _db.collection('users').doc(uid).update({
      'notificationEnabled': enabled,
      'notificationHour': hour,
    });
  }
}
