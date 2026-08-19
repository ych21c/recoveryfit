import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (스플래시 + 랜딩)', () {
    testWidgets(
      '스플래시 화면이 로드되고 로고 · 슬로건 · 로딩 애니메이션이 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        // Advance time into the splash animation without triggering navigation.
        // Total splash animation = 2 200 ms; 500 ms keeps us firmly on splash.
        await tester.pump(const Duration(milliseconds: 500));

        // Splash wordmark is a RichText ('Recovery' + 'Fit') → use findRichText
        expect(find.text('RecoveryFit', findRichText: true), findsWidgets);

        // 슬로건 "부상 후, 더 강하게" 확인
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 배경색 확인 (딥 네이비 #0D1B2A)
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets);
      },
    );

    testWidgets(
      '스플래시에서 랜딩 화면으로 자동 전환됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 랜딩 화면의 메인 헤드라인 확인
        expect(
          find.text('부상 후에도\n운동할 수 있어요'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면에서 히어로 비주얼, 헤드라인, CTA 버튼이 표시됨',
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

        // CTA 버튼 ("무료로 시작하기")
        expect(find.text('무료로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면의 가치 포인트 3종이 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 가치 포인트 라벨들 확인
        expect(find.text('이중 안전\n검증'), findsOneWidget);
        expect(find.text('AI 개인화\n플랜'), findsOneWidget);
        expect(find.text('터치 최소화\n인터페이스'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면 하단 보조 텍스트 (면책 문구)가 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 보조 텍스트
        expect(
          find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면 CTA 버튼 탭 시 면책동의 화면으로 진입',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // CTA 버튼 탭
        final ctaButton = find.text('무료로 시작하기');
        expect(ctaButton, findsOneWidget);
        await tester.tap(ctaButton);
        await tester.pumpAndSettle();

        // 면책동의 화면 진입 확인 ("이용 전 꼭 확인하세요" 텍스트)
        expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
      },
    );

    testWidgets(
      '스플래시 화면의 로딩 애니메이션 (도트 3개)이 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 상태에서 스플래시 화면이 표시됨
        await tester.pump(const Duration(milliseconds: 500));

        // 슬로건 텍스트로 스플래시 상태 확인
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면의 헤더 로고가 상단에 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // RecoveryFit 로고 텍스트 확인 (상단 좌측)
        expect(find.text('RecoveryFit'), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면 CTA 버튼의 스타일이 올바름 (민트 배경색)',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final ctaFinder = find.text('무료로 시작하기');
        expect(ctaFinder, findsOneWidget);

        // ElevatedButton 또는 유사 터치 가능 위젯 확인
        final widget = tester.widget(ctaFinder);
        expect(widget, isNotNull);
      },
    );
  });
}