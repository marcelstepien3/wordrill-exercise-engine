import 'package:flutter/material.dart';

/// Raw design tokens. Nothing in the UI hardcodes a colour, radius or duration;
/// everything resolves through here so the two themes stay in step.
class WrTokens {
  WrTokens._();

  // Light theme. A warm paper background rather than pure white, with
  // off-white cards that still lift off it.
  static const lightBg = Color(0xFFEAE8DE);
  static const lightSurfaceTop = Color(0xFFF7F1E4);
  static const lightSurfaceBot = Color(0xFFF1EAD9);
  static const lightInk = Color(0xFF18160F);
  static const lightInk2 = Color(0xFF2A2620);
  static const lightTextDim = Color(0xFF5A564D);
  static const lightMuted = Color(0xFF827D72);
  static const lightMutedDim = Color(0xFFB0A99B);
  static const lightLine = Color(0x1A18160F);
  static const lightLineStrong = Color(0x2E18160F);
  static const lightAccent = Color(0xFF3F6A4D);
  static const lightAccentHi = Color(0xFF5A8C6A);
  static const lightAccentSoft = Color(0x1A3F6A4D);
  static const lightAccentLine = Color(0x523F6A4D);
  static const lightOnAccent = Color(0xFFFBF8EE);
  static const lightGold = Color(0xFF9B7822);
  static const lightGoldSoft = Color(0x1F9B7822);
  static const lightWarn = Color(0xFFB56A35);
  static const lightWarnSoft = Color(0x1AB56A35);
  static const lightDanger = Color(0xFFA14242);
  static const lightDangerSoft = Color(0x1AA14242);
  static const lightCool = Color(0xFF3F6A8F);
  static const lightCoolSoft = Color(0x1A3F6A8F);

  // Dark theme. Elevation is carried by the bg -> surface steps, not by
  // Material's default overlay.
  static const darkBg = Color(0xFF111728);
  static const darkSurfaceTop = Color(0xFF252F49);
  static const darkSurfaceBot = Color(0xFF1E2840);
  static const darkInk = Color(0xFFE6EBF2);
  static const darkInk2 = Color(0xFFC5CBD6);
  static const darkTextDim = Color(0xFF8E94A0);
  static const darkMuted = Color(0xFF6D7280);
  static const darkMutedDim = Color(0xFF494E58);
  static const darkLine = Color(0x12E6EBF2);
  static const darkLineStrong = Color(0x24E6EBF2);
  static const darkAccent = Color(0xFF92BAA1);
  static const darkAccentHi = Color(0xFFAED3B8);
  static const darkAccentSoft = Color(0x1A92BAA1);
  static const darkAccentLine = Color(0x5292BAA1);
  static const darkOnAccent = Color(0xFF131A2D);
  static const darkGold = Color(0xFFD9B97A);
  static const darkGoldSoft = Color(0x24D9B97A);
  static const darkWarn = Color(0xFFE0A574);
  static const darkWarnSoft = Color(0x24E0A574);
  static const darkDanger = Color(0xFFE08585);
  static const darkDangerSoft = Color(0x24E08585);
  static const darkCool = Color(0xFF8EB0D4);
  static const darkCoolSoft = Color(0x248EB0D4);

  // Animation durations. Shared so a press, a fade and a layout shift that
  // happen together actually finish together.
  static const animSnap = Duration(milliseconds: 90);
  static const animFast = Duration(milliseconds: 160);
  static const animNormal = Duration(milliseconds: 200);
  static const animSlow = Duration(milliseconds: 300);

  // Radii
  static const rSm = 8.0;
  static const rMd = 14.0;
  static const rLg = 18.0;
  static const rXl = 24.0;

  // Spacing, 4pt scale
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s22 = 22.0;
  static const s24 = 24.0;

  static const lightShadowSoft = [
    BoxShadow(
      color: Color(0x1418160F),
      blurRadius: 20,
      offset: Offset(0, 6),
      spreadRadius: -8,
    ),
  ];
  static const darkShadowSoft = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -10,
    ),
  ];

  /// 1px highlight along the top edge of a dark card. Light mode gets its
  /// lift from the drop shadow instead, so this is only used when isDark.
  static const darkShineGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x26FFFFFF),
      Color(0x3DFFFFFF),
      Color(0x26FFFFFF),
      Colors.transparent,
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
}
