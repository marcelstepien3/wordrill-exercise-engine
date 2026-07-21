/// User-facing copy for the extract.
///
/// The full app routes every string through generated localization delegates
/// and ships English and Polish. That machinery is stripped here so the sample
/// runs without a build step, but the indirection is kept: no widget in this
/// repo holds a literal, so swapping this for the real delegate is a change of
/// lookup and nothing else.
class Strings {
  Strings._();

  static const appTitle = 'Exercise Engine';

  static const checkAnswer = 'Check';
  static const nextQuestion = 'Next';
  static const skipQuestion = 'Skip';
  static const finishSession = 'Finish';
  static const restartSession = 'Start again';

  static const feedbackCorrect = 'Correct';
  static const feedbackIncorrect = 'Not quite';
  static const modelAnswerLabel = 'Answer';

  static const correctionHint = 'Rewrite the sentence correctly';
  static const orderingHint = 'Tap or drag the words to build the sentence';

  static const exerciseTypeUnavailable =
      'This exercise type needs a newer version of the app.';

  static const sessionCompleteTitle = 'Session complete';
  static const streakLabel = 'Streak';
  static const xpLabel = 'XP';
  static const levelLabel = 'Level';
  static const accuracyLabel = 'Accuracy';

  static String questionCounter(int current, int total) =>
      'Question $current of $total';

  static String xpGained(int amount) => '+$amount XP';

  static String levelUp(int level) => 'Level $level reached';
}
