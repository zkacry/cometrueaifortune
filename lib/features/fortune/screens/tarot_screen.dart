import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/constants/tarot_data.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/consultation_repository.dart';
import 'package:myfortune/data/repositories/user_repository.dart';
import 'package:myfortune/data/services/claude_service.dart';
import 'package:myfortune/data/services/fortune_summary_service.dart';
import 'package:myfortune/data/services/usage_service.dart';
import 'package:myfortune/features/fortune/screens/result_screen.dart';

class TarotScreen extends StatefulWidget {
  final UserProfile profile;
  final List<Consultation> recentConsultations;

  const TarotScreen({
    super.key,
    required this.profile,
    required this.recentConsultations,
  });

  @override
  State<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends State<TarotScreen> {
  final _worryController = TextEditingController();
  _Step _step = _Step.input;
  List<TarotCard>? _drawnCards;
  List<bool>? _reversed;

  @override
  void dispose() {
    _worryController.dispose();
    super.dispose();
  }

  void _drawCards() {
    if (_worryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('悩みを入力してください')));
      return;
    }
    final rng = Random();
    final indices = <int>[];
    while (indices.length < 3) {
      final i = rng.nextInt(majorArcana.length);
      if (!indices.contains(i)) indices.add(i);
    }
    setState(() {
      _drawnCards = indices.map((i) => majorArcana[i]).toList();
      _reversed = List.generate(3, (_) => rng.nextBool());
      _step = _Step.cards;
    });
  }

  Future<void> _getReading() async {
    setState(() => _step = _Step.loading);

    try {
      // 過去サマリーを取得（リソース消費を抑えたコンテキスト）
      final summary = await FortuneSummaryService.getSummaryForPrompt(
        widget.profile.uid,
        widget.recentConsultations,
      );

      final result = await ClaudeService().generateTarotReading(
        profile: widget.profile,
        worry: _worryController.text.trim(),
        cards: _drawnCards!,
        reversed: _reversed!,
        recentConsultations: widget.recentConsultations,
        fortuneSummary: summary,
      );

      // SQLiteに保存
      final consultation = Consultation(
        uid: widget.profile.uid,
        createdAt: DateTime.now(),
        worry: _worryController.text.trim(),
        fortuneType: FortuneType.tarot,
        cards: _drawnCards!.map((c) => c.nameJp).toList(),
        cardReversed: _reversed!,
        reading: result.reading,
        score: result.score,
        suggestedActions: result.suggestedActions,
      );
      final id = await ConsultationRepository().save(consultation);

      // DB保存成功後に初めて利用回数を増やす（SharedPreferences + Firestore 両方）
      await UsageService.increment();
      await UserRepository().incrementReadingCount(widget.profile.uid);

      if (mounted) {
        final nav = Navigator.of(context);
        final v = await nav.push(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              consultation: Consultation(
                id: id,
                uid: consultation.uid,
                createdAt: consultation.createdAt,
                worry: consultation.worry,
                fortuneType: consultation.fortuneType,
                cards: consultation.cards,
                cardReversed: consultation.cardReversed,
                reading: result.reading,
                score: result.score,
                suggestedActions: result.suggestedActions,
              ),
              cards: _drawnCards!,
              reversed: _reversed!,
            ),
          ),
        );
        if (mounted) nav.pop(v);
      }
    } catch (e) {
      debugPrint('TarotReading error: $e');
      setState(() => _step = _Step.cards);
      if (mounted) {
        String errorMessage = '鑑定中にエラーが発生しました。もう一度お試しください。';
        if (e.toString().contains('Web') || e.toString().contains('CORS')) {
          errorMessage = 'Androidアプリをご使用ください';
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage = 'APIの認証に失敗しました。設定を確認してください。';
        } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          errorMessage = '接続がタイムアウトしました。ネットワークを確認してください。';
        } else if (e.toString().contains('No internet') || e.toString().contains('Connection')) {
          errorMessage = 'インターネット接続を確認してください。';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タロット占い'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: switch (_step) {
        _Step.input => _InputStep(
            controller: _worryController, onNext: _drawCards),
        _Step.cards => _CardsStep(
            cards: _drawnCards!,
            reversed: _reversed!,
            onGetReading: _getReading),
        _Step.loading => const _LoadingStep(),
      },
    );
  }
}

enum _Step { input, cards, loading }

// ── 悩みカテゴリ定義 ──────────────────────────────
const _worryCategories = [
  ('💕 恋愛・パートナー', '恋愛・パートナー'),
  ('💼 仕事・キャリア', '仕事・キャリア'),
  ('👥 人間関係', '人間関係'),
  ('💰 お金・将来', 'お金・将来'),
  ('🏠 家族', '家族'),
  ('🌿 健康・メンタル', '健康・メンタル'),
  ('🌟 進路・転換期', '進路・転換期'),
  ('✏️ その他', '__other__'),
];

// ── 悩み入力 ────────────────────────────────────────
class _InputStep extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _InputStep({required this.controller, required this.onNext});

  @override
  State<_InputStep> createState() => _InputStepState();
}

class _InputStepState extends State<_InputStep> {
  String? _selectedCategory;

  void _selectCategory(String value) {
    setState(() => _selectedCategory = value);
    if (value != '__other__') {
      widget.controller.text = value;
    } else {
      widget.controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showFreeText = _selectedCategory == '__other__';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今、何が気になっていますか？',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 6),
          const Text(
            'テーマを選んでカードを引いてください。',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          // カテゴリグリッド
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _worryCategories.map((cat) {
              final isSelected = _selectedCategory == cat.$2;
              return GestureDetector(
                onTap: () => _selectCategory(cat.$2),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.accent.withValues(alpha: 0.15)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.accent
                          : AppTheme.divider,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    cat.$1,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          // その他：自由記入
          if (showFreeText) ...[
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(
                  color: AppTheme.textPrimary, height: 1.8),
              decoration: const InputDecoration(
                hintText: '気になっていることを教えてください…',
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCategory == null ? null : widget.onNext,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18)),
              child: const Text('カードを引く 🃏',
                  style: TextStyle(
                      fontSize: 16, letterSpacing: 2, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── カード表示 ──────────────────────────────────────
class _CardsStep extends StatefulWidget {
  final List<TarotCard> cards;
  final List<bool> reversed;
  final VoidCallback onGetReading;

  const _CardsStep({
    required this.cards,
    required this.reversed,
    required this.onGetReading,
  });

  @override
  State<_CardsStep> createState() => _CardsStepState();
}

class _CardsStepState extends State<_CardsStep>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _rotateAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .asMap()
        .entries
        .map((e) {
          final controller = e.value;
          final delay = (e.key * 200) / 600;
          return Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(delay, 1, curve: Curves.elasticOut),
            ),
          );
        })
        .toList();

    _rotateAnimations = _controllers
        .asMap()
        .entries
        .map((e) {
          final controller = e.value;
          final delay = (e.key * 200) / 600;
          return Tween<double>(begin: -0.1, end: 0).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(delay, 1, curve: Curves.easeOutCubic),
            ),
          );
        })
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var controller in _controllers) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final positions = ['過去', '現在', '未来'];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '3枚のカードが出ました',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: Listenable.merge([
                  _scaleAnimations[i],
                  _rotateAnimations[i],
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[i].value,
                    child: Transform.rotate(
                      angle: _rotateAnimations[i].value,
                      child: Column(children: [
                        Text(positions[i],
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(height: 8),
                        Container(
                          width: 90,
                          height: 140,
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.accent.withValues(alpha: 0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent
                                    .withValues(alpha: 0.2 * _scaleAnimations[i].value),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RotatedBox(
                                quarterTurns: widget.reversed[i] ? 2 : 0,
                                child: Text(widget.cards[i].emoji,
                                    style: const TextStyle(fontSize: 32)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.cards[i].nameJp,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                widget.reversed[i] ? '逆位置' : '正位置',
                                style: TextStyle(
                                  color: widget.reversed[i]
                                      ? Colors.orange.shade300
                                      : AppTheme.accent,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              );
            }),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onGetReading,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18)),
              child: const Text('鑑定してもらう ✨',
                  style: TextStyle(fontSize: 16, letterSpacing: 2, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingStep extends StatefulWidget {
  const _LoadingStep();

  @override
  State<_LoadingStep> createState() => _LoadingStepState();
}

class _LoadingStepState extends State<_LoadingStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedBuilder(
          animation: _rotation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotation.value * 2 * pi,
              child: const Text('🔮', style: TextStyle(fontSize: 56)),
            );
          },
        ),
        const SizedBox(height: 24),
        const CircularProgressIndicator(
            color: AppTheme.accent, strokeWidth: 2),
        const SizedBox(height: 24),
        const Text('カードが語りかけています…',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                letterSpacing: 1)),
      ]),
    );
  }
}
