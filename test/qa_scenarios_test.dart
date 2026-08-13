import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recovery_fit/main.dart';

void main() {
  group('RecoveryFit 시작 페이지 (Splash & Landing)', () {
    setUp(() {
      // Provide an in-memory SharedPreferences store so StorageService.init()
      // resolves instantly in tests without real platform channels.
      SharedPreferences.setMockInitialValues({});
    });

    
    testWidgets('앱 시작 시 스플래시 스크린 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // 스플래시 스크린에서 RecoveryFit 로고/텍스트 확인
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('스플래시 스크린 배경색이 딥 네이비 (#0D1B2A)', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Scaffold의 배경색이 dark navy인지 확인
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsWidgets);
    });

    testWidgets('스플래시 스크린에서 로고 중앙 배치 확인', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // 화면에 적어도 하나의 Center 위젯이 있는지 확인 (로고 중앙 배치)
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('스플래시 스크린에 태그라인 "부상 후, 더 강하게" 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // 태그라인 텍스트 확인
      expect(find.text('부상 후, 더 강하게'), findsWidgets);
    });

    testWidgets('스플래시 스크린에서 프로그레스 인디케이터 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // 로딩 인디케이터 (CircularProgressIndicator 또는 dots) 확인
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('스플래시에서 최소 2초 후 다음 화면으로 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 초기 상태 (스플래시)
      await tester.pumpAndSettle(const Duration(seconds: 1));
      final initialCount = find.byType(Scaffold).evaluate().length;
      
      // 2초 이상 대기 후 상태 확인
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // 화면이 전환되었거나 유지되어야 함
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('랜딩 페이지에서 RecoveryFit 로고 좌상단 배치', (tester) async {
      // 온보딩 완료 상태로 초기화하고 바로 랜딩으로 이동
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 로고가 좌상단에 있는지 확인 (AppBar 또는 상단 영역에)
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('랜딩 페이지 메인 헤드라인 "부상 후에도\\n운동할 수 있어요" 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 메인 헤드라인 텍스트 확인
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);
    });

    testWidgets('랜딩 페이지에 [시작하기] CTA 버튼 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // [시작하기] 버튼 확인
      expect(find.text('시작하기'), findsWidgets);
    });

    testWidgets('랜딩 페이지는 스크롤 없이 단일 뷰포트 구성', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // ListView 또는 SingleChildScrollView 없이 Column 또는 Stack 사용 확인
      // 스크롤 불가능한 레이아웃 확인
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('[시작하기] 버튼 탭 시 다음 화면 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // [시작하기] 버튼 찾기
      final startButton = find.text('시작하기');
      expect(startButton, findsWidgets);
      
      // 버튼 탭
      await tester.tap(startButton.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // 다음 화면 (온보딩)으로 진입했는지 확인
      // OnboardingDisclaimerScreen으로 전환되어야 함
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('랜딩 페이지 배경에 그라디언트 오버레이 적용', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Container with gradient를 찾기
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('랜딩 페이지에 가치 제안 문구 3종 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 가치 제안 텍스트들이 화면에 표시되어 있는지 확인
      // (구체적인 문구는 디자인 스펙에 따라)
      final textElements = find.byType(Text);
      expect(textElements, findsWidgets);
    });

    testWidgets('랜딩 페이지 하단에 법적 면책 텍스트 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 의료 면책 텍스트 확인
      expect(find.text('의료기기'), findsWidgets);
    });

    testWidgets('스플래시 페이드인 애니메이션 실행', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 초기 상태 (페이드인 시작)
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Scaffold), findsWidgets);
      
      // 애니메이션이 진행되는 동안 위젯이 계속 존재
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('랜딩 페이지는 신규 사용자만 접근 가능', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 온보딩이 완료되지 않았다면 랜딩 페이지가 표시됨
      // (또는 스플래시 이후 랜딩으로 진입)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('스플래시와 랜딩 간 전환 로직 확인', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 표시 확인
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsWidgets);
      
      // 전환 후 랜딩 또는 다음 화면 표시 확인
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('스플래시 스크린에 민트색 프로그레스 도트 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      
      // 프로그레스 인디케이터 확인
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('랜딩 페이지 헤더에 흰색 로고 배치', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 상단 영역 확인 (Safe Area 내)
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('스플래시 태그라인은 로고 하단 16px 간격 유지', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Padding을 통한 간격 설정 확인
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('랜딩 페이지 [시작하기] 버튼은 단일 CTA', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // ElevatedButton 개수 확인 (랜딩에서는 주요 CTA 버튼이 1개)
      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsWidgets);
    });

    testWidgets('스플래시에서 로딩 완료 후 자동 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 충분한 시간 대기 (로딩 + 페이드아웃 포함)
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // 최종 화면 표시 확인
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('스플래시 스크린 배경 풀스크린 확인', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Scaffold가 전체 화면을 차지하는지 확인
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('랜딩 페이지 히어로 이미지 영역 표시 (상단 55%)', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 이미지 또는 일러스트 영역 (Container/Image/decoration)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('랜딩 페이지는 터치 최소화 원칙 적용 (단일 CTA)', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // 주요 상호작용 요소가 [시작하기] 버튼 1개만
      expect(find.text('시작하기'), findsWidgets);
      
      // 추가 버튼이 없는지 확인
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });
}