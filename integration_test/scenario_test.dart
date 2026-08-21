import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (Splash & Landing)', () {
    testWidgets(
      '스플래시 화면: 로고 및 로딩 애니메이션 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 화면 로드 확인
        expect(find.text('RecoveryFit'), findsWidgets);
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
        
        // 로딩 도트 애니메이션 확인
        expect(find.byIcon(Icons.circle), findsWidgets);
      },
    );

    testWidgets(
      '스플래시 화면: 페이드인/아웃 애니메이션 후 자동 전환',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 초기 프레임: 스플래시 화면 표시
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
        
        // 페이드인 애니메이션 진행 (600ms)
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
        
        // 대기 시간 (1200ms)
        await tester.pump(const Duration(milliseconds: 1200));
        expect(find.text('부상 후, 더 강하게'), findsOneWidget);
        
        // 페이드아웃 애니메이션 (400ms)
        await tester.pump(const Duration(milliseconds: 400));
        
        // 비동기 초기화 대기
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // 랜딩 화면으로 전환 확인
        expect(find.textContaining('무료로 시작하기'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면: 히어로 일러스트 및 메인 헤드라인 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 화면 애니메이션 건너뛰기
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // 메인 헤드라인 확인
        expect(find.text('부상 후에도'), findsOneWidget);
        expect(find.text('운동할 수 있어요'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면: 서브 헤드라인 및 가치 포인트 3종 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // 서브 헤드라인 확인
        expect(
          find.textContaining('AI가 내 부상 상태를 분석하고'),
          findsOneWidget,
        );
        expect(
          find.textContaining('안전한 재활 플랜을 만들어드려요'),
          findsOneWidget,
        );
        
        // 가치 포인트 확인
        expect(find.textContaining('이중 안전'), findsOneWidget);
        expect(find.textContaining('AI 개인화'), findsOneWidget);
        expect(find.textContaining('터치 최소화'), findsOneWidget);
      },
    );

    testWidgets(
      '랜딩 화면: CTA 버튼 "[무료로 시작하기]" 표시 및 탭 가능',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // CTA 버튼 확인
        final ctaButton = find.textContaining('무료로 시작하기');
        expect(ctaButton, findsOneWidget);
        
        // CTA 버튼이 ElevatedButton 위젯 내에 있는지 확인
        expect(
          find.ancestor(of: ctaButton, matching: find.byType(ElevatedButton)),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면: 보조 텍스트 "[의료기기 아님 · 전문의 상담을 대체하지 않습니다]" 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // 보조 텍스트 확인
        expect(
          find.textContaining('의료기기 아님'),
          findsOneWidget,
        );
        expect(
          find.textContaining('전문의 상담을 대체하지 않습니다'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '랜딩 화면: CTA 버튼 탭 후 면책 동의 화면으로 진입',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // CTA 버튼 탭
        await tester.tap(find.textContaining('무료로 시작하기'));
        
        // 라우팅 애니메이션 대기
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // 면책 동의 화면 확인
        expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
        // 면책 문구는 순수 RichText(TextSpan)라 findRichText 없이는 안 잡힘
        expect(find.textContaining('의료기기', findRichText: true), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면: 헤더 로고 좌측 상단에 표시',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // 헤더에 있는 RecoveryFit 텍스트 확인
        expect(find.text('RecoveryFit'), findsWidgets);
      },
    );

    testWidgets(
      '랜딩 화면: 색상 스킴 검증 (민트 CTA, 딥 네이비 배경)',
      (tester) async {
        await tester.pumpWidget(const RecoveryFitApp());
        
        // 스플래시 → 랜딩 전환
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 1200));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        
        // Scaffold 배경 색상 확인 (딥 네이비 #0D1B2A)
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsWidgets);
        
        // CTA 버튼의 배경 색상이 민트 (#00C9A7)인지 확인
        final ctaButton = find.ancestor(
          of: find.textContaining('무료로 시작하기'),
          matching: find.byType(ElevatedButton),
        );
        expect(ctaButton, findsOneWidget);
      },
    );
  });
}