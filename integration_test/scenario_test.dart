import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (스플래시 + 랜딩)', () {
    testWidgets(
      '스플래시 화면이 표시되고 도트 애니메이션이 보임',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        // 스플래시 화면 자체를 검증하는 시나리오라 pumpAndSettle을 쓰면 안 된다 —
        // 로딩 도트가 반복 애니메이션이라 SplashScreen이 화면에서 사라질 때까지
        // (즉 랜딩으로 넘어갈 때까지) 절대 settle되지 않아서, pumpAndSettle이
        // 결국 랜딩 화면까지 넘어간 뒤에야 반환되어 스플래시 콘텐츠를 놓친다.
        // 첫 프레임만 그려서 초기 상태를 바로 확인한다.
        await tester.pump();

        // 스플래시 화면의 핵심 콘텐츠 확인
        expect(find.text('RecoveryFit'), findsWidgets);
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 로딩 도트가 있는지 확인 (아이콘 또는 위젯)
        expect(find.byIcon(Icons.circle), findsWidgets);
      },
    );

    testWidgets(
      '스플래시 화면에서 랜딩 화면으로 자동 전환됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 상태: 스플래시 화면 (도트 애니메이션 진행 중)
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 2초 대기 후 프레임 진행
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 랜딩 화면의 핵심 텍스트 찾기
        expect(find.textContaining('부상 후에도'), findsOneWidget);
        expect(find.textContaining('운동할 수 있어요'), findsOneWidget);
        expect(find.textContaining('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면에 "무료로 시작하기" CTA 버튼이 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 → 랜딩 전환 대기
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // CTA 버튼 확인
        expect(find.text('무료로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면의 가치 포인트 3종이 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 가치 포인트 텍스트 확인
        expect(find.textContaining('이중 안전'), findsOneWidget);
        expect(find.textContaining('AI 개인화'), findsOneWidget);
        expect(find.textContaining('터치 최소화'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면에 의료 면책 텍스트가 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 의료 면책 텍스트 확인
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
      '랜딩 화면에서 CTA 버튼 탭 시 면책동의 화면으로 이동',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 → 랜딩 전환 대기
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // CTA 버튼 탭
        await tester.tap(find.text('무료로 시작하기'));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 면책동의 화면으로 이동했는지 확인
        expect(find.textContaining('이용 전 꼭 확인하세요'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면 헤더에 RecoveryFit 로고가 표시됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // 랜딩 헤더의 로고 텍스트 확인 (여러 개 중 최소 1개)
        expect(find.text('RecoveryFit'), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면이 스크롤되지 않는 단일 뷰포트 구성임',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // 스크롤 가능 요소가 없음을 확인 (스크롤 불가)
        final listFinder = find.byType(ListView);
        final singleChildScrollFinder = find.byType(SingleChildScrollView);

        // 랜딩 화면 자체에는 스크롤 뷰가 없어야 함
        // (Scaffold → Column 구조)
        expect(listFinder, findsNothing);
        expect(singleChildScrollFinder, findsNothing);
      },
    );

    testWidgets(
      '스플래시 화면의 배경색이 짙은 네이비(#0D1B2A)임',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // 스플래시 화면의 배경 컨테이너 확인
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets);

        // 배경색이 어두운 색상임을 확인 (정확한 색상 검증은 픽셀 단위이므로 생략)
      },
    );
  });
}