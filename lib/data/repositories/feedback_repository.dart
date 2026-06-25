import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfortune/data/models/bug_report.dart';
import 'package:myfortune/data/models/feature_request.dart';

class FeedbackRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference get _bugs => _db.collection('bugReports');
  CollectionReference get _requests => _db.collection('featureRequests');

  // ── Bug Reports ─────────────────────────────────────

  Future<String> submitBugReport(BugReport report) async {
    final doc = await _bugs.add(report.toFirestore());
    return doc.id;
  }

  Future<List<BugReport>> getMyBugReports(String userId) async {
    final snap = await _bugs
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs
        .map((d) =>
            BugReport.fromFirestore(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  // ── Feature Requests ────────────────────────────────

  Future<String> submitFeatureRequest(FeatureRequest request) async {
    final doc = await _requests.add(request.toFirestore());
    return doc.id;
  }

  Future<List<FeatureRequest>> getMyFeatureRequests(String userId) async {
    final snap = await _requests
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
    return snap.docs
        .map((d) => FeatureRequest.fromFirestore(
            d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeatureRequest>> getTopFeatureRequests({int limit = 20}) async {
    final snap = await _requests
        .orderBy('votes', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => FeatureRequest.fromFirestore(
            d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> voteFeatureRequest(String requestId, String userId) async {
    final ref = _requests.doc(requestId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final voters = List<String>.from(data['voters'] ?? []);
      if (voters.contains(userId)) return; // already voted
      voters.add(userId);
      tx.update(ref, {
        'votes': (data['votes'] ?? 0) + 1,
        'voters': voters,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> unvoteFeatureRequest(String requestId, String userId) async {
    final ref = _requests.doc(requestId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final voters = List<String>.from(data['voters'] ?? []);
      if (!voters.contains(userId)) return;
      voters.remove(userId);
      tx.update(ref, {
        'votes': ((data['votes'] ?? 1) - 1).clamp(0, 999999),
        'voters': voters,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }
}
