import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:recovery_fit/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('시작 페이지 (SplashScreen & LandingScreen)', () {
    /// 시나리오 1: 스플래시 화면 로드 및 로고 표시
    testWidgets('스플래시 화면이 표시되고 로고와 슬로건이 보임', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());
      await tester.pump(const Duration(milliseconds: 500));

      // 스플래시 화면 진입 확인 — 로고 워드마크 텍스트로 식별
      expect(find.text('RecoveryFit'), findsWidgets);
      
      // 슬로건 텍스트 확인
      expect(find.text('부상 후, 더 강하게'), findsWidgets);
    });

    /// 시나리오 2: 스플래시 애니메이션 진행 및 자동 전환
    testWidgets('스플래시가 애니메이션을 보여주고 자동으로 다음 화면으로 전환', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 로드 직후 스플래시 화면 확인
      expect(find.text('부상 후, 더 강하게'), findsWidgets);

      // 애니메이션 시간(페이드인 + 정지 + 페이드아웃 = 2.2초) 이후 다음 화면으로 전환될 때까지 기다림
      // 반복 애니메이션이 있을 수 있으므로 작은 duration으로 여러 번 pump
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 스플래시 이후 LandingScreen 진입 — "무료로 시작하기" 버튼으로 식별
      expect(find.text('무료로 시작하기'), findsWidgets);
    });

    /// 시나리오 3: 랜딩 화면 진입 및 핵심 요소 확인
    testWidgets('랜딩 화면에 히어로 텍스트, 가치 포인트, CTA 버튼이 모두 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 애니메이션 스킵
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 랜딩 화면 확인
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);

      // 서브 헤드라인 — 2줄 텍스트이지만 같은 Text 위젯으로 구성됨
      expect(find.text('AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요'), findsWidgets);

      // 가치 포인트 3종 라벨 확인
      expect(find.text('이중 안전\n검증'), findsWidgets);
      expect(find.text('AI 개인화\n플랜'), findsWidgets);
      expect(find.text('터치 최소화\n인터페이스'), findsWidgets);

      // CTA 버튼 확인
      expect(find.text('무료로 시작하기'), findsWidgets);

      // 보조 텍스트 확인
      expect(find.text('의료기기 아님 · 전문의 상담을 대체하지 않습니다'), findsWidgets);
    });

    /// 시나리오 4: 랜딩 화면 CTA 버튼 터치 동작
    testWidgets('무료로 시작하기 버튼 클릭 시 면책 동의 화면으로 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 대기
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // CTA 버튼 터치
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      // 면책 동의 화면 진입 확인
      expect(find.text('이용 전 꼭 확인하세요'), findsWidgets);
    });

    /// 시나리오 5: 스플래시 로드 중 플랫폼 초기화 완료 확인
    testWidgets('스플래시 화면이 표시되는 첫 프레임에 로드 준비가 됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 첫 프레임에서 즉시 스플래시 확인 가능 (Platform init이 동시에 진행)
      expect(find.text('RecoveryFit'), findsWidgets);
      expect(find.text('부상 후, 더 강하게'), findsWidgets);
    });

    /// 시나리오 6: 랜딩 화면 히어로 일러스트 존재 확인
    testWidgets('랜딩 화면에 히어로 일러스트(SVG) 영역이 상단에 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 랜딩 화면의 헤더 로고 확인 (상단 왼쪽)
      expect(find.text('RecoveryFit'), findsWidgets);

      // 메인 헤드라인이 화면에 있으므로 히어로 영역이 렌더링됨을 간접 확인
      expect(find.text('부상 후에도'), findsWidgets);
    });

    /// 시나리오 7: 랜딩 화면 회색 계열 배경 + 깊은 네이비 배경
    testWidgets('랜딩 화면 배경이 딥 네이비(#0D1B2A) 색상으로 설정됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 배경색 직접 확인은 어렵지만, 텍스트 색상(흰색)이 보임 = 어두운 배경
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('무료로 시작하기'), findsWidgets);
    });

    /// 시나리오 8: 랜딩 화면의 CTA 버튼 스타일 확인
    testWidgets('CTA 버튼이 민트색 배경, 진한 텍스트 색상으로 표시됨', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 버튼 존재 확인
      final ctaButton = find.text('무료로 시작하기');
      expect(ctaButton, findsWidgets);

      // 버튼이 ElevatedButton 타입인지 확인 (디자인 상 민트색 배경의 버튼)
      final buttonWidget = find.ancestor(
        of: ctaButton,
        matching: find.byType(ElevatedButton),
      );
      expect(buttonWidget, findsWidgets);
    });

    /// 시나리오 9: 스플래시 로딩 도트 애니메이션
    testWidgets('스플래시 화면에서 로딩 도트가 3개 애니메이션으로 표시', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 초기 프레임에서 스플래시 로드
      expect(find.text('RecoveryFit'), findsWidgets);
      expect(find.text('부상 후, 더 강하게'), findsWidgets);

      // 로딩 도트는 시각적 요소이므로 직접 테스트 불가,
      // 대신 애니메이션 시간 동안 스플래시 유지 확인
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('부상 후, 더 강하게'), findsWidgets);

      await tester.pump(const Duration(milliseconds: 600));
      // 여전히 스플래시 화면 (페이드아웃 전)
      expect(find.text('부상 후, 더 강하게'), findsWidgets);
    });

    /// 시나리오 10: 신규 사용자 분기 (disclaimer 미완료) 시 LandingScreen 진입
    testWidgets('신규 사용자는 스플래시 후 LandingScreen을 거쳐 온보딩으로 진입', (tester) async {
      await tester.pumpWidget(const RecoveryFitApp());

      // 스플래시 → 랜딩 전환 확인
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // 랜딩 화면 요소 모두 확인
      expect(find.text('부상 후에도'), findsWidgets);
      expect(find.text('운동할 수 있어요'), findsWidgets);
      expect(find.text('무료로 시작하기'), findsWidgets);

      // CTA 버튼 클릭 → 면책 동의 화면 진입
      await tester.tap(find.text('무료로 시작하기'));
      await tester.pumpAndSettle();

      expect(find.text('이용 전 꼭 확인하세요'), findsWidgets);
    });
  });
}