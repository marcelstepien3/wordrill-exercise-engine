import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../domain/exercise.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_typography.dart';
import 'exercise_inline_gap.dart';
import 'exercise_renderer_multiple_choice.dart';
import 'exercise_renderer_ordering.dart';
import 'exercise_renderer_sentence_correction.dart';

/// The two layout slots the factory fills for a given exercise.
///
/// Some types answer below the sentence and some answer inside it, so the
/// factory returns both slots instead of a single widget. The screen owns the
/// page layout and just drops these in.
class RendererResult {
  const RendererResult({
    required this.interactiveArea,
    this.sentenceSlot,
  });

  /// Replaces the default sentence widget. Non-null only for the types that
  /// embed their input inline with the text.
  final Widget? sentenceSlot;

  /// Rendered below the sentence and the feedback line.
  final Widget interactiveArea;
}

/// Maps an exercise type onto its renderer.
///
/// Adding a type means adding a case here and a widget beside it. The screen
/// never branches on type, so the answer flow it drives stays one code path no
/// matter how many types exist.
class ExerciseRendererFactory {
  ExerciseRendererFactory._();

  /// Free-text types, as opposed to the ones answered by tapping a choice.
  ///
  /// The screen uses this to allow more time, hide the skip shortcut and turn
  /// off the select-then-confirm flow that only makes sense for options.
  static bool isTextInput(String type) =>
      type == 'fill_in_gap' ||
      type == 'sentence_ordering' ||
      type == 'sentence_correction' ||
      type == 'translation' ||
      type == 'word_formation' ||
      type == 'sentence_transformation';

  static RendererResult build({
    required SanitizedExercise exercise,
    required AttemptResult? result,
    required bool isLoading,
    required bool showResult,
    required String? currentAnswer,
    required bool wasSkipped,
    required void Function(String) onAnswerChanged,
  }) {
    // A submitted answer is locked while the result is on screen, and while a
    // submission is in flight, so a double tap cannot change it after the fact.
    final enabled = result == null && !isLoading;

    switch (exercise.type) {
      // Open single-blank types all share the cloze renderer: the answer is
      // typed onto the blank in the sentence itself, not in a field below.
      case 'fill_in_gap':
      case 'translation':
      case 'word_formation':
      case 'sentence_transformation':
        return RendererResult(
          sentenceSlot: InlineGapSentence(
            sentence: exercise.prompt.sentence,
            typedText: currentAnswer ?? '',
            enabled: enabled,
            onChanged: onAnswerChanged,
            result: result,
            gapLength: exercise.gapLength,
          ),
          interactiveArea: const SizedBox.shrink(),
        );

      case 'sentence_ordering':
        return RendererResult(
          interactiveArea: ExerciseRendererOrdering(
            words: exercise.options,
            currentSentence: currentAnswer ?? '',
            enabled: enabled,
            onChanged: onAnswerChanged,
            result: result,
          ),
        );

      case 'sentence_correction':
        return RendererResult(
          interactiveArea: ExerciseRendererSentenceCorrection(
            typedText: currentAnswer ?? '',
            enabled: enabled,
            onChanged: onAnswerChanged,
            result: result,
            // Open types carry no option list, so the model answer only exists
            // once grading has returned it.
            correctText: result?.correctAnswer,
          ),
        );

      case 'multiple_choice':
        return RendererResult(
          interactiveArea: ExerciseRendererMultipleChoice(
            options: exercise.options,
            isLoading: isLoading,
            wasSkipped: wasSkipped,
            showResult: showResult,
            onOptionTap: onAnswerChanged,
            result: result,
            selectedOptionId: currentAnswer,
          ),
        );

      // An unknown type means content was authored for a newer build. Showing a
      // clear message beats crashing on a payload the app cannot render.
      default:
        return const RendererResult(interactiveArea: _UnknownTypeCard());
    }
  }
}

class _UnknownTypeCard extends StatelessWidget {
  const _UnknownTypeCard();

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surfaceTop,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      child: Row(
        children: [
          Icon(Icons.system_update_rounded, color: c.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Strings.exerciseTypeUnavailable,
              style: WrType.bodyMd.copyWith(color: c.textDim),
            ),
          ),
        ],
      ),
    );
  }
}
