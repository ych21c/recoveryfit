# RecoveryFit — Agent Memory

## Project Overview
Flutter Android app (recovery_fit) — AI-powered injury-safe workout planner.
- LLM: Anthropic Claude (Sonnet for initial plan, Haiku for weekly adjustment)
- State: Riverpod (StateNotifier)
- Navigation: go_router
- Storage: Hive (models) + SharedPreferences (settings/flags)
- Charts: fl_chart
- In-app purchase: in_app_purchase
- Notifications: flutter_local_notifications

## Build Commands
```bash
flutter pub get         # install dependencies
flutter analyze         # lint check (must pass with 0 errors)
flutter build apk --debug   # build Android debug APK
```

## Key Architecture
- `lib/core/constants/` — AppConstants, InjuryRules, EquipmentMapping
- `lib/data/models/` — Hive models (workout_plan, daily_log, user_profile, exercise)
- `lib/data/services/` — LlmService, StorageService, ExerciseService, NotificationService
- `lib/data/repositories/` — ExerciseRepository, PlanRepository, LogRepository
- `lib/domain/usecases/` — GeneratePlanUseCase, AdjustPlanUseCase
- `lib/presentation/` — Screens organized by feature
- `lib/widgets/` — Shared UI components (ExerciseCard, PainLevelSlider)

## User Flow
1. `/disclaimer` — Legal terms & medical consent (first launch)
2. `/onboarding` — 6-step profile collection (injury, pain, goal, frequency, environment, equipment)
3. LLM call → 4-week plan generated → `/home`
4. Daily: `/checklist` — mark exercises complete/skip/pain
5. Weekly (1×/week): adjust plan via LLM (`/home` banner)
6. Stats: `/progress` — 3 charts (pain trend, completion rate, weekly volume)
7. Subscription: `/settings/subscription` — ₩2,900/month via Google Play

## Important Constraints
- **LLM calls**: max 5/month per user (1 initial + 4 weekly) — enforced in StorageService.canMakeLlmCall + use cases
- **Weekly adjustment**: once per 7 days — enforced in StorageService.canAdjustWeekly + AdjustPlanUseCase
- **Subscription product ID**: `com.recoveryfit.app.monthly`
- **Medical disclaimer**: must appear in onboarding footer AND home page

## Android Config
- Requires core library desugaring for flutter_local_notifications (build.gradle.kts)
- Permissions: INTERNET, RECEIVE_BOOT_COMPLETED, VIBRATE, POST_NOTIFICATIONS, BILLING
- Min SDK: flutter.minSdkVersion (set by Flutter SDK)

## Exercise Database
- `assets/exercises/exercises.json` — 70+ exercises with safety_tags for injury filtering
- Safety tags match exclusion rules in `InjuryRules.exclusionRules`
- Equipment tags match `EquipmentMapping` for home/gym filtering

## Hive TypeIds
- UserProfile: 0
- PlannedExercise: 1
- WorkoutDay: 2
- WorkoutWeek: 3
- WorkoutPlan: 4
- ExerciseLogEntry: 5
- DailyLog: 6
