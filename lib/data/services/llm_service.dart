import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../models/exercise.dart';
import '../models/user_profile.dart';
import '../models/workout_plan.dart';

class LlmCallLimitException implements Exception {
  @override
  String toString() =>
      '이번 달 AI 호출 한도(${AppConstants.maxMonthlyLlmCalls}회)에 도달했습니다. 다음 달에 갱신됩니다.';
}

class LlmService {
  LlmService._();
  static final LlmService instance = LlmService._();

  static const _anthropicVersion = '2023-06-01';

  Future<WorkoutPlan> generateInitialPlan({
    required String apiKey,
    required UserProfile profile,
    required List<Exercise> allowedExercises,
    required Set<String> exclusionTags,
  }) async {
    final prompt = _buildInitialPlanPrompt(
      profile: profile,
      allowedExercises: allowedExercises,
      exclusionTags: exclusionTags,
    );

    final raw = await _callAnthropic(
      apiKey: apiKey,
      model: AppConstants.initialPlanModel,
      prompt: prompt,
    );

    final planJson = _extractJson(raw);
    return WorkoutPlan.fromJson(planJson, profile.id);
  }

  Future<WorkoutPlan> adjustWeeklyPlan({
    required String apiKey,
    required UserProfile profile,
    required WorkoutPlan currentPlan,
    required List<Exercise> allowedExercises,
    required Set<String> exclusionTags,
    required Map<String, dynamic> weekSummary,
  }) async {
    final prompt = _buildWeeklyAdjustPrompt(
      profile: profile,
      currentPlan: currentPlan,
      allowedExercises: allowedExercises,
      exclusionTags: exclusionTags,
      weekSummary: weekSummary,
    );

    final raw = await _callAnthropic(
      apiKey: apiKey,
      model: AppConstants.weeklyAdjustModel,
      prompt: prompt,
    );

    final planJson = _extractJson(raw);
    return WorkoutPlan.fromJson(planJson, profile.id);
  }

  Future<String> _callAnthropic({
    required String apiKey,
    required String model,
    required String prompt,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.anthropicBaseUrl}/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': _anthropicVersion,
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'max_tokens': AppConstants.maxOutputTokens,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Anthropic API error ${response.statusCode}: ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content = (body['content'] as List).first as Map<String, dynamic>;
    return content['text'] as String;
  }

  Map<String, dynamic> _extractJson(String raw) {
    // LLM may wrap JSON in markdown code fences; strip them
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw FormatException('LLM response does not contain valid JSON:\n$raw');
    }
    return jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
  }

  String _buildInitialPlanPrompt({
    required UserProfile profile,
    required List<Exercise> allowedExercises,
    required Set<String> exclusionTags,
  }) {
    final exerciseListJson = jsonEncode(
      allowedExercises
          .map((e) => {
                'id': e.id,
                'name_ko': e.nameKo,
                'muscle_groups': e.muscleGroups,
                'equipment': e.equipment,
                'difficulty': e.difficulty,
                'phase_tags': e.phaseTags,
              })
          .toList(),
    );

    final goalLabel = _goalLabel(profile.goalEnum);
    final envLabel = _envLabel(profile.environmentEnum);

    return '''
당신은 공인 트레이너입니다. 아래 사용자 프로필에 맞는 4주 운동 플랜을 JSON으로 생성하세요.

## 절대 규칙 (반드시 준수)
1. ALLOWED_EXERCISES에 있는 exercise_id만 사용하세요.
2. EXCLUDED_TAGS가 safety_tags에 포함된 운동은 절대 선택하지 마세요: ${exclusionTags.join(', ')}
3. 아래 JSON 스키마를 정확히 따르세요.
4. 설명 없이 JSON만 출력하세요.

## 사용자 프로필
- 부상/통증: ${profile.injuryDescription}
- 통증 수준: ${profile.painLevel}/10
- 목표: $goalLabel
- 운동 빈도: 주 ${profile.weeklyFrequency}회
- 운동 환경: $envLabel
- 보유 장비: ${profile.equipment.join(', ')}
- 감지된 부위: ${profile.detectedBodyParts.join(', ')}

## 운동 목록 (ALLOWED_EXERCISES)
$exerciseListJson

## 출력 JSON 스키마
{
  "plan_id": "string (UUID)",
  "created_at": "ISO8601",
  "total_weeks": 4,
  "safety_disclaimer": "⚠️ 의료기기가 아님. 전문의 상담 권장.",
  "weeks": [
    {
      "week": 1,
      "theme": "string (주제 예: 안정화 및 활성화)",
      "progression_note": "string",
      "days": [
        {
          "day_of_week": 1,
          "focus_area": "string",
          "estimated_duration_minutes": 40,
          "exercises": [
            {
              "exercise_id": "ex001",
              "phase": "warmup|rehab|main|cooldown",
              "sets": 3,
              "reps": "10-12",
              "rest_seconds": 60,
              "intensity_note": "RPE 5-6",
              "coach_note": "string"
            }
          ]
        }
      ]
    }
  ]
}

## 가이드라인
- 주 ${profile.weeklyFrequency}일 운동일 배정 (day_of_week: 1=월~7=일)
- 각 세션: warmup 2–3개 → rehab/main 4–6개 → cooldown 1–2개 순서
- 통증 수준 ${profile.painLevel}을 고려해 초기 강도는 낮게, 4주차로 갈수록 점진적으로 강도 증가
- 동일 근육군 연속 배정 금지
''';
  }

  String _buildWeeklyAdjustPrompt({
    required UserProfile profile,
    required WorkoutPlan currentPlan,
    required List<Exercise> allowedExercises,
    required Set<String> exclusionTags,
    required Map<String, dynamic> weekSummary,
  }) {
    final exerciseListJson = jsonEncode(
      allowedExercises
          .map((e) => {'id': e.id, 'name_ko': e.nameKo, 'phase_tags': e.phaseTags})
          .toList(),
    );
    final summaryJson = jsonEncode(weekSummary);
    final envLabel = _envLabel(profile.environmentEnum);

    return '''
당신은 공인 트레이너입니다. 지난 7일 기록을 바탕으로 운동 플랜을 조정하세요.

## 절대 규칙
1. ALLOWED_EXERCISES에 있는 exercise_id만 사용하세요.
2. EXCLUDED_TAGS 포함 운동 금지: ${exclusionTags.join(', ')}
3. 동일한 JSON 스키마로 4주 플랜 전체를 반환하세요.
4. JSON만 출력하세요.

## 사용자 정보
- 부상/통증: ${profile.injuryDescription}
- 목표: ${_goalLabel(profile.goalEnum)}
- 환경: $envLabel

## 지난 7일 요약
$summaryJson

## 운동 목록
$exerciseListJson

## 조정 지침
- 완료율 < 70%이면 난이도/볼륨 감소
- 통증 증가 트렌드면 해당 부위 부하 감소
- 완료율 > 90%이고 통증 감소면 볼륨 5–10% 증가
- 자주 스킵된 운동은 유사 대체 운동으로 교체

## 출력 스키마 (초기 플랜과 동일)
{
  "plan_id": "string",
  "created_at": "ISO8601",
  "total_weeks": 4,
  "safety_disclaimer": "⚠️ 의료기기가 아님. 전문의 상담 권장.",
  "weeks": [ ... ]
}
''';
  }

  String _goalLabel(WorkoutGoal goal) => switch (goal) {
        WorkoutGoal.muscleGain => '근육량 증가',
        WorkoutGoal.recovery => '회복(재활)',
        WorkoutGoal.weightLoss => '체중감소',
      };

  String _envLabel(WorkoutEnvironment env) => switch (env) {
        WorkoutEnvironment.home => '집',
        WorkoutEnvironment.gym => '헬스장',
        WorkoutEnvironment.both => '집+헬스장',
      };
}
