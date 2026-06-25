import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/services/claude_service.dart';

class CompatibilityScreen extends StatefulWidget {
  final UserProfile profile;
  final List<Consultation> recentConsultations;

  const CompatibilityScreen({
    super.key,
    required this.profile,
    required this.recentConsultations,
  });

  @override
  State<CompatibilityScreen> createState() => _CompatibilityScreenState();
}

class _CompatibilityScreenState extends State<CompatibilityScreen> {
  final _nameController = TextEditingController();
  DateTime _partnerBirthdate = DateTime(1995, 6, 15);
  bool _isLoading = false;
  CompatibilityResult? _result;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _partnerBirthdate,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('ja', 'JP'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.accent,
            onPrimary: Colors.white,
            surface: AppTheme.card,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _partnerBirthdate = picked);
  }

  Future<void> _startReading() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相手の名前を入力してください')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final result = await ClaudeService().generateCompatibilityReading(
        profile: widget.profile,
        partnerName: name,
        partnerBirthdate: _partnerBirthdate,
        recentConsultations: widget.recentConsultations,
      );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
      debugPrint('Compatibility error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💕 相性占い'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // あなたの情報
            _InfoCard(
              label: 'あなた',
              name: widget.profile.nickname,
              zodiac: widget.profile.zodiacSign,
              birthdate: widget.profile.birthdate,
              color: AppTheme.accent,
            ),
            const SizedBox(height: 16),

            // ❤️ アイコン
            const Center(
              child: Text('💕', style: TextStyle(fontSize: 32)),
            ),
            const SizedBox(height: 16),

            // 相手の情報入力
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE91E8C).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '相手',
                    style: TextStyle(
                      color: Color(0xFFE91E8C),
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 名前
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: '相手の名前（ニックネーム可）',
                      prefixIcon:
                          Icon(Icons.person_outline, color: AppTheme.textSecondary),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 生年月日
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(children: [
                        const Icon(Icons.cake_outlined,
                            color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${_partnerBirthdate.year}年${_partnerBirthdate.month}月${_partnerBirthdate.day}日',
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 16),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 占うボタン
            if (_result == null && !_isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startReading,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: const Color(0xFFE91E8C),
                  ),
                  child: const Text(
                    '相性を占う 💕',
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 2,
                        color: Colors.white),
                  ),
                ),
              ),

            // ローディング
            if (_isLoading) ...[
              const Center(
                child: Column(children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFE91E8C)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '二人の相性を分析中...',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ]),
              ),
            ],

            // エラー
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '占いに失敗しました。もう一度お試しください。',
                  style: TextStyle(color: AppTheme.error, fontSize: 13),
                ),
              ),

            // 結果
            if (_result != null) ...[
              _CompatibilityResultWidget(result: _result!),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _result = null;
                    _nameController.clear();
                  }),
                  child: const Text('もう一度占う'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String name;
  final String zodiac;
  final DateTime birthdate;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.name,
    required this.zodiac,
    required this.birthdate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, letterSpacing: 1),
          ),
          Text(
            name,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          Text(
            '$zodiac・${birthdate.year}年${birthdate.month}月${birthdate.day}日生',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12),
          ),
        ]),
      ]),
    );
  }
}

class _CompatibilityResultWidget extends StatelessWidget {
  final CompatibilityResult result;

  const _CompatibilityResultWidget({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 総合スコア
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B2D8B), Color(0xFFE91E8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Text(
              '${result.partnerName}さんとの相性',
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              '${result.overallScore}点',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _scoreLabel(result.overallScore),
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, letterSpacing: 2),
            ),
          ]),
        ),
        const SizedBox(height: 16),

        // 詳細スコア
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _ScoreRow('💝 恋愛相性', result.loveScore),
              const SizedBox(height: 10),
              _ScoreRow('🤝 友情相性', result.friendshipScore),
              const SizedBox(height: 10),
              _ScoreRow('💼 仕事相性', result.workScore),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 鑑定文
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            result.reading,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 推奨アクション
        if (result.suggestedActions.isNotEmpty) ...[
          const Text(
            '💡 アドバイス',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: result.suggestedActions
                  .map((a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✨ ',
                                style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                a,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }

  String _scoreLabel(int score) {
    if (score >= 90) return '最高の相性 ✨';
    if (score >= 75) return '相性抜群 💕';
    if (score >= 60) return '良い相性 😊';
    if (score >= 45) return '普通の相性 🌱';
    return '要努力 💪';
  }
}

class _ScoreRow extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreRow(this.label, this.score);

  @override
  Widget build(BuildContext context) {
    final color = score >= 75
        ? const Color(0xFFE91E8C)
        : score >= 50
            ? AppTheme.accent
            : AppTheme.textSecondary;

    return Row(children: [
      SizedBox(
        width: 100,
        child: Text(
          label,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 13),
        ),
      ),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppTheme.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 40,
        child: Text(
          '$score点',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ]);
  }
}
