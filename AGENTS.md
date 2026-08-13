# RecoveryFit — Agent Notes

## Project Overview
Flutter app for AI-powered injury rehabilitation workout planning.
- Package: `com.recoveryfit.recovery_fit`
- State mgmt: Riverpod (`flutter_riverpod`)
- Navigation: go_router
- Local DB: Hive (strongly typed, adapters pre-generated)
- Charts: fl_chart

## Key Architecture Notes

### Design Tokens (AppTheme)
Colors match `design/applied/*.html` mockups exactly:
- `primary` = `#2E7D6B`, `primaryDark` = `#1B5E4F`, `primaryLight` = `#4CAF95`
- `secondary` = `#F4A261` (orange), `background` = `#F8FAF9`
- Old code used `AppTheme.divider` → now renamed `AppTheme.border`

### Navigation Flow (AppRoutes)
```
/landing → /disclaimer → /onboarding → /generating → /home
                                                     ↕ 3-tab shell
/session (pushed)               /home  /analytics  /settings
/session-complete
/weekly-report
```
- New users start at `/landing` (SCR-LANDING); existing users (`onboardingDone=true`) go directly to `/home`
- Shell has 3 tabs only: 홈, 통계, 설정
- Session screens use `context.push()` (not `go()`), so back button works

### Data Layer
- `UserProfile` Hive model: single `goal` field (maps long-term WorkoutGoal)
- Short-term goal from onboarding is prefixed into `injuryDescription` as `[shortGoal] text`
- `ExerciseRepository.getById()` is sync (uses cached `ExerciseService._cache`)
- `ChecklistNotifier.batchComplete()` marks all pending exercises as completed
- Session screen uses local in-memory state for per-set weight/reps (not persisted)

### Onboarding (5 Steps)
1. InjuryStep — text + example chips
2. PainLevelStep — colored 1-10 slider + chips
3. GoalStep (isShortTerm=true) — 통증완화/가동성/재활
4. GoalStep (isShortTerm=false) — 스태미나/근육/체중
5. EnvironmentStep — combined freq chips + location radio + equipment checkboxes

### Design/Applied HTML Mockups
- LandingPage (`lib/presentation/landing/landing_page.dart`): SCR-LANDING spec from designer_output.md v1.2.0; dark navy #0D1B2A bg, mint #00C9A7 CTA, 3-column value points
- ATM-5: Disclaimer + Injury Input (Onboarding 1.1, 1.2)
- ATM-6: Pain Level + Short/Long Goals (1.3, 1.4, 1.5)
- ATM-7: Environment+Equipment + AI Generating (1.6, Step 2)
- ATM-8: Home Dashboard + Swipe-to-skip cards (Step 3)
- ATM-9: Session Screen + Quick-Edit overlay (Step 4+5)
- ATM-10: Session Complete + Pain Feedback modal (Step 6)
- ATM-11: Analytics with KPI + 3 charts (Step 7)
- ATM-12: Weekly Report + AI adjustments (Step 8)

## Build Notes

### Android Build (aarch64 host issue)
This repo runs on an **aarch64** machine but the Android NDK is for **x86_64**.
The NDK's clang requires `libz.so.1` (x86_64 version). Fix applied:
```
dpkg-deb --extract zlib1g_amd64.deb /tmp/zlib1g_amd64
cp /tmp/zlib1g_amd64/usr/lib/x86_64-linux-gnu/libz.so.1.3 /lib/x86_64-linux-gnu/
ln -sf /lib/x86_64-linux-gnu/libz.so.1.3 /lib/x86_64-linux-gnu/libz.so.1
```
Also requires in `android/app/build.gradle.kts`:
```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### Pre-existing Unused Pages
`checklist_page.dart`, `progress_page.dart`, `plan_page.dart`, `workout_detail_page.dart`
are not referenced in the router but still compile (kept for future reference).

## Commands
```bash
flutter analyze          # Static analysis
<<<<<<< HEAD
flutter test             # Unit tests
flutter build apk --debug  # Build debug APK
```

## CI Notes
- `.github/workflows/validation.yml` runs `flutter analyze` + `flutter test` + `flutter build apk --debug`
- Root `.gitignore` was generated from a Python template that included `lib/` — this silently excluded all Flutter source files from git tracking, causing CI to fail with "Target file 'lib/main.dart' not found". Fixed by removing the `lib/` line from `.gitignore` and staging all `lib/` files. Always check this if CI reports missing Flutter source files.
=======
flutter build apk --debug  # Build debug APK
```
>>>>>>> 9ef3b65 (AI Implement: 사용자가 앱을 사용하는 **전체 유저 인터랙션 기본 플로우(8단계)**를 먼저 정의하고, 지금까지 도출된 모)
