import 'package:flutter/material.dart';

import 'wr_tokens.dart';

/// Semantic colour set exposed as a [ThemeExtension].
///
/// Widgets never reach for a raw token or a `Colors.*` constant. They ask for a
/// role (`accent`, `danger`, `line`) and the extension resolves it for whichever
/// theme is active, which is what makes the same renderer work in both modes
/// without a single `isDark` branch in the widget tree.
@immutable
class WrColors extends ThemeExtension<WrColors> {
  const WrColors({
    required this.bg,
    required this.surfaceTop,
    required this.surfaceBot,
    required this.ink,
    required this.ink2,
    required this.textDim,
    required this.muted,
    required this.mutedDim,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.accentHi,
    required this.accentSoft,
    required this.accentLine,
    required this.onAccent,
    required this.gold,
    required this.goldSoft,
    required this.warn,
    required this.warnSoft,
    required this.danger,
    required this.dangerSoft,
    required this.cool,
    required this.coolSoft,
    required this.isDark,
  });

  factory WrColors.light() => const WrColors(
        bg: WrTokens.lightBg,
        surfaceTop: WrTokens.lightSurfaceTop,
        surfaceBot: WrTokens.lightSurfaceBot,
        ink: WrTokens.lightInk,
        ink2: WrTokens.lightInk2,
        textDim: WrTokens.lightTextDim,
        muted: WrTokens.lightMuted,
        mutedDim: WrTokens.lightMutedDim,
        line: WrTokens.lightLine,
        lineStrong: WrTokens.lightLineStrong,
        accent: WrTokens.lightAccent,
        accentHi: WrTokens.lightAccentHi,
        accentSoft: WrTokens.lightAccentSoft,
        accentLine: WrTokens.lightAccentLine,
        onAccent: WrTokens.lightOnAccent,
        gold: WrTokens.lightGold,
        goldSoft: WrTokens.lightGoldSoft,
        warn: WrTokens.lightWarn,
        warnSoft: WrTokens.lightWarnSoft,
        danger: WrTokens.lightDanger,
        dangerSoft: WrTokens.lightDangerSoft,
        cool: WrTokens.lightCool,
        coolSoft: WrTokens.lightCoolSoft,
        isDark: false,
      );

  factory WrColors.dark() => const WrColors(
        bg: WrTokens.darkBg,
        surfaceTop: WrTokens.darkSurfaceTop,
        surfaceBot: WrTokens.darkSurfaceBot,
        ink: WrTokens.darkInk,
        ink2: WrTokens.darkInk2,
        textDim: WrTokens.darkTextDim,
        muted: WrTokens.darkMuted,
        mutedDim: WrTokens.darkMutedDim,
        line: WrTokens.darkLine,
        lineStrong: WrTokens.darkLineStrong,
        accent: WrTokens.darkAccent,
        accentHi: WrTokens.darkAccentHi,
        accentSoft: WrTokens.darkAccentSoft,
        accentLine: WrTokens.darkAccentLine,
        onAccent: WrTokens.darkOnAccent,
        gold: WrTokens.darkGold,
        goldSoft: WrTokens.darkGoldSoft,
        warn: WrTokens.darkWarn,
        warnSoft: WrTokens.darkWarnSoft,
        danger: WrTokens.darkDanger,
        dangerSoft: WrTokens.darkDangerSoft,
        cool: WrTokens.darkCool,
        coolSoft: WrTokens.darkCoolSoft,
        isDark: true,
      );

  final Color bg;
  final Color surfaceTop;
  final Color surfaceBot;
  final Color ink;
  final Color ink2;
  final Color textDim;
  final Color muted;
  final Color mutedDim;
  final Color line;
  final Color lineStrong;
  final Color accent;
  final Color accentHi;
  final Color accentSoft;
  final Color accentLine;
  final Color onAccent;
  final Color gold;
  final Color goldSoft;
  final Color warn;
  final Color warnSoft;
  final Color danger;
  final Color dangerSoft;
  final Color cool;
  final Color coolSoft;
  final bool isDark;

  @override
  WrColors copyWith({
    Color? bg,
    Color? surfaceTop,
    Color? surfaceBot,
    Color? ink,
    Color? ink2,
    Color? textDim,
    Color? muted,
    Color? mutedDim,
    Color? line,
    Color? lineStrong,
    Color? accent,
    Color? accentHi,
    Color? accentSoft,
    Color? accentLine,
    Color? onAccent,
    Color? gold,
    Color? goldSoft,
    Color? warn,
    Color? warnSoft,
    Color? danger,
    Color? dangerSoft,
    Color? cool,
    Color? coolSoft,
    bool? isDark,
  }) =>
      WrColors(
        bg: bg ?? this.bg,
        surfaceTop: surfaceTop ?? this.surfaceTop,
        surfaceBot: surfaceBot ?? this.surfaceBot,
        ink: ink ?? this.ink,
        ink2: ink2 ?? this.ink2,
        textDim: textDim ?? this.textDim,
        muted: muted ?? this.muted,
        mutedDim: mutedDim ?? this.mutedDim,
        line: line ?? this.line,
        lineStrong: lineStrong ?? this.lineStrong,
        accent: accent ?? this.accent,
        accentHi: accentHi ?? this.accentHi,
        accentSoft: accentSoft ?? this.accentSoft,
        accentLine: accentLine ?? this.accentLine,
        onAccent: onAccent ?? this.onAccent,
        gold: gold ?? this.gold,
        goldSoft: goldSoft ?? this.goldSoft,
        warn: warn ?? this.warn,
        warnSoft: warnSoft ?? this.warnSoft,
        danger: danger ?? this.danger,
        dangerSoft: dangerSoft ?? this.dangerSoft,
        cool: cool ?? this.cool,
        coolSoft: coolSoft ?? this.coolSoft,
        isDark: isDark ?? this.isDark,
      );

  /// Interpolates every role so a light/dark switch animates instead of
  /// snapping. [isDark] flips at the halfway point because a bool cannot be
  /// meaningfully interpolated.
  @override
  WrColors lerp(ThemeExtension<WrColors>? other, double t) {
    if (other is! WrColors) return this;
    return WrColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surfaceTop: Color.lerp(surfaceTop, other.surfaceTop, t)!,
      surfaceBot: Color.lerp(surfaceBot, other.surfaceBot, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedDim: Color.lerp(mutedDim, other.mutedDim, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentHi: Color.lerp(accentHi, other.accentHi, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentLine: Color.lerp(accentLine, other.accentLine, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      warnSoft: Color.lerp(warnSoft, other.warnSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      cool: Color.lerp(cool, other.cool, t)!,
      coolSoft: Color.lerp(coolSoft, other.coolSoft, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Shorthand accessor so widgets can write `final c = context.wr;`.
extension WrColorsX on BuildContext {
  WrColors get wr => Theme.of(this).extension<WrColors>() ?? WrColors.dark();
}

ThemeData wrLightTheme() {
  final c = WrColors.light();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.accent,
      surface: c.surfaceTop,
    ),
    extensions: [c],
  );
}

ThemeData wrDarkTheme() {
  final c = WrColors.dark();
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: c.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: Brightness.dark,
      surface: c.surfaceTop,
    ),
    extensions: [c],
  );
}
