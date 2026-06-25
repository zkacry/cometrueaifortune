class FeatureRequest {
  final String? id;
  final String userId;
  final String category;
  final String title;
  final String description;
  final String useCase;
  final List<String> targetPlan;
  final int votes;
  final List<String> voters;
  final String status;
  final DateTime createdAt;
  final String? developerComment;
  final String? plannedVersion;
  final DateTime? updatedAt;

  const FeatureRequest({
    this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.description,
    this.useCase = '',
    this.targetPlan = const [],
    this.votes = 0,
    this.voters = const [],
    this.status = 'new',
    required this.createdAt,
    this.developerComment,
    this.plannedVersion,
    this.updatedAt,
  });

  bool hasVoted(String uid) => voters.contains(uid);

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'category': category,
        'title': title,
        'description': description,
        'useCase': useCase,
        'targetPlan': targetPlan,
        'votes': votes,
        'voters': voters,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'developerComment': developerComment,
        'plannedVersion': plannedVersion,
        'updatedAt': (updatedAt ?? createdAt).toIso8601String(),
      };

  factory FeatureRequest.fromFirestore(
          String id, Map<String, dynamic> data) =>
      FeatureRequest(
        id: id,
        userId: data['userId'] ?? '',
        category: data['category'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        useCase: data['useCase'] ?? '',
        targetPlan: List<String>.from(data['targetPlan'] ?? []),
        votes: data['votes'] ?? 0,
        voters: List<String>.from(data['voters'] ?? []),
        status: data['status'] ?? 'new',
        createdAt: DateTime.parse(data['createdAt']),
        developerComment: data['developerComment'],
        plannedVersion: data['plannedVersion'],
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'])
            : null,
      );

  String get statusLabel {
    switch (status) {
      case 'new':
        return '受付中';
      case 'under_review':
        return '検討中';
      case 'backlog':
        return 'バックログ';
      case 'planned':
        return '実装予定';
      case 'shipped':
        return '実装完了';
      default:
        return status;
    }
  }

  String get statusEmoji {
    switch (status) {
      case 'new':
        return '🔴';
      case 'under_review':
        return '🟡';
      case 'backlog':
        return '🟠';
      case 'planned':
        return '🟢';
      case 'shipped':
        return '🟦';
      default:
        return '⚪';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'new_feature':
        return '新機能の追加';
      case 'improvement':
        return '既存機能の改善';
      case 'ui':
        return 'UI/UXの改善';
      case 'performance':
        return 'パフォーマンス向上';
      default:
        return 'その他';
    }
  }
}
