import 'package:flutter/material.dart';

import '../core/app_feedback.dart';
import '../core/strings.dart';
import '../domain/exercise.dart';
import '../theme/wr_theme.dart';
import '../theme/wr_tokens.dart';
import '../theme/wr_typography.dart';

/// Sentence ordering: build a sentence from a shuffled word bank.
///
/// Two input paths on purpose. Tapping is the fast path, adding to the end and
/// removing on a second tap. Dragging is the precise path, dropping a word
/// between two others so a missed word can be slotted into place without
/// clearing everything after it. Tiles look identical in the bank and the tray,
/// and a word that moves between them slides rather than fades, so the eye can
/// follow where it went.
class ExerciseRendererOrdering extends StatefulWidget {
  const ExerciseRendererOrdering({
    required this.words,
    required this.currentSentence,
    required this.enabled,
    required this.onChanged,
    super.key,
    this.result,
  });

  final List<ExerciseOption> words;
  final String currentSentence;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final AttemptResult? result;

  @override
  State<ExerciseRendererOrdering> createState() =>
      _ExerciseRendererOrderingState();
}

class _DragData {
  const _DragData(this.word);
  final ExerciseOption word;
}

class _ExerciseRendererOrderingState extends State<ExerciseRendererOrdering> {
  late List<ExerciseOption> _placed;
  late List<ExerciseOption> _bank;

  @override
  void initState() {
    super.initState();
    _placed = [];
    _bank = List.of(widget.words);
  }

  @override
  void didUpdateWidget(ExerciseRendererOrdering old) {
    super.didUpdateWidget(old);
    // A cleared result means the next question loaded, so refill the bank.
    if (widget.result == null && old.result != null) {
      setState(() {
        _placed = [];
        _bank = List.of(widget.words);
      });
    }
  }

  void _emit() => widget.onChanged(_placed.map((w) => w.text).join(' '));

  /// Inserts [word] at [index], appending when index is null, and pulls it out
  /// of wherever it currently sits.
  ///
  /// The reindex matters: when a word moves forward from an earlier position,
  /// removing it first shifts every later index left by one, so the target has
  /// to be decremented or the word lands one slot past where it was dropped.
  void _placeAt(ExerciseOption word, int? index) {
    if (!widget.enabled) return;
    AppFeedback.select();
    setState(() {
      final wasAt = _placed.indexOf(word);
      _bank.remove(word);
      if (wasAt != -1) _placed.removeAt(wasAt);
      var target = index ?? _placed.length;
      if (wasAt != -1 && wasAt < target) target -= 1;
      target = target.clamp(0, _placed.length);
      _placed.insert(target, word);
    });
    _emit();
  }

  void _removeFromPlaced(ExerciseOption word) {
    if (!widget.enabled) return;
    AppFeedback.select();
    setState(() {
      _placed.remove(word);
      if (!_bank.contains(word)) _bank.add(word);
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final result = widget.result;
    final graded = result != null && !result.isPending;
    final isCorrect = result?.isCorrect ?? false;

    // Once graded the tiles stop being interactive and collapse into one
    // readable line, because the answer is now something to read, not build.
    if (graded) {
      final sentenceColor = isCorrect ? c.accent : c.danger;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 66),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isCorrect ? c.accentSoft : c.dangerSoft,
              borderRadius: BorderRadius.circular(WrTokens.rLg),
              border: Border.all(
                color: isCorrect
                    ? c.accentLine
                    : c.danger.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Text(
              _placed.map((w) => w.text).join(' '),
              style: WrType.serifMd.copyWith(
                color: sentenceColor,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(WrTokens.rMd),
                border: Border.all(color: c.accentLine),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16, color: c.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.correctAnswer,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The answer tray. Dropping anywhere in its empty space appends,
        // which is the forgiving target for an imprecise drag.
        DragTarget<_DragData>(
          onWillAcceptWithDetails: (_) => widget.enabled,
          onAcceptWithDetails: (d) => _placeAt(d.data.word, null),
          builder: (context, candidate, rejected) {
            final hot = candidate.isNotEmpty;
            return AnimatedSize(
              duration: WrTokens.animNormal,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedContainer(
                duration: WrTokens.animFast,
                curve: Curves.easeOut,
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 66),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _placed.isEmpty
                      ? c.surfaceTop
                      : c.surfaceTop.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(WrTokens.rLg),
                  border: Border.all(
                    color: hot
                        ? c.accent
                        : (_placed.isEmpty ? c.line : c.accentLine),
                    width: 1.5,
                  ),
                ),
                child: _placed.isEmpty
                    ? Center(
                        child: Text(
                          Strings.orderingHint,
                          style: WrType.bodyMd.copyWith(color: c.muted),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _placed.length; i++)
                            _slot(_placed[i], i),
                        ],
                      ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // The word bank doubles as a drop target, so dragging a placed word
        // back down removes it. It only accepts words that are actually placed.
        DragTarget<_DragData>(
          onWillAcceptWithDetails: (d) =>
              widget.enabled && _placed.contains(d.data.word),
          onAcceptWithDetails: (d) => _removeFromPlaced(d.data.word),
          builder: (context, candidate, rejected) {
            return AnimatedSize(
              duration: WrTokens.animNormal,
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final word in _bank)
                    _MoveIn(
                      key: ValueKey('b_${word.id}'),
                      begin: const Offset(0, -0.5),
                      child: _tile(
                        word,
                        onTap: () => _placeAt(word, null),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// A placed word wrapped in its own drop target, where a drop means insert
  /// before this word. This is what makes precise reordering possible.
  Widget _slot(ExerciseOption word, int index) {
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (d) => widget.enabled && d.data.word != word,
      onAcceptWithDetails: (d) => _placeAt(d.data.word, index),
      builder: (context, candidate, rejected) {
        final showGap = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: WrTokens.animFast,
          curve: Curves.easeOut,
          // Opens a gap on hover so the drop position is visible before release.
          padding: EdgeInsets.only(left: showGap ? 14 : 0),
          child: _MoveIn(
            key: ValueKey('p_${word.id}'),
            begin: const Offset(0, 0.5),
            child: _tile(
              word,
              onTap: () => _removeFromPlaced(word),
            ),
          ),
        );
      },
    );
  }

  Widget _tile(ExerciseOption word, {required VoidCallback onTap}) {
    final visual = _TileVisual(text: word.text);
    if (!widget.enabled) return visual;
    return Draggable<_DragData>(
      data: _DragData(word),
      feedback: Material(
        type: MaterialType.transparency,
        child: _TileVisual(text: word.text, dragging: true),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: visual),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: visual,
      ),
    );
  }
}

/// Slides its child in from [begin], expressed as a fraction of its own size.
///
/// A pure transform with no fade, so a word reads as moving between the bank
/// and the tray rather than disappearing from one and appearing in the other.
/// The caller keys this by word id plus area, which is what stops untouched
/// tiles from replaying the animation every time the layout reflows.
class _MoveIn extends StatefulWidget {
  const _MoveIn({required this.child, required this.begin, super.key});

  final Widget child;
  final Offset begin;

  @override
  State<_MoveIn> createState() => _MoveInState();
}

class _MoveInState extends State<_MoveIn> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: widget.begin,
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SlideTransition(position: _slide, child: widget.child);
}

class _TileVisual extends StatelessWidget {
  const _TileVisual({required this.text, this.dragging = false});

  final String text;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    return AnimatedScale(
      scale: dragging ? 1.06 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: c.surfaceTop,
          borderRadius: BorderRadius.circular(WrTokens.rMd),
          border: Border.all(color: dragging ? c.accent : c.line),
          // A dragged tile lifts higher so it reads as above the sheet.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dragging ? 0.16 : 0.06),
              blurRadius: dragging ? 14 : 8,
              offset: Offset(0, dragging ? 6 : 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: WrType.bodyMd.copyWith(
            color: c.ink,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
