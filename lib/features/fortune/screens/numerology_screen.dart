import 'package:flutter/material.dart';
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

List<(String, String)> _numWorryCategories(AppLocalizations t) => [
      (t.worryCategoryLove, t.worryCategoryLove),
      (t.worryCategoryWork, t.worryCategoryWork),
      (t.worryCategoryRelationship, t.worryCategoryRelationship),
      (t.worryCategoryMoney, t.worryCategoryMoney),
      (t.worryCategoryFamily, t.worryCategoryFamily),
      (t.worryCategoryHealth, t.worryCategoryHealth),
      (t.worryCategoryPath, t.worryCategoryPath),
      (t.worryCategoryOther, '__other__'),
    ];

class NumerologyScreen extends StatefulWidget {
  final UserProfile profile;
  final List<Consultation> recentConsultations;

  const NumerologyScreen({
    super.key,
    required this.profile,
    required this.recentConsultations,
  });

  @override
  State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final _worryController = TextEditingController();
  String? _selectedCategory;
  bool _loading = false;

  int get _lifeNumber {
    final b = widget.profile.birthdate;
    final digits = '${b.year}${b.month}${b.day}'
        .split('')
        .map(int.parse)
        .reduce((a, b) => a + b);
    var n = digits;
    while (n > 9 && n != 11 && n != 22 && n != 33) {
      n = n.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return n;
  }

  @override
  void dispose() {
    _worryController.dispose();
    super.dispose();
  }

  Future<void> _getReading() async {
    if (_worryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.worryEmptyError)));
      return;
    }
    setState(() => _loading = true);

    try {
      // 過去サマリーを取得
      final summary = await FortuneSummaryService.getSummaryForPrompt(
        widget.profile.uid,
        widget.recentConsultations,
      );

      final result = await ClaudeService().generateNumerologyReading(
        profile: widget.profile,
        worry: _worryController.text.trim(),
        recentConsultations: widget.recentConsultations,
        fortuneSummary: summary,
        languageCode: LocaleController.instance.locale.value.languageCode,
      );

      final consultation = Consultation(
        uid: widget.profile.uid,
        createdAt: DateTime.now(),
        worry: _worryController.text.trim(),
        fortuneType: FortuneType.numerology,
        reading: result.reading,
        score: result.score,
        suggestedActions: result.suggestedActions,
      );
      final id = await ConsultationRepository().save(consultation);

      // DB保存成功後に初めて利用回数を増やす
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
                reading: result.reading,
                score: result.score,
                suggestedActions: result.suggestedActions,
              ),
              cards: const [],
              reversed: const [],
            ),
          ),
        );
        if (mounted) nav.pop(v);
      }
    } catch (e) {
      debugPrint('Numerology error: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGenericReading)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.numerologyAppBarTitle),
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
                  const Text('🔢', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text(t.numerologyLoading,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ライフパスナンバー表示
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppTheme.accent, width: 2),
                        color: AppTheme.card,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(t.numerologyLifePath,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10)),
                          Text(
                            '$_lifeNumber',
                            style: const TextStyle(
                              color: AppTheme.accent,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    t.worryPrompt,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.numerologySubtitle,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // カテゴリ選択
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _numWorryCategories(t).map((cat) {
                      final isSelected = _selectedCategory == cat.$2;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat.$2);
                          if (cat.$2 != '__other__') {
                            _worryController.text = cat.$2;
                          } else {
                            _worryController.clear();
                          }
                        },
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
                  if (_selectedCategory == '__other__') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _worryController,
                      maxLines: 3,
                      autofocus: true,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, height: 1.8),
                      decoration: InputDecoration(
                        hintText: t.worryHint,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedCategory == null ? null : _getReading,
                      style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 18)),
                      child: Text(t.numerologyButton,
                          style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: 2,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
