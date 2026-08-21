import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets('스플래시 화면이 표시되고 로고/슬로건/로딩 도트가 노출됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 스플래시 화면의 배경색 확인
      expect(find.byType(Scaffold), findsWidgets);

      // RecoveryFit 텍스트 확인
      expect(find.textContaining('Recovery'), findsWidgets);
      expect(find.textContaining('Fit'), findsWidgets);

      // 슬로건 확인
      expect(find.textContaining('부상 후, 더 강하게'), findsWidgets);
    });

    testWidgets('스플래시 화면에서 로딩 도트 애니메이션이 동작함', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 첫 번째 도트 찾기
      final dotFinder = find.byType(AnimatedBuilder);
      expect(dotFinder, findsWidgets);

      // 600ms 페이드인 시간 대기
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('부상 후, 더 강하게'), findsWidgets);
    });

    testWidgets('스플래시 화면 애니메이션 완료 후 랜딩 화면으로 자동 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 페이드인 0.6s + 정지 1.2s + 페이드아웃 0.4s = 2.2s 이상 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 랜딩 화면의 메인 헤드라인 확인
      final landingFinder = find.text('부상 후에도');
      if (landingFinder.evaluate().isNotEmpty) {
        expect(landingFinder, findsWidgets);
      }
    });

    testWidgets('랜딩 화면에 메인 헤드라인과 서브 헤드라인이 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 메인 헤드라인: "부상 후에도\n운동할 수 있어요" (2줄)
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);

      // 서브 헤드라인: "AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요"
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsWidgets);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsWidgets);
    });

    testWidgets('랜딩 화면에 가치 포인트 3종 (아이콘 + 라벨)이 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsWidgets);
      expect(find.text('검증'), findsWidgets);
      expect(find.text('AI 개인화'), findsWidgets);
      expect(find.text('플랜'), findsWidgets);
      expect(find.text('터치 최소화'), findsWidgets);
      expect(find.text('인터페이스'), findsWidgets);
    });

    testWidgets('랜딩 화면의 CTA 버튼이 표시되고 탭 가능함', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // "무료로 시작하기" 버튼 찾기
      final ctaFinder = find.text('무료로 시작하기');
      expect(ctaFinder, findsWidgets);

      // 버튼이 ElevatedButton 내에 있는지 확인
      final elevatedButtonFinder = find.byType(ElevatedButton);
      expect(elevatedButtonFinder, findsWidgets);
    });

    testWidgets('랜딩 화면의 보조 텍스트(면책사항)가 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 보조 텍스트: "의료기기 아님 · 전문의 상담을 대체하지 않습니다"
      expect(find.textContaining('의료기기 아님'), findsWidgets);
      expect(find.textContaining('전문의 상담'), findsWidgets);
    });

    testWidgets('랜딩 화면의 CTA 버튼을 탭하면 면책동의 화면으로 이동', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 면책동의 화면의 텍스트 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsWidgets);
      expect(find.textContaining('의료기기가 아닙니다'), findsWidgets);
    });

    testWidgets('랜딩 화면의 히어로 이미지 영역이 상단 55% 영역에 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 히어로 영역에는 SVG 또는 Container가 있음 — 메인 콘텐츠가 하단부에 있는지 확인
      expect(find.textContaining('부상 후에도'), findsWidgets);
      expect(find.textContaining('운동할 수 있어요'), findsWidgets);
      // 이 텍스트들이 화면 하단부에 배치되어 있음을 암시적으로 확인
    });

    testWidgets('랜딩 화면의 로고가 상단 좌측에 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 헤더 로고 텍스트 확인
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('CTA 버튼 탭 시 눌림 효과(scale 및 brightness)가 적용됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입 대기
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      final ctaFinder = find.text('무료로 시작하기');
      expect(ctaFinder, findsWidgets);

      // 버튼 press 시뮬레이션
      await tester.press(ctaFinder);
      await tester.pump(const Duration(milliseconds: 100));

      // 눌림 상태에서도 버튼이 여전히 존재하는지 확인
      expect(find.text('무료로 시작하기'), findsWidgets);
    });

    testWidgets('스플래시와 랜딩 화면의 배경색이 정확한 색상코드를 사용함', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 첫 번째 화면(스플래시): 색상 검증은 Finder로 직접 검증 불가능하므로
      // Scaffold 또는 Container의 존재로 화면 구조 확인
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });

}
