

---
## Stage: planning

# RecoveryFit PRD — c052dd6b

## 산출물 경로: `/workspace/c052dd6b/prd.md`

---

```markdown
# RecoveryFit Product Requirements Document (PRD)
**Project ID**: c052dd6b  
**Repository**: ych21c/recoveryfit  
**Stage**: Planning  
**Version**: 1.0.0  
**Last Updated**: 2025-01-31  
**Author**: AI Team PM

---

## 1. Executive Summary

RecoveryFit은 부상·통증을 가진 사용자가 전문의 없이도 안전하게
재활 운동을 수행할 수 있도록 AI 기반 개인화 운동 플랜을 제공하는
모바일 애플리케이션입니다.

핵심 원칙은 **"터치 최소화"** 입니다. 모든 인터랙션은
[기본 화면 노출] → [원터치/기본 동작] → [Quick-Edit/세부 변경]
3-레이어 구조를 따르며, 사용자가 추가 입력 없이 앱 진입부터
운동 완료까지 최소 터치로 달성할 수 있어야 합니다.

---

## 2. Problem Statement

| 문제 | 현황 |
|------|------|
| 부상자 운동 접근성 | 부상 후 어떤 운동을 해야 할지 몰라 운동을 포기 |
| 안전성 불안 | 잘못된 운동으로 부상 악화 우려 |
| 기록 부담 | 기존 운동 앱의 복잡한 입력 구조가 지속 사용 저해 |
| 진척도 피드백 부재 | 통증 감소 / 체력 향상 상관관계를 직관적으로 확인 불가 |

---

## 3. Target User

- **Primary**: 부상 후 재활 중이거나 만성 통증을 가진 20~50대 성인
- **Secondary**: 예방적 재활 운동에 관심 있는 일반 성인
- **Exclusion**: 전문 선수, 의료적 처치가 즉시 필요한 급성 환자

---

## 4. 핵심 설계 원칙

### 4.1 터치 최소화 3-Layer Rule
```
Layer 1 [기본 화면 노출 상태]
  → 사용자가 아무것도 하지 않아도 최적 기본값이 표시됨

Layer 2 [원터치/기본 동작]
  → 1회 터치로 기본값 그대로 진행 가능

Layer 3 [Quick-Edit/세부 변경 동작]
  → 변경이 필요할 때만 추가 인터랙션 (키보드 최소화)
```

### 4.2 AI Safety First
- 1차 안전 검증: 프롬프트 레벨 제약 (Claude Haiku)
- 2차 안전 검증: 서버 사이드 Rule-based 검증 (10~15개 안전 규칙)
- 면책 고지: 의료기기 아님, 전문의 상담 권장 (앱 최초 실행 시)

---

## 5. 기능 요구사항 상세 명세

### 5.1 STEP 1 — 온보딩 & 조건 입력

#### REQ-01: 법적 면책 동의
| 항목 | 내용 |
|------|------|
| ID | REQ-01 |
| 화면 | OnboardingDisclaimerScreen |
| 기본 노출 | "의료기기 아님, 전문의 상담 권장" 팝업 |
| 원터치 동작 | [동의하고 시작] 버튼 1회 터치 → 다음 스크린 진입 |
| Quick-Edit | 없음 |
| 트리거 | 앱 최초 실행 시 1회만 노출 |
| 저장 데이터 | `disclaimer_agreed_at: timestamp` |

#### REQ-02: 부상/통증 자유 텍스트 입력
| 항목 | 내용 |
|------|------|
| ID | REQ-02 |
| 화면 | OnboardingInjuryInputScreen |
| 기본 노출 | 텍스트 입력창 + 예시 칩 3종 |
| 칩 목록 | "무릎 인대 나갔어요", "허리 디스크 초기", "어깨 회전근개 통증" |
| 원터치 동작 | 칩 터치 → 입력창 자동 완성 → [다음] 터치 |
| Quick-Edit | 키보드로 자유 텍스트 직접 수정 |
| 저장 데이터 | `injury_description: string` |
| 유효성 검증 | 최소 5자 이상 입력 시 [다음] 활성화 |

#### REQ-03: 통증 수준 선택 (NRS 1~10)
| 항목 | 내용 |
|------|------|
| ID | REQ-03 |
| 화면 | OnboardingPainLevelScreen |
| 기본 노출 | 슬라이더, 기본값 5점에 핀 고정 |
| 원터치 동작 | 5점 기본값 그대로 [다음] 터치 |
| Quick-Edit | 숫자 칩(1~10) 터치 또는 슬라이더 드래그 |
| 저장 데이터 | `initial_pain_score: integer(1-10)` |

#### REQ-04: 단기 목표 선택
| 항목 | 내용 |
|------|------|
| ID | REQ-04 |
| 화면 | OnboardingShortTermGoalScreen |
| 기본 노출 | 칩 3종, [통증 완화] 기본 선택 |
| 칩 목록 | 통증 완화(기본), 관절 가동성 회복, 부상 재활 |
| 원터치 동작 | 기본 선택 상태에서 [다음] 터치 |
| Quick-Edit | 다른 칩 터치 시 즉시 선택 변경 (단일 선택) |
| 저장 데이터 | `short_term_goal: enum` |

#### REQ-05: 장기 목표 선택
| 항목 | 내용 |
|------|------|
| ID | REQ-05 |
| 화면 | OnboardingLongTermGoalScreen |
| 기본 노출 | 칩 3종, [스태미나/체력 향상] 기본 선택 |
| 칩 목록 | 스태미나/체력 향상(기본), 근육량 증가, 체중 감량 |
| 원터치 동작 | 기본 선택 상태에서 [다음] 터치 |
| Quick-Edit | 다른 칩 터치 시 즉시 선택 변경 (단일 선택) |
| 저장 데이터 | `long_term_goal: enum` |

#### REQ-06: 운동 환경 및 장비 선택
| 항목 | 내용 |
|------|------|
| ID | REQ-06 |
| 화면 | OnboardingEnvironmentScreen |
| 기본 노출 | 주당 빈도: 주3회, 장소: 집, 장비: 맨몸 기본 선택 |
| 원터치 동작 | 기본값 유지 → [플랜 생성하기] 1회 터치 |
| Quick-Edit (빈도) | 주2회, 주4회, 주5회 칩 터치 |
| Quick-Edit (장소) | 헬스장, 둘 다 라디오 버튼 터치 |
| Quick-Edit (장비-집) | 덤벨, 밴드, 철봉 복수 체크박스 터치 |
| 저장 데이터 | `weekly_frequency: int`, `location: enum`, `equipment: array` |
| 조건부 렌더링 | 장소='헬스장' 선택 시 장비 섹션 숨김 |

---

### 5.2 STEP 2 — AI 플랜 생성 & 이중 안전 검증

#### REQ-07: Rule-based 이중 안전 검증 및 플랜 생성
| 항목 | 내용 |
|------|------|
| ID | REQ-07 |
| 화면 | PlanGeneratingScreen |
| 기본 노출 | 프로그레스 바 + "부상 안전 규칙 검증 중..." 애니메이션 |
| 검증 레이어 1 | 프롬프트 제약: Claude Haiku에 안전 규칙 주입 |
| 검증 레이어 2 | 서버 사이드 코드: 10~15개 안전 규칙 검증 |
| 성공 동작 | 4주 JSON 스키마 수신 → 자동으로 홈 화면 진입 |
| 실패 동작 | 에러 메시지 + [재시도] 버튼 1회 터치 |
| 사용자 개입 | 없음 (완전 자동화) |
| 출력 스키마 | `WorkoutPlan { weeks: Week[4], exercises: Exercise[] }` |

**안전 검증 규칙 예시 (10~15개)**
```
R-01: 급성 통증(NRS 8+) 시 고강도 운동 제외
R-02: 무릎 부상 시 스쿼트 계열 하중 제한
R-03: 허리 디스크 시 데드리프트/굿모닝 제외
R-04: 어깨 부상 시 오버헤드 프레스 제외
R-05: 첫 주 운동 볼륨 이전 주 대비 +10% 이하
R-06: 재활 동작은 전체 운동의 최소 40% 이상
R-07: 세션 간 동일 부위 48시간 이상 휴식 보장
R-08: 운동 시간 60분 초과 불가 (초보자 기준)
R-09: 통증 부위 직접 자극 동작 1주차 제외
R-10: 모든 세션 워밍업 동작 최소 1개 필수 포함
```

---

### 5.3 STEP 3 — 메인 홈 대시보드

#### REQ-08: 일일 운동 요약 카드
| 항목 | 내용 |
|------|------|
| ID | REQ-08 |
| 화면 | HomeDashboardScreen |
| 기본 노출 | 오늘 날짜, 목표 운동 5개 요약 카드 (준비1, 재활/보조2, 메인2) |
| 원터치 A | 카드 전체 터치 → Step 4 세션 상세 진입 |
| 원터치 B | [오늘의 운동 일괄 완료] 터치 → 전 세트 일괄 승인 완료 |
| Quick-Edit | 특정 운동 카드 좌우 슬라이드 → [스킵] 처리 |
| 부가 노출 | 주간 완료율 진척 바, 현재 통증 점수, 연속 운동일 뱃지 |

---

### 5.4 STEP 4 & 5 — 세션 상세 및 세트 기록

#### REQ-09: Auto Pre-fill 데이터 로딩
| 항목 | 내용 |
|------|------|
| ID | REQ-09 |
| 화면 | WorkoutSessionScreen |
| 기본 노출 | 이전 세션 [무게/횟수/세트수] 자동 입력된 상태 |
| 첫 진입 시 | AI 추천값으로 Pre-fill |
| 원터치 동작 | 화면 진입 후 즉시 운동 수행 가능 (추가 입력 없음) |
| 저장 데이터 | `prefill_source: enum(prev_session, ai_recommendation)` |

#### REQ-10: 세트별 원터치 완료
| 항목 | 내용 |
|------|------|
| ID | REQ-10 |
| 화면 | WorkoutSessionScreen > SetItem |
| 기본 노출 | 각 세트 우측 미완료 체크박스 [  ] |
| 원터치 동작 | 체크박스 터치 → 완료 체크 + 60초 휴식 카운트다운 자동 시작 |
| 타이머 UI | 화면 하단 고정 바 형태로 카운트다운 노출 |
| 타이머 Skip | 타이머 영역 터치 시 즉시 스킵 |

#### REQ-11: 세트 수 증감 (Quick Set Edit)
| 항목 | 내용 |
|------|------|
| ID | REQ-11 |
| 화면 | WorkoutSessionScreen > SetList |
| 기본 노출 | 세트 목록 하단 [+ 세트 추가] 버튼 |
| 원터치 동작 | [+ 세트 추가] 터치 → 이전 세트와 동일 무게/횟수 새 라인 생성 |
| Quick-Edit | 세트 라인 스와이프 → [삭제] 버튼 노출 → 터치 삭제 |

#### REQ-12: 무게 & 횟수 퀵 수정
| 항목 

---
## Stage: planning

```json
{
  "summary": "RecoveryFit 프로젝트의 시작 페이지(SplashScreen / LandingScreen) 디자인 요구사항을 기존 PRD에 추가합니다. 온보딩 진입 전 첫 화면으로, 브랜드 아이덴티티를 전달하고 사용자를 자연스럽게 온보딩으로 유도하는 역할을 합니다.",
  "requirements": [
    {
      "id": "REQ-00-A",
      "title": "스플래시 스크린 (앱 로딩)",
      "screen": "SplashScreen",
      "description": "앱 최초 진입 시 표시되는 로딩 화면. 브랜드 로고와 슬로건을 노출하며 초기 데이터 로딩 완료 후 자동 전환.",
      "design_spec": {
        "background": "딥 네이비 (#0D1B2A) 풀스크린",
        "logo": "중앙 배치 — RecoveryFit 워드마크 (흰색) + 재활/회복을 상징하는 심볼 아이콘 (민트 #00C9A7)",
        "tagline": "로고 하단 16px 간격 — '부상 후, 더 강하게' (흰색, Font-size 16sp, Letter-spacing 0.08em)",
        "loading_indicator": "로고 하단 민트색 프로그레스 도트 (3개 애니메이션)",
        "animation": "페이드인 0.6s → 정지 1.2s → 페이드아웃 0.4s 후 다음 화면 전환",
        "duration": "최소 2초, 초기 로딩 완료 시점 기준 자동 전환 (최대 5초)"
      },
      "transition": {
        "신규_사용자": "SplashScreen → LandingScreen",
        "기존_사용자_disclaimer_완료": "SplashScreen → HomeDashboardScreen"
      }
    },
    {
      "id": "REQ-00-B",
      "title": "시작 랜딩 페이지 디자인",
      "screen": "LandingScreen",
      "description": "신규 사용자가 스플래시 이후 최초로 마주하는 페이지. 서비스 가치를 직관적으로 전달하고 온보딩 시작을 유도. 터치 최소화 원칙에 따라 단일 CTA 버튼으로 구성.",
      "layer_rule": {
        "layer_1_기본_노출": "히어로 비주얼 + 핵심 가치 문구 3종 + [시작하기] CTA 버튼 자동 노출",
        "layer_2_원터치": "[시작하기] 1회 터치 → OnboardingDisclaimerScreen(REQ-01) 진입",
        "layer_3_quick_edit": "없음 (랜딩은 단방향 진입 전용)"
      },
      "design_spec": {
        "layout": "풀스크린 스크롤 없음, 단일 뷰포트 구성",
        "배경": {
          "type": "그라디언트 오버레이 + 배경 이미지",
          "image": "재활 운동 중인 인물 일러스트 (사진 아님 — 의료적 부담 완화)",
          "gradient": "상단 투명 → 하단 딥 네이비 (#0D1B2A) 60% 오버레이",
          "이미지_위치": "화면 상단 55% 영역"
        },
        "헤더_영역": {
          "위치": "상단 Safe Area 기준 16px",
          "내용": "RecoveryFit 로고 좌측 상단 배치 (흰색, 소형)"
        },
        "히어로_텍스트": {
          "위치": "화면 세로 45% 지점부터 하단 방향",
          "main_headline": {
            "text": "부상 후에도\n운동할 수 있어요",
            "style": "Bold, 28sp, 흰색, 줄간격 1.35"
          },
          "sub_headline": {
            "text": "AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요",
            "style": "Regular, 15sp, 흰색 80% 투명도, 줄간격 1.5",
            "margin_top": "12px"
          }
        },
        "가치_포인트_3종": {
          "위치": "서브 헤드라인 하단 24px",
          "layout": "가로 3열 아이콘 + 텍스트",
          "항목": [
            {
              "icon": "shield-check (민트색)",
              "label": "이중 안전\n검증"
            },
            {
              "icon": "brain (민트색)",
              "label": "AI 개인화\n플랜"
            },
            {
              "icon": "touch-minimal (민트색)",
              "label": "터치 최소화\n인터페이스"
            }
          ],
          "style": "아이콘 24px, 텍스트 12sp 흰색 70%"
        },
        "CTA_버튼": {
          "위치": "하단 Safe Area 기준 32px 위 고정",
          "text": "무료로 시작하기",
          "style": {
            "background": "민트 #00C9A7",
            "text_color": "#0D1B2A (딥 네이비)",
            "font": "Bold 17sp",
            "border_radius": "14px",
            "height": "56px",
            "width": "화면 좌우 24px 마진"
          },
          "터치_피드백": "눌림 시 scale 0.97 + 밝기 10% 감소 (0.1s)"
        },
        "보조_텍스트": {
          "위치": "CTA 버튼 하단 12px",
          "text": "의료기기 아님 · 전문의 상담을 대체하지 않습니다",
          "style": "Regular 11sp, 흰색 45% 투명도, 중앙 정렬"
        }
      },
      "접근성": {
        "다크모드": "별도 다크모드 없음 (기본 다크 디자인)",
        "색상_대비": "WCAG AA 기준 충족 — 주요 텍스트 대비비 4.5:1 이상",
        "폰트_크기": "시스템 폰트 크기 설정 반영 (sp 단위 사용)",
        "스크린_리더": "히어로 텍스트 + CTA 버튼 contentDescription 필수 지정"
      },
      "저장_데이터": "없음 (랜딩은 데이터 수집 없음)",
      "분기_조건": "disclaimer_agreed_at 존재 시 LandingScreen 스킵 → HomeDashboardScreen 직행"
    },
    {
      "id": "REQ-00-C",
      "title": "컬러 시스템 & 타이포그래피 가이드 (시작 페이지 기준)",
      "description": "시작 페이지 전용 디자인 토큰 정의. 이후 전체 앱 디자인 시스템으로 확장 기준점.",
      "color_tokens": {
        "primary_dark": "#0D1B2A",
        "primary_mint": "#00C9A7",
        "primary_mint_light": "#33D4B8",
        "text_primary": "#FFFFFF",
        "text_secondary": "rgba(255,255,255,0.70)",
        "text_tertiary": "rgba(255,255,255,0.45)",
        "surface_overlay": "rgba(13,27,42,0.60)"
      },
      "typography": {
        "headline_l": "Bold 28sp / Line-height 1.35",
        "headline_m": "SemiBold 22sp / Line-height 1.4",
        "body_l": "Regular 15sp / Line-height 1.5",
        "body_s": "Regular 12sp / Line-height 1.4",
        "caption": "Regular 11sp / Line-height 1.3",
        "button": "Bold 17sp / Letter-spacing 0.01em"
      },
      "motion": {
        "duration_fast": "100ms",
        "duration_normal": "200ms",
        "duration_slow": "400ms",
        "easing": "ease-in-out"
      }
    }
  ],
  "milestones": [
    {
      "id": "M-00",
      "title": "시작 페이지 디자인 완료",
      "duration": "3일",
      "tasks": [
        "SplashScreen 고해상도 목업 제작 (1종)",
        "LandingScreen 고해상도 목업 제작 (1종)",
        "컬러 토큰 / 타이포그래피 Figma 디자인 시스템 등록",
        "일러스트 에셋 확정 (히어로 이미지 1종, 아이콘 3종)",
        "개발팀 핸드오프용 Figma Inspect 링크 생성"
      ],
      "deliverables": [
        "Figma 목업 파일 (SplashScreen + LandingScreen)",
        "디자인 토큰 JSON 파일",
        "/workspace/c052dd6b/prd.md 업데이트 (REQ-00-A/B/C 반영)"
      ],
      "담당": "Designer",
      "선행_조건": "없음"
    },
    {
      "id": "M-01",
      "title": "시작 페이지 개발 구현",
      "duration": "2일",
      "tasks": [
        "SplashScreen 컴포넌트 구현 (로고 페이드인 애니메이션)",
        "LandingScreen 컴포넌트 구현 (히어로 비주얼 + CTA)",
        "신규/기존 사용자 분기 로직 구현 (disclaimer_agreed_at 체크)",
        "접근성 contentDescription 적용",
        "QA: 다양한 화면 크기 대응 확인"
      ],
      "deliverables": [
        "SplashScreen.kt / LandingScreen.kt (또는 .tsx)",
        "디자인 토큰 적용 완료된 컴포넌트"
      ],
      "담당": "Frontend Developer",
      "선행_조건": "M-00 완료"
    }
  ]
}
```

---

## 산출물: `/workspace/c052dd6b/prd.md` 추가/수정 내용

```markdown
## 0. 시작 페이지 디자인 (신규 추가 — v1.1.0)

> **변경 이력**: 2025-01-31 | 온보딩 진입 전 시작 페이지 디자인 요구사항 추가

---

### REQ-00-A: 스플래시 스크린

| 항목 | 내용 |
|------|------|
| ID | REQ-00-A |
| 화면 | SplashScreen |
| 배경 | 딥 네이비 #0D1B2A 풀스크린 |
| 로고 | 중앙 배치, 흰색 워드마크 + 민트(#00C9A7) 심볼 |
| 슬로건 | "부상 후, 더 강하게" — 16sp, Letter-spacing 0.08em |
| 로딩 표시 | 민트색 도트 3개 애니메이션 |
| 애니메이션 | 페이드인 0.6s → 정지 1.2s → 페이드아웃 0.4s |
| 전환 조건 | 신규: LandingScreen / 기존(동의완료): HomeDashboardScreen |

---

### REQ-00-B: 시작 랜딩 페이지

| 항목 | 내용 |
|------|------|
| ID | REQ-00-B |
| 화면 | LandingScreen |
| 기본 노출 | 히어로 비주얼 + 핵심 가치 3종 + CTA 버튼 |
| 원터치 동작 | [무료로 시작하기] 1회 터치 → REQ-01(면책동의) 진입 |
| Quick-Edit | 없음 |

**레이아웃 구성**

```
┌─────────────────────────────────┐
│ [로고 소형]          Safe Area  │
│                                 │
│   [히어로 일러스트 영역 55%]    │
│      (딥 네이비 그라디언트      │
│         오버레이 60%)           │
│                                 │
│  부상 후에도                    │
│  운동할 수 있어요               │  ← Bold 28sp 흰색
│                                 │
│  AI가 내 부상 상태를 분석하고   │
│  안전한 재활 플랜을 만들어드려요│  ← Regular 15sp 흰색 80%
│                                 │
│  🛡 이중안전  🧠 AI개인화  👆터치최소│  ← 아이콘+12sp
│                                 │
│ ┌─────────────────────────────┐ │
│ │      무료로 시작하기         │ │  ← 민트 배경, 네이비 텍스트
│ └─────────────────────────────┘ │
│  의료기기 아님 · 전문의 상담    │
│  을 대체하지 않습니다           │  ← 11sp 흰색 45%
└─────────────────────────────────┘
```

---

### REQ-00-C: 디자인 토큰 (시작 페이지 기준)

| 토큰 | 값 |
|------|----|
| primary-dark | #0D1B2A |
| primary-mint | #00C9A7 |
| text-primary | #FFFFFF |
| text-secondary | rgba(255,255,255,0.70) |
| text-tertiary | rgba(255,255,255,0.45) |
| headline-l | Bold 28sp / 1.35 |
| button | Bold 17sp |
| duration-normal | 200ms ease-in-out |
```