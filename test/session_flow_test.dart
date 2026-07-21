import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wordrill_exercise_engine/core/strings.dart';
import 'package:wordrill_exercise_engine/demo/demo_session_screen.dart';
import 'package:wordrill_exercise_engine/theme/wr_theme.dart';

/// Pumps the demo on a tall surface.
///
/// The default 800x600 test viewport cuts off the feedback panel on the
/// question with four options, so the widgets under test are never laid out.
Future<void> _pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(900, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(theme: wrLightTheme(), home: const DemoSessionScreen()),
  );
}

/// Taps an answer and waits out both the submit delay and the result animation.
Future<void> _answerAndSettle(WidgetTester tester, Finder target) async {
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the first question with its options', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Choose the correct form.'), findsOneWidget);
    expect(find.text('goes'), findsOneWidget);
    expect(find.text(Strings.questionCounter(1, 6)), findsOneWidget);
  });

  testWidgets('tapping a correct option grades it and awards XP',
      (tester) async {
    await _pumpApp(tester);

    await _answerAndSettle(tester, find.text('goes'));

    expect(find.text(Strings.feedbackCorrect), findsOneWidget);
    expect(find.text(Strings.xpGained(10)), findsOneWidget);
    expect(find.text(Strings.nextQuestion), findsOneWidget);
  });

  testWidgets('a wrong option reveals the model answer', (tester) async {
    await _pumpApp(tester);

    await _answerAndSettle(tester, find.text('going'));

    expect(find.text(Strings.feedbackIncorrect), findsOneWidget);
    expect(find.textContaining('goes'), findsWidgets);
  });

  testWidgets('advances to the next question and resets the answer state',
      (tester) async {
    await _pumpApp(tester);

    await _answerAndSettle(tester, find.text('goes'));
    await tester.tap(find.text(Strings.nextQuestion));
    await tester.pumpAndSettle();

    expect(find.text(Strings.questionCounter(2, 6)), findsOneWidget);
    expect(find.text(Strings.feedbackCorrect), findsNothing);
    expect(find.text(Strings.checkAnswer), findsOneWidget);
  });

  testWidgets('free-text answers are graded through the inline blank',
      (tester) async {
    await _pumpApp(tester);

    await _answerAndSettle(tester, find.text('goes'));
    await tester.tap(find.text(Strings.nextQuestion));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'to');
    await tester.pumpAndSettle();
    await _answerAndSettle(tester, find.text(Strings.checkAnswer));

    expect(find.text(Strings.feedbackCorrect), findsOneWidget);
    // Second correct answer in a row, so the streak bonus lifts it above base.
    expect(find.text(Strings.xpGained(11)), findsOneWidget);
  });

  testWidgets('skipping grades as incorrect and awards no XP', (tester) async {
    await _pumpApp(tester);

    await _answerAndSettle(tester, find.text(Strings.skipQuestion));

    expect(find.text(Strings.feedbackIncorrect), findsOneWidget);
    expect(find.text(Strings.xpGained(10)), findsNothing);
  });

  testWidgets('a wrong answer resets the streak', (tester) async {
    await _pumpApp(tester);

    await _answerAndSettle(tester, find.text('goes'));
    await tester.tap(find.text(Strings.nextQuestion));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'nonsense');
    await tester.pumpAndSettle();
    await _answerAndSettle(tester, find.text(Strings.checkAnswer));

    expect(find.text(Strings.feedbackIncorrect), findsOneWidget);
    // The streak chip is only rendered while the streak is above zero.
    expect(find.byIcon(Icons.local_fire_department_rounded), findsNothing);
  });
}
