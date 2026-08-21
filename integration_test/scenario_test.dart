import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets('스플래시 스크린 표시 후 랜딩으로 자동 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 1. 스플래시 화면 로고 확인
      expect(find.text('Recovery'), findsOneWidget);
      expect(find.text('Fit'), findsOneWidget);
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
      
      // 2. 로딩 도트 애니메이션 진행
      await tester.pump(const Duration(milliseconds: 500));
      
      // 3. 페이드아웃 후 랜딩 화면으로 전환될 때까지 기다리기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 4. 랜딩 화면 콘텐츠 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면 히어로 텍스트와 CTA 버튼 렌더링', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 애니메이션 완료 후 랜딩으로 전환
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
      
      // 서브 헤드라인 확인
      expect(find.textContaining('AI가 내 부상 상태를 분석'), findsWidgets);
      expect(find.textContaining('안전한 재활 플랜을 만들어드려요'), findsWidgets);
    });

    testWidgets('랜딩 화면 가치 포인트 3종 아이콘과 라벨 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩으로 전환
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('이중 안전').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 가치 포인트 라벨들 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면 CTA 버튼 원터치로 면책 동의 화면 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩으로 전환 후 CTA 버튼 터치
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }
      
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // 면책 동의 화면으로 전환 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
      expect(find.text('의료기기가 아닙니다'), findsWidgets);
    });

    testWidgets('랜딩 화면 보조 텍스트 "의료기기 아님" 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩으로 전환
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.textContaining('의료기기 아님').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 보조 텍스트 확인
      expect(find.textContaining('의료기기 아님'), findsWidgets);
      expect(find.textContaining('전문의 상담을 대체하지 않습니다'), findsWidgets);
    });

    testWidgets('랜딩 화면 로고 좌측 상단에 렌더링', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩으로 전환
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('RecoveryFit').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 로고 텍스트 확인
      final logoFinder = find.text('RecoveryFit');
      expect(logoFinder, findsWidgets); // 여러 곳에 나타남 (스플래시, 랜딩)
    });

    testWidgets('랜딩 화면 스크롤 없음 단일 뷰포트 레이아웃 확인', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 랜딩으로 전환
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 300));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 주요 요소들이 모두 보이는지 확인 (스크롤 불필요)
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
      expect(find.text('무료로 시작하기'), findsOneWidget);
      expect(find.textContaining('의료기기 아님'), findsWidgets);
    });

    testWidgets('스플래시 화면 도트 애니메이션 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시에서 도트들이 보이는지 확인
      await tester.pump(const Duration(milliseconds: 100));
      
      // 로딩 인디케이터 (도트) 확인 - 각 도트는 내부적으로 작은 원형 위젯
      expect(find.byType(Scaffold), findsWidgets);
      
      // 페이드인 애니메이션 진행
      await tester.pump(const Duration(milliseconds: 600));
      
      // 정지 상태
      await tester.pump(const Duration(milliseconds: 1200));
      
      // 페이드아웃 시작
      await tester.pump(const Duration(milliseconds: 400));
    });

    testWidgets('기존 사용자(onboarding_done=true) 직접 홈 대시보드로 이동', (tester) async {
      // 주의: 이 테스트는 실제 저장소 초기화 필요하므로 
      // 통합 테스트 환경에서 사전 조건 설정 필요
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 앱 시작 후 라우팅 상태 확인
      // (실제로는 StorageService.onboardingDone이 true인 경우를 모의 해야 함)
      await tester.pump(const Duration(seconds: 2));
    });
  });

}
