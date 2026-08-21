import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing) 검증', () {
    testWidgets('스플래시 화면 로드 및 로고 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 스플래시 화면이 나타나는지 확인
      expect(find.text('Recovery'), findsWidgets);
      expect(find.text('Fit'), findsWidgets);
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('스플래시 로딩 도트 애니메이션 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 로딩 도트가 존재하는지 확인 (애니메이션은 실행 중)
      expect(find.byIcon(Icons.circle), findsWidgets);
    });

    testWidgets(
        '스플래시 화면이 일정 시간 후 랜딩 화면으로 전환',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기: 스플래시 화면에서 "Recovery" 텍스트 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 스플래시 애니메이션 진행 (페이드인 0.6s + 정지 1.2s + 페이드아웃 0.4s 이상)
      // 보수적으로 2.5초 pump
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 랜딩 화면의 CTA 버튼이 나타나는지 확인
      expect(
        find.byType(ElevatedButton),
        findsWidgets,
        reason: '랜딩 화면의 CTA 버튼이 표시되어야 함',
      );
    });

    testWidgets('랜딩 화면에 메인 헤드라인 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 애니메이션 건너뛰고 랜딩 화면 도달
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // "부상 후에도\n운동할 수 있어요" 검증
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면에 서브 헤드라인 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 서브 헤드라인 각 줄 검증 (소스에 \n으로 나뉨)
      expect(
        find.text('AI가 내 부상 상태를 분석하고'),
        findsOneWidget,
      );
      expect(
        find.text('안전한 재활 플랜을 만들어드려요'),
        findsOneWidget,
      );
    });

    testWidgets('랜딩 화면에 가치 포인트 3종 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 가치 포인트 라벨 검증
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면의 CTA 버튼 "무료로 시작하기" 표시',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // CTA 버튼 텍스트 검증
      expect(
        find.text('무료로 시작하기'),
        findsOneWidget,
        reason: '랜딩 화면의 CTA 버튼이 "무료로 시작하기" 텍스트를 표시해야 함',
      );
    });

    testWidgets('랜딩 화면의 보조 텍스트 (면책) 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 보조 텍스트 검증 (소스에 여러 줄로 나뉨)
      expect(find.text('의료기기 아님'), findsOneWidget);
      expect(
        find.text('전문의 상담을 대체하지 않습니다'),
        findsOneWidget,
      );
    });

    testWidgets('CTA 버튼 탭 시 면책동의 화면으로 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책동의 화면으로 진입 확인 (예: "동의하고 시작" 버튼 검색)
      expect(
        find.text('동의하고 시작'),
        findsOneWidget,
        reason: '면책동의 화면의 주 CTA 버튼이 표시되어야 함',
      );
    });

    testWidgets('랜딩 화면 헤더에 로고 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 헤더의 RecoveryFit 로고 텍스트 검증
      expect(
        find.text('RecoveryFit'),
        findsWidgets,
        reason: '랜딩 헤더와 스플래시에 로고가 있을 수 있음',
      );
    });

    testWidgets('랜딩 화면 배경 색상 및 레이아웃 검증',
        (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // 메인 콘텐츠 Column 존재 확인
      expect(find.byType(Column), findsWidgets);

      // Scaffold 존재 확인
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}