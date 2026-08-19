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
/ (Splash, 2.2 s) → /landing (new user) → /disclaimer → /onboarding → /generating → /home
                   → /home    (returning)                              ↕ 3-tab shell
/session (pushed)         /home  /analytics  /settings
/session-complete
/weekly-report
```
- Splash checks `StorageService.onboardingDone`; new users go to /landing, returning to /home
- Landing CTA navigates to /disclaimer; router redirect at /landing skips to /home when done
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
This repo runs on an **aarch64** machine but the Android SDK/NDK binaries are **x86_64**.
AAPT2 and Gradle tooling require x86_64 shared libraries. Complete fix:

```bash
# 1. zlib
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/z/zlib/zlib1g_1.3.dfsg+really1.3.1-1ubuntu1_amd64.deb" -o /tmp/zlib1g_amd64.deb
dpkg-deb --extract /tmp/zlib1g_amd64.deb /tmp/zlib1g_amd64
mkdir -p /lib/x86_64-linux-gnu
cp /tmp/zlib1g_amd64/usr/lib/x86_64-linux-gnu/libz.so.1.3.1 /lib/x86_64-linux-gnu/
ln -sf /lib/x86_64-linux-gnu/libz.so.1.3.1 /lib/x86_64-linux-gnu/libz.so.1

# 2. glibc (ld-linux-x86-64.so.2, libc.so.6, libdl.so.2, libm.so.6, etc.)
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/libc6_2.39-0ubuntu8_amd64.deb" -o /tmp/libc6_amd64.deb
dpkg-deb --extract /tmp/libc6_amd64.deb /tmp/libc6_amd64
cp /tmp/libc6_amd64/usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib/x86_64-linux-gnu/
cp /tmp/libc6_amd64/usr/lib/x86_64-linux-gnu/libc.so.6 /lib/x86_64-linux-gnu/
cp /tmp/libc6_amd64/usr/lib/x86_64-linux-gnu/libdl.so.2 /lib/x86_64-linux-gnu/
cp /tmp/libc6_amd64/usr/lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/
cp /tmp/libc6_amd64/usr/lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/
cp /tmp/libc6_amd64/usr/lib/x86_64-linux-gnu/librt.so.1 /lib/x86_64-linux-gnu/
mkdir -p /lib64
ln -sf /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

# 3. libgcc_s
curl -sL "http://archive.ubuntu.com/ubuntu/pool/main/g/gcc-14/libgcc-s1_14-20240412-0ubuntu1_amd64.deb" -o /tmp/libgcc_s1_amd64.deb
dpkg-deb --extract /tmp/libgcc_s1_amd64.deb /tmp/libgcc_s1_amd64
cp /tmp/libgcc_s1_amd64/usr/lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/
```

Also requires in `android/app/build.gradle.kts` (already present):
```kotlin
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

### Pre-existing Unused Pages
`checklist_page.dart`, `progress_page.dart`, `plan_page.dart`, `workout_detail_page.dart`
are not referenced in the router but still compile (kept for future reference).

### Start-Page Design System (`lib/design_system/`)
Added for the splash + landing screens:
- `AppColors` — primaryDark `#0D1B2A`, primaryMint `#00C9A7`; includes v1.2.0 alias tokens for backward compat
- `AppTypography` — headlineL (Bold 28sp/1.35), bodyL, caption, button styles
- `AppSpacing` — horizontalMargin 24, ctaBottomPad 32
- `AppMotion` — durationFadeIn 600ms, durationHold 1200ms, durationFadeOut 400ms

### Start-Page Screens (`lib/screens/`)
- `splash/splash_screen.dart` — deep navy fullscreen, fade in/hold/out animation, routes based on `onboardingDone`
- `splash/widgets/dot_loading_indicator.dart` — 3 mint dots with sequential bounce (stagger 200ms each)
- `landing/landing_screen.dart` — fullscreen no-scroll, hero top 55%, content bottom-aligned
- `landing/widgets/hero_visual.dart` — CustomPaint reproducing the ATM-5 SVG illustration + gradient overlay
- `landing/widgets/value_points_row.dart` — 3-column icon+label row (shield/brain/touch icons)
- `landing/widgets/cta_button.dart` — mint 56px button, scale+darken on press

## Commands
```bash
flutter analyze          # Static analysis
flutter test             # Unit tests
flutter build apk --debug  # Build debug APK
```

## CI Notes
- `.github/workflows/validation.yml` runs `flutter analyze` + `flutter test` + `flutter build apk --debug`
- Root `.gitignore` was generated from a Python template that included `lib/` — this silently excluded all Flutter source files from git tracking, causing CI to fail with "Target file 'lib/main.dart' not found". Fixed by removing the `lib/` line from `.gitignore` and staging all `lib/` files. Always check this if CI reports missing Flutter source files.

## Integration Test Notes
- `integration_test` package must be listed under `dev_dependencies` in `pubspec.yaml` (`sdk: flutter`).
- `integration_test/scenario_test.dart` uses `IntegrationTestWidgetsFlutterBinding` (standard integration test). Running with `flutter test integration_test/scenario_test.dart` on Linux attempts a Linux desktop build — which requires GTK3 dev libraries (absent on this host). Run with a connected Android device or emulator for CI.
- Headline text in the landing screen is split into **separate `Text` widgets** (one per visual line): use `find.text('부상 후에도')` and `find.text('운동할 수 있어요')` separately — NOT `find.text('부상 후에도\n운동할 수 있어요')`.
- The splash loading indicator is `DotLoadingIndicator` (custom widget with `BoxShape.circle` Containers) — use `find.byType(DotLoadingIndicator)`, NOT `find.byIcon(Icons.circle)`.
- The landing CTA is a custom `CtaButton` (GestureDetector + AnimatedContainer + AnimatedScale), NOT `ElevatedButton`; use `find.byType(CtaButton)` with the import `package:recovery_fit/screens/landing/widgets/cta_button.dart`.
- `tester.tapDown()` / `tester.tapUp()` do NOT exist in `WidgetTester`. Simulate pointer-down/up with `await tester.startGesture(offset)` and `await gesture.up()`.
- For **splash-screen checks**: use `pump(Duration(seconds: 2))` — app init + 2s keeps us within the 2.2s total splash animation window before navigation fires.
- For **landing-screen checks** after splash: use `pumpAndSettle(Duration(seconds: 4))` — 4s exceeds the 2.2s animation; once navigation happens landing is static and pumpAndSettle settles.
- The `RecoveryFitApp._initFuture` is a static memoized Future; subsequent tests in the same run reuse it without re-initialising Hive/SharedPreferences.
- Onboarding Step 2 navigation: the "다음" `ElevatedButton` is disabled until injury text ≥ 5 chars; call `tester.enterText(find.byType(TextField).first, '...')` before tapping it.

## Linux Dev-Tool Setup (aarch64, Ubuntu 24.04)
The `apt` package manager on this host has broken amd64/aarch64 cross-configuration; use manual binary installs:
- **cmake**: download `cmake-X.Y.Z-linux-aarch64.sh` from github.com/Kitware/CMake/releases, run with `--prefix=/usr/local`.
- **ninja**: download `ninja-linux-aarch64.zip` from github.com/ninja-build/ninja/releases.
- **clang/clang++**: download `clang+llvm-X.Y.Z-aarch64-linux-gnu.tar.xz` from github.com/llvm/llvm-project/releases, extract with `--strip-components=1` to `/usr/local`.
- **pkg-config**: build from source (`pkg-config-0.29.2.tar.gz` from pkgconfig.freedesktop.org, `./configure --with-internal-glib --prefix=/usr/local`).
- GTK3 dev libraries still unavailable on this host — Linux integration-test builds may still fail; use Android target for integration tests in CI.
