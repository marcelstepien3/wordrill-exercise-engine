import 'package:flutter_test/flutter_test.dart';
import 'package:wordrill_exercise_engine/domain/level_calculator.dart';

void main() {
  group('levelForXp', () {
    test('starts at level 1 with no XP', () {
      expect(LevelCalculator.levelForXp(0), 1);
    });

    test('stays on a level until the next threshold is reached', () {
      expect(LevelCalculator.levelForXp(99), 1);
      expect(LevelCalculator.levelForXp(100), 2);
      expect(LevelCalculator.levelForXp(299), 2);
      expect(LevelCalculator.levelForXp(300), 3);
    });

    test('caps at the maximum level', () {
      expect(LevelCalculator.levelForXp(60000), LevelCalculator.maxLevel);
      expect(LevelCalculator.levelForXp(999999), LevelCalculator.maxLevel);
    });

    test('treats negative XP as level 1 rather than throwing', () {
      expect(LevelCalculator.levelForXp(-50), 1);
    });
  });

  group('progress within a level', () {
    test('reports the fraction between two thresholds', () {
      // Level 2 spans 100 to 300, so 200 XP is halfway.
      expect(LevelCalculator.xpWithinLevel(200, 2), 100);
      expect(LevelCalculator.xpRangeForLevel(2), 200);
      expect(LevelCalculator.progressForXp(200, 2), 0.5);
    });

    test('is empty at the exact moment a level begins', () {
      expect(LevelCalculator.progressForXp(100, 2), 0.0);
    });

    test('shows a full bar at the maximum level', () {
      expect(LevelCalculator.isPrestige(LevelCalculator.maxLevel), isTrue);
      expect(
        LevelCalculator.progressForXp(60000, LevelCalculator.maxLevel),
        1.0,
      );
    });

    test('clamps rather than overflowing when XP exceeds the level', () {
      expect(LevelCalculator.progressForXp(999999, 2), 1.0);
    });
  });

  group('titles', () {
    test('returns a title for every valid level', () {
      for (var level = 1; level <= LevelCalculator.maxLevel; level++) {
        expect(LevelCalculator.titleForLevel(level), isNotEmpty);
      }
    });

    test('clamps out of range levels instead of throwing', () {
      expect(LevelCalculator.titleForLevel(0), 'Beginner');
      expect(LevelCalculator.titleForLevel(999), 'Grammar Immortal');
    });
  });
}
