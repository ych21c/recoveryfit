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

## Android Build Configuration (after QA fix)

### Gradle / AGP versions
| Config | Value | Reason |
|--------|-------|--------|
| Gradle wrapper | 8.6 | Java 21 support (8.0 fails with class file version 65) |
| AGP | 8.3.2 | Java 21 + `sourceCompatibility = VERSION_1_8` fix (needs >=8.2.1) |
| Kotlin | 1.9.22 | Compatible with AGP 8.3.x |

### settings.gradle format
Uses new declarative `pluginManagement {}` + `plugins {}` format (NOT the old
`apply from: ".../app_plugin_loader.gradle"` which caused "plugin not found" errors).

### Desugaring dependency
Correct artifact: `com.android.tools:desugar_jdk_libs:2.0.4`  
(Wrong: `com.android.tools.build:desugaring:2.0.4`)

### App icons
mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png must exist (created as
solid #1DB954 green placeholders; replace with actual RecoveryFit branding).

### Font config
Pretendard font files are NOT bundled - font config removed from pubspec.yaml.
App falls back to system font. To use Pretendard: add TTF files to `assets/fonts/`
and restore the fonts section in pubspec.yaml.

### AAPT2 Daemon Startup Failure Fix (ARM64 Container)
This project runs in an **ARM64 Linux container on Apple Silicon macOS** (Docker Desktop).
All Android SDK binaries (`aapt2`, NDK `clang`, etc.) ship as x86-64 ELF files.
macOS Rosetta 2 can translate them **if** x86-64 glibc is installed in the container.

**One-time setup** (run once per fresh container; survives apt cache clears):
```sh
# 1. Download & extract libc6 (x86-64 glibc + dynamic linker)
cd /tmp
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.39-0ubuntu8_amd64.deb" -o libc6.deb
dpkg-deb -x libc6.deb libc6_extract
mkdir -p /lib64 /usr/lib/x86_64-linux-gnu
cp /tmp/libc6_extract/usr/lib/x86_64-linux-gnu/lib*.so* /usr/lib/x86_64-linux-gnu/
cp /tmp/libc6_extract/usr/lib64/ld-linux-x86-64.so.2 /lib64/

# 2. libgcc_s + libstdc++ (needed by aapt2 and clang)
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-14/libgcc-s1_14-20240412-0ubuntu1_amd64.deb" -o libgcc.deb
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-14/libstdc++6_14-20240412-0ubuntu1_amd64.deb" -o libstdcpp.deb
dpkg-deb -x libgcc.deb libgcc_extract && dpkg-deb -x libstdcpp.deb libstdcpp_extract
find /tmp/libgcc_extract /tmp/libstdcpp_extract -name "*.so*" | xargs -I{} cp {} /usr/lib/x86_64-linux-gnu/

# 3. zlib1g (needed by NDK clang)
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/z/zlib/zlib1g_1.3.dfsg-3.1ubuntu2_amd64.deb" -o zlib1g.deb
dpkg-deb -x zlib1g.deb zlib1g_extract
cp /tmp/zlib1g_extract/usr/lib/x86_64-linux-gnu/libz.so.1* /usr/lib/x86_64-linux-gnu/
```

**`android/gradle.properties` override** (already in file):
```
android.aapt2FromMavenOverride=/opt/android-sdk-linux/build-tools/34.0.0/aapt2
```
This points AGP to the standalone SDK AAPT2 (which now runs via Rosetta) instead
of the bundled Maven AAPT2 daemon which also fails.

After the one-time setup above, `flutter build apk --debug` succeeds.

## Important Notes
- Anthropic API key is entered by user in Settings and stored in SharedPreferences
  (never sent to any server other than api.anthropic.com).
- Medical disclaimer (`AppConstants.disclaimer`) must appear on onboarding last step,
  home screen, and subscription page per Korean health app guidelines.
- Android `minSdkVersion = 21` (Android 5.0+); in_app_purchase requires billing permission.
- `local.properties` is NOT tracked by git (machine-specific). QA must set:
  `sdk.dir=<android-sdk-path>` and `flutter.sdk=<flutter-sdk-path>`.

## Testing
No automated tests yet. Manual QA checklist:
1. Onboarding: all 6 steps, injury keyword detection, equipment selection
2. Plan generation: LLM call limit counter increments, unsafe exercise removal
3. Checklist: complete/skip/pain recording persists across app restart
4. Progress charts: data appears after ≥1 daily log
5. Weekly adjust: blocked before 7 days, works after
6. Subscription: IAP flow, restore purchase
