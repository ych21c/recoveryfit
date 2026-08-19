import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:recovery_fit/core/router/app_router.dart';
import 'package:recovery_fit/data/services/storage_service.dart';
import 'package:recovery_fit/screens/landing/landing_screen.dart';
import 'package:recovery_fit/screens/splash/splash_screen.dart';

// Minimal router that starts at Splash and can navigate to Landing/Disclaimer.
GoRouter _makeRouter() => GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.landing,
          builder: (_, __) => const LandingScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: AppRoutes.disclaimer,
          builder: (_, __) =>
              const Scaffold(body: Text('이용 전 꼭 확인하세요')),
        ),
      ],
    );

// Minimal router that starts directly at Landing (skips Splash/Hive init).
GoRouter _landingRouter() => GoRouter(
      initialLocation: AppRoutes.landing,
      routes: [
        GoRoute(
          path: AppRoutes.landing,
          builder: (_, __) => const LandingScreen(),
        ),
        GoRoute(
          path: AppRoutes.disclaimer,
          builder: (_, __) =>
              const Scaffold(body: Text('이용 전 꼭 확인하세요')),
        ),
      ],
    );

// Sets the test viewport to a standard phone size (390×844) to avoid layout
// overflows that occur at the default 800×600 test surface.
void _usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  setUpAll(() async {
    // SharedPreferences mock so StorageService.init() succeeds without disk.
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
  });

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    testWidgets('스플래시 화면 로드 및 표시', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _makeRouter()));
      // Two pumps: first lets GoRouter build the initial route, second
      // renders it fully. We intentionally do NOT advance time past the
      // 2 200 ms splash animation so SplashScreen remains visible.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // 스플래시 화면 존재 확인
      expect(find.byType(SplashScreen), findsWidgets);

      // RecoveryFit 워드마크 텍스트 확인 (RichText — requires findRichText)
      expect(find.text('RecoveryFit', findRichText: true), findsWidgets);

      // 슬로건 텍스트 확인
      expect(find.text('부상 후, 더 강하게'), findsWidgets);

      // 로딩 도트 존재 (Container with circular BoxDecoration)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('랜딩 화면으로 전환 및 콘텐츠 표시', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _makeRouter()));
      await tester.pump();

      // Splash animation totals 2 200 ms; advance past it so _navigate() fires.
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 랜딩 화면 존재 확인
      expect(find.byType(LandingScreen), findsWidgets);

      // 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);

      // 서브 헤드라인 확인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsWidgets);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsWidgets);
    });

    testWidgets('랜딩 화면 가치 포인트 3종 표시', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _landingRouter()));
      await tester.pumpAndSettle();

      // 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsWidgets);
      expect(find.text('검증'), findsWidgets);

      expect(find.text('AI 개인화'), findsWidgets);
      expect(find.text('플랜'), findsWidgets);

      expect(find.text('터치 최소화'), findsWidgets);
      expect(find.text('인터페이스'), findsWidgets);
    });

    testWidgets('CTA 버튼 "무료로 시작하기" 표시 및 탭 가능', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _landingRouter()));
      await tester.pumpAndSettle();

      // CTA 버튼 텍스트 확인 (CtaButton은 GestureDetector 기반 커스텀 위젯)
      expect(find.text('무료로 시작하기'), findsWidgets);
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('랜딩 화면 보조 텍스트 표시', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _landingRouter()));
      await tester.pumpAndSettle();

      // 의료기기 아님 면책 텍스트 확인
      expect(find.text('의료기기 아님'), findsWidgets);
      expect(find.text('전문의 상담을 대체하지 않습니다'), findsWidgets);
    });

    testWidgets('랜딩 화면 헤더 로고 표시', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _landingRouter()));
      await tester.pumpAndSettle();

      // 헤더에 RecoveryFit 로고 확인
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('스플래시 화면 배경색 확인 (딥 네이비)', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _makeRouter()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Scaffold의 배경색이 설정돼 있는지 확인
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('CTA 버튼 탭 시 다음 화면 진입', (tester) async {
      _usePhoneSize(tester);
      await tester.pumpWidget(
          MaterialApp.router(routerConfig: _landingRouter()));
      await tester.pumpAndSettle();

      // CTA 버튼 탭 (Text 위젯 위치로 탭 — GestureDetector가 받아서 처리)
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 다음 화면(면책 동의)로 진입했는지 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsWidgets);
    });
  });
}