# Software Architect
Project: c052dd6b | Stage: design

# Software Architect 산출물 생성 중...

## 프로젝트 분석: c052dd6b | Design Stage

---

```json
{
  "tech_stack": {
    "frontend": {
      "framework": "Flutter 3.x (Dart)",
      "target_platform": "Android (primary), iOS (future)",
      "state_management": "Riverpod 2.x",
      "local_storage": "Hive (offline cache) + SharedPreferences",
      "http_client": "Dio 5.x",
      "ui_components": "Material 3 + custom design system"
    },
    "backend": {
      "runtime": "Node.js 20 LTS (TypeScript)",
      "framework": "Fastify 4.x",
      "hosting": "Railway.app (cost-effective, ~$5/mo)",
      "database": "PostgreSQL 15 (Railway managed)",
      "orm": "Prisma 5.x",
      "cache": "Redis 7 (Upstash free tier → paid)",
      "auth": "Supabase Auth (JWT)",
      "file_storage": "Supabase Storage (exercise media)"
    },
    "ai_layer": {
      "llm_provider": "OpenAI GPT-4o-mini (primary) / GPT-4o (fallback)",
      "llm_gateway": "Custom safety filter middleware",
      "prompt_strategy": "RAG-lite: symptom → exercise library lookup → structured generation",
      "rate_limiting": "4~5 calls/user/month enforced at API gateway"
    },
    "payments": {
      "provider": "Google Play Billing (Android in-app subscription)",
      "server_validation": "Google Play Developer API webhook",
      "subscription_price": "KRW 2,900/month"
    },
    "devops": {
      "ci_cd": "GitHub Actions",
      "monitoring": "Sentry (error) + PostHog (analytics)",
      "secrets": "Railway env vars + GitHub Secrets",
      "repo": "ych21c/recoveryfit"
    }
  },

  "api_spec": [
    {
      "id": "AUTH-01",
      "method": "POST",
      "path": "/api/v1/auth/register",
      "description": "이메일/소셜 회원가입",
      "auth_required": false,
      "request_body": {
        "email": "string",
        "password": "string | null",
        "provider": "email | google | kakao",
        "provider_token": "string | null"
      },
      "response": {
        "200": { "user_id": "uuid", "access_token": "jwt", "refresh_token": "jwt" }
      }
    },
    {
      "id": "AUTH-02",
      "method": "POST",
      "path": "/api/v1/auth/token/refresh",
      "description": "JWT 갱신",
      "auth_required": false,
      "request_body": { "refresh_token": "string" },
      "response": {
        "200": { "access_token": "jwt", "refresh_token": "jwt" }
      }
    },
    {
      "id": "USER-01",
      "method": "GET",
      "path": "/api/v1/users/me",
      "description": "내 프로필 + 구독 상태 조회",
      "auth_required": true,
      "response": {
        "200": {
          "user_id": "uuid",
          "email": "string",
          "subscription_status": "free | active | expired",
          "llm_calls_used": "integer",
          "llm_calls_limit": 5,
          "plan_count": "integer"
        }
      }
    },
    {
      "id": "USER-02",
      "method": "PATCH",
      "path": "/api/v1/users/me/profile",
      "description": "기본 신체 정보 업데이트",
      "auth_required": true,
      "request_body": {
        "age": "integer | null",
        "gender": "male | female | other | null",
        "fitness_level": "beginner | intermediate | advanced | null",
        "existing_conditions": "string[] | null"
      },
      "response": { "200": { "updated": true } }
    },
    {
      "id": "PLAN-01",
      "method": "POST",
      "path": "/api/v1/plans/generate",
      "description": "증상 텍스트 → 4주 운동 플랜 LLM 생성 (핵심 엔드포인트)",
      "auth_required": true,
      "subscription_required": true,
      "rate_limit": "5/month per user",
      "request_body": {
        "symptom_text": "string (max 500자)",
        "pain_level": "integer (1-10)",
        "affected_area": "string (enum: neck | shoulder | lower_back | knee | ankle | etc)",
        "user_profile_snapshot": {
          "age": "integer",
          "fitness_level": "string",
          "existing_conditions": "string[]"
        }
      },
      "response": {
        "200": {
          "plan_id": "uuid",
          "safety_check_passed": true,
          "disclaimer": "string (의료 면책 문구)",
          "plan": {
            "title": "string",
            "duration_weeks": 4,
            "weeks": [
              {
                "week": 1,
                "focus": "string",
                "sessions": [
                  {
                    "day": "integer",
                    "exercises": [
                      {
                        "exercise_id": "uuid",
                        "name": "string",
                        "sets": "integer",
                        "reps": "string",
                        "duration_sec": "integer | null",
                        "rest_sec": "integer",
                        "modification": "string (부상 배려 변형 동작)"
                      }
                    ]
                  }
                ]
              }
            ]
          }
        },
        "403": { "error": "SUBSCRIPTION_REQUIRED" },
        "429": { "error": "LLM_QUOTA_EXCEEDED", "reset_date": "ISO8601" },
        "422": { "error": "SAFETY_FILTER_BLOCKED", "reason": "string" }
      }
    },
    {
      "id": "PLAN-02",
      "method": "GET",
      "path": "/api/v1/plans",
      "description": "내 플랜 목록 조회",
      "auth_required": true,
      "query_params": { "page": 1, "limit": 10 },
      "response": {
        "200": {
          "plans": [
            {
              "plan_id": "uuid",
              "title": "string",
              "created_at": "ISO8601",
              "status": "active | completed | archived",
              "progress_percent": "integer"
            }
          ],
          "total": "integer"
        }
      }
    },
    {
      "id": "PLAN-03",
      "method": "GET",
      "path": "/api/v1/plans/:plan_id",
      "description": "플랜 상세 조회",
      "auth_required": true,
      "response": { "200": "Full plan object (PLAN-01 response schema)" }
    },
    {
      "id": "SESSION-01",
      "method": "POST",
      "path": "/api/v1/plans/:plan_id/sessions/:session_id/complete",
      "description": "운동 세션 완료 기록",
      "auth_required": true,
      "request_body": {
        "completed_exercises": [
          { "exercise_id": "uuid", "sets_done": "integer", "pain_feedback": "integer (0-10)" }
        ],
        "session_note": "string | null",
        "duration_minutes": "integer"
      },
      "response": {
        "200": {
          "session_log_id": "uuid",
          "plan_progress_percent": "integer",
          "streak_days": "integer"
        }
      }
    },
    {
      "id": "EXERCISE-01",
      "method": "GET",
      "path": "/api/v1/exercises",
      "description": "운동 라이브러리 조회 (안전 검증 완료된 목록)",
      "auth_required": true,
      "query_params": {
        "affected_area": "string | null",
        "difficulty": "beginner | intermediate | advanced | null",
        "search": "string | null",
        "page": 1,
        "limit": 20
      },
      "response": {
        "200": {
          "exercises": [
            {
              "exercise_id": "uuid",
              "name": "string",
              "description": "string",
              "affected_areas": "string[]",
              "contraindications": "string[]",
              "difficulty": "string",
              "media_url": "string | null",
              "is_safety_verified": true
            }
          ]
        }
      }
    },
    {
      "id": "BILLING-01",
      "method": "POST",
      "path": "/api/v1/billing/subscription/validate",
      "description": "Google Play 구독 영수증 서버 검증",
      "auth_required": true,
      "request_body": {
        "purchase_token": "string",
        "product_id": "string",
        "package_name": "string"
      },
      "response": {
        "200": {
          "subscription_status": "active",
          "expires_at": "ISO8601",
          "is_trial": "boolean"
        },
        "400": { "error": "INVALID_PURCHASE_TOKEN" }
      }
    },
    {
      "id": "BILLING-02",
      "method": "POST",
      "path": "/api/v1/billing/webhook/google-play",
      "description": "Google Play RTDN(실시간 개발자 알림) 수신",
      "auth_required": false,
      "note": "Google Cloud Pub/Sub → Railway 웹훅",
      "request_body": { "message": "base64 encoded notification" },
      "response": { "200": { "received": true } }
    },
    {
      "id": "SAFETY-01",
      "method": "POST",
      "path": "/api/v1/internal/safety-check",
      "description": "1차 규칙 기반 안전 필터 (내부 미들웨어 호출용)",
      "auth_required": "internal_api_key",
      "request_body": {
        "symptom_text": "string",
        "affected_area": "string",
        "pain_level": "integer"
      },
      "response": {
        "200": { "passed": "boolean", "risk_flags": "string[]", "recommendation": "string" }
      }
    }
  ],

  "data_models": [
    {
      "model": "User",
      "table": "users",
      "description": "회원 기본 정보",
      "fields": [
        { "name": "id", "type": "UUID", "constraints": "PK, DEFAULT gen_random_uuid()" },
        { "name": "email", "type": "VARCHAR(255)", "constraints": "UNIQUE, NOT NULL" },
        { "name": "supabase_