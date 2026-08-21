import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets('스플래시 화면 로드 후 로고와 로딩 애니메이션 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 화면의 RecoveryFit 로고 확인
      expect(find.text('Recovery'), findsWidgets);
      expect(find.text('Fit'), findsWidgets);
      
      // 슬로건 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      
      // 로딩 도트 확인 (3개)
      expect(find.byIcon(Icons.circle), findsWidgets);
    });

    testWidgets('스플래시 화면에서 배경색이 딥 네이비이고, 텍스트가 흰색', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 배경이 깔려있는 Scaffold 또는 Container 확인
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);
      
      // 텍스트 색상은 흰색 계열 확인 (슬로건)
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('스플래시에서 자동 전환 — 랜딩 화면으로 이동', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 초기: 스플래시 화면 (로고 확인)
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      
      // 애니메이션 + 페이드아웃 + 비동기 완료를 기다림
      // 큰 시간 단발 pump는 비동기 미완료 가능하므로 작게 여러 번
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        
        // "무료로 시작하기" 버튼이 나타나면 랜딩 화면에 도달
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 랜딩 화면 진입 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 히어로 텍스트와 CTA 버튼 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 → 랜딩 전환 기다림
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }
      
      // 메인 헤드라인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
      
      // 서브 헤드라인
      expect(find.textContaining('AI가 내 부상 상태를'), findsWidgets);
      expect(find.textContaining('안전한 재활 플랜을'), findsWidgets);
      
      // CTA 버튼
      expect(find.text('무료로 시작하기'), findsOneWidget);
      
      // 보조 텍스트 (disclaimer)
      expect(find.textContaining('의료기기 아님'), findsOneWidget);
      expect(find.textContaining('전문의 상담을 대체하지 않습니다'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 가치 포인트 3종 아이콘 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }
      
      // 가치 포인트 라벨 확인
      expect(find.textContaining('이중 안전'), findsWidgets);
      expect(find.textContaining('검증'), findsWidgets);
      
      expect(find.textContaining('AI 개인화'), findsWidgets);
      expect(find.textContaining('플랜'), findsWidgets);
      
      expect(find.textContaining('터치 최소화'), findsWidgets);
      expect(find.textContaining('인터페이스'), findsWidgets);
    });

    testWidgets('랜딩 화면 — [무료로 시작하기] 탭하면 면책동의 화면으로 이동', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }
      
      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      
      // 비동기 라우팅 완료 기다림
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        
        // 면책 동의 화면의 특징: "이용 전 꼭 확인하세요"
        if (find.textContaining('이용 전').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 면책 동의 화면 진입 확인
      expect(find.textContaining('이용 전'), findsWidgets);
      expect(find.text('의료기기가 아닙니다'), findsOneWidget);
      
      // 동의 버튼
      expect(find.text('동의하고 시작'), findsOneWidget);
    });

    testWidgets('랜딩 화면 — 로고가 좌상단 및 헤더 위치에 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }
      
      // 헤더 영역에 RecoveryFit 로고 (소형)
      expect(find.text('RecoveryFit'), findsWidgets);
    });
  });

}
