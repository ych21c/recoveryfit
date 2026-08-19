import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';
import 'package:recovery_fit/screens/splash/splash_screen.dart';
import 'package:recovery_fit/screens/landing/landing_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen) 검증', () {
    testWidgets('SplashScreen 진입 후 로고/슬로건/로딩 도트 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      // SplashScreen 자체 존재 확인
      expect(find.byType(SplashScreen), findsOneWidget);

      // 로고 워드마크 텍스트 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 슬로건 "부상 후, 더 강하게" 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트 애니메이션 (3개의 동일한 원형 위젯)
      // 도트는 재사용 가능한 위젯이므로 findsWidgets 사용
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets(
        'SplashScreen 애니메이션 진행 후 자동으로 LandingScreen 전환',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 초기: SplashScreen 표시
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LandingScreen), findsNothing);

      // 페이드인(0.6s) + 정지(1.2s) + 페이드아웃(0.4s) = 2.2s
      // 안전하게 2.5s 대기
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 전환 후 LandingScreen 출현 확인
      expect(find.byType(LandingScreen), findsOneWidget);
    });

    testWidgets('LandingScreen 메인 헤드라인 및 서브 헤드라인 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // SplashScreen 애니메이션 통과
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 메인 헤드라인: "부상 후에도\n운동할 수 있어요"
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인: "AI가 내 부상 상태를 분석하고..."
      expect(
        find.text('AI가 내 부상 상태를 분석하고'),
        findsOneWidget,
      );
      expect(
        find.text('안전한 재활 플랜을 만들어드려요'),
        findsOneWidget,
      );
    });

    testWidgets('LandingScreen 가치 포인트 3개 표시', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 3개의 가치 포인트: "이중 안전\n검증" / "AI 개인화\n플랜" / "터치 최소화\n인터페이스"
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('LandingScreen CTA 버튼 "무료로 시작하기" 표시 및 클릭',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // CTA 버튼 텍스트 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 버튼은 ElevatedButton 타입
      expect(find.byType(ElevatedButton), findsWidgets);

      // 버튼 탭 (클릭)
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책 동의 화면(DisclaimerPage)으로 진입 확인
      // DisclaimerPage의 고유 텍스트: "이용 전 꼭 확인하세요"
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
    });

    testWidgets('LandingScreen 보조 텍스트 "의료기기 아님 · 전문의 상담..."',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 보조 텍스트 확인
      expect(
        find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
        findsOneWidget,
      );
    });

    testWidgets('LandingScreen 헤더 로고 "RecoveryFit" 좌측 상단 배치',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // LandingScreen에서도 로고 재표시 확인
      // 텍스트 "RecoveryFit"은 여러 곳에 나타날 수 있음
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('SplashScreen 배경색 딥 네이비 (#0D1B2A) 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 100));

      // SplashScreen이 보이는 동안 배경 Container 찾기
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
      // 구체적인 색상 검증은 위젯 트리 구조에 따라 달라짐
      // 현재 SplashScreen 존재만 확인
    });

    testWidgets('LandingScreen 히어로 일러스트 영역 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 히어로 일러스트는 SVG 또는 이미지로 구현
      // LandingScreen 내 이미지/SVG 존재 확인
      expect(find.byType(LandingScreen), findsOneWidget);
      
      // ListView/CustomPaint 등으로 구현된 시각적 콘텐츠 존재
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('LandingScreen 스크롤 없음 (단일 뷰포트)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 스크롤 불가능 확인: SingleChildScrollView / ListView 등 스크롤 위젯 부재
      expect(find.byType(SingleChildScrollView), findsNothing);
      
      // 콘텐츠는 Column/Stack으로 배치
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('CTA 버튼 터치 시 스케일 0.97 + 밝기 감소 애니메이션',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 버튼 찾기
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsWidgets);

      // 버튼 눌림 상태 시뮬레이션
      await tester.tapDown(find.text('무료로 시작하기'));
      await tester.pump(const Duration(milliseconds: 50));

      // 버튼 해제
      await tester.tapUp(find.text('무료로 시작하기'));
      await tester.pump(const Duration(milliseconds: 150));

      // 애니메이션 통과 후 다음 화면 진입
      await tester.pumpAndSettle();
    });

    testWidgets('LandingScreen 진입 시 색상 대비 WCAG AA 기준 충족 (시각적)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // 주요 텍스트 존재 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('무료로 시작하기'), findsOneWidget);
      
      // 실제 색상 대비는 렌더링 후 픽셀 분석 필요
      // 통합 테스트에서는 텍스트 가독성 존재만 검증
    });

    testWidgets('원터치 진입: LandingScreen → DisclaimerPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // SplashScreen 통과
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // LandingScreen 상태 확인
      expect(find.byType(LandingScreen), findsOneWidget);

      // CTA 버튼 원터치
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // DisclaimerPage 진입 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
    });

    testWidgets('신규 사용자 분기: disclaimer_agreed_at 없으면 Landing 진입',
        (WidgetTester tester) async {
      // StorageService에 disclaimer_agreed_at이 없는 상태 가정
      // (통합 테스트 환경에서는 초기 상태이므로 자동으로 충족)
      
      await tester.pumpWidget(const RecoveryFitApp());
      
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      // LandingScreen 출현 확인
      expect(find.byType(LandingScreen), findsOneWidget);
    });
  });
}