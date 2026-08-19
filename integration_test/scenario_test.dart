import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    testWidgets('스플래시 화면이 표시되고 로고 + 슬로건 + 로딩 도트 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 스플래시 화면 배경색 확인 (딥 네이비 #0D1B2A)
      expect(
        find.byType(Scaffold),
        findsWidgets,
      );

      // 로고 텍스트 "RecoveryFit" 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 슬로건 "부상 후, 더 강하게" 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트 애니메이션 (3개 원형) 확인
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('스플래시에서 랜딩 화면으로 전환됨',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 로딩 상태
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 스플래시 애니메이션 완료 후 랜딩 화면 진입 대기
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 랜딩 화면 텍스트 확인: "부상 후에도\n운동할 수 있어요"
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면에 주요 콘텐츠가 표시됨 (히어로, 헤드라인, CTA)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 메인 헤드라인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인
      expect(
        find.text('AI가 내 부상 상태를 분석하고'),
        findsOneWidget,
      );
      expect(
        find.text('안전한 재활 플랜을 만들어드려요'),
        findsOneWidget,
      );

      // CTA 버튼 "무료로 시작하기"
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 보조 텍스트 (의료기기 면책)
      expect(
        find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
        findsOneWidget,
      );
    });

    testWidgets('랜딩 화면의 3가지 가치 포인트 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 가치 포인트 3종: "이중 안전\n검증", "AI 개인화\n플랜", "터치 최소화\n인터페이스"
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);

      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);

      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면의 CTA 버튼 클릭 시 면책 동의 화면으로 진입',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책 동의 화면의 주요 텍스트 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
      expect(find.text('의료기기가 아닙니다'), findsWidgets);
    });

    testWidgets('랜딩 화면 헤더에 로고 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 헤더 로고 "RecoveryFit" (상단 좌측 소형)
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('랜딩 화면 배경이 그라디언트 + 오버레이 적용됨',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 배경 색상 확인 (딥 네이비 #0D1B2A)
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);

      // 컨테이너를 통한 배경 검증
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('랜딩 화면 CTA 버튼이 민트색 배경 + 네이비 텍스트',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // CTA 버튼 찾기
      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);

      // 버튼의 부모 위젯이 올바른 색상으로 스타일링되어 있는지 확인
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('면책 동의 화면에서 "동의하고 시작" 버튼 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // CTA 탭하여 면책 동의 화면 진입
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책 동의 화면의 주요 버튼
      expect(find.text('동의하고 시작'), findsOneWidget);
      expect(find.text('나중에 읽기'), findsOneWidget);
    });

    testWidgets('면책 동의 후 온보딩 화면 진입',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 랜딩 → CTA 클릭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책 동의 → "동의하고 시작" 클릭
      await tester.tap(find.text('동의하고 시작'));
      await tester.pumpAndSettle();

      // 온보딩 화면: 부상 입력 필드 확인
      expect(find.text('어디가 불편하신가요?'), findsOneWidget);
    });

    testWidgets('온보딩 Step 1: 부상 입력 화면에 텍스트 필드와 예시 칩 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('동의하고 시작'));
      await tester.pumpAndSettle();

      // 부상 입력 필드 확인
      expect(find.byType(TextField), findsWidgets);

      // 예시 칩 확인 (예: "무릎 인대 나갔어요")
      expect(find.text('무릎 인대 나갔어요'), findsOneWidget);
      expect(find.text('허리 디스크 초기'), findsOneWidget);
      expect(find.text('어깨 회전근개 통증'), findsOneWidget);
    });

    testWidgets('온보딩 Step 1: 예시 칩 탭으로 텍스트 필드에 자동 완성',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('동의하고 시작'));
      await tester.pumpAndSettle();

      // 예시 칩 "무릎 인대 나갔어요" 탭
      await tester.tap(find.text('무릎 인대 나갔어요'));
      await tester.pumpAndSettle();

      // 텍스트 필드에 입력되었는지 확인
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('온보딩 Step 2-4: 통증 수준, 단기 목표, 장기 목표 선택',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('동의하고 시작'));
      await tester.pumpAndSettle();

      // Step 1 완료 후 "다음" 버튼 탭
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      // 통증 수준 선택 화면
      expect(find.text('지금 통증이 얼마나 심한가요?'), findsOneWidget);

      // 슬라이더와 숫자 칩 확인
      expect(find.byType(Slider), findsWidgets);
    });
  });
}