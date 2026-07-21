import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';

import '../core/app_feedback.dart';
import '../domain/exercise.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_tokens.dart';
import '../theme/wr_typography.dart';

/// Multiple choice answers as a list of lettered pills.
class ExerciseRendererMultipleChoice extends StatelessWidget {
  const ExerciseRendererMultipleChoice({
    required this.options,
    required this.isLoading,
    required this.wasSkipped,
    required this.showResult,
    required this.onOptionTap,
    super.key,
    this.result,
    this.selectedOptionId,
  });

  final List<ExerciseOption> options;
  final AttemptResult? result;
  final String? selectedOptionId;
  final bool isLoading;
  final bool wasSkipped;
  final bool showResult;
  final void Function(String) onOptionTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: showResult ? Offset.zero : const Offset(0, -0.02),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      child: Column(
        children: options.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AnswerCard(
              option: entry.value,
              index: entry.key,
              result: result,
              selectedOptionId: selectedOptionId,
              isLoading: isLoading,
              wasSkipped: wasSkipped,
              onTap: result == null && !isLoading
                  ? () => onOptionTap(entry.value.id)
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnswerCard extends StatefulWidget {
  const _AnswerCard({
    required this.option,
    required this.index,
    required this.isLoading,
    required this.wasSkipped,
    this.result,
    this.selectedOptionId,
    this.onTap,
  });

  final ExerciseOption option;
  final int index;
  final AttemptResult? result;
  final String? selectedOptionId;
  final bool isLoading;
  final bool wasSkipped;
  final VoidCallback? onTap;

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  bool _feedbackIsCorrect = false;
  late final AnimationController _feedbackCtrl;
  late final Animation<double> _scalePulse;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scalePulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.04), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.98), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.98, end: 1), weight: 35),
    ]).animate(
      CurvedAnimation(parent: _feedbackCtrl, curve: Curves.easeInOut),
    );
  }

  /// Fires the reaction animation on the transition into a graded state, not on
  /// every rebuild while graded, so the pulse plays exactly once. Only the two
  /// cards the learner cares about react: the correct one and, if they missed,
  /// the one they picked.
  @override
  void didUpdateWidget(_AnswerCard old) {
    super.didUpdateWidget(old);
    if (old.result == null &&
        widget.result != null &&
        !widget.result!.isPending) {
      final isCorrect = widget.option.id == widget.result!.correctAnswer;
      final isWrong = !widget.result!.isCorrect &&
          widget.option.id == widget.result!.submittedAnswer;
      if (isCorrect || isWrong) {
        _feedbackIsCorrect = isCorrect;
        _feedbackCtrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final isPending = widget.result?.isPending ?? false;
    final isCorrectAnswer = !isPending &&
        widget.result != null &&
        widget.option.id == widget.result!.correctAnswer;
    final isWrongSelected = !isPending &&
        !widget.wasSkipped &&
        widget.result != null &&
        !widget.result!.isCorrect &&
        widget.option.id == widget.result!.submittedAnswer;
    final isPendingSelected = isPending &&
        widget.result != null &&
        widget.option.id == widget.result!.submittedAnswer;
    final isPreSelected =
        widget.result == null && widget.selectedOptionId == widget.option.id;

    // Everything the learner is not being told about fades back, so the two
    // cards that carry the lesson are the only ones at full strength.
    final dimmed = widget.result != null &&
        !isCorrectAnswer &&
        !isWrongSelected &&
        !isPendingSelected;

    // A pending answer is styled like a selection rather than a verdict,
    // because offline the correctness is genuinely not known yet.
    final highlightAccent =
        isCorrectAnswer || isPreSelected || isPendingSelected;

    var borderColor = c.line;
    var cardBg = c.surfaceTop;
    var badgeBg = c.mutedDim.withValues(alpha: 0.55);
    var contentColor = c.ink;
    const letterColor = Colors.white;
    var borderWidth = 1.0;

    if (highlightAccent) {
      borderColor = c.accent;
      cardBg = c.accentSoft;
      badgeBg = c.accent;
      contentColor = c.ink;
      borderWidth = 1.5;
    } else if (isWrongSelected) {
      borderColor = c.danger.withValues(alpha: 0.7);
      cardBg = c.dangerSoft;
      badgeBg = c.danger;
      contentColor = c.danger;
      borderWidth = 1.5;
    }

    final letter = _letters[widget.index.clamp(0, _letters.length - 1)];

    Widget? trailing;
    if (highlightAccent) {
      trailing = Icon(Icons.check_rounded, size: 18, color: c.accent);
    } else if (isWrongSelected) {
      trailing = Icon(Icons.close_rounded, size: 18, color: c.danger);
    }

    final card = GestureDetector(
      onTapDown:
          widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              // Haptic only. The correct or wrong sound follows on submit, and
              // a click here would muddy it.
              AppFeedback.tick();
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: WrTokens.animSnap,
        child: AnimatedOpacity(
          opacity: dimmed ? 0.4 : 1.0,
          duration: WrTokens.animNormal,
          child: AnimatedContainer(
            duration: WrTokens.animNormal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: WrTokens.animNormal,
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: WrType.caption.copyWith(
                      color: letterColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.option.text,
                    style: WrType.titleMd.copyWith(
                      fontSize: 15.5,
                      color: contentColor,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // Two different reactions from one controller: correct pulses in scale,
    // wrong shakes horizontally on a decaying sine.
    return AnimatedBuilder(
      animation: _feedbackCtrl,
      builder: (context, child) {
        final t = _feedbackCtrl.value;
        if (t == 0) return child!;
        if (_feedbackIsCorrect) {
          return Transform.scale(scale: _scalePulse.value, child: child);
        }
        final dx = sin(t * pi * 2.5) * 6 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: card,
    );
  }
}
