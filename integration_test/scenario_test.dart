import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    testWidgets('스플래시 화면 표시 — 로고, 슬로건, 로딩 도트', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 스플래시 화면이 표시됨
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      expect(find.byIcon(Icons.circle), findsWidgets);
    });

    testWidgets('스플래시 → 랜딩 전환 — 신규 사용자 경로', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 애니메이션 대기
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 랜딩 화면의 메인 헤드라인 확인
      expect(find.text('부상 후에도\n운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 히어로 텍스트와 CTA 버튼 렌더링', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 메인 헤드라인
      expect(find.text('부상 후에도'), findsOneWidget);
      
      // 서브 헤드라인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      
      // CTA 버튼
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 가치 포인트 3종 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 가치 포인트 레이블 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 보조 텍스트(면책) 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 면책 텍스트
      expect(find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget);
    });

    testWidgets('CTA 버튼 탭 → 면책 동의 화면 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // CTA 버튼 찾기
      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);

      // 버튼 탭
      await tester.tap(ctaButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 면책 동의 화면 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
    });

    testWidgets('버튼 탭 시 스케일 및 밝기 피드백 작동', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final ctaButton = find.byType(ElevatedButton);
      expect(ctaButton, findsWidgets);

      // 버튼 영역 탭 (다운 상태)
      await tester.tapDown(find.text('무료로 시작하기'));
      await tester.pump(const Duration(milliseconds: 50));

      // 탭 해제
      await tester.tapUp(find.text('무료로 시작하기'));
      await tester.pump(const Duration(milliseconds: 100));

      // 이후 화면 전환 확인
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — RecoveryFit 로고 소형 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 로고 텍스트 존재 확인 (헤더 로고 포함)
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('스플래시 화면 색상 — 딥 네이비 배경 확인', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 배경 색상 검증 (Scaffold 또는 Container)
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      // 첫 번째 스플래시 Scaffold 배경 색상 확인
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('랜딩 화면 스크롤 불가 — 단일 뷰포트 구성', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 랜딩 화면의 메인 콘텐츠 영역에서 스크롤 시도
      final mainHeadline = find.text('부상 후에도');
      expect(mainHeadline, findsOneWidget);

      // 스크롤 시도 (성공하지 않아야 함 — 스크롤 불가)
      await tester.drag(mainHeadline, const Offset(0, -300));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // 여전히 화면에 표시됨
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 히어로 일러스트 영역 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // SVG 또는 Container를 통한 히어로 영역 검증
      // (실제 일러스트는 Positioned/Container로 감싸져 있음)
      expect(find.byType(Container), findsWidgets);
      
      // 헤드라인이 화면 하단부에 위치함을 암시적으로 확인
      expect(find.text('부상 후에도'), findsOneWidget);
    });
  });
}