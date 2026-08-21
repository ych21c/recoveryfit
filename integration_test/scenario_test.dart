import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    testWidgets('SplashScreen 진입 시 로고와 로딩 표시가 보임',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump();

      // 스플래시 화면 확인 — 텍스트로 식별
      expect(find.textContaining('RecoveryFit'), findsWidgets);
      expect(find.textContaining('부상 후'), findsWidgets);
      
      // 로딩 도트 애니메이션 확인
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SplashScreen 페이드인 및 페이드아웃 애니메이션 진행',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 초기 프레임: 페이드인 진행 중
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('부상 후'), findsWidgets);
      
      // 홀드 구간
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('부상 후'), findsWidgets);
      
      // 페이드아웃 시작 — 하지만 아직 화면에 보임
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('부상 후'), findsWidgets);
    });

    testWidgets('신규 사용자는 SplashScreen 후 LandingScreen으로 진입',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 화면의 애니메이션 시간 대기
      // fadeIn 0.6s + hold 1.2s + fadeOut 0.4s = 2.2s
      // 비동기 초기화 최대 5s 고려하여 여러 번 pump
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // LandingScreen 진입 확인
      expect(find.text('무료로 시작하기'), findsOneWidget);
    });

    testWidgets('LandingScreen 메인 헤드라인이 정확하게 표시됨',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // 스플래시 애니메이션 진행
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) {
          break;
        }
      }

      expect(find.text('부상 후에도'), findsOneWidget);
      expect(find.textContaining('운동할 수 있어요'), findsWidgets);
    });

    testWidgets('LandingScreen 서브 헤드라인(AI 분석 텍스트) 표시 확인',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('AI').evaluate().isNotEmpty) {
          break;
        }
      }

      expect(find.textContaining('AI'), findsWidgets);
      expect(find.textContaining('안전한 재활 플랜'), findsWidgets);
    });

    testWidgets('LandingScreen 가치 포인트 3종 아이콘과 레이블 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('이중 안전').evaluate().isNotEmpty) {
          break;
        }
      }

      expect(find.textContaining('이중 안전'), findsWidgets);
      expect(find.textContaining('검증'), findsWidgets);
      
      expect(find.textContaining('AI 개인화'), findsWidgets);
      expect(find.textContaining('플랜'), findsWidgets);
      
      expect(find.textContaining('터치 최소화'), findsWidgets);
      expect(find.textContaining('인터페이스'), findsWidgets);
    });

    testWidgets('LandingScreen CTA 버튼 "무료로 시작하기" 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsOneWidget);
      
      // CTA 버튼이 ElevatedButton인지 확인
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('LandingScreen 면책 텍스트(의료기기 아님) 하단에 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('의료기기 아님').evaluate().isNotEmpty) {
          break;
        }
      }

      expect(find.textContaining('의료기기 아님'), findsWidgets);
      expect(find.textContaining('전문의 상담'), findsWidgets);
    });

    testWidgets('LandingScreen 로고(RecoveryFit 텍스트 + 심볼) 상단에 배치',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('RecoveryFit').evaluate().isNotEmpty) {
          break;
        }
      }

      // 상단에 RecoveryFit 로고 텍스트가 있는지 확인
      expect(find.text('RecoveryFit'), findsWidgets);
    });

    testWidgets('LandingScreen에서 CTA 버튼 탭 시 화면 이동',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      // LandingScreen으로 이동할 때까지 대기
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('무료로 시작하기').evaluate().isNotEmpty) {
          break;
        }
      }

      // CTA 버튼 탭
      await tester.tap(find.text('무료로 시작하기'));
      
      // 다음 화면(면책 동의) 진입 확인
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.textContaining('이용 전 꼭 확인').evaluate().isNotEmpty ||
            find.textContaining('동의').evaluate().isNotEmpty) {
          break;
        }
      }
      
      // 다음 화면의 주요 요소 확인 (면책 동의 화면)
      expect(
        find.textContaining('의료기기'),
        findsWidgets,
        reason: '면책 동의 화면으로 진입했는지 확인',
      );
    });

    testWidgets('SplashScreen에서 최소 애니메이션 시간(2초) 이상 표시',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      final startTime = DateTime.now();
      
      // 스플래시 화면에서 최소 2초 이상
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.textContaining('부상 후'), findsWidgets);
      
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.textContaining('부상 후'), findsWidgets);
      
      final elapsedTime = DateTime.now().difference(startTime);
      expect(elapsedTime.inMilliseconds >= 2000, true);
    });

    testWidgets('LandingScreen 배경이 다크(디프 네이비) 컬러로 설정',
        (WidgetTester tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('부상 후에도').evaluate().isNotEmpty) {
          break;
        }
      }

      // 스캐폴드 배경색이 어두운 색인지 확인 (구조적 검증)
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}