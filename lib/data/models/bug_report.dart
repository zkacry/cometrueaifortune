class BugReport {
  final String? id;
  final String userId;
  final String category;
  final String description;
  final String steps;
  final String priority;
  final String status;
  final DateTime createdAt;
  final String? developerComment;
  final DateTime? updatedAt;

  const BugReport({
    this.id,
    required this.userId,
    required this.category,
    required this.description,
    this.steps = '',
    required this.priority,
    this.status = 'open',
    required this.createdAt,
    this.developerComment,
    this.updatedAt,
  });

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'category': category,
        'description': description,
        'steps': steps,
        'priority': priority,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'developerComment': developerComment,
        'updatedAt': (updatedAt ?? createdAt).toIso8601String(),
      };

  factory BugReport.fromFirestore(String id, Map<String, dynamic> data) =>
      BugReport(
        id: id,
        userId: data['userId'] ?? '',
        category: data['category'] ?? '',
        description: data['description'] ?? '',
        steps: data['steps'] ?? '',
        priority: data['priority'] ?? 'medium',
        status: data['status'] ?? 'open',
        createdAt: DateTime.parse(data['createdAt']),
        developerComment: data['developerComment'],
        updatedAt: data['updatedAt'] != null
            ? DateTime.parse(data['updatedAt'])
            : null,
      );

  String get statusLabel {
    switch (status) {
      case 'open':
        return '受付中';
      case 'investigating':
        return '調査中';
      case 'in_progress':
        return '修正中';
      case 'resolved':
        return '解決済み';
      default:
        return status;
    }
  }

  String get statusEmoji {
    switch (status) {
      case 'open':
        return '🔴';
      case 'investigating':
        return '🟡';
      case 'in_progress':
        return '🔵';
      case 'resolved':
        return '🟢';
      default:
        return '⚪';
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'display':
        return '占い結果が表示されない';
      case 'crash':
        return 'アプリがクラッシュ';
      case 'calculation':
        return '計算が間違っている';
      case 'navigation':
        return '画面遷移がおかしい';
      default:
        return 'その他';
    }
  }
}
