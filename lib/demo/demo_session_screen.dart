import 'package:flutter/material.dart';

import '../core/app_feedback.dart';
import '../core/strings.dart';
import '../domain/exercise.dart';
import '../domain/local_grader.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_tokens.dart';
import '../theme/wr_typography.dart';
import '../widgets/exercise_renderer_factory.dart';
import '../widgets/wr_surface.dart';
import 'mock_exercises.dart';
import 'progress_header.dart';
import 'session_summary_view.dart';

/// Drives one practice session end to end.
///
/// All answer state lives here rather than inside the renderers. That is
/// deliberate: a renderer can be rebuilt, replaced or scrolled out of view at
/// any point, and answer state kept inside one would be lost with it. The
/// renderers stay controlled widgets that report changes upward and render
/// whatever they are handed back.
///
/// The production app replaces the [LocalGrader] call with an API request and
/// keeps everything else, since the screen only ever consumes an
/// [AttemptResult] and does not care where it was produced.
class DemoSessionScreen extends StatefulWidget {
  const DemoSessionScreen({super.key});

  @override
  State<DemoSessionScreen> createState() => _DemoSessionScreenState();
}

class _DemoSessionScreenState extends State<DemoSessionScreen> {
  final _grader = LocalGrader(keys: demoAnswerKeys);
  final _scrollController = ScrollController();

  int _index = 0;
  String? _currentAnswer;
  AttemptResult? _result;
  bool _isSubmitting = false;
  bool _wasSkipped = false;
  bool _finished = false;

  ProgressState _progress = const ProgressState();
  int _correctCount = 0;

  SanitizedExercise get _exercise => demoExercises[_index];
  bool get _isLastQuestion => _index == demoExercises.length - 1;

  bool get _canSubmit =>
      !_isSubmitting &&
      _result == null &&
      (_currentAnswer?.trim().isNotEmpty ?? false);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onAnswerChanged(String value) {
    setState(() => _currentAnswer = value);

    // Multiple choice has no separate confirm step, so a tap both selects and
    // submits. The free-text types wait for the Check button.
    if (!ExerciseRendererFactory.isTextInput(_exercise.type)) {
      _submit();
    }
  }

  Future<void> _submit({bool skipped = false}) async {
    if (_isSubmitting || _result != null) return;
    setState(() {
      _isSubmitting = true;
      _wasSkipped = skipped;
    });

    // Stands in for the network round trip so the loading state is exercised
    // rather than skipped over instantly.
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    final graded = _grader.grade(
      exercise: _exercise,
      submitted: skipped ? '' : (_currentAnswer ?? ''),
      state: _progress,
    );

    if (graded.result.isCorrect) {
      AppFeedback.success();
    } else {
      AppFeedback.error();
    }

    setState(() {
      _result = graded.result;
      _progress = graded.state;
      _isSubmitting = false;
      if (graded.result.isCorrect) _correctCount++;
    });
  }

  void _next() {
    AppFeedback.tap();
    if (_isLastQuestion) {
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index++;
      // Clearing the result is what signals the renderers to reset. They watch
      // for the transition rather than being told to clear directly.
      _result = null;
      _currentAnswer = null;
      _wasSkipped = false;
    });
    _scrollController.jumpTo(0);
  }

  void _restart() {
    AppFeedback.tap();
    setState(() {
      _index = 0;
      _result = null;
      _currentAnswer = null;
      _wasSkipped = false;
      _finished = false;
      _progress = const ProgressState();
      _correctCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wr;

    if (_finished) {
      return Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: SessionSummaryView(
            totalQuestions: demoExercises.length,
            correctCount: _correctCount,
            progress: _progress,
            onRestart: _restart,
          ),
        ),
      );
    }

    final rendered = ExerciseRendererFactory.build(
      exercise: _exercise,
      result: _result,
      isLoading: _isSubmitting,
      showResult: _result != null,
      currentAnswer: _currentAnswer,
      wasSkipped: _wasSkipped,
      onAnswerChanged: _onAnswerChanged,
    );

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            ProgressHeader(
              progress: _progress,
              questionIndex: _index,
              questionCount: demoExercises.length,
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _InstructionBlock(prompt: _exercise.prompt),
                  const SizedBox(height: 16),

                  // Three cases, in order: the type supplies its own sentence
                  // widget because it answers inline; the type has a sentence to
                  // show; or it has none, as with word ordering, where the words
                  // in the bank are the whole prompt and an empty card would just
                  // repeat the instruction.
                  if (rendered.sentenceSlot != null) ...[
                    rendered.sentenceSlot!,
                    const SizedBox(height: 20),
                  ] else if (_exercise.prompt.sentence.isNotEmpty) ...[
                    _SentenceCard(text: _exercise.prompt.sentence),
                    const SizedBox(height: 20),
                  ],

                  rendered.interactiveArea,

                  if (_result != null) ...[
                    const SizedBox(height: 20),
                    _FeedbackPanel(result: _result!),
                  ],
                ],
              ),
            ),
            _ActionBar(
              result: _result,
              isSubmitting: _isSubmitting,
              canSubmit: _canSubmit,
              isLastQuestion: _isLastQuestion,
              onSubmit: _submit,
              onSkip: () => _submit(skipped: true),
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionBlock extends StatelessWidget {
  const _InstructionBlock({required this.prompt});

  final ExercisePrompt prompt;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (prompt.context != null) ...[
          Text(
            prompt.context!.toUpperCase(),
            style: WrType.eyebrow.copyWith(color: c.muted),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          prompt.instruction,
          style: WrType.titleMd.copyWith(color: c.textDim),
        ),
      ],
    );
  }
}

class _SentenceCard extends StatelessWidget {
  const _SentenceCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return WrSurface(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: Text(
        text,
        style: WrType.displaySm.copyWith(height: 1.4, color: c.ink),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// The teaching moment after grading: verdict, XP, the rule and an example.
class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({required this.result});

  final AttemptResult result;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final ok = result.isCorrect;

    return WrSurface(
      variant: ok ? WrSurfaceVariant.accent : WrSurfaceVariant.danger,
      radius: WrTokens.rLg,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 18,
                color: ok ? c.accent : c.danger,
              ),
              const SizedBox(width: 8),
              Text(
                ok ? Strings.feedbackCorrect : Strings.feedbackIncorrect,
                style: WrType.titleMd.copyWith(
                  color: ok ? c.accent : c.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (result.xpGained > 0)
                Text(
                  Strings.xpGained(result.xpGained),
                  style: WrType.titleSm.copyWith(color: c.gold),
                ),
            ],
          ),
          if (!ok) ...[
            const SizedBox(height: 10),
            Text(
              '${Strings.modelAnswerLabel}: ${result.correctAnswer}',
              style: WrType.bodyMd.copyWith(
                color: c.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (result.explanation.rule.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              result.explanation.rule,
              style: WrType.bodySm.copyWith(color: c.textDim),
            ),
          ],
          if (result.explanation.examples.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final example in result.explanation.examples)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  example.en,
                  style: WrType.serifSm.copyWith(
                    color: c.ink2,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          if (result.leveledUp) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.military_tech_rounded, size: 18, color: c.gold),
                const SizedBox(width: 8),
                Text(
                  Strings.levelUp(result.level),
                  style: WrType.titleSm.copyWith(color: c.gold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The bottom bar. Shows Check before grading and Next after, so there is only
/// ever one obvious action available.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.result,
    required this.isSubmitting,
    required this.canSubmit,
    required this.isLastQuestion,
    required this.onSubmit,
    required this.onSkip,
    required this.onNext,
  });

  final AttemptResult? result;
  final bool isSubmitting;
  final bool canSubmit;
  final bool isLastQuestion;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final graded = result != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      color: c.bg,
      child: Row(
        children: [
          if (!graded)
            TextButton(
              onPressed: isSubmitting ? null : onSkip,
              child: Text(
                Strings.skipQuestion,
                style: WrType.titleSm.copyWith(color: c.muted),
              ),
            ),
          const Spacer(),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: graded ? onNext : (canSubmit ? onSubmit : null),
              style: FilledButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: c.onAccent,
                disabledBackgroundColor: c.mutedDim.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.onAccent,
                      ),
                    )
                  : Text(
                      graded
                          ? (isLastQuestion
                              ? Strings.finishSession
                              : Strings.nextQuestion)
                          : Strings.checkAnswer,
                      style: WrType.titleMd.copyWith(color: c.onAccent),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
