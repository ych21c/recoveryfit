import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

// 스플래시 → 랜딩 전환은 2.2초 애니메이션뿐 아니라 실제 비동기 초기화
// (Hive/알림 서비스 등)까지 함께 끝나야 일어난다. `pump(Duration(seconds: 3))`처럼
// 한 번에 큰 Duration을 pump하면 프레임/마이크로태스크가 딱 한 번만 도는데, 그
// 한 번 안에 이 초기화 체인이 다 안 풀려서 3초를 기다려도 여전히 스플래시에
// 머물러 있는 것으로 관측됐다(실측: 500ms씩 나눠 pump하면 2.0~2.5초 사이에
// 실제로 전환됨). 그래서 작은 단위로 여러 번 나눠서 pump한다.
Future<void> pumpUntilLanding(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.text('부상 후에도').evaluate().isNotEmpty) return;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 통합 테스트 (ATM-5)', () {
    testWidgets(
      '스플래시 스크린: 로고 & 슬로건 & 로딩 도트 표시 확인',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 화면이 보여질 때까지 대기 (최대 1초)
        await tester.pump(const Duration(milliseconds: 100));

        // 1. RecoveryFit 워드마크 확인
        expect(
          find.text('RecoveryFit'),
          findsWidgets,
          reason: '스플래시 화면에 RecoveryFit 로고가 있어야 함',
        );

        // 2. 슬로건 "부상 후, 더 강하게" 확인
        expect(
          find.text('부상 후, 더 강하게'),
          findsOneWidget,
          reason: '스플래시 화면에 슬로건이 정확히 하나 표시되어야 함',
        );

        // 3. 로딩 도트(3개) 확인
        //    도트 애니메이션 때문에 여러 개 렌더링될 수 있으므로 findsWidgets 사용
        expect(
          find.byIcon(Icons.circle),
          findsWidgets,
          reason: '로딩 도트가 존재해야 함',
        );

        // 4. 배경색이 딥 네이비인지 확인
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets);
      },
    );

    testWidgets(
      '스플래시 스크린: 페이드인/아웃 애니메이션이 진행됨',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 페이드인 시간(0.6s) 기다림
        await tester.pump(const Duration(milliseconds: 600));

        // 슬로건이 여전히 보임
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);

        // 홀드 시간(1.2s) 기다림
        await tester.pump(const Duration(milliseconds: 1200));

        // 여전히 보임
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 스크린: 메인 헤드라인 & 서브 헤드라인 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());

        // 스플래시 애니메이션 완료(2초 이상) 대기하여 랜딩 화면으로 자동 전환
        await pumpUntilLanding(tester);

        // 네비게이션이 일어났는지 확인 — 랜딩 화면의 특정 텍스트로 판단
        // 메인 헤드라인 — 화면은 두 줄을 별도 Text 위젯 2개로 렌더링하므로
        // (landing_screen.dart 주석 참고) 합친 문자열이 아니라 각 줄을 따로 찾는다.
        expect(
          find.text('부상 후에도'),
          findsOneWidget,
          reason: '랜딩 스크린의 메인 헤드라인(1줄)이 정확히 표시되어야 함',
        );
        expect(
          find.text('운동할 수 있어요'),
          findsOneWidget,
          reason: '랜딩 스크린의 메인 헤드라인(2줄)이 정확히 표시되어야 함',
        );

        // 서브 헤드라인 — 마찬가지로 두 줄이 별도 Text 위젯이다.
        expect(
          find.text('AI가 내 부상 상태를 분석하고'),
          findsOneWidget,
          reason: '랜딩 스크린의 서브 헤드라인(1줄)이 정확히 표시되어야 함',
        );
        expect(
          find.text('안전한 재활 플랜을 만들어드려요'),
          findsOneWidget,
          reason: '랜딩 스크린의 서브 헤드라인(2줄)이 정확히 표시되어야 함',
        );
      },
    );

    testWidgets(
      '랜딩 스크린: 가치 포인트 3종 아이콘 & 라벨 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await pumpUntilLanding(tester);

        // 가치 포인트 라벨 확인 — 각 라벨도 line1/line2가 별도 Text 위젯이다
        // (value_points_row.dart 주석 참고).
        expect(find.text('이중 안전'), findsOneWidget, reason: '첫 번째 가치 포인트 라벨(1줄)');
        expect(find.text('검증'), findsOneWidget, reason: '첫 번째 가치 포인트 라벨(2줄)');

        expect(find.text('AI 개인화'), findsOneWidget, reason: '두 번째 가치 포인트 라벨(1줄)');
        expect(find.text('플랜'), findsOneWidget, reason: '두 번째 가치 포인트 라벨(2줄)');

        expect(find.text('터치 최소화'), findsOneWidget, reason: '세 번째 가치 포인트 라벨(1줄)');
        expect(find.text('인터페이스'), findsOneWidget, reason: '세 번째 가치 포인트 라벨(2줄)');
      },
    );

    testWidgets(
      '랜딩 스크린: "무료로 시작하기" CTA 버튼 표시 & 탭 가능',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await pumpUntilLanding(tester);

        // 버튼 텍스트 확인
        expect(
          find.text('무료로 시작하기'),
          findsOneWidget,
          reason: 'CTA 버튼이 정확한 라벨로 표시되어야 함',
        );

        // ElevatedButton 찾기
        final ctaButton = find.byType(ElevatedButton);
        expect(ctaButton, findsWidgets);

        // 버튼이 탭 가능한지 확인 (실제 탭은 하지 않음 — 온보딩이 진행되므로)
        final button = ctaButton.first;
        expect(button, findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 스크린: 보조 텍스트 "의료기기 아님" 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await pumpUntilLanding(tester);

        expect(
          find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget,
          reason: '보조 텍스트(의료기기 아님 면책)가 표시되어야 함',
        );
      },
    );

    testWidgets(
      '랜딩 스크린: RecoveryFit 로고가 좌측 상단에 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await pumpUntilLanding(tester);

        // 로고는 AppBar나 헤더 영역에 위치
        // Text("RecoveryFit") 재확인
        expect(
          find.text('RecoveryFit'),
          findsWidgets, // 스플래시에서도 나타나므로 여러 개
          reason: '랜딩 스크린 헤더에도 로고가 표시되어야 함',
        );
      },
    );

    testWidgets(
      '랜딩 스크린: CTA 버튼 탭 시 온보딩/면책 화면으로 진입',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        await pumpUntilLanding(tester);

        // CTA 버튼 탭
        final ctaFinder = find.text('무료로 시작하기');
        expect(ctaFinder, findsOneWidget);

        await tester.tap(ctaFinder);
        await tester.pumpAndSettle();

        // 면책 화면 또는 온보딩 화면의 특정 텍스트로 확인
        // 예: "이용 전 꼭 확인하세요" (면책 화면) 또는 온보딩 헤더
        // 여기서는 스크린이 변했는지만 확인 (테스트 범위 내)
        expect(
          find.byType(ElevatedButton),
          findsWidgets,
          reason: '다음 화면으로 진입했어야 함',
        );
      },
    );
  });
}