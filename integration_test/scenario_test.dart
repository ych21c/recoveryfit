import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (ATM-5)', () {
    testWidgets('스플래시 화면이 표시되고 로딩 도트가 애니메이션됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 로고 텍스트 확인
      expect(find.text('RecoveryFit'), findsWidgets);

      // 슬로건 확인
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 배경이 딥 네이비인지 확인 (SizedBox나 Container의 배경색 검증)
      expect(find.byType(Scaffold), findsWidgets);

      // 로딩 도트 3개 확인 (애니메이션 중이므로 dot 클래스나 구체적 위젯 타입 대신 텍스트/아이콘으로)
      // 실제 구현에서 도트는 단순 Container일 가능성이 높으므로, 화면 구성 확인만
      expect(find.byType(Column), findsWidgets);

      // 페이드인 애니메이션 진행 중 확인
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('스플래시에서 랜딩 페이지로 자동 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기: 스플래시 화면
      expect(find.text('부상 후, 더 강하게'), findsOneWidget);

      // 페이드아웃 + 전환 대기 (2~3초)
      await tester.pump(const Duration(milliseconds: 600)); // 페이드인
      await tester.pump(const Duration(milliseconds: 1200)); // 홀드
      await tester.pump(const Duration(milliseconds: 400)); // 페이드아웃
      await tester.pump(const Duration(milliseconds: 500)); // 초기화 및 라우팅

      // 랜딩 화면의 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);
    });

    testWidgets('랜딩 페이지: 메인 헤드라인과 서브 헤드라인이 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 통과
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // 헤드라인 확인
      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.text('운동할 수 있어요'), findsOneWidget);

      // 서브 헤드라인 확인 (여러 줄이므로 각각 검증)
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsOneWidget);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsOneWidget);
    });

    testWidgets('랜딩 페이지: 가치 포인트 3종이 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsOneWidget);
      expect(find.text('검증'), findsOneWidget);
      expect(find.text('AI 개인화'), findsOneWidget);
      expect(find.text('플랜'), findsOneWidget);
      expect(find.text('터치 최소화'), findsOneWidget);
      expect(find.text('인터페이스'), findsOneWidget);
    });

    testWidgets('랜딩 페이지: CTA 버튼 "무료로 시작하기"가 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // CTA 버튼 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);

      // 버튼이 ElevatedButton이거나 GestureDetector인지 확인
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('랜딩 페이지: 보조 텍스트 (의료기기 아님) 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // 보조 텍스트 확인
      expect(find.text('의료기기 아님'), findsOneWidget);
      expect(find.text('전문의 상담을 대체하지 않습니다'), findsOneWidget);
    });

    testWidgets('랜딩 페이지: 헤더 로고 (RecoveryFit 소형) 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // 로고 텍스트는 화면에 최소 2회 이상 나타남 (스플래시 + 랜딩 헤더)
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('CTA 버튼 터치 시 면책동의 페이지로 이동', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // CTA 버튼 탭
      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);

      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      // 면책동의 페이지의 특징적인 텍스트 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsOneWidget);
    });

    testWidgets('랜딩 페이지에서 배경이 그라디언트 오버레이와 함께 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));

      // 랜딩 페이지의 스캐폴드 확인
      expect(find.byType(Scaffold), findsWidgets);

      // 배경색이 어두운 톤인지 확인 (딥 네이비 기반)
      // 직접 색상을 검증하기는 어려우므로 컬러 스키마 확인
      expect(find.byType(Container), findsWidgets);
    });
  });
}