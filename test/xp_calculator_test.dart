import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_arcade/core/constants/app_constants.dart';
import 'package:pocket_arcade/core/utils/xp_calculator.dart';

void main() {
  group('XpCalculator', () {
    test('level 1 -> 2 costs the base amount', () {
      expect(XpCalculator.xpForLevel(1), AppConstants.baseXpPerLevel);
    });

    test('later levels require strictly more XP', () {
      expect(XpCalculator.xpForLevel(5),
          greaterThan(XpCalculator.xpForLevel(2)));
      expect(XpCalculator.xpForLevel(10),
          greaterThan(XpCalculator.xpForLevel(5)));
    });

    test('a player with 0 XP is level 1', () {
      expect(XpCalculator.levelForXp(0), 1);
    });

    test('crossing the level-1 threshold reaches level 2', () {
      final int needed = XpCalculator.xpForLevel(1);
      expect(XpCalculator.levelForXp(needed), 2);
      expect(XpCalculator.levelForXp(needed - 1), 1);
    });

    test('xpIntoLevel resets at each level boundary', () {
      final int needed = XpCalculator.xpForLevel(1);
      expect(XpCalculator.xpIntoLevel(needed), 0);
      expect(XpCalculator.xpIntoLevel(needed + 10), 10);
    });

    test('levelProgress stays within 0..1', () {
      for (final int xp in <int>[0, 50, 100, 250, 1000, 5000]) {
        final double p = XpCalculator.levelProgress(xp);
        expect(p, inInclusiveRange(0.0, 1.0));
      }
    });
  });
}
