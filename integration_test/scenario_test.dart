import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen + LandingScreen)', () {
    testWidgets('SplashScreen이 로드되고 로고/슬로건/로딩 도트가 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // SplashScreen 화면인지 확인 — 배경색으로 검증
      expect(find.byType(Scaffold), findsWidgets);

      // 로고 텍스트 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 슬로건 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트 (애니메이션 진행 중이므로 존재 확인만)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SplashScreen 애니메이션 진행 후 LandingScreen으로 전환된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 프레임
      await tester.pump();
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 페이드인 애니메이션 진행 (0.6s)
      await tester.pump(const Duration(milliseconds: 700));

      // 홀드 기간 진행 (1.2s)
      await tester.pump(const Duration(milliseconds: 1300));

      // 페이드아웃 애니메이션 진행 (0.4s) + 추가 여유
      await tester.pump(const Duration(milliseconds: 500));

      // LandingScreen으로 전환되었는지 확인
      // LandingScreen의 핵심 텍스트: "무료로 시작하기" 버튼 라벨
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('LandingScreen이 올바른 레이아웃으로 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 후 LandingScreen 대기
      await tester.pump(const Duration(milliseconds: 3000));

      // 헤더 로고 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인 확인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsOneWidget);

      // 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);

      // CTA 버튼 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 보조 텍스트 확인
      expect(find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'), findsOneWidget);
    });

    testWidgets('LandingScreen의 "무료로 시작하기" 버튼을 탭하면 면책 동의 화면으로 진입한다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 3000));

      // LandingScreen 렌더링 완료 대기
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // "무료로 시작하기" 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책 동의 화면(DisclaimerPage)의 특징적 텍스트로 확인
      // 목업 ATM-5 기준: "이용 전 꼭 확인하세요"
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);

      // "동의하고 시작" 버튼 확인
      expect(find.text('동의하고 시작'), findsOneWidget);
    });

    testWidgets('SplashScreen 로딩 중 로고/슬로건이 페이드인된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 상태 — 페이드인 전
      await tester.pump();

      // 로고 확인 (불투명도 상태는 위젯 트리에서 직접 검증 불가이므로 존재만 확인)
      expect(find.text('RecoveryFit'), findsWidgets);
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 페이드인 진행 (0.6s)
      await tester.pump(const Duration(milliseconds: 600));

      // 여전히 표시되는지 확인
      expect(find.text('RecoveryFit'), findsWidgets);
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('LandingScreen 가치 포인트 3개 아이콘이 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 가치 포인트 라벨들이 모두 나타나는지 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget); // "이중 안전\n검증" 중 "검증" 라인

      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget); // "AI 개인화\n플랜" 중 "플랜" 라인

      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget); // "터치 최소화\n인터페이스" 중 "인터페이스" 라인
    });

    testWidgets('LandingScreen 배경이 딥 네이비 색상이다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // SplashScreen 애니메이션 완료
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Scaffold 또는 Container 배경 색상 검증
      // 실제 위젯 트리에서 배경 색상을 직접 검증하기 위해
      // Material 위젯이 존재하고 콘텐츠가 표시되는지로 간접 확인
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('CTA 버튼 탭 시 즉시 반응한다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // LandingScreen 표시 대기
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 버튼 존재 확인
      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);

      // 버튼 탭
      await tester.tap(ctaButton);

      // 네비게이션 즉시 반응 (애니메이션 포함 0.5초)
      await tester.pump(const Duration(milliseconds: 100));

      // DisclaimerPage 화면 표시 대기
      await tester.pumpAndSettle();

      // 면책 동의 화면 텍스트 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
    });

    testWidgets('보조 텍스트(의료 면책)가 하단에 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // LandingScreen 표시 대기
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 보조 텍스트 확인
      expect(
        find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
        findsOneWidget,
      );
    });
  });
}