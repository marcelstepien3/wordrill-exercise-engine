import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../domain/exercise.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_typography.dart';
import 'wr_surface.dart';

/// Sentence correction: the learner rewrites a whole faulty sentence.
///
/// Unlike the single-blank types there is no gap to fill, so this is a plain
/// multi-line field that changes colour with the verdict. When the answer is
/// wrong the submitted text is struck through and the model answer is shown
/// underneath, putting the two versions next to each other where the difference
/// is easiest to see.
class ExerciseRendererSentenceCorrection extends StatefulWidget {
  const ExerciseRendererSentenceCorrection({
    required this.typedText,
    required this.enabled,
    required this.onChanged,
    super.key,
    this.result,
    this.correctText,
  });

  final String typedText;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final AttemptResult? result;

  /// The model answer. Null before grading, since showing it early would give
  /// the exercise away.
  final String? correctText;

  @override
  State<ExerciseRendererSentenceCorrection> createState() =>
      _ExerciseRendererSentenceCorrectionState();
}

class _ExerciseRendererSentenceCorrectionState
    extends State<ExerciseRendererSentenceCorrection> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.typedText);
  }

  /// Same lifecycle as the inline gap: hold the text through the feedback
  /// phase, clear it when the next question arrives.
  @override
  void didUpdateWidget(ExerciseRendererSentenceCorrection old) {
    super.didUpdateWidget(old);
    if (widget.result != null && old.result == null) {
      _controller.text = widget.typedText;
    }
    if (widget.result == null && old.result != null) {
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final result = widget.result;

    final variant = result == null
        ? WrSurfaceVariant.neutral
        : result.isCorrect
            ? WrSurfaceVariant.accent
            : WrSurfaceVariant.danger;

    // Only strike through when there is actually a better version to show.
    final showDiff = result != null &&
        !result.isCorrect &&
        widget.correctText != null &&
        widget.correctText!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WrSurface(
          variant: variant,
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: WrType.bodyMd.copyWith(
              color: c.ink,
              decoration: showDiff ? TextDecoration.lineThrough : null,
              decorationColor: showDiff ? c.danger : null,
              decorationThickness: showDiff ? 2 : null,
            ),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: Strings.correctionHint,
              hintStyle: WrType.bodyMd.copyWith(color: c.muted),
              // The field sits inside a styled container, so the global input
              // theme's fill and borders have to be switched off individually.
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        // No verdict label here. The renderer states the outcome through the
        // field's own colour and, when wrong, the strikethrough plus the model
        // answer below. Spelling it out in words as well would repeat the
        // feedback panel the screen already shows underneath.
        if (showDiff) ...[
          const SizedBox(height: 8),
          WrSurface(
            variant: WrSurfaceVariant.accent,
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: c.accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.correctText!,
                    style: WrType.bodyMd.copyWith(
                      color: c.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
