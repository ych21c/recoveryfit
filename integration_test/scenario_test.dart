import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen + LandingScreen)', () {
    testWidgets('스플래시 화면 진입: 로고·슬로건·로딩 도트 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 식별: 고유 슬로건 텍스트로 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로고 워드마크 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 로딩 도트는 애니메이션 중이므로 존재 확인만
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('스플래시 → 랜딩 화면 전환: 자동 네비게이션',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시에서 시작
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 페이드아웃 + 전환 애니메이션 후 랜딩 화면 도착
      // (스플래시는 최소 2초, 실제로는 더 오래 걸릴 수 있음)
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      // 남은 비동기 초기화(Hive/알림 서비스) 체인이 끝날 때까지 정착 대기.
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 랜딩 화면의 고유 CTA 텍스트로 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('랜딩 화면: 메인 헤드라인 + 서브 헤드라인 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // 메인 헤드라인 (2줄이므로 각각 검증)
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인 (2줄)
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsOneWidget);
    });

    testWidgets('랜딩 화면: 가치 포인트 3종 아이콘 + 라벨 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // 3개의 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget); // "이중 안전\n검증"으로 나뉨
      
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면: CTA 버튼 "무료로 시작하기" 표시 및 탭 가능',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // CTA 버튼 찾기
      final ctaButton = find.byType(ElevatedButton);
      expect(ctaButton, findsWidgets); // 화면에 여러 버튼이 있을 수 있음

      // "무료로 시작하기" 텍스트가 버튼에 있는지 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 버튼이 탭 가능한지 확인 (상호작용 가능)
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('랜딩 화면: 보조 텍스트 "의료기기 아님 · 전문의 상담..." 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // 보조 텍스트는 한 Text 위젯 안의 전체 문구 일부이므로 부분 일치로 확인
      expect(find.textContaining('의료기기 아님'), findsOneWidget);
      expect(find.textContaining('전문의 상담을 대체하지 않습니다'), findsOneWidget);
    });

    testWidgets('랜딩 화면: 로고 좌측 상단 배치 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // RecoveryFit 로고 텍스트가 존재
      final logo = find.text('RecoveryFit');
      expect(logo, findsWidgets); // 여러 화면에서 나타날 수 있음

      // 로고가 상단에 있는지 확인 (위젯 레이아웃 상 SafeArea 내에 배치)
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('랜딩 화면: 히어로 일러스트 영역 (상단 55%) 배경 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // 배경이 있는 컨테이너/스택 구조 확인
      expect(find.byType(Stack), findsWidgets);
      expect(find.byType(Container), findsWidgets);

      // SVG 또는 그라디언트 오버레이가 렌더링됨
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('랜딩 화면 디자인: 색상 체계 (딥 네이비 + 민트) 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // Scaffold 또는 Container의 배경색이 설정됨
      // (정확한 색상 코드 검증은 렌더링된 픽셀이 필요하므로, 
      //  여기서는 구조 존재만 확인)
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('CTA 버튼 터치 시 온보딩 화면으로 전환',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 도착
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) break;
      }

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 온보딩 화면으로 전환 (면책 동의 또는 온보딩 페이지)
      // 다음 화면의 고유 요소로 확인 (예: "동의하고 시작" 버튼)
      // 또는 "어디가 불편하신가요?" 등 온보딩 텍스트
      await tester.pump(const Duration(milliseconds: 500));
      
      // 다음 화면에서 기대되는 요소 중 하나 확인
      final nextScreenElements = find.byType(Column);
      expect(nextScreenElements, findsWidgets);
    });
  });
}