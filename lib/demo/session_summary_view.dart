import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../domain/level_calculator.dart';
import '../domain/local_grader.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_tokens.dart';
import '../theme/wr_typography.dart';
import '../widgets/wr_surface.dart';

/// End of session: accuracy, XP earned and the level reached.
class SessionSummaryView extends StatelessWidget {
  const SessionSummaryView({
    required this.totalQuestions,
    required this.correctCount,
    required this.progress,
    required this.onRestart,
    super.key,
  });

  final int totalQuestions;
  final int correctCount;
  final ProgressState progress;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    // Guards the divide so an empty session shows zero rather than NaN.
    final accuracy = totalQuestions == 0
        ? 0
        : ((correctCount / totalQuestions) * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_rounded, size: 56, color: c.accent),
            const SizedBox(height: 16),
            Text(
              Strings.sessionCompleteTitle,
              style: WrType.displayMd.copyWith(color: c.ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            WrSurface(
              radius: WrTokens.rXl,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                children: [
                  _StatRow(
                    label: Strings.accuracyLabel,
                    value: '$accuracy%',
                  ),
                  const SizedBox(height: 14),
                  _StatRow(
                    label: Strings.xpLabel,
                    value: '${progress.totalXp}',
                  ),
                  const SizedBox(height: 14),
                  _StatRow(
                    label: Strings.levelLabel,
                    value: '${progress.level} '
                        '(${LevelCalculator.titleForLevel(progress.level)})',
                  ),
                  const SizedBox(height: 14),
                  _StatRow(
                    label: Strings.streakLabel,
                    value: '${progress.streak}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: onRestart,
                style: FilledButton.styleFrom(
                  backgroundColor: c.accent,
                  foregroundColor: c.onAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  Strings.restartSession,
                  style: WrType.titleMd.copyWith(color: c.onAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: WrType.bodyMd.copyWith(color: c.muted)),
        Text(
          value,
          style: WrType.titleMd.copyWith(color: c.ink),
        ),
      ],
    );
  }
}
