

---
## Stage: design

# RecoveryFit — Software Architecture Specification
**Project ID**: c052dd6b | **Stage**: design | **Version**: 1.0.0

---

## `/workspace/c052dd6b/architecture.md`

---

## 0. Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│  React Native (Expo)  ─── Zustand Store ─── React Query Cache  │
└────────────────────┬────────────────────────────────────────────┘
                     │ HTTPS / WebSocket
┌────────────────────▼────────────────────────────────────────────┐
│                      API GATEWAY LAYER                          │
│         AWS API Gateway  ──  JWT Auth (Supabase Auth)          │
└────┬─────────────┬──────────────────┬───────────────┬───────────┘
     │             │                  │               │
┌────▼───┐  ┌──────▼─────┐  ┌────────▼──────┐  ┌────▼──────────┐
│ Auth   │  │  Workout   │  │  AI Planner   │  │  Analytics    │
│Service │  │  Service   │  │  Service      │  │  Service      │
│(Node)  │  │  (Node)    │  │  (Python)     │  │  (Node)       │
└────┬───┘  └──────┬─────┘  └────────┬──────┘  └────┬──────────┘
     │             │                  │               │
┌────▼─────────────▼──────────────────▼───────────────▼──────────┐
│                      DATA LAYER                                 │
│   PostgreSQL (Supabase)  │  Redis (ElastiCache)  │  S3          │
└─────────────────────────────────────────────────────────────────┘
                                │
┌───────────────────────────────▼─────────────────────────────────┐
│                   EXTERNAL SERVICES                             │
│  Anthropic Claude API  │  AWS SES (Push)  │  FCM / APNs        │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Technology Stack

| 레이어 | 기술 선택 | 선정 근거 |
|--------|-----------|-----------|
| **Mobile Client** | React Native (Expo SDK 51) | Cross-platform, OTA 배포, Gesture Handler 내장 |
| **State Management** | Zustand + React Query v5 | 세션 로컬 상태(Zustand) / 서버 캐시(React Query) 역할 분리 |
| **UI Component** | NativeWind + custom Chip/Slider | Tailwind 스타일 일관성, Quick-Edit 오버레이 구현 |
| **Backend Runtime** | Node.js 20 (Fastify) + Python 3.12 (FastAPI) | Fastify: 저지연 CRUD / FastAPI: AI 추론 파이프라인 |
| **Database** | PostgreSQL 15 (Supabase) | Row Level Security, Realtime Subscription |
| **Cache** | Redis 7 (ElastiCache) | Pre-fill 데이터 TTL 캐싱, 세션 잠금 |
| **AI 모델** | Claude claude-sonnet-4 (초기 플랜) / Claude claude-haiku-4-5 (주간 조정) | Sonnet: 4주 플랜 정밀 생성 / Haiku: 저비용 주간 미세조정 |
| **Auth** | Supabase Auth (JWT + RLS) | 소셜 로그인 + Row-level 보안 내장 |
| **Push Notification** | FCM + APNs via AWS SNS | 크로스 플랫폼 단일 인터페이스 |
| **Storage** | AWS S3 | 운동 플랜 JSON 버전 아카이브 |
| **CI/CD** | GitHub Actions → EAS Build → AWS ECS | 자동 테스트 → 네이티브 빌드 → 컨테이너 배포 |
| **Monitoring** | Sentry (에러) + Datadog (APM) | 에러 추적 + AI 응답 레이턴시 모니터링 |

---

## 2. Data Models

### 2.1 users

```sql
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           TEXT UNIQUE NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now(),
  
  -- 온보딩 완료 여부
  onboarding_completed  BOOLEAN DEFAULT FALSE,
  
  -- Step 1.2: 부상/통증 자유 텍스트
  injury_description    TEXT,                    -- "무릎 인대 나갔어요"
  
  -- Step 1.3: 초기 통증 수준 (NTRS 1~10)
  initial_pain_score    SMALLINT CHECK (initial_pain_score BETWEEN 1 AND 10),
  
  -- Step 1.4 / 1.5: 목표
  short_term_goal       TEXT CHECK (short_term_goal IN (
                          'pain_relief', 'mobility_recovery', 'injury_rehab'
                        )),
  long_term_goal        TEXT CHECK (long_term_goal IN (
                          'stamina', 'muscle_gain', 'weight_loss'
                        )),
  
  -- Step 1.6: 운동 환경
  weekly_frequency      SMALLINT DEFAULT 3,       -- 주 2/3/4/5회
  workout_location      TEXT CHECK (workout_location IN ('home', 'gym', 'both')) DEFAULT 'home',
  available_equipment   TEXT[] DEFAULT ARRAY['bodyweight'],  -- ['dumbbell','band','pullup_bar']
  
  -- 법적 동의
  disclaimer_agreed_at  TIMESTAMPTZ,
  disclaimer_version    TEXT DEFAULT 'v1.0'
);
```

### 2.2 workout_plans

```sql
CREATE TABLE workout_plans (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ DEFAULT now(),
  
  -- 플랜 메타
  plan_version    SMALLINT DEFAULT 1,             -- 주간 미세조정 시 +1
  week_number     SMALLINT NOT NULL,              -- 1~4 (4주 플랜)
  status          TEXT CHECK (status IN ('active','archived','draft')) DEFAULT 'draft',
  
  -- AI 생성 원본 JSON (S3 아카이브 URL 참조)
  plan_json_s3_key  TEXT,                         -- s3://bucket/plans/{user_id}/{id}.json
  
  -- 안전 검증 결과
  safety_check_passed   BOOLEAN DEFAULT FALSE,
  safety_check_flags    JSONB DEFAULT '[]',        -- 위반 규칙 목록
  
  -- 생성에 사용한 Claude 모델
  ai_model_used   TEXT,                           -- 'claude-sonnet-4' | 'claude-haiku-4-5'
  ai_prompt_tokens    INTEGER,
  ai_completion_tokens INTEGER
);

-- 플랜 내 개별 운동 세션 정의
CREATE TABLE plan_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id         UUID REFERENCES workout_plans(id) ON DELETE CASCADE,
  
  day_of_week     SMALLINT NOT NULL,              -- 0=월 ~ 6=일
  week_offset     SMALLINT NOT NULL,              -- 0=1주차 ~ 3=4주차
  session_order   SMALLINT DEFAULT 0,
  
  -- 운동 구성 (Step 3.1: 준비1 + 재활/보조2 + 메인2 = 5개)
  exercises       JSONB NOT NULL                  -- 아래 exercise 스키마 배열
  -- [{ exercise_id, category, prescribed_sets, prescribed_reps,
  --    prescribed_weight_kg, rest_seconds, notes }]
);
```

### 2.3 exercises (운동 마스터)

```sql
CREATE TABLE exercises (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  name_en         TEXT,
  
  -- 분류
  category        TEXT CHECK (category IN (
                    'warmup',         -- 준비운동
                    'rehab',          -- 재활/보조
                    'main'            -- 메인 근력
                  )),
  muscle_groups   TEXT[],             -- ['quadriceps','hamstring']
  equipment_required TEXT[],          -- ['bodyweight','dumbbell']
  
  -- 안전 제약 (Rule-based 검증용)
  contraindications TEXT[],           -- ['knee_ligament','lumbar_disc']
  max_pain_score_allowed SMALLINT,    -- 이 운동 허용 최대 통증 점수
  
  -- 기본 추천값 (Pre-fill 기준)
  default_sets    SMALLINT DEFAULT 3,
  default_reps    SMALLINT DEFAULT 10,
  default_weight_kg DECIMAL(5,2) DEFAULT 0,
  
  is_active       BOOLEAN DEFAULT TRUE
);
```

### 2.4 workout_sessions (실제 수행 기록)

```sql
CREATE TABLE workout_sessions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  plan_session_id UUID REFERENCES plan_sessions(id),
  
  started_at      TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ,
  status          TEXT CHECK (status IN ('in_progress','completed','skipped')) DEFAULT 'in_progress',
  
  -- Step 6.1: 세션 종료 통증 점수
  post_pain_score SMALLINT CHECK (post_pain_score BETWEEN 1 AND 10),
  pain_note       TEXT,
  
  -- 일괄 완료 (Step 3.1 방법B)
  bulk_completed  BOOLEAN DEFAULT FALSE
);

-- 세트별 상세 기록 (Step 5.1 ~ 5.3)
CREATE TABLE set_logs (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id      UUID REFERENCES workout_sessions(id) ON DELETE CASCADE,
  exercise_id     UUID REFERENCES exercises(id),
  
  set_number      SMALLINT NOT NULL,
  
  -- Pre-fill 원본 추천값 (Step 4.1)
  prescribed_weight_kg  DECIMAL(5,2),
  prescribed_reps       SMALLINT,
  
  -- 실제 수행값 (Step 5.3 Quick-Edit 결과)
  actual_weight_kg      DECIMAL(5,2),
  actual_reps           SMALLINT,
  
  -- 볼륨 계산 (Step 7.3: Σ무게×횟수×세트)
  volume_kg             DECIMAL(8,2)

---
## Stage: design

# RecoveryFit — Software Architecture Specification (완전판)
**Project ID**: c052dd6b | **Stage**: design | **Version**: 1.2.0

> **작업 내용**: max_tokens 한도로 중단된 architecture.md 완전 재생성 + SplashScreen 화면 목업 & Flutter 구현 가이드 추가

---

## 산출물 경로: `/workspace/c052dd6b/architecture.md`

---

```json
{
  "tech_stack": {
    "mobile_client": {
      "framework": "Flutter 3.22 (Dart 3.4)",
      "state_management": "Riverpod 2.x + flutter_hooks",
      "ui_kit": "Custom Design System (RecoveryFit DS)",
      "navigation": "GoRouter 14.x",
      "http_client": "Dio 5.x + Retrofit",
      "local_storage": "Hive 2.x (세션 캐시) + SharedPreferences (설정)",
      "animations": "flutter_animate 4.x",
      "push_notification": "firebase_messaging 15.x",
      "change_reason": "React Native → Flutter 전환: 네이티브 렌더링 성능, Splash/Launch Screen 완전 제어, 단일 코드베이스 플랫폼 일관성"
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
      "description": "당일 운동 요약 카드 조회 (Step 3)",
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
      "description": "오늘의 운동 일괄 완료 (Step 3.1 방법B)",
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
      "description": "세션 Pre-fill 데이터 조회 (Step 4.1)",
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
      "description": "세트 완료 기록 (Step 5.1~5.3)",
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
      "description": "세트 수치 수정 (Quick-Edit 오버레이 변경 시)",
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
      "description": "세트 삭제 (스와이프 → 삭제)",
      "response": { "deleted": true },
      "auth_required": true,
      "step": 5
    },
    {
      "id": "API-12",
      "method": "PATCH",
      "path": "/v1/sessions/{session_id}/exercises/{exercise_id}/skip",
      "service": "workout-service",
      "description": "운동 스킵 처리 (홈 카드 슬라이드 → 스킵)",
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
      "description": "세션 종료 및 통증 피드백 저장 (Step 6)",
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
      "description": "통증 추이 그래프 데이터 (Step 7.1)",
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
      "description": "주간 운동 완료율 바 그래프 (Step 7.2)",
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
      "description": "주간 운동 볼륨 추이 그래프 (Step 7.3)",
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
      "description": "주간 Haiku 미세조정 플랜 생성 (Step 8, 스케줄러 자동 호출)",
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
      "description": "주간 미세조정 플랜 원터치 승인 적용 (Step 8.2)",
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
      "description": "플랜 내 일별 세션 정의 (운동 구성 처방)",
      "columns": {
        "id": "UUID PK",
        "plan_id": "UUID FK→workout_plans CASCADE",
        "day_of_week": "SMALLINT NOT NULL (0=월~6=일)",
        "week_offset": "SMALLINT NOT NULL (0=1주차~3=4주차)",
        "session_order": "SMALLINT DEFAULT 0",
        "exercises": "JSONB NOT NULL [{exercise_id,category,prescribed_sets,prescribed_reps,prescribed_weight_kg,rest_seconds,notes}]"
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
      "description": "세트별 상세 기록 (Quick-Edit 최종값)",
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
      "description": "통증 시계열 데이터 (Step 7.1 그래프 원본)",
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

## 아키텍처 전체 다이어그램

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                               │
│   Flutter 3.22 ── Riverpod 2.x ── GoRouter ── flutter_animate  │
│   SplashScreen → Onboarding → Home → Session → Analytics       │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS / SSE
┌────────────────────────▼────────────────────────────────────────┐
│                    API GATEWAY LAYER                            │
│        AWS API Gateway  ──  Supabase JWT Auth Middleware        │
└────┬───────────┬──────────────────┬──────────────┬─────────────┘
     │           │                  │              │
┌────▼───┐ ┌────▼──────┐  ┌────────▼──────┐ ┌────▼──────────┐
│ Auth   │ │ Workout   │  │  AI Planner   │ │  Analytics    │
│Service │ │ Service   │  │  Service      │ │  Service      │
│Node 20 │ │ Fastify4  │  │  FastAPI 3.12 │ │  Fastify 4    │
└────┬───┘ └────┬──────┘  └────────┬──────┘ └────┬──────────┘
     │          │                  │              │
┌────▼──────────▼──────────────────▼──────────────▼────────────┐
│                       DATA LAYER                              │
│  PostgreSQL 15 (Supabase RLS) │ Redis 7 │ AWS S3             │
└───────────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────▼─────────────────────────────────────┐
│                  EXTERNAL SERVICES                            │
│  Anthropic Claude API │ FCM/APNs (AWS SNS) │ Sentry+Datadog  │
└───────────────────────────────────────────────────────────────┘
```

---

## SplashScreen 화면 목업 & Flutter 구현 가이드

### 디자인 명세

```
┌─────────────────────────────────────┐
│                                     │  ← 배경: linear-gradient
│                                     │     160deg
│                                     │     #EFF6FF → #F8FAFC
│                                     │
│                                     │
│           ┌─────────────┐           │
│           │             │           │
│           │  🏃  (48px) │           │  ← 아이콘 컨테이너
│           │             │           │     72×72px
│           │             │           │     bg: #4F8EF7 (Primary)
│           │             │           │     border-radius: 20px
│           └─────────────┘           │     box-shadow: 0 8px 32px
│                                     │     rgba(79,142,247, 0.28)
│          RecoveryFit                │  ← 앱명: 28px Bold
│                                     │     color: #1E3A5F
│      부상을 딛고, 더 강하게           │  ← 슬로건: 14px Regular
│                                     │     color: #64748B
│                                     │
│                                     │
│                                     │
│         ────────────                │  ← 로딩 인디케이터
│          Progress Bar               │     width: 120px, h: 3px
│         (Animated)                  │     color: #4F8EF7
│                                     │
└─────────────────────────────────────┘
```

### 컬러 & 타이포그래피 시스템

```
Primary Blue    : #4F8EF7  (아이콘 배경, 로딩바)
Dark Text       : #1E3A5F  (앱 이름)
Subtitle Text   : #64748B  (슬로건)
Background Start: #EFF6FF  (그라디언트 시작)
Background End  : #F8FAFC  (그라디언트 끝)

앱 이름 폰트    : 28px, FontWeight.w700, letterSpacing: -0.5
슬로건 폰트     : 14px, FontWeight.w400, letterSpacing: 0.3
아이콘 크기     : 48px (이모지 대신 커스텀 아이콘 권장)
```

### Flutter 위젯 구조

```dart
// 파일: lib/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  // ──────────────────────────────────────────
  // 컬러 토큰 (RecoveryFit Design System)
  // ──────────────────────────────────────────
  static const Color kPrimaryBlue    = Color(0xFF4F8EF7);
  static const Color kDarkText       = Color(0xFF1E3A5F);
  static const Color kSubtitleText   = Color(0xFF64748B);
  static const Color kBgStart        = Color(0xFFEFF6FF);
  static const Color kBgEnd          = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    // 프로그레스 바 애니메이션 컨트롤러
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    // 2.5초 후 라우팅 결정
    Future.delayed(const Duration(milliseconds: 2500), _navigateNext);
  }

  /// 온보딩 완료 여부에 따라 분기
  Future<void> _navigateNext() async {
    if (!mounted) return;
    final bool onboardingDone = await _checkOnboardingStatus();
    if (!mounted) return;

    if (onboardingDone) {
      context.go('/home');          // Step 3 메인 홈 대시보드
    } else {
      context.go('/onboarding');    // Step 1 온보딩 시작
    }
  }

  Future<bool> _checkOnboardingStatus() async {
    // SharedPreferences 또는 Supabase user 조회
    // 예: final user = ref.read(authProvider);
    // return user?.onboardingCompleted ?? false;
    return false; // 기본값
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ── 1. 배경 그라디언트 ──────────────────────
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // 160deg ≈ begin: topLeft, end: bottomRight
            stops: [0.0, 1.0],
            colors: [kBgStart, kBgEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // ── 2. 앱 아이콘 컨테이너 ───────────────
              _buildIconContainer()
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),

              const SizedBox(height: 24),

              // ── 3. 앱 이름 ───────────────────────────
              Text(
                'RecoveryFit',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kDarkText,
                  letterSpacing: -0.5,
                ),
              )
              .animate(delay: 300.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.3, end: 0.0, duration: 500.ms),

              const SizedBox(height: 8),

              // ── 4. 슬로건 ────────────────────────────
              Text(
                '부상을 딛고, 더 강하게',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: kSubtitleText,
                  letterSpacing: 0.3,
                ),
              )
              .animate(delay: 500.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.3, end: 0.0, duration: 500.ms),

              const Spacer(flex: 3),

              // ── 5. 로딩 프로그레스 바 ────────────────
              _buildProgressBar()
                .animate(delay: 400.ms)
                .fadeIn(duration: 400.ms),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 아이콘 컨테이너 위젯
  // ─────────────────────────────────────────────
  Widget _buildIconContainer() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: kPrimaryBlue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.28),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '🏃',
          style: TextStyle(fontSize: 38),
          // 프로덕션: Text 대신 SvgPicture.asset('assets/icons/runner.svg')
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // 애니메이션 프로그레스 바 위젯
  // ─────────────────────────────────────────────
  Widget _buildProgressBar() {
    return SizedBox(
      width: 120,
      height: 3,
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progressController.value,
              backgroundColor: kPrimaryBlue.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryBlue),
              minHeight: 3,
            ),
          );
        },
      ),
    );
  }
}
```

### GoRouter 라우트 등록

```dart
// 파일: lib/router/app_router.dart

import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',           // SplashScreen 첫 진입
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeDashboardScreen(),
    ),
    // ... 이하 세션, 통계, 주간리포트 라우트
  ],
);
```

### Android 네이티브 런치 스크린 연동

```xml
<!-- android/app/src/main/res/drawable/launch_background.xml -->
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 배경: #EFF6FF (그라디언트는 shape으로 근사) -->
    <item>
        <shape android:shape="rectangle">
            <gradient
                android:startColor="#EFF6FF"
                android:endColor="#F8FAFC"
                android:angle="225" />
        </shape>
    </item>
    <!-- 중앙 로고 아이콘 (drawable 리소스) -->
    <item
        android:gravity="center"
        android:drawable="@drawable/splash_icon" />
</layer-list>
```

```xml
<!-- android/app/src/main/res/values/styles.xml -->
<style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
    <item name="android:windowBackground">@drawable/launch_background</item>
    <item name="android:statusBarColor">#EFF6FF</item>
</style>
```

### iOS 런치 스크린 연동

```
<!-- ios/Runner/Base.lproj/LaunchScreen.storyboard -->
UIViewController
  └── View (backgroundColor: #EFF6FF → 그라디언트는 CAGradientLayer로 viewDidLoad)
       └── UIImageView (splashIcon.png, center: x=50%, y=44%)
            └── NSLayoutConstraint: width=72, height=72
       └── UILabel "RecoveryFit" (center-x, top: imageView.bottom + 24)
       └── UILabel "부상을 딛고, 더 강하게" (center-x, top: title.bottom + 8)
```

### flutter_native_splash 자동화 설정 (권장)

```yaml
# pubspec.yaml에 추가
dev_dependencies:
  flutter_native_splash: ^2.4.0

flutter_native_splash:
  color: "#EFF6FF"           # iOS/Android 배경색 (그라디언트 근사값)
  image: assets/splash_icon.png   # 72×72 RecoveryFit 아이콘
  android_12:
    color: "#EFF6FF"
    icon_background_color: "#4F8EF7"
  web: false                 # 웹 비활성화

# 실행 명령
# dart run flutter_native_splash:create
```

---

## 안전 검증 Rule Engine 상세

```
Layer 1: Claude claude-sonnet-4 System Prompt 제약
─────────────────────────────────────────────────
R-01: NRS 8+ → 고강도 운동(1RM 70%↑) 전면 제외
R-02: 무릎 부상 → 스쿼트/런지/레그프레스 하중 제한
R-03: 허리 디스크 → 데드리프트/굿모닝/SLDL 제외
R-04: 어깨 회전근개 → 오버헤드 프레스/업라이트로우 제외
R-05: 1주차 볼륨 → 2주차 대비 +10% 이하
R-06: 재활 운동 → 전체 세션의 최소 40% 필수
R-07: 동일 부위 → 48시간 이상 회복 휴식 보장
R-08: 세션 시간 → 60분 초과 금지 (초보 기준)
R-09: 통증 부위 직접 자극 → 1주차 전면 제외
R-10: 모든 세션 → 워밍업 최소 1개 필수
R-11: 맨몸 전용 환경 → 바벨/케이블 운동 제외
R-12: NRS 6↑ + 재활 목표 → 메인 운동 세트 3 이하
R-13: 주 2회 이하 → 전신 운동 위주, 분할 금지
R-14: 운동 중 통증 악화 패턴 → 다음 세션 강도 자동 -20%
R-15: 4주차 볼륨 → 1주차 대비 최대 +40% 이하

Layer 2: Python FastAPI Rule Engine (서버 사이드 재검증)
────────────────────────────────────────────────────────
→ Claude JSON 응답 수신 직후 동일 15개 규칙으로 재검증
→ 위반 감지 시: 자동 교체 (Warmup 동작으로 대체) + safety_check_flags 기록
→ 모든 위반 시정 불가 시: 플랜 생성 실패 반환 → 클라이언트 [재시도] 노출
```

---

## 성능 SLA 목표

```
홈 대시보드 로딩     : < 500ms  (Redis 캐시)
세트 완료 응답       : < 200ms  (낙관적 업데이트)
Quick-Edit 오버레이  : < 100ms  (Riverpod 로컬 상태)
AI 플랜 생성         : < 30s    (SSE 스트리밍)
주간 Haiku 조정      : < 10s
Analytics 차트       : < 1s
앱 Cold Start (Splash): < 2.5s  → 스플래시 종료 후 라우팅
API 가용성           : 99.5% SLA
```

---

## 파일 구조 (Flutter 프로젝트)

```
lib/
├── main.dart
├── router/
│   └── app_router.dart
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart          ← SplashScreen (신규)
│   ├── onboarding/
│   │   ├── disclaimer_screen.dart      ← Step 1.1
│   │   ├── injury_input_screen.dart    ← Step 1.2
│   │   ├── pain_level_screen.dart      ← Step 1.3
│   │   ├── short_goal_screen.dart      ← Step 1.4
│   │   ├── long_goal_screen.dart       ← Step 1.5
│   │   └── environment_screen.dart     ← Step 1.6
│   ├── plan_generating/
│   │   └── plan_generating_screen.dart ← Step 2
│   ├── home/
│   │   └── home_dashboard_screen.dart  ← Step 3
│   ├── session/
│   │   ├── session_screen.dart         ← Step 4~5
│   │   ├── set_item_widget.dart
│   │   └── quick_edit_overlay.dart     ← Step 5.3
│   ├── session_complete/
│   │   └── session_complete_screen.dart← Step 6
│   ├── analytics/
│   │   └── analytics_screen.dart       ← Step 7
│   └── recalibration/
│       └── recalibration_screen.dart   ← Step 8
├── providers/
│   ├── auth_provider.dart
│   ├── session_provider.dart
│   └── analytics_provider.dart
├── services/
│   ├── api_service.dart
│   └── push_service.dart
└── design_system/
    ├── colors.dart                     ← kPrimaryBlue, kDarkText...
    ├── typography.dart
    └── spacing.dart
```

---

**/workspace/c052dd6b/architecture.md — Version 1.2.0 완료**  
*SplashScreen 목업 + Flutter 구현 가이드 포함 | API 18개 | 테이블 8개 | 안전 규칙 15개*