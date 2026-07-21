import 'package:flutter/material.dart';

import '../theme/wr_theme.dart';
import '../theme/wr_tokens.dart';

/// Semantic colour treatment for a card.
enum WrSurfaceVariant { neutral, accent, danger, warn, gold, cool }

/// The one card primitive. Every panel in the app is a [WrSurface] rather than a
/// hand-rolled Container, so border, radius, shadow and the tinted variants stay
/// consistent and a change to card styling happens in one place.
class WrSurface extends StatelessWidget {
  const WrSurface({
    required this.child,
    super.key,
    this.variant = WrSurfaceVariant.neutral,
    this.padding,
    this.radius = WrTokens.rLg,
    this.shine = true,
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final WrSurfaceVariant variant;
  final EdgeInsetsGeometry? padding;
  final double radius;

  /// Draws the 1px top highlight in dark mode. Off for cards that sit on top of
  /// another card, where a second highlight reads as a seam.
  final bool shine;

  /// Overrides the variant's default border, for a card tinted by content.
  final Color? borderColor;

  final VoidCallback? onTap;

  Color _borderColor(WrColors c) => switch (variant) {
        WrSurfaceVariant.accent => c.accentLine,
        WrSurfaceVariant.danger => c.danger.withValues(alpha: 0.22),
        WrSurfaceVariant.warn => c.warn.withValues(alpha: 0.22),
        WrSurfaceVariant.gold => c.gold.withValues(alpha: 0.22),
        WrSurfaceVariant.cool => c.cool.withValues(alpha: 0.22),
        WrSurfaceVariant.neutral => c.line,
      };

  Color _tintColor(WrColors c) => switch (variant) {
        WrSurfaceVariant.accent => c.accentSoft,
        WrSurfaceVariant.danger => c.dangerSoft,
        WrSurfaceVariant.warn => c.warnSoft,
        WrSurfaceVariant.gold => c.goldSoft,
        WrSurfaceVariant.cool => c.coolSoft,
        WrSurfaceVariant.neutral => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.wr;
    final shadows = c.isDark ? WrTokens.darkShadowSoft : WrTokens.lightShadowSoft;
    final tint = _tintColor(c);

    final Widget content = Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [c.surfaceTop, c.surfaceBot],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor ?? _borderColor(c)),
            boxShadow: shadows,
          ),
          // Clipped one pixel tighter than the border so the tint overlay does
          // not paint over the border itself.
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - 1),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                if (tint != Colors.transparent)
                  Positioned.fill(child: ColoredBox(color: tint)),
                Padding(
                  padding: padding ?? const EdgeInsets.all(WrTokens.s16),
                  child: child,
                ),
              ],
            ),
          ),
        ),
        if (shine && c.isDark)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: WrTokens.darkShineGradient,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return _Pressable(onTap: onTap!, child: content);
    }
    return content;
  }
}

/// Press feedback shared by every tappable card: a small scale-down on touch
/// plus a light haptic, applied here once rather than at each call site.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: WrTokens.animSnap,
        child: widget.child,
      ),
    );
  }
}
