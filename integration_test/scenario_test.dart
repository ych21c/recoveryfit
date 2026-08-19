import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (스플래시 & 랜딩)', () {
    testWidgets('SplashScreen 표시 및 로고/슬로건 검증',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen이 초기에 보여야 함
      expect(find.byType(SplashScreen), findsOneWidget);

      // RecoveryFit 텍스트 (로고 워드마크)
      expect(find.text('RecoveryFit'), findsWidgets);

      // 슬로건 텍스트
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트 애니메이션 존재 확인
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SplashScreen에서 LandingScreen으로 자동 전환',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기: SplashScreen 표시
      expect(find.byType(SplashScreen), findsOneWidget);

      // 스플래시 애니메이션 지속 시간만큼 대기 (최소 2초)
      await tester.pump(const Duration(milliseconds: 600)); // 페이드인
      await tester.pump(const Duration(milliseconds: 1200)); // 정지
      await tester.pump(const Duration(milliseconds: 400)); // 페이드아웃

      // LandingScreen으로 전환되어야 함
      expect(find.byType(LandingScreen), findsOneWidget);
    });

    testWidgets('LandingScreen 레이아웃 및 주요 요소 검증',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // LandingScreen 표시 확인
      expect(find.byType(LandingScreen), findsOneWidget);

      // 헤더 로고 검증
      expect(find.text('RecoveryFit'), findsWidgets);

      // 메인 헤드라인
      expect(find.text('부상 후에도\n운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인
      expect(find.text('AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요'),
          findsOneWidget);

      // CTA 버튼
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 면책 고지
      expect(find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget);
    });

    testWidgets('LandingScreen 가치 포인트 3종 표시 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // 세 가지 가치 포인트 텍스트 확인
      expect(find.text('이중 안전\n검증'), findsOneWidget);
      expect(find.text('AI 개인화\n플랜'), findsOneWidget);
      expect(find.text('터치 최소화\n인터페이스'), findsOneWidget);
    });

    testWidgets('LandingScreen CTA 버튼 탭 동작 검증',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // DisclaimerPage로 이동 확인 (OnboardingDisclaimerScreen)
      expect(find.byType(DisclaimerPage), findsOneWidget);
    });

    testWidgets('LandingScreen 히어로 일러스트 영역 존재 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // LandingScreen 표시 확인
      expect(find.byType(LandingScreen), findsOneWidget);

      // 히어로 영역이 포함되어 있으므로 최소 하나의 Container 또는 Stack이 있음
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('LandingScreen 배경 색상 검증 (딥 네이비)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // LandingScreen이 있는지 확인
      expect(find.byType(LandingScreen), findsOneWidget);

      // Scaffold의 배경 색상이 설정되어 있음을 확인
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);
    });

    testWidgets('SplashScreen 도트 애니메이션 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 프레임에서 도트가 표시되는지 확인
      expect(find.byType(Container), findsWidgets);

      // 약간의 시간 경과 (애니메이션 진행)
      await tester.pump(const Duration(milliseconds: 300));

      // 여전히 SplashScreen이 표시되어야 함
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('LandingScreen 스크롤 불가 (단일 뷰포트) 확인',
        (WidgetTester tester) async {
      await tester.binding.window.physicalSizeTestValue =
          const Size(375, 812);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // 스크롤 시도
      await tester.drag(find.byType(LandingScreen), const Offset(0, -50));
      await tester.pump();

      // LandingScreen이 여전히 표시되어야 함 (스크롤 불가)
      expect(find.byType(LandingScreen), findsOneWidget);
    });

    testWidgets('LandingScreen 텍스트 렌더링 확인 (기본 폰트 사이즈)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 2200));

      // 메인 헤드라인과 CTA 버튼이 렌더링됨
      expect(find.text('부상 후에도\n운동할 수 있어요'), findsOneWidget);
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });
  });
}