# Product Manager
Project: c052dd6b | Stage: planning

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