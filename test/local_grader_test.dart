import 'package:flutter_test/flutter_test.dart';
import 'package:wordrill_exercise_engine/domain/exercise.dart';
import 'package:wordrill_exercise_engine/domain/local_grader.dart';

const _openExercise = SanitizedExercise(
  id: 'open',
  position: 1,
  type: 'fill_in_gap',
  prompt: ExercisePrompt(instruction: 'Fill it in', sentence: 'a ___ b'),
  options: [],
);

const _choiceExercise = SanitizedExercise(
  id: 'choice',
  position: 1,
  type: 'multiple_choice',
  prompt: ExercisePrompt(instruction: 'Pick one', sentence: 'a ___ b'),
  options: [
    ExerciseOption(id: 'opt_a', text: 'wrong'),
    ExerciseOption(id: 'opt_b', text: 'right'),
  ],
);

const _grader = LocalGrader(
  keys: {
    'open': AnswerKey(
      exerciseId: 'open',
      answer: 'knowledge',
      alternatives: ['know-how'],
      explanation: ExerciseExplanation.empty,
    ),
    'choice': AnswerKey(
      exerciseId: 'choice',
      answer: 'opt_b',
      explanation: ExerciseExplanation.empty,
    ),
  },
);

AttemptResult _gradeOpen(String submitted, {ProgressState? state}) => _grader
    .grade(
      exercise: _openExercise,
      submitted: submitted,
      state: state ?? const ProgressState(),
    )
    .result;

void main() {
  group('normalize', () {
    test('ignores case, padding and trailing punctuation', () {
      expect(LocalGrader.normalize('  Knowledge. '), 'knowledge');
    });

    test('collapses internal whitespace runs', () {
      expect(LocalGrader.normalize('have   been  working'), 'have been working');
    });
  });

  group('open answers', () {
    test('accepts the canonical answer', () {
      expect(_gradeOpen('knowledge').isCorrect, isTrue);
    });

    test('accepts it despite case and punctuation noise', () {
      expect(_gradeOpen('  KNOWLEDGE! ').isCorrect, isTrue);
    });

    test('accepts a registered alternative', () {
      expect(_gradeOpen('know-how').isCorrect, isTrue);
    });

    test('rejects a typo inside the word', () {
      expect(_gradeOpen('knowlege').isCorrect, isFalse);
    });

    test('rejects an empty submission', () {
      expect(_gradeOpen('').isCorrect, isFalse);
      expect(_gradeOpen('   ').isCorrect, isFalse);
    });
  });

  group('multiple choice', () {
    test('compares option ids exactly, without normalizing', () {
      final result = _grader
          .grade(
            exercise: _choiceExercise,
            submitted: 'opt_b',
            state: const ProgressState(),
          )
          .result;
      expect(result.isCorrect, isTrue);
    });

    test('rejects a wrong option', () {
      final result = _grader
          .grade(
            exercise: _choiceExercise,
            submitted: 'opt_a',
            state: const ProgressState(),
          )
          .result;
      expect(result.isCorrect, isFalse);
    });
  });

  group('XP and streak', () {
    test('awards the base amount for the first correct answer', () {
      final result = _gradeOpen('knowledge');
      expect(result.xpGained, 10);
      expect(result.streak, 1);
    });

    test('grows the award as the streak grows', () {
      final result = _gradeOpen(
        'knowledge',
        state: const ProgressState(totalXp: 500, streak: 4),
      );
      expect(result.streak, 5);
      expect(result.xpGained, 14);
    });

    test('caps the streak bonus', () {
      final result = _gradeOpen(
        'knowledge',
        state: const ProgressState(totalXp: 5000, streak: 100),
      );
      expect(result.xpGained, 25);
    });

    test('awards nothing and resets the streak on a wrong answer', () {
      final result = _gradeOpen(
        'wrong',
        state: const ProgressState(totalXp: 500, streak: 7),
      );
      expect(result.xpGained, 0);
      expect(result.streak, 0);
      expect(result.totalXp, 500);
    });

    test('flags the attempt that crosses a level threshold', () {
      final result = _gradeOpen(
        'knowledge',
        state: const ProgressState(totalXp: 95, streak: 0),
      );
      expect(result.totalXp, 105);
      expect(result.level, 2);
      expect(result.leveledUp, isTrue);
    });

    test('does not flag a level up when the threshold is not crossed', () {
      expect(_gradeOpen('knowledge').leveledUp, isFalse);
    });
  });

  test('throws when an exercise has no registered key', () {
    const orphan = SanitizedExercise(
      id: 'missing',
      position: 1,
      type: 'fill_in_gap',
      prompt: ExercisePrompt(instruction: 'x', sentence: 'x ___'),
      options: [],
    );
    expect(
      () => _grader.grade(
        exercise: orphan,
        submitted: 'anything',
        state: const ProgressState(),
      ),
      throwsStateError,
    );
  });
}
