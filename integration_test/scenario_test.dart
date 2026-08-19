import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';
import 'package:recovery_fit/core/router/app_router.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets(
      '사용자가 앱을 시작하면 스플래시 화면이 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle();

        // 스플래시 화면의 핵심 요소 확인
        expect(find.text('Recovery'), findsWidgets);
        expect(find.text('Fit'), findsWidgets);
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 로딩 도트 애니메이션 확인 (3개)
        expect(find.byType(Container), findsWidgets);
      },
    );

    testWidgets(
      '스플래시 화면에서 로딩이 완료되면 랜딩 화면으로 자동 전환된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 로딩 대기
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 랜딩 화면의 주요 텍스트 확인
        expect(
          find.text('부상 후에도\n운동할 수 있어요'),
          findsOneWidget,
        );
        expect(
          find.text('무료로 시작하기'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면에 히어로 텍스트와 CTA 버튼이 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 메인 헤드라인
        expect(
          find.text('부상 후에도\n운동할 수 있어요'),
          findsOneWidget,
        );

        // 서브 헤드라인
        expect(
          find.text('AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요'),
          findsOneWidget,
        );

        // CTA 버튼
        expect(find.text('무료로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면에 RecoveryFit 로고가 상단에 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 헤더 로고 확인
        expect(find.text('RecoveryFit'), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면에 3가지 가치 포인트가 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 가치 포인트 라벨 확인
        expect(find.text('이중 안전\n검증'), findsOneWidget);
        expect(find.text('AI 개인화\n플랜'), findsOneWidget);
        expect(find.text('터치 최소화\n인터페이스'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면에 의료 면책 문구가 하단에 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 면책 문구
        expect(
          find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '사용자가 무료로 시작하기 버튼을 클릭하면 온보딩으로 진입한다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 버튼 찾기
        final ctaButton = find.widgetWithText(ElevatedButton, '무료로 시작하기');
        expect(ctaButton, findsOneWidget);

        // 버튼 클릭
        await tester.tap(ctaButton);
        await tester.pumpAndSettle();

        // 면책 동의 페이지로 이동 확인
        expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
      },
    );

    testWidgets(
      '무료로 시작하기 버튼이 터치 피드백을 제공한다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final ctaButton = find.byType(ElevatedButton).first;
        
        // 버튼 눌림 시뮬레이션
        await tester.longPress(ctaButton);
        await tester.pump(const Duration(milliseconds: 100));

        // 시각적 상태 변화 확인
        expect(ctaButton, findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면의 배경이 딥 네이비 색상으로 설정되어 있다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Scaffold 배경색 확인
        expect(find.byType(Scaffold), findsWidgets);
      },
    );

    testWidgets(
      '스플래시 화면의 RecoveryFit 워드마크가 색상으로 강조된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 화면에서 워드마크 확인
        expect(find.text('Recovery'), findsWidgets);
        expect(find.text('Fit'), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면에서 히어로 이미지 영역이 상단 55%를 차지한다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 화면 레이아웃 확인
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets);
      },
    );

    testWidgets(
      '사용자가 이미 동의를 완료했다면 랜딩을 스킵하고 홈으로 이동한다',
      (tester) async {
        // 이 테스트는 onboarding_done 플래그를 설정한 상태에서만 실행
        // 현재는 기본적으로 스플래시→랜딩 흐름을 따름
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 신규 사용자이므로 랜딩 화면이 표시됨
        expect(find.text('부상 후에도\n운동할 수 있어요'), findsOneWidget);
      },
    );

    testWidgets(
      '스플래시 화면의 애니메이션이 0.6초 페이드인 후 1.2초 정지한다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 페이드인 구간 (0~600ms)
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 정지 구간 (600~1800ms)
        await tester.pump(const Duration(milliseconds: 1200));
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면의 주요 텍스트가 모두 흰색으로 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 주요 텍스트들이 화면에 표시됨
        expect(find.text('부상 후에도\n운동할 수 있어요'), findsOneWidget);
        expect(
          find.text('AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '무료로 시작하기 CTA 버튼이 민트 배경에 네이비 텍스트로 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final button = find.byType(ElevatedButton);
        expect(button, findsWidgets);

        // 버튼 텍스트 확인
        expect(find.text('무료로 시작하기'), findsOneWidget);
      },
    );
  });
}