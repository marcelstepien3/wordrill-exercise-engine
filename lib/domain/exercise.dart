/// A single selectable answer.
///
/// [id] is deliberately opaque. In the production app the server issues a
/// session-scoped identifier per delivery rather than the row's real primary
/// key, so nothing stable enough to build an answer key from ever reaches the
/// device.
class ExerciseOption {
  const ExerciseOption({required this.id, required this.text});

  final String id;
  final String text;
}

class ExercisePrompt {
  const ExercisePrompt({
    required this.instruction,
    required this.sentence,
    this.context,
  });

  /// What the learner is being asked to do, shown above the sentence.
  final String instruction;

  /// The sentence itself. Open types mark the blank with `___`, and
  /// multi-line prompts are split on `\n` by the renderer.
  final String sentence;

  /// Optional scene-setting line shown above the instruction.
  final String? context;
}

/// An exercise as it arrives on the device: prompt, options, and nothing else.
///
/// The name is the point. There is no `isCorrect` flag on the options and no
/// answer field anywhere on this object, because the same payload shape is what
/// the network layer delivers.
class SanitizedExercise {
  const SanitizedExercise({
    required this.id,
    required this.position,
    required this.type,
    required this.prompt,
    required this.options,
    this.gapLength,
  });

  final String id;
  final int position;

  /// One of `multiple_choice`, `fill_in_gap`, `translation`, `word_formation`,
  /// `sentence_transformation`, `sentence_ordering`, `sentence_correction`.
  final String type;

  final ExercisePrompt prompt;

  /// Answer choices for `multiple_choice`, or the shuffled word bank for
  /// `sentence_ordering`. Empty for the free-text types.
  final List<ExerciseOption> options;

  /// Character count of the expected answer, used to pre-size the blank as a
  /// subtle length hint. Length only, never the answer itself.
  final int? gapLength;
}

class ExerciseExample {
  const ExerciseExample({required this.en, required this.translation});

  final String en;
  final String translation;
}

/// The teaching payload shown after an answer is submitted.
class ExerciseExplanation {
  const ExerciseExplanation({
    required this.rule,
    required this.examples,
  });

  final String rule;
  final List<ExerciseExample> examples;

  static const empty = ExerciseExplanation(rule: '', examples: []);
}

/// The graded outcome of one attempt.
///
/// Every field here is an output of grading, never an input to it. The UI reads
/// this to decide what to render and does not recompute any of it.
class AttemptResult {
  const AttemptResult({
    required this.isCorrect,
    required this.correctAnswer,
    required this.submittedAnswer,
    required this.explanation,
    required this.xpGained,
    required this.totalXp,
    required this.level,
    required this.streak,
    this.leveledUp = false,
    this.isPending = false,
  });

  final bool isCorrect;

  /// The model answer. For multiple choice this is the winning option's [id];
  /// for the open types there is no option id, so it carries the answer text.
  final String correctAnswer;

  final String submittedAnswer;
  final ExerciseExplanation explanation;

  final int xpGained;
  final int totalXp;
  final int level;
  final int streak;

  /// True when this attempt crossed a level threshold, so the UI can celebrate
  /// once instead of diffing levels itself.
  final bool leveledUp;

  /// True when an answer was recorded offline and correctness is not known yet.
  /// The renderers use this to show a neutral submitted state rather than a
  /// right or wrong one.
  final bool isPending;
}
