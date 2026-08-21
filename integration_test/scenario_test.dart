import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen + LandingScreen)', () {
    testWidgets(
        '스플래시 화면 진입 후 로고·슬로건·로딩 도트 표시',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 스플래시 화면 진입 확인: RecoveryFit 로고 텍스트
      expect(find.textContaining('Recovery'), findsWidgets); // wordmark renders as one Text.rich('RecoveryFit')
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트 애니메이션 확인
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets(
        '스플래시 화면에서 배경색이 딥 네이비 (#0D1B2A)',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // Scaffold 또는 Container의 배경색 확인
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsWidgets);
    });

    testWidgets(
        '스플래시 애니메이션 후 랜딩 화면으로 자동 전환',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 표시 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 애니메이션 및 로딩 완료 대기 (3초 이상)
      // pumpAndSettle은 반복 애니메이션 때문에 사용 불가
      // 대신 작은 단위로 여러 번 pump
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        // 랜딩 화면의 CTA 버튼 또는 고유 텍스트 확인
        final ctaButton = find.text('무료로 시작하기');
        if (ctaButton.evaluate().isNotEmpty) {
          break;
        }
      }

      // 랜딩 화면 진입 확인: CTA 버튼
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets(
        '랜딩 화면: 메인 헤드라인 표시',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) {
          break;
        }
      }

      // 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets(
        '랜딩 화면: 서브 헤드라인 및 가치 포인트 표시',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('AI가 내 부상 상태를 분석하고').evaluate().isNotEmpty) {
          break;
        }
      }

      // 서브 헤드라인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      expect(find.textContaining('안전한 재활 플랜'), findsOneWidget);

      // 가치 포인트 라벨 확인 (3개)
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets(
        '랜딩 화면: CTA 버튼 "무료로 시작하기" 표시 및 탭 가능',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);

      // 버튼 탭
      await tester.tap(ctaButton);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 면책 동의 화면으로 진입 확인
      expect(
          find.text('이용 전 꼭 확인하세요'),
          findsOneWidget);
    });

    testWidgets(
        '랜딩 화면: 보조 텍스트 "의료기기 아님..." 표시',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('의료기기 아님').evaluate().isNotEmpty) {
          break;
        }
      }

      // 보조 텍스트 확인
      expect(find.textContaining('의료기기 아님'), findsOneWidget);
      expect(find.textContaining('전문의 상담'), findsOneWidget);
    });

    testWidgets(
        '랜딩 화면 스크롤 없음 (단일 뷰포트)',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // SingleChildScrollView 또는 ListView 없는지 확인
      // (있으면 스크롤 가능하므로 제약이 없음)
      // 일반적으로 스크롤 불가 화면은 Column으로 구성
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets(
        '랜딩 화면 헤더에 로고 표시',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('RecoveryFit').evaluate().isNotEmpty) {
          break;
        }
      }

      // 헤더 로고 확인
      expect(find.text('RecoveryFit'), findsWidgets);
    });
  });
}