

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