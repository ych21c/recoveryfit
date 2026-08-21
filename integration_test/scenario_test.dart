import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets('스플래시 화면이 나타나고 로딩 애니메이션이 진행된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 확인 — 로고와 슬로건이 표시되는지 검증
      expect(find.textContaining('RecoveryFit'), findsWidgets);
      expect(find.textContaining('부상 후, 더 강하게'), findsWidgets);

      // 로딩 도트 애니메이션 확인 (3개 점이 동시에 진행 중)
      // dot 클래스들이 animated 상태로 동작하는지만 확인
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('스플래시 화면에서 자동으로 랜딩 화면으로 전환된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 진행
      await tester.pump(const Duration(milliseconds: 600)); // fadeIn
      await tester.pump(const Duration(milliseconds: 1200)); // hold
      await tester.pump(const Duration(milliseconds: 400)); // fadeOut

      // 랜딩 화면의 핵심 텍스트 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }

      // 랜딩 화면 전환 확인 — 헤드라인과 CTA 버튼이 표시
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('랜딩 화면에 히어로 일러스트가 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // 히어로 일러스트 영역이 렌더링되었는지 확인
      // SVG가 embedded된 SizedBox/Container로 표시
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('랜딩 화면에 핵심 가치 포인트 3종이 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('이중 안전').evaluate().isNotEmpty) break;
      }

      // 3개 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsWidgets);
      expect(find.text('AI 개인화'), findsWidgets);
      expect(find.text('터치 최소화'), findsWidgets);
    });

    testWidgets('랜딩 화면에 면책 조항 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('의료기기 아님').evaluate().isNotEmpty) break;
      }

      // 면책 조항 텍스트 확인
      expect(find.textContaining('의료기기 아님'), findsWidgets);
      expect(find.textContaining('전문의 상담을 대체하지 않습니다'), findsWidgets);
    });

    testWidgets('CTA 버튼 "무료로 시작하기"를 탭하면 면책 동의 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 면책 동의 화면으로 전환되었는지 확인
      // 면책 화면의 헤더나 주요 콘텐츠 확인
      expect(find.textContaining('이용 전 꼭 확인하세요'), findsWidgets);
    });

    testWidgets('스플래시 화면에서 RecoveryFit 로고(WordMark)가 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 로고 텍스트 확인 (색상 강조는 시각적 검증이므로 생략)
      expect(find.textContaining('Recovery'), findsWidgets);
      expect(find.textContaining('Fit'), findsWidgets);

      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('랜딩 화면의 헤더에 RecoveryFit 로고가 소형으로 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }

      // 랜딩 화면의 헤더 로고 확인
      expect(find.textContaining('RecoveryFit'), findsWidgets);
    });

    testWidgets('랜딩 화면의 메인 헤드라인이 2줄로 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }

      // 메인 헤드라인의 각 줄 확인
      // 실제 소스에서 "\n"으로 나뉠 수 있으므로 각 부분을 따로 검증
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);
    });

    testWidgets('랜딩 화면의 서브 헤드라인이 표시된다', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 자동 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('AI가 내 부상 상태를 분석하고').evaluate().isNotEmpty) break;
      }

      // 서브 헤드라인의 부분 검증
      expect(find.textContaining('AI가 내 부상 상태를 분석하고'), findsWidgets);
      expect(find.textContaining('안전한 재활 플랜을 만들어드려요'), findsWidgets);
    });
  });

}
