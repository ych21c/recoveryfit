import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_fit/core/constants/injury_rules.dart';

void main() {
  test('InjuryRules detects knee body part from Korean text', () {
    final parts = InjuryRules.detectBodyParts('무릎 인대 나갔어요');
    expect(parts, contains('knee'));
  });

  test('InjuryRules returns exclusion tags for knee', () {
    final tags = InjuryRules.getExclusionTags(['knee']);
    expect(tags, contains('jump'));
    expect(tags, contains('deep_squat'));
    expect(tags, contains('lunge'));
  });

  test('InjuryRules detects lower_back from 허리', () {
    final parts = InjuryRules.detectBodyParts('허리가 너무 아파요');
    expect(parts, contains('lower_back'));
  });
}
