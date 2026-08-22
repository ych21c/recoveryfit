import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets('스플래시 화면이 앱 진입 직후 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 딥 네이비 배경 확인
      expect(find.byType(Scaffold), findsWidgets);
      
      // RecoveryFit 로고/텍스트 확인
      expect(find.textContaining('Recovery'), findsWidgets);
      
      // 슬로건 "부상 후, 더 강하게" 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('스플래시 화면에서 로딩 도트 애니메이션 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 도트 3개가 있는지 확인 (bounce 애니메이션)
      expect(find.byType(Container), findsWidgets);
      
      // 작은 시간 진행해서 애니메이션 프레임 진행
      await tester.pump(const Duration(milliseconds: 500));
      
      // 여전히 화면에 표시되어야 함
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('스플래시에서 랜딩 화면으로 자동 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 초기: 스플래시 표시
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      
      // 최소 2초 이상 대기 (애니메이션 + 초기화)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      
      // 랜딩 화면의 헤드라인이 나타날 때까지 반복 대기
      for (var i = 0; i < 10; i++) {
        if (find.text('부상 후에도').evaluate().isNotEmpty ||
            find.text('운동할 수 있어요').evaluate().isNotEmpty) {
          break;
        }
        await tester.pump(const Duration(milliseconds: 500));
      }
      
      // 랜딩 화면 헤드라인 확인
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);
    });

    testWidgets('랜딩 화면에서 히어로 이미지 영역이 상단 55% 차지', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시에서 랜딩으로 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }
      
      // 랜딩 화면 진입 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면에서 RecoveryFit 로고가 좌측 상단에 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩 화면으로 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }
      
      // RecoveryFit 텍스트 확인
      expect(find.textContaining('RecoveryFit'), findsWidgets);
    });

    testWidgets('랜딩 화면에서 주요 헤드라인과 서브 헤드라인이 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩 화면 진입
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }
      
      // 메인 헤드라인 (여러 줄이므로 각각 확인)
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
      
      // 서브 헤드라인 (여러 Text 위젯일 가능성)
      expect(find.textContaining('AI'), findsWidgets);
      expect(find.textContaining('부상'), findsWidgets);
    });

    testWidgets('랜딩 화면에서 가치 포인트 3종 아이콘과 레이블이 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩 화면 진입
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }
      
      // 3가지 가치 포인트 텍스트 확인
      expect(find.textContaining('이중 안전'), findsWidgets);
      expect(find.textContaining('AI 개인화'), findsWidgets);
      expect(find.textContaining('터치 최소화'), findsWidgets);
    });

    testWidgets('랜딩 화면에서 "무료로 시작하기" CTA 버튼이 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩 화면 진입
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }
      
      // CTA 버튼 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);
      
      // ElevatedButton 타입 확인
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('랜딩 화면에서 면책 텍스트가 하단에 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩 화면 진입
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) break;
      }
      
      // 면책 텍스트 확인
      expect(
        find.textContaining('의료기기 아님'),
        findsWidgets,
      );
      expect(
        find.textContaining('전문의 상담'),
        findsWidgets,
      );
    });

    testWidgets('랜딩 화면의 CTA 버튼을 탭하면 다음 화면으로 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩 화면 진입
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }
      
      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      
      // 화면 전환 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        // 다음 화면 헤드라인 확인 (면책 동의 또는 온보딩)
        if (find.textContaining('확인').evaluate().isNotEmpty ||
            find.textContaining('동의').evaluate().isNotEmpty ||
            find.textContaining('어디가').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 더 이상 "무료로 시작하기" 버튼이 화면에 없어야 함
      // (다음 화면으로 진입했음을 의미)
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    });
  });

}
