/// Maps a total XP figure onto a level, a title and a progress fraction.
///
/// This is presentation only. The production app treats the server's level as
/// authoritative and uses this to render the progress bar between two known
/// thresholds, which is why every method is a pure function of its arguments
/// and nothing here mutates or persists state.
class LevelCalculator {
  LevelCalculator._();

  static const int maxLevel = 20;

  /// Levels 1 to 10 follow a geometric curve so early progress feels quick.
  /// Levels 11 to 20 flatten to 3000 XP per level, turning the tail into a
  /// steady grind rather than an exponential wall.
  static const List<int> _xpThresholds = [
    0, // L1
    100, // L2
    300, // L3
    700, // L4
    1500, // L5
    3000, // L6
    5500, // L7
    10000, // L8
    18000, // L9
    30000, // L10
    33000, // L11
    36000, // L12
    39000, // L13
    42000, // L14
    45000, // L15
    48000, // L16
    51000, // L17
    54000, // L18
    57000, // L19
    60000, // L20
  ];

  static const List<String> _titles = [
    'Beginner',
    'Learner',
    'Student',
    'Apprentice',
    'Practitioner',
    'Achiever',
    'Expert',
    'Master',
    'Grand Master',
    'Grammar King',
    'Grammar Legend',
    'Grammar Sage',
    'Grammar Oracle',
    'Grammar Virtuoso',
    'Grammar Wizard',
    'Grammar Champion',
    'Grammar Titan',
    'Grammar Hero',
    'Grammar Deity',
    'Grammar Immortal',
  ];

  /// The top level, where the progress bar sits full and stops moving.
  static bool isPrestige(int level) => level >= maxLevel;

  /// Resolves total XP to a level. Walks down from the top so the highest
  /// threshold that has been passed wins.
  static int levelForXp(int totalXp) {
    for (var level = maxLevel; level >= 1; level--) {
      if (totalXp >= _xpThresholds[level - 1]) return level;
    }
    return 1;
  }

  static int xpThresholdForLevel(int level) {
    final index = level.clamp(1, maxLevel) - 1;
    return _xpThresholds[index];
  }

  static int xpThresholdForNextLevel(int level) {
    if (level >= maxLevel) return _xpThresholds[maxLevel - 1];
    return _xpThresholds[level.clamp(1, maxLevel - 1)];
  }

  static String titleForLevel(int level) {
    final index = level.clamp(1, maxLevel) - 1;
    return _titles[index];
  }

  /// XP earned inside the current level, the numerator of the progress bar.
  static int xpWithinLevel(int totalXp, int level) {
    final range = xpRangeForLevel(level);
    if (isPrestige(level)) return range;
    return (totalXp - xpThresholdForLevel(level)).clamp(0, range);
  }

  /// Width of the current level in XP, the denominator of the progress bar.
  static int xpRangeForLevel(int level) {
    if (level >= maxLevel) {
      return _xpThresholds[maxLevel - 1] - _xpThresholds[maxLevel - 2];
    }
    return xpThresholdForNextLevel(level) - xpThresholdForLevel(level);
  }

  /// Progress through the current level, 0.0 to 1.0. Guards the divide because
  /// a malformed threshold table would otherwise produce NaN and silently blank
  /// the bar rather than fail loudly.
  static double progressForXp(int totalXp, int level) {
    final range = xpRangeForLevel(level);
    if (range <= 0) return 1;
    return (xpWithinLevel(totalXp, level) / range).clamp(0.0, 1.0);
  }
}
