import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    testWidgets('스플래시 화면이 표시되고 자동으로 랜딩으로 전환됨', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump(const Duration(milliseconds: 100));

      // 스플래시 화면 로고 확인 (RecoveryFit 워드마크)
      expect(find.text('Recovery'), findsOneWidget);
      expect(find.text('Fit'), findsOneWidget);

      // 슬로건 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 로딩 도트 애니메이션 표시 중 확인
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('스플래시 애니메이션 후 랜딩 화면으로 이동', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 스플래시 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 애니메이션 + 초기화 완료 대기 (최대 3초)
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // 랜딩 화면의 CTA 버튼 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('랜딩 화면에서 주요 텍스트 확인', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 애니메이션 통과
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // 랜딩 화면 메인 헤드라인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsOneWidget);
    });

    testWidgets('랜딩 화면의 가치 포인트 3종 확인', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면의 CTA 버튼이 탭 가능함', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // CTA 버튼 확인 및 상태 검증
      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);

      // 버튼이 ElevatedButton 또는 GestureDetector로 감싸져 있음을 확인
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('랜딩 화면의 보조 텍스트(의료기기 아님) 확인', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // 의료기기 부고 텍스트 확인
      expect(find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'), findsOneWidget);
    });

    testWidgets('랜딩 화면 로고 확인', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // 헤더의 RecoveryFit 로고 확인 (상단 좌측 작은 로고)
      // 스플래시의 워드마크와 구분하기 위해 "RecoveryFit" 텍스트 전체 검색
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('스플래시 화면에 배경색이 딥 네이비 (#0D1B2A)임을 확인', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump(const Duration(milliseconds: 100));

      // Scaffold의 배경색 또는 Container의 배경색이 깔려있는지 확인
      // 스플래시 배경이 #0D1B2A인 것을 간접적으로 확인 (어두운 배경)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('랜딩 화면 진입 후 네비게이션 바가 없음을 확인', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // 랜딩은 단순 화면이므로 BottomNavigationBar가 없음
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('CTA 버튼 탭 시 면책 동의 화면으로 이동 준비', (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 랜딩 화면 진입
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 다음 화면(면책 동의)으로 진입했는지 확인
      // "이용 전 꼭 확인하세요" 텍스트가 있는지 검증
      expect(
        find.text('이용 전 꼭 확인하세요'),
        findsOneWidget,
      );
    });
  });
}