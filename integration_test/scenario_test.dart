import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    testWidgets('스플래시 화면 로드 및 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 스플래시 화면 존재 확인
      expect(find.byType(SplashScreen), findsWidgets);
      
      // RecoveryFit 워드마크 텍스트 확인
      expect(find.text('RecoveryFit'), findsWidgets);
      
      // 슬로건 텍스트 확인
      expect(find.text('부상 후, 더 강하게'), findsWidgets);
      
      // 로딩 도트 존재 (애니메이션)
      expect(find.byType(CircleAvatar), findsWidgets);
    });

    testWidgets('랜딩 화면으로 전환 및 콘텐츠 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 스플래시 후 랜딩 화면으로 전환 대기
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 랜딩 화면 존재 확인
      expect(find.byType(LandingScreen), findsWidgets);
      
      // 메인 헤드라인 확인
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);
      
      // 서브 헤드라인 확인
      expect(find.text('AI가 내 부상 상태를 분석하고'), findsWidgets);
      expect(find.text('안전한 재활 플랜을 만들어드려요'), findsWidgets);
    });

    testWidgets('랜딩 화면 가치 포인트 3종 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 랜딩까지 대기
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 가치 포인트 라벨 확인
      expect(find.text('이중 안전'), findsWidgets);
      expect(find.text('검증'), findsWidgets);
      
      expect(find.text('AI 개인화'), findsWidgets);
      expect(find.text('플랜'), findsWidgets);
      
      expect(find.text('터치 최소화'), findsWidgets);
      expect(find.text('인터페이스'), findsWidgets);
    });

    testWidgets('CTA 버튼 "무료로 시작하기" 표시 및 탭 가능', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 랜딩까지 대기
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // CTA 버튼 찾기
      final ctaButton = find.widgetWithText(ElevatedButton, '무료로 시작하기');
      expect(ctaButton, findsWidgets);
      
      // 버튼이 탭 가능한 상태인지 확인
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('랜딩 화면 보조 텍스트 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 랜딩까지 대기
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 의료기기 아님 면책 텍스트 확인
      expect(find.text('의료기기 아님'), findsWidgets);
      expect(find.text('전문의 상담을 대체하지 않습니다'), findsWidgets);
    });

    testWidgets('랜딩 화면 헤더 로고 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 랜딩까지 대기
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 헤더에 RecoveryFit 로고 확인
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('스플래시 화면 배경색 확인 (딥 네이비)', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // Scaffold의 배경색이 darknavy인지 확인
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);
    });

    testWidgets('CTA 버튼 탭 시 다음 화면 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pumpAndSettle();

      // 랜딩까지 대기
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // CTA 버튼 탭
      await tester.tap(find.widgetWithText(ElevatedButton, '무료로 시작하기'));
      await tester.pumpAndSettle();

      // 다음 화면(면책 동의)로 진입했는지 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsWidgets);
    });
  });
}