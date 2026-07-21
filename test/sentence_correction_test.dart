import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordrill_exercise_engine/core/strings.dart';
import 'package:wordrill_exercise_engine/domain/exercise.dart';
import 'package:wordrill_exercise_engine/theme/wr_theme.dart';
import 'package:wordrill_exercise_engine/widgets/exercise_renderer_sentence_correction.dart';

AttemptResult _result({required bool isCorrect}) => AttemptResult(
      isCorrect: isCorrect,
      correctAnswer: 'He does not like waiting',
      submittedAnswer: 'He dont like waiting',
      explanation: ExerciseExplanation.empty,
      xpGained: isCorrect ? 10 : 0,
      totalXp: 10,
      level: 1,
      streak: isCorrect ? 1 : 0,
    );

Future<void> _pump(WidgetTester tester, {AttemptResult? result}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: wrDarkTheme(),
      home: Scaffold(
        body: ExerciseRendererSentenceCorrection(
          typedText: 'He dont like waiting',
          enabled: result == null,
          onChanged: (_) {},
          result: result,
          correctText: result?.correctAnswer,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the hint and no answer before grading', (tester) async {
    await _pump(tester);

    expect(find.text(Strings.correctionHint), findsOneWidget);
    expect(find.textContaining('does not like'), findsNothing);
  });

  // The renderer signals the outcome through colour and the diff. Stating it in
  // words too would duplicate the feedback panel the screen shows underneath,
  // which is exactly what this once did.
  testWidgets('does not label the verdict itself', (tester) async {
    await _pump(tester, result: _result(isCorrect: true));

    expect(find.text(Strings.feedbackCorrect), findsNothing);
    expect(find.text(Strings.feedbackIncorrect), findsNothing);
  });

  testWidgets('reveals the model answer only when wrong', (tester) async {
    await _pump(tester, result: _result(isCorrect: false));
    expect(find.text('He does not like waiting'), findsOneWidget);

    await _pump(tester, result: _result(isCorrect: true));
    expect(find.text('He does not like waiting'), findsNothing);
  });

  testWidgets('strikes through the submission when wrong', (tester) async {
    await _pump(tester, result: _result(isCorrect: false));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('leaves the submission unstruck when correct', (tester) async {
    await _pump(tester, result: _result(isCorrect: true));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.style?.decoration, isNot(TextDecoration.lineThrough));
  });
}
