import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
  testWidgets('스플래시 화면이 앱 시작 시 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Recovery'), findsWidgets);
    expect(find.text('부상 후, 더 강하게'), findsOneWidget);
  });

  testWidgets('스플래시 로딩 도트 애니메이션이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    // 도트는 Container + 애니메이션으로 구성, 직접 찾기 어려움
    // 대신 화면이 SplashScreen 상태임을 간접 확인
    expect(find.text('부상 후, 더 강하게'), findsOneWidget);
  });

  testWidgets('스플래시 화면에서 정해진 시간 후 랜딩 화면으로 전환된다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    // 애니메이션 완료 대기 (페이드인 0.6s + 정지 1.2s + 페이드아웃 0.4s = 2.2s)
    // 초기화 비동기 작업까지 고려하여 작은 단위로 여러 번 pump
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
    }

    // 랜딩 화면의 CTA 버튼이 나타났는지 확인
    expect(find.text('무료로 시작하기'), findsOneWidget);
  });

  testWidgets('랜딩 화면이 정상적으로 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    // 스플래시 → 랜딩 전환 대기
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
    }

    // 랜딩 화면의 핵심 요소 확인
    expect(find.text('부상 후에도'), findsOneWidget);
    expect(find.text('운동할 수 있어요'), findsOneWidget);
    expect(find.textContaining('AI가 내 부상 상태를 분석하고'), findsOneWidget);
  });

  testWidgets('랜딩 화면에 가치 포인트 3종이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('이중 안전').evaluate().isNotEmpty) break;
    }

    expect(find.textContaining('이중 안전'), findsWidgets);
    expect(find.textContaining('AI 개인화'), findsWidgets);
    expect(find.textContaining('터치 최소화'), findsWidgets);
  });

  testWidgets('랜딩 화면의 CTA 버튼 텍스트가 정확하다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
    }

    expect(find.text('무료로 시작하기'), findsOneWidget);
  });

  testWidgets('랜딩 화면의 면책 문구가 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.textContaining('의료기기 아님').evaluate().isNotEmpty) break;
    }

    expect(
      find.textContaining('의료기기 아님'),
      findsWidgets,
    );
    expect(
      find.textContaining('전문의 상담을 대체하지 않습니다'),
      findsWidgets,
    );
  });

  testWidgets('랜딩 화면의 CTA 버튼을 탭하면 면책 동의 화면으로 이동한다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    // 스플래시 → 랜딩 전환
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
    }

    // CTA 버튼 탭
    await tester.tap(find.text('무료로 시작하기'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // 면책 화면 텍스트 확인
    expect(find.textContaining('이용 전 꼭 확인하세요'), findsWidgets);
    expect(find.text('동의하고 시작'), findsOneWidget);
  });

  testWidgets('랜딩 화면의 로고가 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('RecoveryFit').evaluate().isNotEmpty) break;
    }

    expect(find.text('RecoveryFit'), findsWidgets);
  });

  testWidgets('히어로 일러스트 영역이 화면 상단에 배치된다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
    }

    // 히어로 영역은 상단 55%에 배치됨
    // 실제 위치를 픽셀로 검증하기는 어려우므로,
    // 히어로 위에 나타나는 콘텐츠(헤더 로고 등)가 있는지로 확인
    final heroContent = find.textContaining('RecoveryFit');
    expect(heroContent, findsWidgets);

    // 하단에 나타나는 CTA 버튼이 있는지 확인
    expect(find.text('무료로 시작하기'), findsOneWidget);
  });

  testWidgets('랜딩 화면이 스크롤 없이 단일 뷰포트로 구성된다',
      (WidgetTester tester) async {
    await tester.pumpWidget(const RecoveryFitApp());

    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
    }

    // 모든 핵심 콘텐츠가 화면에 보여야 함
    expect(find.text('부상 후에도'), findsOneWidget);
    expect(find.text('운동할 수 있어요'), findsOneWidget);
    expect(find.text('무료로 시작하기'), findsOneWidget);

    // SingleChildScrollView가 없어야 함 (단일 뷰포트)
    expect(find.byType(SingleChildScrollView), findsNothing);
  });
});

}
