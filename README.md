# RecoveryFit

> **부상·통증 증상을 입력하면 LLM이 안전 검증된 맞춤 운동 플랜을 생성해주는 Flutter 앱 (Android 우선)**

---

## 앱 개요

RecoveryFit은 사용자가 부상/통증 증상을 자유 텍스트로 입력하면 Claude AI가 안전 필터를 거친 운동 라이브러리 내에서 4주 맞춤 운동 플랜을 생성하는 모바일 앱입니다.

### 핵심 기능
| 기능 | 설명 |
|------|------|
| 온보딩 6단계 | 부상·통증 텍스트, 통증 수준(1-10), 목표, 빈도, 환경, 장비 |
| AI 플랜 생성 | Claude Sonnet으로 4주 구조화 JSON 플랜 생성 |
| 부상 안전 필터 | 10-15개 규칙 기반 이중 검증 (LLM 전 + 후) |
| 일별 체크리스트 | 완료/스킵/통증 기록 (통일 카드 UI) |
| 통계 3종 | 통증 추이 / 완료율 / 주간 볼륨 그래프 |
| 주간 재조정 | 7일 기록 요약 → Claude Haiku로 플랜 갱신 (월 최대 4회) |
| 인앱결제 | 월 2,900원 구독 (Google Play) |

### LLM 비용 제어
- 사용자당 월 5회 한도 (초기 플랜 1회 Sonnet + 주간 갱신 4회 Haiku)
- 고정 JSON 스키마, 자유 서술 최소화

---

## 기술 스택

- **Flutter** 3.x (Android 우선, minSdk 21)
- **State**: flutter_riverpod
- **Navigation**: go_router
- **Storage**: Hive (구조화) + SharedPreferences (설정)
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **IAP**: in_app_purchase
- **LLM**: Anthropic Claude API (REST)

---

## 시작하기

```bash
# 1. Flutter SDK 설치 (https://flutter.dev/docs/get-started/install)
# 2. 의존성 설치
flutter pub get

# 3. Android 기기/에뮬레이터 연결 후 실행
flutter run

# 4. 설정 화면에서 Anthropic API 키 입력 (console.anthropic.com)
```

> **폰트**: `assets/fonts/` 에 Pretendard TTF 파일이 필요합니다.  
> 없으면 `pubspec.yaml`의 `fonts:` 섹션을 제거하면 시스템 기본 폰트로 동작합니다.

---

## 프로젝트 구조

```
lib/
├── main.dart                   # Hive 초기화, 앱 진입점
├── app.dart                    # RecoveryFitApp
├── core/                       # 상수, 테마, 라우터
├── data/
│   ├── models/                 # UserProfile, WorkoutPlan, DailyLog, Exercise
│   ├── services/               # StorageService, ExerciseService, LlmService
│   └── repositories/           # ExerciseRepository, PlanRepository, LogRepository
├── domain/usecases/            # GeneratePlanUseCase, AdjustPlanUseCase
├── presentation/               # 온보딩, 홈, 플랜, 체크리스트, 통계, 설정
└── widgets/                    # ExerciseCard, PainLevelSlider
assets/
└── exercises/exercises.json    # 150개 운동 DB (안전태그·상태태그·장비 포함)
```

---

## ⚠️ 면책조항

RecoveryFit은 **의료기기가 아닙니다**. 제공되는 운동 플랜은 일반적인 건강 정보를 위한 것이며 의학적 진단·치료·처방을 대체하지 않습니다. 부상·통증이 있는 경우 **반드시 전문의와 상담** 후 운동을 시작하세요.
