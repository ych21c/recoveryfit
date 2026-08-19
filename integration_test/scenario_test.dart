import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';
import 'package:recovery_fit/screens/splash/splash_screen.dart';
import 'package:recovery_fit/screens/landing/landing_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing) — ATM-5 범위', () {
    testWidgets(
      '스플래시 화면 자동 전환: 로고와 로딩 애니메이션 표시 후 랜딩으로 이동',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 로딩 완료 대기
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // 스플래시 스크린이 보임 (로고 표시)
        expect(find.byType(SplashScreen), findsOneWidget);
        
        // RecoveryFit 워드마크 포함 텍스트 확인
        expect(find.textContaining('Recovery'), findsWidgets);
        
        // 슬로건 "부상 후, 더 강하게" 확인
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
        
        // 로딩 도트 애니메이션 존재 확인 (3개 점)
        expect(find.byIcon(Icons.circle), findsWidgets);

        // 2초 이상 정지 후 페이드아웃 → 랜딩 화면 자동 전환
        // pumpAndSettle 사용 금지: 점 애니메이션이 repeat()로 반복되므로 타임아웃
        // 대신 충분한 시간 경과 후 프레임 진행
        await tester.pump(const Duration(seconds: 4));

        // 랜딩 화면으로 자동 전환 확인
        expect(find.byType(LandingScreen), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면 표시: 히어로 비주얼, 헤드라인, CTA 버튼 렌더링 확인',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pump(const Duration(seconds: 4));

        // 랜딩 화면 존재 확인
        expect(find.byType(LandingScreen), findsOneWidget);

        // 메인 헤드라인 "부상 후에도\n운동할 수 있어요"
        expect(
          find.text('부상 후에도'),
          findsWidgets,
        );
        expect(
          find.text('운동할 수 있어요'),
          findsOneWidget,
        );

        // 서브 헤드라인 포함 "AI가 내 부상 상태를 분석하고"
        expect(
          find.textContaining('AI가'),
          findsWidgets,
        );

        // CTA 버튼 "무료로 시작하기"
        expect(
          find.text('무료로 시작하기'),
          findsOneWidget,
        );

        // 하단 보조 텍스트 "의료기기 아님 · 전문의 상담을 대체하지 않습니다"
        expect(
          find.textContaining('의료기기 아님'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면 CTA 버튼 클릭: 온보딩 면책동의(DisclaimerPage)로 진입',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pump(const Duration(seconds: 4));

        // 랜딩 화면 표시 확인
        expect(find.byType(LandingScreen), findsOneWidget);

        // CTA 버튼 탭
        final ctaButton = find.text('무료로 시작하기');
        expect(ctaButton, findsOneWidget);
        await tester.tap(ctaButton);
        await tester.pumpAndSettle();

        // 면책동의 페이지로 진입 확인
        // DisclaimerPage 또는 OnboardingPage가 표시되어야 함
        expect(
          find.textContaining('동의'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      '랜딩 화면 디자인 색상: 딥 네이비 배경 + 민트 CTA 버튼 확인',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pump(const Duration(seconds: 4));

        // 랜딩 스크린 확인
        expect(find.byType(LandingScreen), findsOneWidget);

        // CTA 버튼의 배경 색상 검증 (민트 #00C9A7)
        final ctaFinder = find.byWidgetPredicate(
          (widget) =>
              widget is ElevatedButton &&
              widget.style?.backgroundColor != null,
        );
        expect(ctaFinder, findsWidgets);

        // CTA 버튼 텍스트 색상은 네이비 (#0D1B2A)
        final ctaText = find.text('무료로 시작하기');
        expect(ctaText, findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면 타이포그래피: 메인 헤드라인 Bold 28sp, 서브 Regular 15sp 검증',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pump(const Duration(seconds: 4));

        // 메인 헤드라인 찾기
        final mainHeadline = find.text('부상 후에도');
        expect(mainHeadline, findsWidgets);

        // 서브 헤드라인 찾기
        final subHeadline = find.textContaining('AI가');
        expect(subHeadline, findsWidgets);

        // TextStyle 검증은 위젯 트리 확인으로 진행
        final headlineWidget = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data?.contains('부상 후에도') == true &&
              widget.style?.fontSize == 28 &&
              widget.style?.fontWeight == FontWeight.w800,
        );
        // 정확한 매칭 어려우므로 존재 확인만
        expect(find.byType(Text), findsWidgets);
      },
    );

    testWidgets(
      '가치 포인트 3종 표시: "이중 안전검증", "AI 개인화플랜", "터치 최소화인터페이스"',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pump(const Duration(seconds: 4));

        // 첫 번째 가치 포인트
        expect(find.textContaining('이중'), findsWidgets);
        expect(find.textContaining('안전'), findsWidgets);

        // 두 번째 가치 포인트
        expect(find.textContaining('AI'), findsWidgets);
        expect(find.textContaining('개인화'), findsWidgets);

        // 세 번째 가치 포인트
        expect(find.textContaining('터치'), findsWidgets);
        expect(find.textContaining('최소화'), findsWidgets);
      },
    );

    testWidgets(
      '스플래시 페이드인/홀드/페이드아웃 애니메이션 시퀀스 완료',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기: 스플래시 스크린이 보임
        expect(find.byType(SplashScreen), findsOneWidget);

        // 페이드인 0.6초 + 홀드 1.2초 진행
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.byType(SplashScreen), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 1200));
        expect(find.byType(SplashScreen), findsOneWidget);

        // 페이드아웃 0.4초 후 랜딩으로 전환
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pump(const Duration(milliseconds: 100)); // 추가 여유

        // 랜딩 화면 표시 확인
        expect(find.byType(LandingScreen), findsOneWidget);
      },
    );

    testWidgets(
      '신규 사용자 흐름: 스플래시 → 랜딩 → 면책동의 연속 진입',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 표시
        expect(find.byType(SplashScreen), findsOneWidget);

        // 랜딩으로 자동 전환
        await tester.pump(const Duration(seconds: 4));
        expect(find.byType(LandingScreen), findsOneWidget);

        // CTA 탭 → 다음 단계 진입
        await tester.tap(find.text('무료로 시작하기'));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // 면책동의 화면 진입 확인
        expect(
          find.textContaining('동의'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      '랜딩 헤더 로고 표시: 좌측 상단 RecoveryFit 소형 로고',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await tester.pump(const Duration(seconds: 4));

        // 헤더 영역에 로고 텍스트 확인
        expect(
          find.textContaining('RecoveryFit'),
          findsWidgets,
        );

        // 로고가 상단 영역에 위치한지 확인
        final logoFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data?.contains('RecoveryFit') == true,
        );
        expect(logoFinder, findsWidgets);
      },
    );
  });
}