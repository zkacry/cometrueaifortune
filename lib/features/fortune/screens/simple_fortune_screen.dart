import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/locale/locale_controller.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/repositories/consultation_repository.dart';
import 'package:myfortune/data/repositories/user_repository.dart';
import 'package:myfortune/data/services/claude_service.dart';
import 'package:myfortune/data/services/fortune_summary_service.dart';
import 'package:myfortune/data/services/usage_service.dart';
import 'package:myfortune/features/fortune/screens/result_screen.dart';
import 'package:myfortune/l10n/app_localizations.dart';

/// タロット・数秘術・相性以外の汎用フル占い画面
class SimpleFortuneScreen extends StatefulWidget {
  final FortuneType type;
  final UserProfile profile;
  final List<Consultation> recentConsultations;

  const SimpleFortuneScreen({
    super.key,
    required this.type,
    required this.profile,
    required this.recentConsultations,
  });

  @override
  State<SimpleFortuneScreen> createState() => _SimpleFortuneScreenState();
}

class _SimpleFortuneScreenState extends State<SimpleFortuneScreen> {
  final _inputController = TextEditingController();
  final _extraController = TextEditingController(); // 四柱推命の出生時刻など
  bool _loading = false;

  // 血液型選択
  String? _selectedBloodType;
  static const _bloodTypes = ['A', 'B', 'O', 'AB'];

  // 悩みカテゴリ（夢・ルーン・ホロスコープ共通）
  String? _selectedCategory;
  List<(String, String)> _categories(AppLocalizations t) => [
        (t.worryCategoryLove, t.worryCategoryLove),
        (t.worryCategoryWork, t.worryCategoryWork),
        (t.worryCategoryRelationship, t.worryCategoryRelationship),
        (t.worryCategoryMoney, t.worryCategoryMoney),
        (t.worryCategoryHealth, t.worryCategoryHealth),
        (t.worryCategoryPath, t.worryCategoryPath),
        (t.worryCategoryOther, '__other__'),
      ];

  @override
  void dispose() {
    _inputController.dispose();
    _extraController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    switch (widget.type) {
      case FortuneType.bloodType:
        return _selectedBloodType != null;
      case FortuneType.dream:
        return _inputController.text.trim().isNotEmpty;
      case FortuneType.pastLife:
      case FortuneType.auspiciousCalendar:
      case FortuneType.fourPillars:
        return true; // 生年月日だけで完結（出生時刻は任意）
      default:
        return _selectedCategory != null &&
            (_selectedCategory != '__other__' ||
                _inputController.text.trim().isNotEmpty);
    }
  }

  String get _inputValue {
    switch (widget.type) {
      case FortuneType.bloodType:
        return _selectedBloodType ?? '';
      case FortuneType.pastLife:
      case FortuneType.auspiciousCalendar:
        return AppLocalizations.of(context)!.simpleAutoProfileReading;
      default:
        return _selectedCategory == '__other__'
            ? _inputController.text.trim()
            : _selectedCategory ?? '';
    }
  }

  Future<void> _getReading() async {
    setState(() => _loading = true);
    try {
      debugPrint('[Reading] 占いを開始: ${widget.type.displayName}');

      final summary = await FortuneSummaryService.getSummaryForPrompt(
        widget.profile.uid,
        widget.recentConsultations,
      );
      debugPrint('[Reading] サマリー取得完了');

      final result = await ClaudeService().generateSimpleReading(
        profile: widget.profile,
        type: widget.type,
        input: _inputValue,
        recentConsultations: widget.recentConsultations,
        fortuneSummary: summary,
        extraContext: widget.type == FortuneType.fourPillars
            ? _extraController.text.trim()
            : null,
        languageCode: LocaleController.instance.locale.value.languageCode,
      );
      debugPrint('[Reading] AI占い完了: score=${result.score}');

      final consultation = Consultation(
        uid: widget.profile.uid,
        createdAt: DateTime.now(),
        worry: _inputValue,
        fortuneType: widget.type,
        reading: result.reading,
        score: result.score,
        suggestedActions: result.suggestedActions,
      );
      debugPrint('[Reading] Consultation オブジェクト作成完了');

      int id = -1;
      try {
        id = await ConsultationRepository().save(consultation);
        debugPrint('[Reading] ✅ データベース保存成功: id=$id');
      } catch (dbError) {
        debugPrint('[Reading] ❌ データベース保存失敗: $dbError');
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.errorGenericReading),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // DB保存成功後に初めて回数を消費
      await UsageService.increment();
      debugPrint('[Reading] 使用回数をインクリメント');

      await UserRepository().incrementReadingCount(widget.profile.uid);
      debugPrint('[Reading] 月次カウントをインクリメント');

      if (mounted) {
        final nav = Navigator.of(context);
        final v = await nav.push(MaterialPageRoute(
          builder: (_) => ResultScreen(
            consultation: Consultation(
              id: id,
              uid: consultation.uid,
              createdAt: consultation.createdAt,
              worry: consultation.worry,
              fortuneType: consultation.fortuneType,
              reading: result.reading,
              score: result.score,
              suggestedActions: result.suggestedActions,
            ),
            cards: const [],
            reversed: const [],
          ),
        ));
        if (mounted) {
          setState(() => _loading = false);
          nav.pop(v);
        }
      }
    } catch (e) {
      debugPrint('[Reading] ❌ 予期しないエラー: $e');
      if (mounted) {
        setState(() => _loading = false);
        final t = AppLocalizations.of(context)!;
        String errorMessage = t.errorGenericReading;
        if (e.toString().contains('Web') || e.toString().contains('CORS')) {
          errorMessage = t.errorWebNotSupported;
        } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
          errorMessage = t.errorApiAuth;
        } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
          errorMessage = t.errorTimeout;
        } else if (e.toString().contains('No internet') || e.toString().contains('Connection')) {
          errorMessage = t.errorNoInternet;
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.type.emoji,
                      style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text(t.simpleLoadingFormat(widget.type.displayName),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(widget.type.emoji,
                        style: const TextStyle(fontSize: 64)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.type.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.6),
                  ),
                  const SizedBox(height: 28),

                  // ── 入力UI（占術ごとに切り替え） ──────────
                  if (widget.type == FortuneType.bloodType)
                    _buildBloodTypeInput()
                  else if (widget.type == FortuneType.dream)
                    _buildDreamInput()
                  else if (widget.type == FortuneType.pastLife ||
                      widget.type == FortuneType.auspiciousCalendar)
                    _buildAutoInput()
                  else if (widget.type == FortuneType.fourPillars)
                    _buildFourPillarsInput()
                  else
                    _buildCategoryInput(),

                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _getReading : null,
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18)),
                      child: Text(
                        t.simpleReadingButton(widget.type.emoji),
                        style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 2,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 血液型選択
  Widget _buildBloodTypeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.bloodTypeQuestion,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300)),
        const SizedBox(height: 16),
        Row(
          children: _bloodTypes.map((bt) {
            final selected = _selectedBloodType == bt;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedBloodType = bt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accent.withValues(alpha: 0.15)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppTheme.accent : AppTheme.divider,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      bt,
                      style: TextStyle(
                        color: selected
                            ? AppTheme.accent
                            : AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 夢の内容テキスト入力
  Widget _buildDreamInput() {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.dreamQuestion,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300)),
        const SizedBox(height: 4),
        Text(t.dreamSubtitle,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        TextField(
          controller: _inputController,
          maxLines: 4,
          autofocus: true,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppTheme.textPrimary, height: 1.8),
          decoration: InputDecoration(
            hintText: t.dreamHint,
          ),
        ),
      ],
    );
  }

  // 生年月日で自動完結する占術
  Widget _buildAutoInput() {
    final p = widget.profile;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Text('✨', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.nickname,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15)),
          Text(
            '${DateFormat.yMMMMd(LocaleController.instance.locale.value.languageCode).format(p.birthdate)} ${p.zodiacSign}',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ]),
      ]),
    );
  }

  // 四柱推命：出生時刻を追加入力
  Widget _buildFourPillarsInput() {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAutoInput(),
        const SizedBox(height: 16),
        Text(t.fourPillarsBirthTimeLabel,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w300)),
        const SizedBox(height: 8),
        TextField(
          controller: _extraController,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: t.fourPillarsBirthTimeHint,
          ),
        ),
      ],
    );
  }

  // 悩みカテゴリチップ（ルーン・ホロスコープなど）
  Widget _buildCategoryInput() {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.worryPrompt,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w300)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categories(t).map((cat) {
            final selected = _selectedCategory == cat.$2;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat.$2);
                if (cat.$2 != '__other__') {
                  _inputController.text = cat.$2;
                } else {
                  _inputController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.accent.withValues(alpha: 0.15)
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.accent : AppTheme.divider,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Text(cat.$1,
                    style: TextStyle(
                      color: selected
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontSize: 13,
                    )),
              ),
            );
          }).toList(),
        ),
        if (_selectedCategory == '__other__') ...[
          const SizedBox(height: 12),
          TextField(
            controller: _inputController,
            maxLines: 3,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
                color: AppTheme.textPrimary, height: 1.8),
            decoration: InputDecoration(
              hintText: t.worryHint,
            ),
          ),
        ],
      ],
    );
  }
}
