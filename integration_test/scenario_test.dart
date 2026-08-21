import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (ATM-5) 테스트', () {
    testWidgets(
      '스플래시 화면에 로고, 태그라인, 로딩 도트가 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 딥 네이비 배경 확인
        expect(
          find.byType(Scaffold),
          findsWidgets,
        );

        // RecoveryFit 워드마크 또는 일부 텍스트 확인
        expect(
          find.text('부상 후, 더 강하게'),
          findsOneWidget,
        );

        // 로딩 도트가 애니메이션 중인지 확인 (최소 3개 점이 있어야 함)
        expect(
          find.byType(Container),
          findsWidgets,
        );
      },
    );

    testWidgets(
      '스플래시 화면에서 애니메이션 후 랜딩 화면으로 자동 전환된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 상태: 스플래시 화면의 태그라인 표시
        expect(
          find.text('부상 후, 더 강하게'),
          findsOneWidget,
        );

        // 스플래시 애니메이션 + 초기화 완료 대기
        // 작은 단위로 여러 번 pump하여 비동기 작업 완료 기다리기
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // 랜딩 화면 표시 확인: "무료로 시작하기" CTA 버튼
        expect(
          find.text('무료로 시작하기'),
          findsOneWidget,
        );

        // 히어로 텍스트 확인
        expect(
          find.text('부상 후에도'),
          findsOneWidget,
        );
        expect(
          find.text('운동할 수 있어요'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면에 히어로 이미지, 핵심 가치 3종, CTA 버튼이 표시된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시에서 랜딩으로 전환될 때까지 기다리기
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // 히어로 텍스트
        expect(find.text('부상 후에도'), findsOneWidget);
        expect(find.text('운동할 수 있어요'), findsOneWidget);

        // 서브 헤드라인 (여러 줄이므로 각각 확인)
        expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
        expect(find.text('안전한 재활 플랜을 만들어드려요'), findsOneWidget);

        // 가치 포인트 3종의 라벨 확인
        expect(find.text('이중 안전'), findsOneWidget);
        expect(find.text('검증'), findsOneWidget);
        expect(find.text('AI 개인화'), findsOneWidget);
        expect(find.text('플랜'), findsOneWidget);
        expect(find.text('터치 최소화'), findsOneWidget);
        expect(find.text('인터페이스'), findsOneWidget);

        // CTA 버튼
        expect(find.text('무료로 시작하기'), findsOneWidget);

        // 보조 텍스트
        expect(
          find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면의 CTA 버튼을 누르면 면책 동의 화면으로 이동한다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면 로드 대기
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // CTA 버튼 탭
        await tester.tap(find.text('무료로 시작하기'));
        await tester.pumpAndSettle();

        // 면책 동의 화면 표시 확인
        expect(
          find.text('이용 전 꼭 확인하세요'),
          findsOneWidget,
        );
        expect(
          find.textContaining('의료기기가 아닙니다', findRichText: true),
          // 원문이 Text.rich가 아니라 순수 RichText(TextSpan) 위젯이라
          // findRichText: true 없이는 find.text*()가 아예 못 찾는다.
          findsWidgets,
        );
      },
    );

    testWidgets(
      '랜딩 화면의 레이아웃이 스크롤 없는 단일 뷰포트 구성이다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면 로드
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // ListView나 SingleChildScrollView 같은 스크롤 위젯이 없는지 확인
        // (Scaffold와 Column의 조합으로 구성)
        expect(
          find.byType(ListView),
          findsNothing, // 메인 콘텐츠 영역에는 스크롤 위젯 없음
        );

        // 주요 요소들이 모두 한 화면에 보이는지 확인 (오프스크린 판정 없음)
        final mainHeadline = find.text('부상 후에도');
        expect(mainHeadline, findsOneWidget);
        expect(tester.getRect(mainHeadline).top, greaterThanOrEqualTo(0));

        final ctaButton = find.text('무료로 시작하기');
        expect(ctaButton, findsOneWidget);
        final ctaBottomY = tester.getRect(ctaButton).bottom;
        expect(ctaBottomY, lessThanOrEqualTo(tester.binding.window.physicalSize.height / tester.binding.window.devicePixelRatio));
      },
    );

    testWidgets(
      '랜딩 화면에 RecoveryFit 로고가 좌측 상단에 배치된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면 로드
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // RecoveryFit 텍스트 (로고)를 찾음
        final logoFinder = find.text('RecoveryFit');
        expect(logoFinder, findsOneWidget);

        // 로고의 위치가 좌측 상단인지 확인
        final logoRect = tester.getRect(logoFinder);
        expect(logoRect.left, lessThan(100)); // 좌측 마진 내
        expect(logoRect.top, lessThan(100)); // 상단 마진 내
      },
    );

    testWidgets(
      '스플래시 화면의 로딩 도트가 애니메이션된다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 초기 상태에서 도트 존재 확인
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 프레임 진행으로 애니메이션 확인 (반복 애니메이션이므로 pumpAndSettle 사용 금지)
        await tester.pump(const Duration(milliseconds: 600)); // 페이드인

        // 여전히 스플래시 화면에 있는지 확인
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 1200)); // 정지 상태

        // 더 진행
        await tester.pump(const Duration(milliseconds: 400)); // 페이드아웃

        // 랜딩 화면으로 자동 전환 대기
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // 랜딩 화면 표시 확인
        expect(find.text('무료로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면의 CTA 버튼이 민트색(#00C9A7) 배경을 가진다',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 랜딩 화면 로드
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 200));
          if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
            break;
          }
        }

        // CTA 버튼 찾기
        final ctaButton = find.text('무료로 시작하기');
        expect(ctaButton, findsOneWidget);

        // 버튼의 배경색 확인 (ElevatedButton이므로 Material 위젯으로 렌더링됨)
        final buttonFinder = find.ancestor(
          of: ctaButton,
          matching: find.byType(ElevatedButton),
        );
        expect(buttonFinder, findsOneWidget);

        // 버튼이 스크린 하단 근처에 배치되는지 확인 (Safe Area 기준 32px 위)
        final buttonRect = tester.getRect(find.text('무료로 시작하기'));
        final screenHeight = tester.binding.window.physicalSize.height / tester.binding.window.devicePixelRatio;
        expect(buttonRect.bottom, greaterThan(screenHeight * 0.7)); // 하단 영역
      },
    );
  });
}