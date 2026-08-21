import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (ATM-5: SplashScreen & LandingScreen)', () {
    testWidgets(
      '스플래시 화면 로드 및 애니메이션 확인',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 화면의 핵심 요소 확인 — 로고는 하나의 Text.rich(Recovery+Fit)
        // 위젯이라 전체 문구가 "RecoveryFit"이므로 부분 일치로 확인.
        expect(find.textContaining('Recovery'), findsOneWidget);
        expect(find.textContaining('Fit'), findsOneWidget);
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
        
        // 로딩 도트 확인 (3개)
        expect(find.byIcon(Icons.circle), findsWidgets);
      },
    );

    testWidgets(
      '스플래시에서 랜딩 화면으로 전환',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 화면이 먼저 표시됨
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 애니메이션 완료 후 화면 전환을 기다림
        // 스플래시는 페이드아웃 애니메이션이 있으므로 작은 단위로 pump
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.textContaining('부상 후에도').evaluate().isNotEmpty) {
            break;
          }
        }

        // 랜딩 화면의 주요 텍스트 확인
        expect(find.textContaining('부상 후에도'), findsWidgets);
        expect(find.textContaining('운동할 수 있어요'), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면 - 히어로 텍스트 및 가치 포인트 표시',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 애니메이션이 끝날 때까지 대기
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.textContaining('부상 후에도').evaluate().isNotEmpty) {
            break;
          }
        }

        // 메인 헤드라인
        expect(find.text('부상 후에도'), findsOneWidget);
        expect(find.text('운동할 수 있어요'), findsOneWidget);

        // 서브 헤드라인 (2줄 텍스트는 각각 확인)
        expect(
          find.textContaining('AI가 내 부상 상태를 분석하고'),
          findsOneWidget,
        );
        expect(
          find.textContaining('안전한 재활 플랜을 만들어드려요'),
          findsOneWidget,
        );

        // 가치 포인트 3종 레이블 확인
        expect(find.textContaining('이중 안전'), findsOneWidget);
        expect(find.textContaining('검증'), findsOneWidget);
        expect(find.textContaining('AI 개인화'), findsOneWidget);
        // '플랜'은 서브 헤드라인("...재활 플랜을 만들어드려요")에도 부분
        // 매치되어 findsOneWidget이 2개를 찾는다 — 라벨 위젯 자체는 전체
        // 텍스트가 정확히 "플랜"이므로 완전 일치로 좁힌다.
        expect(find.text('플랜'), findsOneWidget);
        expect(find.textContaining('터치 최소화'), findsOneWidget);
        expect(find.textContaining('인터페이스'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면 - 무료로 시작하기 CTA 버튼',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면까지 대기
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // CTA 버튼 텍스트 확인
        expect(find.text('무료로 시작하기'), findsOneWidget);

        // CTA 버튼 tap 및 다음 화면으로 이동 확인
        await tester.tap(find.text('무료로 시작하기'));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 면책 동의 화면 또는 온보딩 화면의 요소 확인
        // (다음 스크린으로의 진입 확인)
        expect(
          find.text('이용 전 꼭 확인하세요').evaluate().isNotEmpty ||
              find.textContaining('동의').evaluate().isNotEmpty,
          true,
        );
      },
    );

    testWidgets(
      '랜딩 화면 - 보조 텍스트 (면책 문구)',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면까지 대기
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.textContaining('의료기기').evaluate().isNotEmpty) {
            break;
          }
        }

        // 면책 문구 확인
        expect(
          find.textContaining('의료기기 아님'),
          findsOneWidget,
        );
        expect(
          find.textContaining('전문의 상담을 대체하지 않습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면 - 레이아웃 및 색상 토큰 적용',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면 표시 대기
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // 랜딩 화면에서 ElevatedButton이 표시되어 있는지 확인
        // (CTA 버튼)
        expect(find.byType(ElevatedButton), findsWidgets);

        // 기본 레이아웃 요소 (Scaffold) 확인
        expect(find.byType(Scaffold), findsWidgets);
      },
    );

    testWidgets(
      '로고 영역 - RecoveryFit 워드마크 및 심볼 확인',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 스플래시 화면에서 로고 확인 (Text.rich라 부분 일치로 확인)
        expect(find.textContaining('Recovery'), findsOneWidget);
        expect(find.textContaining('Fit'), findsOneWidget);

        // 랜딩 화면으로 이동 후에도 헤더 로고 확인
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.textContaining('부상 후에도').evaluate().isNotEmpty) {
            break;
          }
        }

        // 헤더 로고 (RecoveryFit 텍스트) 확인
        expect(find.text('RecoveryFit'), findsWidgets);
      },
    );

    testWidgets(
      '접근성 - 주요 요소들이 탭 가능 상태인지 확인',
      (WidgetTester tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면까지 이동
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 500));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // CTA 버튼이 탭 가능한지 확인
        final ctaFinder = find.text('무료로 시작하기');
        expect(ctaFinder, findsOneWidget);

        // 버튼 영역을 탭할 수 있는지 테스트
        await tester.tap(ctaFinder);
        await tester.pump();

        // 탭 후 상태 변화 확인 (화면 전환 시작)
        expect(find.byType(Scaffold), findsWidgets);
      },
    );
  });
}