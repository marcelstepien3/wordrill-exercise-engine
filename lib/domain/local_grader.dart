import 'exercise.dart';
import 'level_calculator.dart';

/// The answer key for one exercise, plus the explanation shown after grading.
///
/// This type exists only inside the grader. It is never attached to a
/// [SanitizedExercise], which is what keeps the key off the object the UI holds.
class AnswerKey {
  const AnswerKey({
    required this.exerciseId,
    required this.answer,
    required this.explanation,
    this.alternatives = const [],
  });

  final String exerciseId;

  /// The canonical answer. For multiple choice this is the correct option's id;
  /// for the open types it is the expected text.
  final String answer;

  /// Additional accepted spellings or phrasings for the open types.
  final List<String> alternatives;

  final ExerciseExplanation explanation;
}

/// Running progression state between attempts.
class ProgressState {
  const ProgressState({
    this.totalXp = 0,
    this.streak = 0,
  });

  final int totalXp;

  /// Consecutive correct answers. Resets to zero on a wrong answer.
  final int streak;

  int get level => LevelCalculator.levelForXp(totalXp);
}

/// Grades an attempt and awards XP.
///
/// In the production app this logic lives server side and the device only ever
/// receives the result, because anything the client can compute the client can
/// also forge. This class is the local stand-in that makes the demo runnable
/// with no backend: same inputs, same output shape, no network. Treating it as
/// authoritative in a real build would be the bug it is written to illustrate.
class LocalGrader {
  const LocalGrader({required this.keys});

  final Map<String, AnswerKey> keys;

  static const int _baseXp = 10;
  static const int _streakBonusCap = 15;

  /// Normalizes a free-text answer before comparison.
  ///
  /// Learners type the right answer with the wrong shell constantly: trailing
  /// full stops, double spaces, a stray capital. Grading on the raw string
  /// punishes typing rather than grammar, so case, surrounding punctuation and
  /// whitespace runs are all flattened first. Typos inside the word are still
  /// wrong, which is the distinction that matters.
  static String normalize(String input) {
    final lowered = input.trim().toLowerCase();
    final unpunctuated = lowered.replaceAll(RegExp(r'''[.!?,;:"']'''), '');
    return unpunctuated.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _matches(AnswerKey key, String submitted) {
    final candidate = normalize(submitted);
    if (candidate.isEmpty) return false;
    if (normalize(key.answer) == candidate) return true;
    return key.alternatives.any((alt) => normalize(alt) == candidate);
  }

  /// XP for one correct answer: a flat base plus a bonus that grows with the
  /// streak and then stops. The cap keeps a long session from inflating into
  /// meaningless numbers while still rewarding an unbroken run.
  static int xpFor({required bool isCorrect, required int streakAfter}) {
    if (!isCorrect) return 0;
    final bonus = (streakAfter - 1).clamp(0, _streakBonusCap);
    return _baseXp + bonus;
  }

  /// Grades [submitted] against the key for [exercise] and returns both the
  /// result and the progression state that follows it.
  ///
  /// Returns a record rather than mutating [state] so the caller decides when
  /// progression advances, which keeps the grader trivially testable.
  ({AttemptResult result, ProgressState state}) grade({
    required SanitizedExercise exercise,
    required String submitted,
    required ProgressState state,
  }) {
    final key = keys[exercise.id];
    if (key == null) {
      throw StateError('No answer key registered for exercise ${exercise.id}');
    }

    final isCorrect = exercise.type == 'multiple_choice'
        ? submitted == key.answer
        : _matches(key, submitted);

    final streakAfter = isCorrect ? state.streak + 1 : 0;
    final xpGained = xpFor(isCorrect: isCorrect, streakAfter: streakAfter);
    final totalXp = state.totalXp + xpGained;

    final nextState = ProgressState(totalXp: totalXp, streak: streakAfter);

    return (
      result: AttemptResult(
        isCorrect: isCorrect,
        correctAnswer: key.answer,
        submittedAnswer: submitted,
        explanation: key.explanation,
        xpGained: xpGained,
        totalXp: totalXp,
        level: nextState.level,
        streak: streakAfter,
        leveledUp: nextState.level > state.level,
      ),
      state: nextState,
    );
  }
}
