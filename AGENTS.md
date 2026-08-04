# RecoveryFit — Agent Memory

## Project Overview
Flutter Android-first app that takes free-text injury/pain input, runs it through
a safety filter pipeline, and asks Claude (Anthropic) to generate a 4-week
structured workout plan from a curated exercise library.

## Architecture

### Tech Stack
- **State management**: Riverpod (`flutter_riverpod`) — `StateNotifierProvider`, `FutureProvider`
- **Navigation**: `go_router` with `ShellRoute` for bottom nav
- **Local storage**: Hive (structured objects) + SharedPreferences (settings/flags)
- **Charts**: `fl_chart`
- **Notifications**: `flutter_local_notifications`
- **In-app purchase**: `in_app_purchase`
- **LLM**: Anthropic Claude API (REST via `http` package)

### Directory Layout
```
lib/
  main.dart                     # Hive init, adapter registration, app entry
  app.dart                      # RecoveryFitApp (StorageService init + router)
  core/
    constants/
      app_constants.dart        # LLM models, limits, storage keys, disclaimer
      injury_rules.dart         # Korean keyword → body-part → exclusion-tag rules
      equipment_mapping.dart    # Equipment tag → home/gym/both mapping
    theme/app_theme.dart        # Material 3 theme, pain color helper
    router/app_router.dart      # GoRouter + MainShell (bottom nav)
  data/
    models/
      user_profile.dart + .g.dart   # Hive typeId=0
      workout_plan.dart + .g.dart   # PlannedExercise(1), WorkoutDay(2), WorkoutWeek(3), WorkoutPlan(4)
      daily_log.dart + .g.dart      # ExerciseLogEntry(5), DailyLog(6)
      exercise.dart                  # Pure Dart model, loaded from JSON asset
    services/
      storage_service.dart      # Singleton: Hive boxes + SharedPreferences
      exercise_service.dart     # Singleton: loads/caches assets/exercises/exercises.json
      llm_service.dart          # Anthropic API calls (Sonnet initial, Haiku weekly)
      notification_service.dart # flutter_local_notifications wrapper
    repositories/
      exercise_repository.dart  # Environment filter + injury safety filter
      plan_repository.dart      # Active plan CRUD + date → WorkoutDay lookup
      log_repository.dart       # DailyLog CRUD + week summary builder
  domain/
    usecases/
      generate_plan_usecase.dart # Full pipeline: filter → LLM (Sonnet) → re-validate → persist
      adjust_plan_usecase.dart   # Weekly: log summary → LLM (Haiku) → re-validate → persist
  presentation/
    providers/providers.dart    # All Riverpod providers
    onboarding/                 # 6-step PageView wizard → triggers GeneratePlanUseCase
    home/home_page.dart         # Dashboard: greeting, today card, weekly stats
    plan/                       # 4-week tab calendar + workout detail
    checklist/checklist_page.dart  # Daily exercise checklist (unified ExerciseCard)
    progress/progress_page.dart    # 3 fl_chart charts: pain trend, completion, volume
    settings/                   # API key entry, subscription management
  widgets/
    exercise_card.dart          # Unified card (used in checklist + plan detail)
    pain_level_slider.dart      # Coloured 1-10 slider
assets/
  exercises/exercises.json      # 150 exercises with safety_tags, phase_tags, equipment
```

### Key Design Decisions

#### Injury Safety Filter (Two-Layer)
1. **Pre-LLM**: `ExerciseRepository.getFilteredExercises()` removes exercises whose
   `safety_tags` overlap with `InjuryRules.getExclusionTags(detectedBodyParts)`.
   Filtered list is passed to LLM prompt as `ALLOWED_EXERCISES`.
2. **Post-LLM**: `ExerciseRepository.findUnsafeExercises()` re-validates every
   exercise ID returned by the LLM. Any unsafe IDs are silently removed from the plan.

#### LLM Cost Control
- Max 5 calls/user/month (1 initial Sonnet + 4 weekly Haiku) tracked in SharedPreferences
- Monthly counter resets on first call in a new calendar month
- Weekly adjust gated by 7-day cooldown (`canAdjustWeekly`)
- `StorageService.canMakeLlmCall` checked in both use cases before API call

#### Hive Type IDs
```
0 = UserProfile
1 = PlannedExercise
2 = WorkoutDay
3 = WorkoutWeek
4 = WorkoutPlan
5 = ExerciseLogEntry
6 = DailyLog
```
The `.g.dart` adapter files are hand-written (no build_runner needed at runtime).

#### Exercise JSON Schema
Key fields per exercise:
- `safety_tags`: list of exclusion keys matched against `InjuryRules.exclusionRules`
- `phase_tags`: `warmup | rehab | main | cooldown` — used for phase badge in UI
- `equipment`: matched against `EquipmentMapping` for env filter

#### LLM Prompt Contract
- Initial plan → `claude-sonnet-4-5`, max 4096 tokens, structured JSON only
- Weekly adjust → `claude-haiku-4-5`, same schema
- Both prompts: Korean language, explicit EXCLUDED_TAGS list, no free text
- JSON extraction: strips markdown fences, finds first `{...}` block

## Important Notes
- Flutter is NOT installed in this environment; project was created manually.
  To run: install Flutter SDK, then `flutter pub get && flutter run`.
- `assets/fonts/` directory is referenced in pubspec.yaml but font files are not
  bundled (add Pretendard TTF files or remove font config to use system font).
- Anthropic API key is entered by user in Settings and stored in SharedPreferences
  (never sent to any server other than api.anthropic.com).
- Medical disclaimer (`AppConstants.disclaimer`) must appear on onboarding last step,
  home screen, and subscription page per Korean health app guidelines.
- Android `minSdkVersion = 21` (Android 5.0+); in_app_purchase requires billing permission.

## Testing
No automated tests yet. Manual QA checklist:
1. Onboarding: all 6 steps, injury keyword detection, equipment selection
2. Plan generation: LLM call limit counter increments, unsafe exercise removal
3. Checklist: complete/skip/pain recording persists across app restart
4. Progress charts: data appears after ≥1 daily log
5. Weekly adjust: blocked before 7 days, works after
6. Subscription: IAP flow, restore purchase
