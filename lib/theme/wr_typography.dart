import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale. A serif for anything the learner reads as language (the exercise
/// sentence, example sentences) and a sans for UI chrome, so the two never get
/// confused for each other.
class WrType {
  WrType._();

  // Display, used for the exercise sentence itself.
  static TextStyle get displayLg => GoogleFonts.newsreader(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.8,
        height: 1.05,
      );
  static TextStyle get displayMd => GoogleFonts.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        height: 1.1,
      );
  static TextStyle get displaySm => GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
        height: 1.15,
      );

  // Serif body, for example sentences and italic asides.
  static TextStyle get serifMd => GoogleFonts.newsreader(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );
  static TextStyle get serifSm => GoogleFonts.newsreader(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // UI sans.
  static TextStyle get titleMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );
  static TextStyle get titleSm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  /// Uppercase eyebrow above a section heading.
  static TextStyle get eyebrow => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );
}
