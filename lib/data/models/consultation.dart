import 'package:myfortune/core/constants/fortune_config.dart';

class Consultation {
  final int? id; // SQLite ID
  final String uid;
  final DateTime createdAt;
  final String worry;
  final FortuneType fortuneType;
  final List<String> cards;
  final List<bool> cardReversed;
  final String reading;
  final int? score; // 吉凶スコア 0-100
  final List<String> suggestedActions;
  final String? decision; // ユーザーが記録した決断
  final bool? wasTrueJudgement; // null=未判定, true=当たった, false=外れた
  final bool synced; // Firestoreと同期済み

  Consultation({
    this.id,
    required this.uid,
    required this.createdAt,
    required this.worry,
    required this.fortuneType,
    required this.reading,
    this.cards = const [],
    this.cardReversed = const [],
    this.score,
    this.suggestedActions = const [],
    this.decision,
    this.wasTrueJudgement,
    this.synced = false,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'worry': worry,
        'fortuneType': fortuneType.name,
        'cards': cards.join(','),
        'cardReversed': cardReversed.map((b) => b ? '1' : '0').join(','),
        'reading': reading,
        'score': score,
        'suggestedActions': suggestedActions.join('|'),
        'decision': decision,
        'wasTrueJudgement': wasTrueJudgement == null ? null : (wasTrueJudgement! ? 1 : 0),
        'synced': synced ? 1 : 0,
      };

  factory Consultation.fromMap(Map<String, dynamic> map) {
    final cardsStr = map['cards'] as String? ?? '';
    final reversedStr = map['cardReversed'] as String? ?? '';
    final actionsStr = map['suggestedActions'] as String? ?? '';
    final wasTrueJudgement = map['wasTrueJudgement'] as int?;
    return Consultation(
      id: map['id'] as int?,
      uid: map['uid'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['createdAt'] as int),
      worry: map['worry'] as String,
      fortuneType: FortuneType.values.firstWhere(
        (t) => t.name == map['fortuneType'],
        orElse: () => FortuneType.tarot,
      ),
      cards: cardsStr.isEmpty ? [] : cardsStr.split(','),
      cardReversed: reversedStr.isEmpty
          ? []
          : reversedStr.split(',').map((s) => s == '1').toList(),
      reading: map['reading'] as String,
      score: map['score'] as int?,
      suggestedActions: actionsStr.isEmpty ? [] : actionsStr.split('|'),
      decision: map['decision'] as String?,
      wasTrueJudgement: wasTrueJudgement == null ? null : wasTrueJudgement == 1,
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }

  Consultation copyWith({
    String? decision,
    bool? wasTrueJudgement,
  }) => Consultation(
        id: id,
        uid: uid,
        createdAt: createdAt,
        worry: worry,
        fortuneType: fortuneType,
        cards: cards,
        cardReversed: cardReversed,
        reading: reading,
        score: score,
        suggestedActions: suggestedActions,
        decision: decision ?? this.decision,
        wasTrueJudgement: wasTrueJudgement ?? this.wasTrueJudgement,
        synced: synced,
      );
}
