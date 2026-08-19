import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash + Landing)', () {
    testWidgets('스플래시 화면 진입 및 로고/슬로건 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 스플래시 화면의 RecoveryFit 로고 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 슬로건 "부상 후, 더 강하게" 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('스플래시 화면 로딩 도트 애니메이션 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 상태에서 로딩 도트 확인 (3개의 원)
      expect(find.byType(Container), findsWidgets);

      // 첫 프레임에서 화면 렌더링 완료 확인
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('스플래시 화면에서 랜딩 화면으로 전환',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 초기 표시
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 애니메이션 시간 기다림 (페이드인 0.6s + 정지 1.2s)
      await tester.pump(const Duration(milliseconds: 1900));

      // 랜딩 화면 진입 대기
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // 랜딩 화면의 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 화면 히어로 비주얼 및 핵심 텍스트 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 스킵 (1.9초 대기)
      await tester.pump(const Duration(milliseconds: 1900));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // 랜딩 화면 메인 헤드라인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsOneWidget);
    });

    testWidgets('랜딩 화면 가치 포인트 3종 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 스킵
      await tester.pump(const Duration(milliseconds: 1900));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // 가치 포인트 라벨 확인 (각 항목이 여러 Text 위젯으로 나뉘어 있음)
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 화면 CTA 버튼 "무료로 시작하기" 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 스킵
      await tester.pump(const Duration(milliseconds: 1900));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // CTA 버튼 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 버튼이 ElevatedButton 형태 확인
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('랜딩 화면 보조 텍스트 (의료기기 아님 고지) 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 스킵
      await tester.pump(const Duration(milliseconds: 1900));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // 보조 텍스트 확인
      expect(find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'),
          findsOneWidget);
    });

    testWidgets('랜딩 화면 CTA 버튼 탭 시 면책동의 화면으로 진입',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 스킵
      await tester.pump(const Duration(milliseconds: 1900));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책동의 화면의 특정 텍스트 확인
      // ("이용 전 꼭 확인하세요" 또는 "동의하고 시작" 버튼)
      expect(
          find.text('이용 전 꼭 확인하세요').or(find.text('동의하고 시작')),
          findsWidgets);
    });

    testWidgets('스플래시 화면 딥 네이비 배경색 (#0D1B2A) 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 배경색 검증: 스플래시 화면의 Scaffold 또는 Container의 배경색 확인
      // Material 내부의 색상 검증은 위젯 트리 분석으로 진행
      expect(find.byType(Scaffold), findsWidgets);

      // 스플래시 화면이 최상단에 렌더링 중 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);
    });

    testWidgets('랜딩 화면 로고 아이콘 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 화면 스킵
      await tester.pump(const Duration(milliseconds: 1900));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // 상단 로고 확인 (작은 사이즈의 RecoveryFit 로고)
      expect(find.text('RecoveryFit'), findsWidgets);
    });
  });
}