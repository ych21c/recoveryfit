# Software Architect
Project: c052dd6b | Stage: design

# Software Architect — RecoveryFit Architecture Update

**Project**: c052dd6b | **Stage**: design | **Version**: 1.3.0

> **작업 내용**: Planning 산출물(REQ-00-A/B/C) 반영 — SplashScreen 디자인 토큰 교체 + LandingScreen 신규 추가

---

## 변경 분석

| 구분 | v1.2.0 (기존) | v1.3.0 (이번) |
|------|--------------|--------------|
| SplashScreen 컬러 | `#4F8EF7` 블루 계열 | `#0D1B2A` 딥 네이비 + `#00C9A7` 민트 (PRD 확정값) |
| SplashScreen 로딩 | LinearProgressBar | 민트색 도트 3개 애니메이션 |
| SplashScreen 슬로건 | "부상을 딛고, 더 강하게" | "부상 후, 더 강하게" |
| LandingScreen | **미존재** | **신규 추가** |
| 라우팅 분기 | Splash → Onboarding / Home | Splash → **Landing** → Onboarding / Splash → Home |
| 디자인 토큰 | 비공식 하드코딩 | REQ-00-C 공식 토큰 체계 적용 |

---

```json
{
  "tech_stack": {
    "mobile_client": {
      "framework": "Flutter 3.22 (Dart 3.4)",
      "state_management": "Riverpod 2.x + flutter_hooks",
      "ui_kit": "Custom Design System (RecoveryFit DS v1.1)",
      "navigation": "GoRouter 14.x",
      "http_client": "Dio 5.x + Retrofit",
      "local_storage": "Hive 2.x (세션 캐시) + SharedPreferences (설정)",
      "animations": "flutter_animate 4.x",
      "push_notification": "firebase_messaging 15.x",
      "design_token_version": "1.1.0 (REQ-00-C 기준 — 딥 네이비/민트 시스템)"
    },
    "backend_api": {
      "runtime": "Node.js 20 (Fastify 4.x)",
      "ai_service": "Python 3.12 (FastAPI)",
      "orm": "Prisma 5.x",
      "validation": "Zod 3.x"
    },
    "ai_models": {
      "plan_generation": "claude-sonnet-4",
      "weekly_recalibration": "claude-haiku-4-5"
    },
    "database": {
      "primary": "PostgreSQL 15 (Supabase)",
      "cache": "Redis 7 (ElastiCache)",
      "storage": "AWS S3"
    },
    "auth": "Supabase Auth (JWT + RLS)",
    "push": "FCM + APNs via AWS SNS",
    "monitoring": "Sentry + Datadog APM",
    "ci_cd": "GitHub Actions → EAS Build → AWS ECS"
  },
  "api_spec": [
    {
      "id": "API-00",
      "method": "GET",
      "path": "/v1/auth/session-check",
      "service": "auth-service",
      "description": "앱 시작 시 기존 사용자 여부 확인 — disclaimer_agreed_at 존재 시 LandingScreen 스킵",
      "response": {
        "user_id": "uuid | null",
        "disclaimer_agreed": "boolean",
        "onboarding_completed": "boolean"
      },
      "auth_required": false,
      "screen": "SplashScreen",
      "routing_logic": {
        "신규_사용자": "disclaimer_agreed=false → LandingScreen",
        "기존_사용자": "disclaimer_agreed=true → HomeDashboardScreen"
      }
    },
    {
      "id": "API-01",
      "method": "POST",
      "path": "/v1/auth/signup",
      "service": "auth-service",
      "description": "소셜/이메일 회원가입",
      "request_body": {
        "email": "string",
        "provider": "enum(google,apple,email)"
      },
      "response": {
        "user_id": "uuid",
        "access_token": "string",
        "refresh_token": "string"
      },
      "auth_required": false,
      "step": 1
    },
    {
      "id": "API-02",
      "method": "POST",
      "path": "/v1/auth/refresh",
      "service": "auth-service",
      "description": "JWT 토큰 갱신",
      "request_body": { "refresh_token": "string" },
      "response": { "access_token": "string" },
      "auth_required": false,
      "step": 1
    },
    {
      "id": "API-03",
      "method": "POST",
      "path": "/v1/onboarding/profile",
      "service": "workout-service",
      "description": "온보딩 프로필 저장 (Step 1.1~1.6 완료 후 1회 호출)",
      "request_body": {
        "disclaimer_agreed_at": "timestamptz",
        "injury_description": "string(min:5)",
        "initial_pain_score": "integer(1-10)",
        "short_term_goal": "enum(pain_relief,mobility_recovery,injury_rehab)",
        "long_term_goal": "enum(stamina,muscle_gain,weight_loss)",
        "weekly_frequency": "integer(2-5)",
        "workout_location": "enum(home,gym,both)",
        "available_equipment": "string[]"
      },
      "response": { "user_id": "uuid", "status": "created" },
      "auth_required": true,
      "step": 1
    },
    {
      "id": "API-04",
      "method": "POST",
      "path": "/v1/plans/generate",
      "service": "ai-planner-service",
      "description": "4주 AI 운동 플랜 생성 (SSE 스트리밍)",
      "request_body": { "user_id": "uuid" },
      "response_stream": {
        "type": "SSE",
        "events": [
          "progress: {step: string, percent: integer}",
          "safety_check: {rule_id: string, passed: boolean}",
          "completed: {plan_id: uuid}"
        ]
      },
      "fallback": "polling /v1/plans/{plan_id}/status",
      "auth_required": true,
      "step": 2,
      "ai_model": "claude-sonnet-4",
      "timeout_seconds": 30
    },
    {
      "id": "API-05",
      "method": "GET",
      "path": "/v1/dashboard/today",
      "service": "workout-service",
      "description": "당일 운동 요약 카드 조회",
      "response": {
        "today_session": {
          "plan_session_id": "uuid",
          "exercises": "ExerciseSummary[5]",
          "estimated_duration_minutes": "integer"
        },
        "weekly_completion_rate": "float(0-100)",
        "current_pain_score": "integer(1-10)",
        "streak_days": "integer"
      },
      "cache": "Redis TTL 5min",
      "auth_required": true,
      "step": 3
    },
    {
      "id": "API-06",
      "method": "POST",
      "path": "/v1/sessions/bulk-complete",
      "service": "workout-service",
      "description": "오늘의 운동 일괄 완료",
      "request_body": {
        "plan_session_id": "uuid",
        "pain_score": "integer(1-10)"
      },
      "response": { "session_id": "uuid", "completed_at": "timestamptz" },
      "auth_required": true,
      "step": 3
    },
    {
      "id": "API-07",
      "method": "GET",
      "path": "/v1/sessions/{plan_session_id}/prefill",
      "service": "workout-service",
      "description": "세션 Pre-fill 데이터 조회",
      "response": {
        "exercises": [
          {
            "exercise_id": "uuid",
            "prefill_source": "enum(prev_session,ai_recommendation)",
            "sets": [
              {
                "set_number": "integer",
                "weight_kg": "decimal",
                "reps": "integer"
              }
            ]
          }
        ]
      },
      "cache": "Redis TTL 24h",
      "auth_required": true,
      "step": 4
    },
    {
      "id": "API-08",
      "method": "POST",
      "path": "/v1/sessions/start",
      "service": "workout-service",
      "description": "세션 시작 (타임스탬프 기록)",
      "request_body": { "plan_session_id": "uuid" },
      "response": { "workout_session_id": "uuid", "started_at": "timestamptz" },
      "auth_required": true,
      "step": 4
    },
    {
      "id": "API-09",
      "method": "POST",
      "path": "/v1/sessions/{session_id}/sets",
      "service": "workout-service",
      "description": "세트 완료 기록",
      "request_body": {
        "exercise_id": "uuid",
        "set_number": "integer",
        "actual_weight_kg": "decimal",
        "actual_reps": "integer",
        "prescribed_weight_kg": "decimal",
        "prescribed_reps": "integer"
      },
      "response": {
        "set_log_id": "uuid",
        "volume_kg": "decimal",
        "next_rest_seconds": "integer"
      },
      "optimistic_update": true,
      "auth_required": true,
      "step": 5
    },
    {
      "id": "API-10",
      "method": "PATCH",
      "path": "/v1/sessions/{session_id}/sets/{set_number}",
      "service": "workout-service",
      "description": "세트 수치 수정 (Quick-Edit)",
      "request_body": {
        "actual_weight_kg": "decimal?",
        "actual_reps": "integer?"
      },
      "response": { "set_log_id": "uuid", "volume_kg": "decimal" },
      "auth_required": true,
      "step": 5
    },
    {
      "id": "API-11",
      "method": "DELETE",
      "path": "/v1/sessions/{session_id}/sets/{set_number}",
      "service": "workout-service",
      "description": "세트 삭제",
      "response": { "deleted": true },
      "auth_required": true,
      "step": 5
    },
    {
      "id": "API-12",
      "method": "PATCH",
      "path": "/v1/sessions/{session_id}/exercises/{exercise_id}/skip",
      "service": "workout-service",
      "description": "운동 스킵 처리",
      "request_body": { "reason": "string?" },
      "response": { "skipped": true },
      "auth_required": true,
      "step": 3
    },
    {
      "id": "API-13",
      "method": "POST",
      "path": "/v1/sessions/{session_id}/complete",
      "service": "workout-service",
      "description": "세션 종료 및 통증 피드백 저장",
      "request_body": {
        "post_pain_score": "integer(1-10)",
        "pain_note": "string?"
      },
      "response": {
        "session_id": "uuid",
        "completed_at": "timestamptz",
        "total_volume_kg": "decimal",
        "summary": "SessionSummary"
      },
      "auth_required": true,
      "step": 6
    },
    {
      "id": "API-14",
      "method": "GET",
      "path": "/v1/analytics/pain-trend",
      "service": "analytics-service",
      "description": "통증 추이 그래프 데이터",
      "query_params": {
        "range": "enum(7d,30d)",
        "user_id": "uuid"
      },
      "response": {
        "data_points": [{ "date": "date", "pain_score": "integer", "note": "string?" }],
        "avg": "float",
        "min": "integer",
        "max": "integer",
        "trend": "enum(improving,stable,worsening)"
      },
      "auth_required": true,
      "step": 7
    },
    {
      "id": "API-15",
      "method": "GET",
      "path": "/v1/analytics/completion-rate",
      "service": "analytics-service",
      "description": "주간 운동 완료율",
      "query_params": { "weeks": "integer(default:4)" },
      "response": {
        "weekly_rates": [{ "week_label": "string", "rate_pct": "float", "days": "DayCompletion[7]" }]
      },
      "auth_required": true,
      "step": 7
    },
    {
      "id": "API-16",
      "method": "GET",
      "path": "/v1/analytics/volume-trend",
      "service": "analytics-service",
      "description": "주간 운동 볼륨 추이",
      "query_params": { "weeks": "integer(default:8)" },
      "response": {
        "weekly_volumes": [{ "week_label": "string", "total_volume_kg": "decimal", "growth_pct": "float" }],
        "pain_volume_correlation": "float(-1 to 1)"
      },
      "auth_required": true,
      "step": 7
    },
    {
      "id": "API-17",
      "method": "POST",
      "path": "/v1/plans/recalibrate",
      "service": "ai-planner-service",
      "description": "주간 Haiku 미세조정 플랜 생성",
      "request_body": {
        "user_id": "uuid",
        "week_summary": {
          "pain_avg": "float",
          "pain_min": "integer",
          "pain_max": "integer",
          "completion_rate_pct": "float",
          "total_volume_kg": "decimal",
          "completed_sessions": "integer"
        }
      },
      "response": {
        "recalibration_id": "uuid",
        "adjustments": [
          {
            "exercise_id": "uuid",
            "weight_delta_kg": "decimal",
            "sets_delta": "integer",
            "action": "enum(adjust,add,remove)"
          }
        ],
        "summary_text": "string"
      },
      "ai_model": "claude-haiku-4-5",
      "trigger": "cron: every Monday 09:00 user-local-timezone",
      "auth_required": true,
      "step": 8
    },
    {
      "id": "API-18",
      "method": "POST",
      "path": "/v1/plans/recalibrate/{recalibration_id}/approve",
      "service": "ai-planner-service",
      "description": "주간 미세조정 플랜 원터치 승인",
      "request_body": {},
      "response": {
        "next_week_plan_id": "uuid",
        "applied_at": "timestamptz"
      },
      "auth_required": true,
      "step": 8
    }
  ],
  "data_models": [
    {
      "table": "users",
      "description": "사용자 프로필 + 온보딩 데이터",
      "columns": {
        "id": "UUID PK DEFAULT gen_random_uuid()",
        "email": "TEXT UNIQUE NOT NULL",
        "created_at": "TIMESTAMPTZ DEFAULT now()",
        "updated_at": "TIMESTAMPTZ DEFAULT now()",
        "onboarding_completed": "BOOLEAN DEFAULT FALSE",
        "injury_description": "TEXT",
        "initial_pain_score": "SMALLINT CHECK (1-10)",
        "short_term_goal": "TEXT ENUM(pain_relief,mobility_recovery,injury_rehab)",
        "long_term_goal": "TEXT ENUM(stamina,muscle_gain,weight_loss)",
        "weekly_frequency": "SMALLINT DEFAULT 3",
        "workout_location": "TEXT ENUM(home,gym,both) DEFAULT home",
        "available_equipment": "TEXT[] DEFAULT ARRAY[bodyweight]",
        "disclaimer_agreed_at": "TIMESTAMPTZ",
        "disclaimer_version": "TEXT DEFAULT v1.0",
        "timezone": "TEXT DEFAULT Asia/Seoul",
        "push_token": "TEXT"
      },
      "rls": "user can only SELECT/UPDATE own row"
    },
    {
      "table": "workout_plans",
      "description": "AI 생성 4주 운동 플랜 메타",
      "columns": {
        "id": "UUID PK",
        "user_id": "UUID FK→users CASCADE",
        "created_at": "TIMESTAMPTZ DEFAULT now()",
        "plan_version": "SMALLINT DEFAULT 1",
        "week_number": "SMALLINT NOT NULL (1-4)",
        "status": "TEXT ENUM(active,archived,draft) DEFAULT draft",
        "plan_json_s3_key": "TEXT",
        "safety_check_passed": "BOOLEAN DEFAULT FALSE",
        "safety_check_flags": "JSONB DEFAULT []",
        "ai_model_used": "TEXT",
        "ai_prompt_tokens": "INTEGER",
        "ai_completion_tokens": "INTEGER"
      },
      "rls": "user can only access own plans"
    },
    {
      "table": "plan_sessions",
      "description": "플랜 내 일별 세션 정의",
      "columns": {
        "id": "UUID PK",
        "plan_id": "UUID FK→workout_plans CASCADE",
        "day_of_week": "SMALLINT NOT NULL (0=월~6=일)",
        "week_offset": "SMALLINT NOT NULL (0=1주차~3=4주차)",
        "session_order": "SMALLINT DEFAULT 0",
        "exercises": "JSONB NOT NULL"
      }
    },
    {
      "table": "exercises",
      "description": "운동 마스터 데이터",
      "columns": {
        "id": "UUID PK",
        "name": "TEXT NOT NULL",
        "name_en": "TEXT",
        "category": "TEXT ENUM(warmup,rehab,main)",
        "muscle_groups": "TEXT[]",
        "equipment_required": "TEXT[]",
        "contraindications": "TEXT[]",
        "max_pain_score_allowed": "SMALLINT",
        "default_sets": "SMALLINT DEFAULT 3",
        "default_reps": "SMALLINT DEFAULT 10",
        "default_weight_kg": "DECIMAL(5,2) DEFAULT 0",
        "is_active": "BOOLEAN DEFAULT TRUE"
      }
    },
    {
      "table": "workout_sessions",
      "description": "실제 수행 세션 기록",
      "columns": {
        "id": "UUID PK",
        "user_id": "UUID FK→users CASCADE",
        "plan_session_id": "UUID FK→plan_sessions",
        "started_at": "TIMESTAMPTZ",
        "completed_at": "TIMESTAMPTZ",
        "status": "TEXT ENUM(in_progress,completed,skipped) DEFAULT in_progress",
        "post_pain_score": "SMALLINT CHECK (1-10)",
        "pain_note": "TEXT",
        "bulk_completed": "BOOLEAN DEFAULT FALSE",
        "total_volume_kg": "DECIMAL(10,2)"
      },
      "rls": "user can only access own sessions"
    },
    {
      "table": "set_logs",
      "description": "세트별 상세 기록",
      "columns": {
        "id": "UUID PK",
        "session_id": "UUID FK→workout_sessions CASCADE",
        "exercise_id": "UUID FK→exercises",
        "set_number": "SMALLINT NOT NULL",
        "prescribed_weight_kg": "DECIMAL(5,2)",
        "prescribed_reps": "SMALLINT",
        "actual_weight_kg": "DECIMAL(5,2)",
        "actual_reps": "SMALLINT",
        "volume_kg": "DECIMAL(8,2) GENERATED AS (actual_weight_kg * actual_reps) STORED",
        "completed_at": "TIMESTAMPTZ",
        "prefill_source": "TEXT ENUM(prev_session,ai_recommendation)"
      }
    },
    {
      "table": "pain_logs",
      "description": "통증 시계열 데이터",
      "columns": {
        "id": "UUID PK",
        "user_id": "UUID FK→users CASCADE",
        "session_id": "UUID FK→workout_sessions",
        "recorded_at": "TIMESTAMPTZ DEFAULT now()",
        "pain_score": "SMALLINT CHECK (1-10)",
        "pain_note": "TEXT",
        "context": "TEXT ENUM(pre_session,post_session,daily_check)"
      }
    },
    {
      "table": "weekly_recalibrations",
      "description": "주간 AI 미세조정 이력",
      "columns": {
        "id": "UUID PK",
        "user_id": "UUID FK→users CASCADE",
        "created_at": "TIMESTAMPTZ DEFAULT now()",
        "week_start_date": "DATE NOT NULL",
        "week_summary_json": "JSONB",
        "adjustments_json": "JSONB",
        "summary_text": "TEXT",
        "ai_model_used": "TEXT DEFAULT claude-haiku-4-5",
        "approved_at": "TIMESTAMPTZ",
        "applied_plan_id": "UUID FK→workout_plans",
        "status": "TEXT ENUM(pending,approved,rejected) DEFAULT pending"
      }
    }
  ]
}
```

---

## 화면 라우팅 플로우 (v1.3.0 변경)

```
앱 시작
   │
   ▼
SplashScreen (REQ-00-A)
   │  API-00 호출: disclaimer_agreed_at 체크
   ├─── 신규 사용자 (false) ──────────────────────▶ LandingScreen (REQ-00-B)
   │                                                    │
   │                                                    │ [무료로 시작하기] 1회 터치
   │                                                    ▼
   │                                              OnboardingDisclaimerScreen (REQ-01)
   │                                                    │
   │                                                    ▼
   │                                              온보딩 플로우 (Step 1.2~1.6)
   │                                                    │
   │                                                    ▼
   │                                              플랜 생성 (Step 2)
   │                                                    │
   │                                                    ▼
   └─── 기존 사용자 (true) ───────────────────────▶ HomeDashboardScreen (Step 3)
```

---

## GoRouter 라우트 (v1.3.0 업데이트)

```dart
// 파일: lib/router/app_router.dart

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [

    // ── 시작 페이지 ────────────────────────────────
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/landing',
      name: 'landing',
      builder: (context, state) => const LandingScreen(),  // ← 신규
    ),

    // ── 온보딩 ─────────────────────────────────────
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── 메인 ───────────────────────────────────────
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    // ... 세션, 통계, 주간리포트 라우트
  ],
);
```

---

## SplashScreen 구현 가이드 (v1.3.0 — 디자인 토큰 교체)

### 화면 목업

```
┌─────────────────────────────────────┐
│                                     │  ← 배경: #0D1B2A (딥 네이비) 풀스크린
│                                     │
│                                     │
│                                     │
│                                     │
│       ┌─────────────────────┐       │
│       │   RecoveryFit       │       │  ← 워드마크 흰색 + 심볼 민트(#00C9A7)
│       │   🔵  [워드마크]    │       │     중앙 배치
│       └─────────────────────┘       │
│                                     │
│       부상 후, 더 강하게             │  ← 16sp, 흰색, letter-spacing 0.08em
│                                     │
│                                     │
│                                     │
│                                     │
│           ●  ●  ●                   │  ← 민트색 도트 3개 애니메이션
│         (도트 페이드 순환)           │
│                                     │
└─────────────────────────────────────┘

전환 애니메이션: 페이드인 0.6s → 정지 1.2s → 페이드아웃 0.4s
최소 표시: 2초 / 최대: 5초 (초기 로딩 완료 기준)
```

### Flutter 구현 코드

```dart
// 파일: lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── REQ-00-C 디자인 토큰 ────────────────────────────────
  static const Color kPrimaryDark      = Color(0xFF0D1B2A);  // primary-dark
  static const Color kPrimaryMint      = Color(0xFF00C9A7);  // primary-mint
  static const Color kTextPrimary      = Color(0xFFFFFFFF);  // text-primary
  static const Color kTextSecondary    = Color(0xB3FFFFFF);  // rgba(255,255,255,0.70)

  // ── 타이포그래피 토큰 ────────────────────────────────────
  // tagline: Regular 16sp / letter-spacing 0.08em
  static const double kTaglineFontSize     = 16.0;
  static const double kTaglineLetterSpacing = 0.08 * 16.0;  // em → px

  // ── 애니메이션 듀레이션 토큰 ─────────────────────────────
  // fadeIn 0.6s → pause 1.2s → fadeOut 0.4s
  static const Duration kFadeInDuration  = Duration(milliseconds: 600);
  static const Duration kPauseDuration   = Duration(milliseconds: 1200);
  static const Duration kFadeOutDuration = Duration(milliseconds: 400);
  static const Duration kMinDisplay      = Duration(seconds: 2);
  static const Duration kMaxDisplay      = Duration(seconds: 5);

  // ── 도트 애니메이션 컨트롤러 ─────────────────────────────
  late List<AnimationController> _dotControllers;
  late List<Animation<double>>   _dotAnimations;

  // ── 전체 페이드 컨트롤러 ─────────────────────────────────
  late AnimationController _fadeController;
  late Animation<double>   _fadeAnimation;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // 1) 전체 페이드 애니메이션 (페이드인)
    _fadeController = AnimationController(
      vsync: this,
      duration: kFadeInDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();

    // 2) 도트 3개 순차 애니메이션
    _dotControllers = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    ));
    _dotAnimations = _dotControllers.map((ctrl) =>
      Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      ),
    ).toList();

    _startDotAnimation();

    // 3) 라우팅 타이머 (최소 2초 보장)
    _scheduleNavigation();
  }

  /// 도트 3개를 120ms 간격으로 순차 반복
  void _startDotAnimation() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _dotControllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 120));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      for (final ctrl in _dotControllers) {
        if (mounted) ctrl.reverse();
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  /// 초기 데이터 로드 + 최소 2초 보장 후 라우팅
  Future<void> _scheduleNavigation() async {
    final results = await Future.wait([
      _checkUserStatus(),
      Future.delayed(kMinDisplay),  // 최소 노출 보장
    ]).timeout(
      kMaxDisplay,
      onTimeout: () => [false, null],
    );

    if (!mounted || _isNavigating) return;
    _isNavigating = true;

    final bool disclaimerAgreed = results[0] as bool;

    // 페이드아웃 후 전환
    await _fadeController.reverse();
    if (!mounted) return;

    if (disclaimerAgreed) {
      context.go('/home');      // 기존 사용자 → 홈 대시보드
    } else {
      context.go('/landing');   // 신규 사용자 → 랜딩 페이지
    }
  }

  /// SharedPreferences에서 disclaimer_agreed_at 확인
  /// (앱 시작 시 네트워크 불필요 — 로컬 캐시 우선)
  Future<bool> _checkUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? agreedAt = prefs.getString('disclaimer_agreed_at');
    return agreedAt != null && agreedAt.isNotEmpty;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (final ctrl in _dotControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,  // #0D1B2A
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Stack(
            children: [
              // ── 중앙: 로고 + 슬로건 ──────────────────────
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 로고 (워드마크 + 심볼)
                    _buildLogoSection(),
                    const SizedBox(height: 16),
                    // 슬로건
                    _buildTagline(),
                  ],
                ),
              ),

              // ── 하단: 도트 로딩 인디케이터 ───────────────
              Positioned(
                bottom: 64,
                left: 0,
                right: 0,
                child: _buildDotIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 로고 영역: 심볼 아이콘(민트) + 워드마크(흰색)
  Widget _buildLogoSection() {
    return Column(
      children: [
        // 심볼 아이콘 (민트색 — 재활/회복 상징)
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.self_improvement_rounded,  // 회복 상징 아이콘
            // 프로덕션: SvgPicture.asset('assets/icons/recoveryfit_symbol.svg')
            color: kPrimaryMint,   // #00C9A7
            size: 56,
          ),
        ),
        const SizedBox(height: 12),
        // 워드마크
        const Text(
          'RecoveryFit',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: kTextPrimary,      // #FFFFFF
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  /// 슬로건: "부상 후, 더 강하게"
  Widget _buildTagline() {
    return Text(
      '부상 후, 더 강하게',
      style: TextStyle(
        fontSize: kTaglineFontSize,        // 16sp
        fontWeight: FontWeight.w400,
        color: kTextSecondary,             // rgba(255,255,255,0.70)
        letterSpacing: kTaglineLetterSpacing, // 0.08em
      ),
    );
  }

  /// 민트색 도트 3개 순차 애니메이션
  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AnimatedBuilder(
            animation: _dotAnimations[i],
            builder: (context, child) {
              return Opacity(
                opacity: _dotAnimations[i].value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kPrimaryMint,   // #00C9A7
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
```

---

## LandingScreen 구현 가이드 (신규 — REQ-00-B)

### 화면 목업

```
┌─────────────────────────────────────┐  ← 풀스크린, 스크롤 없음
│ [🏃 RecoveryFit]      Safe Area 16px│  ← 좌측 상단 소형 로고 (흰색)
│                                     │
│  ╔═══════════════════════════════╗  │
│  ║                               ║  │
│  ║   [재활 운동 일러스트]          ║  │  ← 화면 상단 55% 영역
│  ║   (사진 아님 — 일러스트 권장)  ║  │
│  ║                               ║  │
│  ╚═══════════════════════════════╝  │
│  ████████████████████░░░░░░░░░░░░   │  ← 딥 네이비 60% 그라디언트 오버레이
│                                     │    (위→아래 투명→#0D1B2A)
│  부상 후에도                        │
│  운동할 수 있어요                   │  ← Bold 28sp 흰색 / 줄간격 1.35
│                                     │
│  AI가 내 부상 상태를 분석하고       │
│  안전한 재활 플랜을 만들어드려요    │  ← Regular 15sp 흰색 80% / 줄간격 1.5
│                                     │
│  ┌──────┐  ┌──────┐  ┌──────┐      │
│  │  🛡  │  │  🧠  │  │  👆  │      │  ← 아이콘 24px 민트색
│  │이중  │  │AI개인│  │터치  │      │    텍스트 12sp 흰색 70%
│  │안전  │  │화 플랜│  │최소화│      │
│  │검증  │  │      │  │인터페│      │
│  └──────┘  └──────┘  └──────┘      │
│                                     │
│  ┌─────────────────────────────┐   │
│  │       무료로 시작하기        │   │  ← 민트 배경 / 네이비 텍스트
│  └─────────────────────────────┘   │    Bold 17sp / 56px / radius 14px
│  의료기기 아님 · 전문의 상담을      │  ← Regular 11sp 흰색 45%
│  대체하지 않습니다                  │
│                          Safe Area  │
└─────────────────────────────────────┘
```

### Flutter 구현 코드

```dart
// 파일: lib/screens/landing/landing_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  // ── REQ-00-C 디자인 토큰 ────────────────────────────────
  static const Color kPrimaryDark   = Color(0xFF0D1B2A);
  static const Color kPrimaryMint   = Color(0xFF00C9A7);
  static const Color kPrimaryMintL  = Color(0xFF33D4B8);
  static const Color kTextPrimary   = Color(0xFFFFFFFF);
  static const Color kTextSecondary = Color(0xB3FFFFFF);  // 70%
  static const Color kTextTertiary  = Color(0x73FFFFFF);  // 45%
  static const Color kSurfaceOverlay= Color(0x990D1B2A);  // 60%

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Layer 1: 히어로 이미지 (상단 55%) ─────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: _buildHeroImage(),
          ),

          // ── Layer 2: 그라디언트 오버레이 ──────────────────
          Positioned.fill(
            child: _buildGradientOverlay(),
          ),

          // ── Layer 3: 콘텐츠 ───────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 헤더: 소형 로고
                _buildHeader(),

                const Spacer(),

                // 히어로 텍스트 + 가치 포인트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainHeadline(),
                      const SizedBox(height: 12),
                      _buildSubHeadline(),
                      const SizedBox(height: 24),
                      _buildValuePoints(),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // CTA 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildCtaButton(context),
                ),

                const SizedBox(height: 12),

                // 보조 텍스트 (면책)
                _buildDisclaimerText(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 히어로 이미지 영역 ───────────────────────────────────
  Widget _buildHeroImage() {
    return Container(
      color: kPrimaryDark.withOpacity(0.6),
      child: const Center(
        // 프로덕션:
        // Image.asset('assets/images/hero_rehabilitation.png',
        //   fit: BoxFit.cover)
        // 또는 SvgPicture.asset('assets/images/hero_illustration.svg')
        child: Icon(
          Icons.accessibility_new_rounded,
          size: 120,
          color: Color(0x3300C9A7),  // 민트 placeholder
        ),
      ),
    );
  }

  // ── 그라디언트 오버레이: 상단 투명 → 하단 딥 네이비 60% ──
  Widget _buildGradientOverlay() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.65, 1.0],
          colors: [
            Colors.transparent,
            Colors.transparent,
            Color(0x990D1B2A),   // 60% 딥 네이비
            kPrimaryDark,        // 100% 딥 네이비
          ],
        ),
      ),
    );
  }

  // ── 헤더: 좌상단 소형 로고 ──────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.self_improvement_rounded,
            color: kPrimaryMint,
            size: 22,
          ),
          const SizedBox(width: 6),
          const Text(
            'RecoveryFit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── 메인 헤드라인: Bold 28sp / 줄간격 1.35 ──────────────
  Widget _buildMainHeadline() {
    return const Text(
      '부상 후에도\n운동할 수 있어요',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        height: 1.35,
      ),
      semanticsLabel: '부상 후에도 운동할 수 있어요',
    );
  }

  // ── 서브 헤드라인: Regular 15sp / 흰색 80% / 줄간격 1.5 ─
  Widget _buildSubHeadline() {
    return const Text(
      'AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: kTextSecondary,   // rgba(255,255,255,0.70)
        height: 1.5,
      ),
    );
  }

  // ── 가치 포인트 3종: 가로 3열 아이콘 + 텍스트 ────────────
  Widget _buildValuePoints() {
    final points = [
      (Icons.shield_outlined,      '이중 안전\n검증'),
      (Icons.psychology_outlined,  'AI 개인화\n플랜'),
      (Icons.touch_app_outlined,   '터치 최소화\n인터페이스'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: points.asMap().entries.map((entry) {
        final i = entry.key;
        final (icon, label) = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 8.0 : 0),
            child: Column(
              children: [
                Icon(icon, color: kPrimaryMint, size: 24),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xB3FFFFFF),  // 흰색 70%
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── CTA 버튼: 민트 배경 / 네이비 텍스트 ─────────────────
  Widget _buildCtaButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => context.go('/onboarding'),  // REQ-01 진입
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryMint,             // #00C9A7
          foregroundColor: kPrimaryDark,             // #0D1B2A
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          // 터치 피드백: scale 0.97 + 밝기 10% 감소 (0.1s)
          splashFactory: InkRipple.splashFactory,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return kPrimaryDark.withOpacity(0.10);
            }
            return null;
          }),
        ),
        child: const Text(
          '무료로 시작하기',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.01 * 17,
          ),
          semanticsLabel: '무료로 시작하기 버튼, 온보딩 시작',
        ),
      ),
    );
  }

  // ── 보조 텍스트: 면책 고지 ──────────────────────────────
  Widget _buildDisclaimerText() {
    return const SizedBox(
      width: double.infinity,
      child: Text(
        '의료기기 아님 · 전문의 상담을 대체하지 않습니다',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: kTextTertiary,   // rgba(255,255,255,0.45)
          height: 1.3,
        ),
      ),
    );
  }
}
```

---

## 디자인 토큰 Dart 파일 (REQ-00-C 공식화)

```dart
// 파일: lib/design_system/tokens.dart
// RecoveryFit Design System v1.1 — REQ-00-C 기준

import 'package:flutter/material.dart';

/// ── 컬러 토큰 ──────────────────────────────────────────────
abstract class RFColors {
  static const Color primaryDark      = Color(0xFF0D1B2A);
  static const Color primaryMint      = Color(0xFF00C9A7);
  static const Color primaryMintLight = Color(0xFF33D4B8);
  static const Color textPrimary      = Color(0xFFFFFFFF);
  static const Color textSecondary    = Color(0xB3FFFFFF);  // 70%
  static const Color textTertiary     = Color(0x73FFFFFF);  // 45%
  static const Color surfaceOverlay   = Color(0x990D1B2A);  // 60%
}

/// ── 타이포그래피 토큰 ──────────────────────────────────────
abstract class RFTextStyles {
  // headline-l: Bold 28sp / 1.35
  static const TextStyle headlineL = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, height: 1.35,
  );
  // headline-m: SemiBold 22sp / 1.4
  static const TextStyle headlineM = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, height: 1.40,
  );
  // body-l: Regular 15sp / 1.5
  static const TextStyle bodyL = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, height: 1.50,
  );
  // body-s: Regular 12sp / 1.4
  static const TextStyle bodyS = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.40,
  );
  // caption: Regular 11sp / 1.3
  static const TextStyle caption = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w400, height: 1.30,
  );
  // button: Bold 17sp / letter-spacing 0.01em
  static const TextStyle button = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w700,
    letterSpacing: 0.17,
  );
}

/// ── 모션 토큰 ──────────────────────────────────────────────
abstract class RFMotion {
  static const Duration fast   = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow   = Duration(milliseconds: 400);
  static const Curve    easing = Curves.easeInOut;
}
```

---

## 네이티브 스플래시 연동 (flutter_native_splash)

```yaml
# pubspec.yaml

dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#0D1B2A"              # 딥 네이비 배경
  image: assets/splash_logo.png # RecoveryFit 워드마크 (흰색 PNG)
  android_12:
    color: "#0D1B2A"
    icon_background_color: "#0D1B2A"
    image: assets/splash_icon_android12.png
  ios: true
  web: false

# 생성 명령:
# dart run flutter_native_splash:create
```

---

## 파일 구조 (v1.3.0 업데이트)

```
lib/
├── main.dart
├── router/
│   └── app_router.dart                  ← /landing 라우트 추가
├── design_system/
│   ├── tokens.dart                      ← REQ-00-C 공식 토큰 (신규)
│   ├── typography.dart
│   └── spacing.dart
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart           ← 디자인 토큰 교체 (딥 네이비/민트)
│   ├── landing/
│   │   └── landing_screen.dart          ← LandingScreen 신규 추가 ✨
│   ├── onboarding/
│   │   ├── disclaimer_screen.dart
│   │   ├── injury_input_screen.dart
│   │   ├── pain_level_screen.dart
│   │   ├── short_goal_screen.dart
│   │   ├── long_goal_screen.dart
│   │   └── environment_screen.dart
│   ├── plan_generating/
│   │   └── plan_generating_screen.dart
│   ├── home/
│   │   └── home_dashboard_screen.dart
│   ├── session/
│   │   ├── session_screen.dart
│   │   ├── set_item_widget.dart
│   │   └── quick_edit_overlay.dart
│   ├── session_complete/
│   │   └── session_complete_screen.dart
│   ├── analytics/
│   │   └── analytics_screen.dart
│   └── recalibration/
│       └── recalibration_screen.dart
├── providers/
│   ├── auth_provider.dart
│   ├── session_provider.dart
│   └── analytics_provider.dart
└── services/
    ├── api_service.dart
    └── push_service.dart
```

---

## 성능 SLA (변경 없음)

```
앱 Cold Start → SplashScreen 종료 : < 2.5s
LandingScreen 렌더링              : < 100ms  (정적 화면, 네트워크 없음)
CTA 터치 → 온보딩 진입            : < 200ms  (GoRouter push)
홈 대시보드 로딩                  : < 500ms  (Redis 캐시)
세트 완료 응답                    : < 200ms  (낙관적 업데이트)
AI 플랜 생성                      : < 30s    (SSE 스트리밍)
```

---

**/workspace/c052dd6b/architecture.md — Version 1.3.0**
*변경: SplashScreen 디자인 토큰 교체(딥 네이비/민트) + LandingScreen 신규 추가 | API 19개 (API-00 추가) | 테이블 8개 | 안전 규칙 15개*