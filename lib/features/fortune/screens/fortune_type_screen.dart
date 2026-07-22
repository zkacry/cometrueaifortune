import 'package:flutter/material.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/theme/app_theme.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';
import 'package:myfortune/features/fortune/screens/compatibility_screen.dart';
import 'package:myfortune/features/fortune/screens/numerology_screen.dart';
import 'package:myfortune/features/fortune/screens/omikuji_screen.dart';
import 'package:myfortune/features/fortune/screens/simple_fortune_screen.dart';
import 'package:myfortune/features/fortune/screens/tarot_screen.dart';
import 'package:myfortune/features/settings/screens/upgrade_screen.dart';
import 'package:myfortune/l10n/app_localizations.dart';

class FortuneTypeScreen extends StatelessWidget {
  final UserProfile profile;
  final List<Consultation> recentConsultations;

  const FortuneTypeScreen({
    super.key,
    required this.profile,
    required this.recentConsultations,
  });

  // プラン別に表示する占術グループ（hidden=trueは除外）
  List<({String label, List<FortuneType> types})> _sections(AppLocalizations t) => [
        (
          label: t.fortuneTypeFreeSection,
          types: [
            FortuneType.omikuji,
            FortuneType.tarot,
            FortuneType.compatibility,
            FortuneType.bloodType,
          ],
        ),
        (
          label: t.fortuneTypeLightSection,
          types: [
            FortuneType.numerology,
            FortuneType.rune,
            FortuneType.pastLife,
            FortuneType.horoscope,
          ],
        ),
        (
          label: t.fortuneTypeProSection,
          types: [
            FortuneType.fourPillars,
            FortuneType.auspiciousCalendar,
          ],
        ),
      ];

  void _navigate(BuildContext context, FortuneType type) {
    // プラン制限チェック
    if (!type.isAvailableFor(profile.plan)) {
      _showUpgradeDialog(context, type);
      return;
    }

    final nav = Navigator.of(context);

    Widget screen;
    switch (type) {
      case FortuneType.tarot:
        screen = TarotScreen(
            profile: profile, recentConsultations: recentConsultations);
        break;
      case FortuneType.numerology:
        screen = NumerologyScreen(
            profile: profile, recentConsultations: recentConsultations);
        break;
      case FortuneType.compatibility:
        screen = CompatibilityScreen(
            profile: profile, recentConsultations: recentConsultations);
        break;
      case FortuneType.omikuji:
        screen = OmikujiScreen(profile: profile);
        break;
      default:
        screen = SimpleFortuneScreen(
            type: type,
            profile: profile,
            recentConsultations: recentConsultations);
    }

    // おみくじはカウント消費しないので単純push
    if (type == FortuneType.omikuji) {
      nav.push(MaterialPageRoute(builder: (_) => screen));
    } else {
      nav.push(MaterialPageRoute(builder: (_) => screen))
          .then((v) => nav.pop(v));
    }
  }

  void _showUpgradeDialog(BuildContext context, FortuneType type) {
    final t = AppLocalizations.of(context)!;
    final required = type.requiredPlan;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text(
          t.fortuneTypeUpgradeDialogTitle(type.displayName, required.displayName),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
        ),
        content: Text(
          t.fortuneTypeUpgradeDialogBody(required.monthlyPrice),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.commonCancel,
                style: const TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => UpgradeScreen(profile: profile)),
              );
            },
            child: Text(t.commonUpgrade),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.fortuneTypeAppBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            t.fortuneTypeRemaining(profile.remainingReadings),
            style:
                const TextStyle(color: AppTheme.accent, fontSize: 13),
          ),
          const SizedBox(height: 20),
          for (final section in _sections(t)) ...[
            _SectionHeader(label: section.label),
            const SizedBox(height: 10),
            for (final type in section.types) ...[
              _TypeCard(
                type: type,
                available: type.isAvailableFor(profile.plan),
                onTap: () => _navigate(context, type),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w500),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final FortuneType type;
  final bool available;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: available ? 1.0 : 0.55,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: available
                  ? AppTheme.accent.withValues(alpha: 0.3)
                  : AppTheme.divider,
            ),
          ),
          child: Row(children: [
            // アイコン画像 or emoji
            _FortuneIcon(type: type, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    type.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!available)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type.requiredPlan.displayName,
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 10),
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary, size: 13),
          ]),
        ),
      ),
    );
  }
}

/// 占術アイコン（アセット画像 or emoji フォールバック）
class _FortuneIcon extends StatelessWidget {
  final FortuneType type;
  final double size;
  const _FortuneIcon({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    final asset = type.iconAsset;
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(asset,
            width: size, height: size, fit: BoxFit.cover),
      );
    }
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(type.emoji,
            style: TextStyle(fontSize: size * 0.6)),
      ),
    );
  }
}
