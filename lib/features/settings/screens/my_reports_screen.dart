import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/bug_report.dart';
import 'package:myfortune/data/models/feature_request.dart';
import 'package:myfortune/data/repositories/feedback_repository.dart';

class MyReportsScreen extends StatefulWidget {
  final String userId;
  const MyReportsScreen({super.key, required this.userId});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  List<BugReport> _bugs = [];
  List<FeatureRequest> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = FeedbackRepository();
      final bugs = await repo.getMyBugReports(widget.userId);
      final reqs = await repo.getMyFeatureRequests(widget.userId);
      if (mounted) {
        setState(() {
          _bugs = bugs;
          _requests = reqs;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 過去の報告・要望'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'バグ報告'),
            Tab(text: '改善要望'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.accent, strokeWidth: 2))
          : TabBarView(
              controller: _tab,
              children: [
                _BugList(bugs: _bugs),
                _RequestList(requests: _requests),
              ],
            ),
    );
  }
}

// ── Bug list ────────────────────────────────────────────

class _BugList extends StatelessWidget {
  final List<BugReport> bugs;
  const _BugList({required this.bugs});

  @override
  Widget build(BuildContext context) {
    if (bugs.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('🐛', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('バグ報告はまだありません',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {},
      color: AppTheme.accent,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bugs.length,
        itemBuilder: (_, i) => _BugCard(bug: bugs[i]),
      ),
    );
  }
}

class _BugCard extends StatelessWidget {
  final BugReport bug;
  const _BugCard({required this.bug});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(
              '${bug.statusEmoji} ${bug.statusLabel}',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              '${bug.createdAt.year}/${bug.createdAt.month}/${bug.createdAt.day}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
            ),
          ]),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.divider.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              bug.categoryLabel,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bug.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          if (bug.developerComment != null) ...[
            const SizedBox(height: 10),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💬 ',
                  style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(
                  bug.developerComment!,
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 12, height: 1.5),
                ),
              ),
            ]),
          ],
          if (bug.id != null) ...[
            const SizedBox(height: 6),
            Text(
              'ID: ${bug.id!.substring(0, 8).toUpperCase()}',
              style: const TextStyle(
                  color: AppTheme.divider, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Feature request list ──────────────────────────────

class _RequestList extends StatelessWidget {
  final List<FeatureRequest> requests;
  const _RequestList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('💡', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('改善要望はまだありません',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (_, i) => _RequestCard(request: requests[i]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final FeatureRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                request.title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            Row(children: [
              const Icon(Icons.star, size: 13, color: AppTheme.accentGold),
              const SizedBox(width: 3),
              Text('${request.votes}',
                  style: const TextStyle(
                      color: AppTheme.accentGold, fontSize: 12)),
            ]),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Text(
              '${request.statusEmoji} ${request.statusLabel}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(request.categoryLabel,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 10)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            request.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12, height: 1.5),
          ),
          if (request.developerComment != null) ...[
            const SizedBox(height: 10),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 8),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💬 ', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Text(
                  request.developerComment!,
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 12, height: 1.5),
                ),
              ),
            ]),
          ],
          if (request.plannedVersion != null) ...[
            const SizedBox(height: 6),
            Text('📅 ${request.plannedVersion}で実装予定',
                style: const TextStyle(
                    color: AppTheme.accentGold, fontSize: 11)),
          ],
          if (request.id != null) ...[
            const SizedBox(height: 6),
            Text('ID: ${request.id!.substring(0, 8).toUpperCase()}',
                style: const TextStyle(
                    color: AppTheme.divider, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}
