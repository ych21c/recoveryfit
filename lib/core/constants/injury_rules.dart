/// Maps body-part injury keywords → exercise exclusion tags.
/// The pipeline applies these BEFORE sending candidates to the LLM,
/// and re-validates the LLM output server-side.
class InjuryRules {
  InjuryRules._();

  // Korean injury keyword fragments → canonical body-part key
  static const Map<String, String> keywordToBodyPart = {
    '무릎': 'knee',
    '슬': 'knee',
    '허리': 'lower_back',
    '요추': 'lower_back',
    '디스크': 'lower_back',
    '어깨': 'shoulder',
    '회전근': 'shoulder',
    '목': 'neck',
    '경추': 'neck',
    '발목': 'ankle',
    '족관절': 'ankle',
    '고관절': 'hip',
    '엉덩이관절': 'hip',
    '손목': 'wrist',
    '팔꿈치': 'elbow',
    '테니스엘보': 'elbow',
    '골프엘보': 'elbow',
    '흉부': 'chest_rib',
    '갈비': 'chest_rib',
    '햄스트링': 'hamstring',
    '대퇴이두': 'hamstring',
    '종아리': 'calf',
    '비복근': 'calf',
    '전완': 'forearm',
  };

  /// body-part key → list of exercise exclusion tags
  static const Map<String, List<String>> exclusionRules = {
    'knee': [
      'jump',
      'deep_squat',
      'lunge',
      'box_jump',
      'running',
      'stair_climb_loaded',
      'leg_extension_heavy',
      'squat_jump',
    ],
    'lower_back': [
      'deadlift',
      'good_morning',
      'sit_up',
      'leg_raise_hanging',
      'bent_over_row',
      'jefferson_curl',
      'spine_flexion_loaded',
      'hyperextension_loaded',
    ],
    'shoulder': [
      'overhead_press',
      'upright_row',
      'dip',
      'lat_pulldown_wide_grip',
      'behind_neck_press',
      'shoulder_impingement_risk',
    ],
    'neck': [
      'overhead_press',
      'shrug_heavy',
      'neck_extension_loaded',
      'behind_neck_press',
      'cervical_compression',
    ],
    'ankle': [
      'jump',
      'box_jump',
      'running',
      'calf_raise_standing_heavy',
      'single_leg_balance_heavy',
      'lateral_bound',
    ],
    'hip': [
      'deep_squat',
      'lunge',
      'hip_thrust_heavy',
      'leg_press_deep',
      'pistol_squat',
    ],
    'wrist': [
      'push_up',
      'plank',
      'barbell_curl',
      'front_raise_barbell',
      'wrist_loaded',
      'handstand',
    ],
    'elbow': [
      'tricep_dip',
      'preacher_curl',
      'overhead_tricep_extension',
      'close_grip_bench',
      'elbow_flexion_heavy',
    ],
    'chest_rib': [
      'bench_press',
      'push_up',
      'dip',
      'cable_fly',
      'dumbbell_fly',
      'chest_compression',
    ],
    'hamstring': [
      'deadlift',
      'leg_curl_heavy',
      'sprint',
      'nordic_curl',
      'stiff_leg_deadlift',
    ],
    'calf': [
      'calf_raise',
      'jump',
      'running',
      'box_jump',
      'single_leg_calf_raise',
    ],
    'forearm': [
      'wrist_curl',
      'farmer_carry_heavy',
      'reverse_curl_heavy',
    ],
  };

  /// Detect body parts from free-text injury description.
  static List<String> detectBodyParts(String injuryText) {
    final lower = injuryText.toLowerCase();
    final found = <String>{};
    for (final entry in keywordToBodyPart.entries) {
      if (lower.contains(entry.key)) {
        found.add(entry.value);
      }
    }
    return found.toList();
  }

  /// Collect all exclusion tags for the detected body parts.
  static Set<String> getExclusionTags(List<String> bodyParts) {
    final tags = <String>{};
    for (final part in bodyParts) {
      tags.addAll(exclusionRules[part] ?? []);
    }
    return tags;
  }
}
