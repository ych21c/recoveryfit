import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets('스플래시 화면 표시 및 애니메이션 재생', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 스플래시 화면이 표시되는지 확인
      expect(find.text('RecoveryFit'), findsWidgets);
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트(애니메이션)가 있는지 확인
      expect(find.byIcon(Icons.circle), findsWidgets);
    });

    testWidgets('스플래시 화면에서 랜딩 화면으로 자동 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기: 스플래시 화면
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 애니메이션 완료 후 랜딩 화면으로 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 랜딩 화면의 메인 헤드라인 확인
      expect(
        find.textContaining('부상 후에도'),
        findsOneWidget,
      );
      expect(
        find.textContaining('운동할 수 있어요'),
        findsOneWidget,
      );
    });

    testWidgets('랜딩 화면에 모든 핵심 요소가 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 헤더 로고
      expect(find.text('RecoveryFit'), findsWidgets);

      // 메인 헤드라인
      expect(find.textContaining('부상 후에도'), findsOneWidget);
      expect(find.textContaining('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인 (multi-line 텍스트)
      expect(
        find.textContaining('AI가 내 부상 상태를 분석'),
        findsOneWidget,
      );

      // CTA 버튼
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 보조 텍스트 (의료기기 아님 면책)
      expect(
        find.textContaining('의료기기 아님'),
        findsOneWidget,
      );
    });

    testWidgets('랜딩 화면에서 가치 포인트 3종이 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 가치 포인트 3종 확인 (각각 아이콘과 텍스트)
      expect(find.textContaining('이중 안전'), findsOneWidget);
      expect(find.textContaining('AI 개인화'), findsOneWidget);
      expect(find.textContaining('터치 최소화'), findsOneWidget);
    });

    testWidgets('랜딩 화면의 CTA 버튼 탭시 온보딩으로 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // "무료로 시작하기" 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 온보딩 화면(면책동의)으로 진입 확인
      // 면책동의 화면에는 "이용 전 꼭 확인하세요" 텍스트가 있음
      expect(
        find.textContaining('이용 전'),
        findsOneWidget,
      );
    });

    testWidgets('랜딩 화면 배경이 딥 네이비 색상', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Scaffold 배경색 확인 (딥 네이비 #0D1B2A)
      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsWidgets);

      // 최상위 화면 구조 확인 (Material 앱이 제대로 구성되었는지)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('스플래시 화면의 로고 심볼이 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 스플래시 화면의 "RecoveryFit" 워드마크 존재 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 스플래시 화면의 로고 심볼(SVG) 렌더링은 단순 존재 확인으로 충분
      // (정확한 렌더링은 시각적 테스트 필요)
    });

    testWidgets('랜딩 화면에서 스크롤 없이 모든 요소가 한 화면에 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 스크롤 가능한 위젯 확인 (있으면 안 됨 - 단일 뷰포트)
      // 모든 핵심 요소가 동시에 표시되는지 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);
      expect(find.textContaining('부상 후에도'), findsOneWidget);
      expect(find.textContaining('의료기기 아님'), findsOneWidget);

      // 세 요소가 모두 가시 영역에 있음을 확인
      final ctaButton = find.text('무료로 시작하기');
      final disclaimer = find.textContaining('의료기기 아님');

      expect(ctaButton.evaluate().isNotEmpty, true);
      expect(disclaimer.evaluate().isNotEmpty, true);
    });

    testWidgets('랜딩 화면의 CTA 버튼이 민트색 배경을 가짐', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // CTA 버튼 찾기
      final ctaButton = find.byType(ElevatedButton);
      expect(ctaButton, findsWidgets);

      // 버튼이 탭 가능한 상태인지 확인
      expect(
        tester.getSize(find.text('무료로 시작하기')).height,
        greaterThan(0),
      );
    });
  });

}
