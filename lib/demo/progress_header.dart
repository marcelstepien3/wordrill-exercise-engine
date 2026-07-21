import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../domain/level_calculator.dart';
import '../domain/local_grader.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_tokens.dart';
import '../theme/wr_typography.dart';

/// Level, XP, streak and how far through the session the learner is.
///
/// The bar tracks the session, not XP. Tying it to XP within the level was the
/// obvious first move and the wrong one: a level spans hundreds of XP, so a
/// short session nudges the bar a few percent and any skipped question leaves it
/// completely still. A bar that does not visibly move reads as broken. The
/// session is the thing that advances on every single question, so that is what
/// the bar shows, and XP stays a number that ticks up beside the level.
///
/// The bar animates to each new value rather than jumping, and reads its level
/// figures from [LevelCalculator] rather than caching its own, which keeps it
/// correct when XP arrives in a lump and crosses a threshold.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    required this.progress,
    required this.questionIndex,
    required this.questionCount,
    super.key,
  });

  final ProgressState progress;
  final int questionIndex;
  final int questionCount;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final level = progress.level;
    final withinLevel = LevelCalculator.xpWithinLevel(progress.totalXp, level);
    final range = LevelCalculator.xpRangeForLevel(level);

    // Inclusive of the question on screen, so the first of six reads as one step
    // in rather than as an empty bar.
    final fraction = questionCount == 0
        ? 0.0
        : ((questionIndex + 1) / questionCount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LevelBadge(level: level),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LevelCalculator.titleForLevel(level),
                    style: WrType.titleMd.copyWith(color: c.ink),
                  ),
                  Text(
                    LevelCalculator.isPrestige(level)
                        ? '${progress.totalXp} ${Strings.xpLabel}'
                        : '$withinLevel / $range ${Strings.xpLabel}',
                    style: WrType.caption.copyWith(color: c.muted),
                  ),
                ],
              ),
              const Spacer(),
              if (progress.streak > 0) _StreakChip(streak: progress.streak),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: WrTokens.animSlow,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: c.mutedDim.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation(c.accent),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Strings.questionCounter(questionIndex + 1, questionCount),
            style: WrType.caption.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: c.accentSoft,
        shape: BoxShape.circle,
        border: Border.all(color: c.accentLine),
      ),
      alignment: Alignment.center,
      child: Text(
        '$level',
        style: WrType.titleMd.copyWith(
          color: c.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return AnimatedContainer(
      duration: WrTokens.animNormal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.goldSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 15, color: c.gold),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: WrType.titleSm.copyWith(color: c.gold),
          ),
        ],
      ),
    );
  }
}
