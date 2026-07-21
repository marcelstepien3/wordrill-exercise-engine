import 'package:flutter/services.dart';

/// One call picks the haptic for an interaction, so the same gesture feels the
/// same everywhere instead of each widget choosing its own impact strength.
///
/// Named [AppFeedback] rather than `Feedback` because Flutter's material
/// library already exports a class by that name.
///
/// The full app pairs each of these with a sound cue behind a separate user
/// setting. Only the haptic half is included here, to keep the extract free of
/// audio assets.
class AppFeedback {
  AppFeedback._();

  /// Standard tap: buttons, tiles, list rows, chips.
  static void tap() => HapticFeedback.lightImpact();

  /// Heavier press, for primary actions and confirmations.
  static void press() => HapticFeedback.mediumImpact();

  /// Selection change: tabs, segmented controls, option toggles.
  static void select() => HapticFeedback.selectionClick();

  /// A correct answer or an unlocked reward.
  static void success() => HapticFeedback.mediumImpact();

  /// A wrong answer or a blocked action.
  static void error() => HapticFeedback.heavyImpact();

  /// Haptic with no paired sound, for spots where the parent widget already
  /// plays one and a second cue would double up.
  static void tick() => HapticFeedback.lightImpact();
}
