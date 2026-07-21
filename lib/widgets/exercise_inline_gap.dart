import 'package:flutter/material.dart';

import '../domain/exercise.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_typography.dart';
import 'wr_surface.dart';

/// Renders a sentence with the answer typed directly onto the blank instead of
/// into a separate field underneath.
///
/// Keeping the input inline means the learner reads the sentence as a sentence
/// while answering, which is the whole point of a cloze exercise. Shared by
/// every open single-blank type: fill in the gap, translation, word formation
/// and sentence transformation. The types that are not single-blank, sentence
/// ordering and sentence correction, have their own renderers.
///
/// Multi-line aware. A transformation prompt arrives as
/// `source\n(KEYWORD)\ntarget ___`, so each line is laid out separately and
/// only the line holding the `___` gets the input.
///
/// After grading the blank shows what the learner wrote, in accent if they were
/// right and danger if they were wrong. If they skipped without typing, it
/// shows the model answer instead so the slot is never left empty.
class InlineGapSentence extends StatefulWidget {
  const InlineGapSentence({
    required this.sentence,
    required this.typedText,
    required this.enabled,
    required this.onChanged,
    super.key,
    this.result,
    this.gapLength,
  });

  final String sentence;
  final String typedText;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final AttemptResult? result;

  /// Character count of the expected answer. When set, the empty blank is
  /// pre-sized to it as a quiet hint of how long the answer runs.
  final int? gapLength;

  @override
  State<InlineGapSentence> createState() => _InlineGapSentenceState();
}

class _InlineGapSentenceState extends State<InlineGapSentence> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.typedText);
  }

  /// The controller is driven off the result transitions rather than off every
  /// build: the text has to survive into the feedback phase so the learner can
  /// see what they wrote, then clear when the next question arrives.
  @override
  void didUpdateWidget(InlineGapSentence old) {
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
    final baseStyle = WrType.displaySm.copyWith(height: 1.4, color: c.ink);
    final result = widget.result;
    final gapColor = (result == null || result.isCorrect) ? c.accent : c.danger;

    final lines = widget.sentence.split('\n');

    // Measures the expected answer in the real text style to size the empty
    // blank, so the hint is accurate at any font scale rather than a guess in
    // pixels. Clamped so a very long answer cannot push the blank past the card.
    var hintMin = 72.0;
    final gl = widget.gapLength;
    if (result == null && gl != null && gl > 0) {
      final tp = TextPainter(
        text: TextSpan(text: 'n' * gl, style: baseStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      hintMin = (tp.width + 16).clamp(72.0, 340.0);
    }

    return WrSurface(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxGap = constraints.maxWidth;
          return Column(
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _buildLine(lines[i], baseStyle, gapColor, maxGap, hintMin),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildLine(
    String line,
    TextStyle baseStyle,
    Color gapColor,
    double maxGap,
    double gapMinWidth,
  ) {
    if (!line.contains('___')) {
      return Text(line, style: baseStyle, textAlign: TextAlign.center);
    }
    final parts = line.split('___');
    final before = parts.isNotEmpty ? parts[0] : '';
    // Rejoins any further markers so a stray second `___` renders as text
    // rather than silently swallowing the rest of the line.
    final after = parts.length > 1 ? parts.sublist(1).join('___') : '';
    final result = widget.result;
    final typed = widget.typedText.trim();

    // The blank drops the paragraph's line-height multiplier.
    //
    // The surrounding text uses a 1.4 height for readable line spacing, which
    // pads roughly 4px of leading below the glyphs. The blank's rule is drawn at
    // the bottom of its box, so inheriting that leading would float the rule in
    // empty space well under the baseline. At 1.0 the box hugs the glyphs and
    // the rule lands directly beneath them, while baseline alignment keeps the
    // blank sitting on the same line as the words.
    final gapStyle = baseStyle.copyWith(height: 1);

    final Widget gap = result != null
        ? _GapDisplay(
            text: typed.isNotEmpty ? widget.typedText : result.correctAnswer,
            color: typed.isEmpty ? context.wr.accent : gapColor,
            style: gapStyle,
            maxWidth: maxGap,
          )
        : _GapInput(
            controller: _controller,
            style: gapStyle,
            color: gapColor,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            maxWidth: maxGap,
            minWidth: gapMinWidth,
          );

    // The blank is placed as a WidgetSpan inside the paragraph rather than as a
    // sibling in a Wrap. A Wrap centres each child's box against the others, and
    // the field's box is taller than the text's by its padding and underline, so
    // the blank drifts below the baseline. A baseline-aligned span sits on the
    // same line as the words around it and lets the text wrap normally.
    return Text.rich(
      TextSpan(
        children: [
          if (before.isNotEmpty) TextSpan(text: before),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: gap,
          ),
          if (after.isNotEmpty) TextSpan(text: after),
        ],
      ),
      style: baseStyle,
      textAlign: TextAlign.center,
    );
  }
}

class _GapInput extends StatelessWidget {
  const _GapInput({
    required this.controller,
    required this.style,
    required this.color,
    required this.enabled,
    required this.onChanged,
    required this.maxWidth,
    required this.minWidth,
  });

  final TextEditingController controller;
  final TextStyle style;
  final Color color;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final double maxWidth;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    // The underline is drawn by this Container, not by an InputBorder.
    //
    // An InputDecorator reserves its own vertical space for a border and
    // reports a baseline that includes it, which drops the blank below the
    // baseline of the words around it. Stripping the decoration to nothing and
    // drawing the rule here means the field's baseline is just the text's, and
    // it gives the empty and answered states identical geometry: _GapDisplay
    // builds the same box.
    //
    // IntrinsicWidth lets the field grow with what is typed, between the length
    // hint minimum and the card width. Past that it wraps instead of overflowing.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth <= maxWidth ? minWidth : maxWidth,
        maxWidth: maxWidth,
      ),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: color, width: 2)),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            onChanged: onChanged,
            textAlign: TextAlign.center,
            maxLines: null,
            style: style.copyWith(color: color),
            // A global inputDecorationTheme sets filled and its own borders,
            // which otherwise bleed through and paint a box around the blank.
            // All four have to be overridden explicitly, not just the border.
            decoration: const InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

/// The post-grading blank: the same underline, no longer editable.
class _GapDisplay extends StatelessWidget {
  const _GapDisplay({
    required this.text,
    required this.color,
    required this.style,
    required this.maxWidth,
  });

  final String text;
  final Color color;
  final TextStyle style;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: color, width: 2)),
        ),
        child: Text(
          text,
          style: style.copyWith(color: color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
