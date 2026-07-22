import 'package:flutter/material.dart';
import 'package:myfortune/core/locale/locale_controller.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/data/services/claude_service.dart';
import 'package:myfortune/l10n/app_localizations.dart';

class OmikujiScreen extends StatefulWidget {
  final UserProfile profile;
  const OmikujiScreen({super.key, required this.profile});

  @override
  State<OmikujiScreen> createState() => _OmikujiScreenState();
}

class _OmikujiScreenState extends State<OmikujiScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String? _rank;
  String? _message;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _draw() async {
    setState(() {
      _loading = true;
      _rank = null;
      _message = null;
    });
    await _shakeCtrl.forward(from: 0);

    try {
      final raw = await ClaudeService()
          .generateOmikuji(
            profile: widget.profile,
            languageCode: LocaleController.instance.locale.value.languageCode,
          );

      // RANK: と MESSAGE: をパース
      final rankMatch = RegExp(r'RANK:(.+)').firstMatch(raw);
      final msgMatch = RegExp(r'MESSAGE:\n?([\s\S]+)').firstMatch(raw);
      setState(() {
        _rank = rankMatch?.group(1)?.trim() ?? '中吉';
        _message = msgMatch?.group(1)?.trim() ?? raw;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Omikuji error: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.omikujiErrorFetch)));
      }
    }
  }

  // 5パターンのテーマ（日付mod5で決定）
  int get _pattern => DateTime.now().day % 5;

  static const _patterns = [
    (emoji: '🌸', bg: Color(0xFF2D1635), accent: Color(0xFFE8A0C8), label: '春の桜'),
    (emoji: '⭐', bg: Color(0xFF0D1B3E), accent: Color(0xFFC9A84C), label: '夜の星'),
    (emoji: '🍂', bg: Color(0xFF2B1400), accent: Color(0xFFE07B39), label: '秋の紅葉'),
    (emoji: '❄️', bg: Color(0xFF0D2233), accent: Color(0xFF7EC8E0), label: '冬の雪'),
    (emoji: '🌿', bg: Color(0xFF0D2B1A), accent: Color(0xFF6ECC8A), label: '夏の緑'),
  ];

  Color get _rankColor {
    switch (_rank) {
      case '大吉': return AppTheme.success;
      case '吉':   return const Color(0xFF7EC8C8);
      case '中吉': return AppTheme.accentGold;
      case '小吉': return AppTheme.accent;
      case '末吉': return AppTheme.textSecondary;
      case '凶':   return AppTheme.error;
      default:     return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.omikujiAppBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) {
                  final offset = _loading
                      ? 8.0 * (0.5 - (_shakeAnim.value % 1.0)).abs()
                      : 0.0;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: const Text('🎋',
                    style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 32),

              if (_loading)
                Column(children: [
                  const CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 2),
                  const SizedBox(height: 16),
                  Text(t.omikujiLoading,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ])
              else if (_rank != null) ...[
                // 結果表示（5パターンテーマ）
                Builder(builder: (_) {
                  final p = _patterns[_pattern];
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: p.bg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: p.accent.withValues(alpha: 0.6), width: 2),
                    ),
                    child: Column(children: [
                      Text(p.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 4),
                      Text(p.label,
                          style: TextStyle(
                              color: p.accent.withValues(alpha: 0.7),
                              fontSize: 11,
                              letterSpacing: 2)),
                      const SizedBox(height: 16),
                      Text(
                        _rank!,
                        style: TextStyle(
                          color: _rankColor,
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                      ),
                      Divider(
                          color: p.accent.withValues(alpha: 0.3), height: 32),
                      Text(
                        _message ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            height: 2.0),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: _draw,
                  child: Text(t.omikujiRetryButton,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ),
              ] else ...[
                // 初期状態
                Text(
                  t.omikujiIntro(widget.profile.nickname),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 15,
                      height: 1.8),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _draw,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18)),
                    child: Text(t.omikujiDrawButton,
                        style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: 2,
                            color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
