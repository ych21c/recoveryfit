

---
## Stage: design

# RecoveryFit Design Specification
## Project: c052dd6b | Stage: design

---

## 1. Design JSON Specification

```json
{
  "screens": [
    {
      "id": "SCR-01",
      "name": "법적 면책 동의",
      "route": "/onboarding/disclaimer",
      "step": 1,
      "description": "의료기기 아님 면책 팝업",
      "components": ["COMP-MODAL-DISCLAIMER", "COMP-BTN-PRIMARY"],
      "flow_next": "SCR-02"
    },
    {
      "id": "SCR-02",
      "name": "부상/통증 입력",
      "route": "/onboarding/injury",
      "step": 1,
      "description": "자유 텍스트 + 예시 칩 버튼",
      "components": ["COMP-TEXT-INPUT", "COMP-CHIP-EXAMPLE", "COMP-BTN-NEXT"],
      "flow_next": "SCR-03"
    },
    {
      "id": "SCR-03",
      "name": "통증 수준 선택",
      "route": "/onboarding/pain-level",
      "step": 1,
      "description": "NTRS 1~10 슬라이더, 기본값 5",
      "components": ["COMP-SLIDER-PAIN", "COMP-CHIP-NUMBER", "COMP-BTN-NEXT"],
      "flow_next": "SCR-04"
    },
    {
      "id": "SCR-04",
      "name": "단기 목표 선택",
      "route": "/onboarding/short-goal",
      "step": 1,
      "description": "단기 목표 칩 선택, 통증 완화 기본 선택",
      "components": ["COMP-CHIP-GOAL", "COMP-BTN-NEXT"],
      "flow_next": "SCR-05"
    },
    {
      "id": "SCR-05",
      "name": "장기 목표 선택",
      "route": "/onboarding/long-goal",
      "step": 1,
      "description": "장기 목표 칩 선택, 스태미나 기본 선택",
      "components": ["COMP-CHIP-GOAL", "COMP-BTN-NEXT"],
      "flow_next": "SCR-06"
    },
    {
      "id": "SCR-06",
      "name": "운동 환경 & 장비 설정",
      "route": "/onboarding/environment",
      "step": 1,
      "description": "빈도/장소/장비 선택, 기본값 주3회/집/맨몸",
      "components": ["COMP-CHIP-FREQ", "COMP-RADIO-LOCATION", "COMP-CHECK-EQUIPMENT", "COMP-BTN-GENERATE"],
      "flow_next": "SCR-07"
    },
    {
      "id": "SCR-07",
      "name": "AI 플랜 생성 중",
      "route": "/plan/generating",
      "step": 2,
      "description": "안전 검증 + 플랜 생성 프로그레스 화면",
      "components": ["COMP-PROGRESS-BAR", "COMP-ANIMATION-LOADING", "COMP-BTN-RETRY"],
      "flow_next": "SCR-08"
    },
    {
      "id": "SCR-08",
      "name": "메인 홈 대시보드",
      "route": "/home",
      "step": 3,
      "description": "오늘의 운동 요약 카드, 진척도 스냅샷",
      "components": ["COMP-CARD-DAILY", "COMP-BTN-BATCH-COMPLETE", "COMP-NAV-BOTTOM"],
      "flow_next": "SCR-09"
    },
    {
      "id": "SCR-09",
      "name": "세션 상세 & 세트 기록",
      "route": "/session/:id",
      "step": "4+5",
      "description": "Pre-fill 데이터 로딩, 세트별 원터치 완료, 퀵 수정",
      "components": ["COMP-SET-ROW", "COMP-CHECKBOX-COMPLETE", "COMP-TIMER-REST", "COMP-OVERLAY-QUICKEDIT", "COMP-BTN-ADD-SET"],
      "flow_next": "SCR-10"
    },
    {
      "id": "SCR-10",
      "name": "세션 종료 & 피드백",
      "route": "/session/:id/complete",
      "step": 6,
      "description": "통증 점수 확인 팝업, 저장 및 종료",
      "components": ["COMP-MODAL-FEEDBACK", "COMP-CHIP-NUMBER", "COMP-BTN-SAVE"],
      "flow_next": "SCR-11"
    },
    {
      "id": "SCR-11",
      "name": "통계 & 진척도 대시보드",
      "route": "/analytics",
      "step": 7,
      "description": "통증 추이, 완료율, 볼륨 그래프",
      "components": ["COMP-GRAPH-PAIN", "COMP-GRAPH-COMPLETION", "COMP-GRAPH-VOLUME", "COMP-TAB-PERIOD"],
      "flow_next": "SCR-12"
    },
    {
      "id": "SCR-12",
      "name": "주간 리포트 & AI 미세조정",
      "route": "/weekly-report",
      "step": 8,
      "description": "주간 AI 조정 내역 카드, 차주 플랜 적용",
      "components": ["COMP-CARD-WEEKLY-REPORT", "COMP-BTN-APPLY-PLAN"],
      "flow_next": "SCR-08"
    }
  ],
  "components": [
    {
      "id": "COMP-MODAL-DISCLAIMER",
      "name": "면책 동의 모달",
      "type": "modal",
      "props": {
        "title": "이용 전 꼭 확인하세요",
        "body": "RecoveryFit은 의료기기가 아닙니다. 전문 의료인의 진단을 대체하지 않으며, 운동 전 반드시 전문의 상담을 권장합니다.",
        "cta": "동의하고 시작"
      },
      "interactions": ["one-tap-dismiss"]
    },
    {
      "id": "COMP-TEXT-INPUT",
      "name": "부상 텍스트 입력창",
      "type": "input",
      "props": {
        "placeholder": "부상이나 통증 부위를 입력해주세요",
        "maxLength": 200
      },
      "interactions": ["keyboard-edit"]
    },
    {
      "id": "COMP-CHIP-EXAMPLE",
      "name": "예시 칩 버튼",
      "type": "chip-group",
      "props": {
        "chips": ["무릎 인대 나갔어요", "허리 디스크 초기", "어깨 회전근개 통증"],
        "mode": "single-fill"
      },
      "interactions": ["one-tap-autofill"]
    },
    {
      "id": "COMP-SLIDER-PAIN",
      "name": "통증 슬라이더",
      "type": "slider",
      "props": {
        "min": 1,
        "max": 10,
        "default": 5,
        "step": 1,
        "showTicks": true
      },
      "interactions": ["drag", "chip-tap"]
    },
    {
      "id": "COMP-CHIP-NUMBER",
      "name": "숫자 칩 버튼",
      "type": "chip-group",
      "props": {
        "chips": [1,2,3,4,5,6,7,8,9,10],
        "mode": "single-select"
      },
      "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-CHIP-GOAL",
      "name": "목표 선택 칩",
      "type": "chip-group",
      "props": {
        "mode": "single-select",
        "defaultSelected": 0
      },
      "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-CHIP-FREQ",
      "name": "주당 빈도 칩",
      "type": "chip-group",
      "props": {
        "chips": ["주 2회", "주 3회", "주 4회", "주 5회"],
        "defaultSelected": 1
      },
      "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-RADIO-LOCATION",
      "name": "운동 장소 라디오",
      "type": "radio-group",
      "props": {
        "options": ["집", "헬스장", "둘 다"],
        "defaultSelected": "집"
      },
      "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-CHECK-EQUIPMENT",
      "name": "장비 복수 체크박스",
      "type": "checkbox-group",
      "props": {
        "options": ["맨몸", "덤벨", "밴드", "철봉"],
        "defaultChecked": ["맨몸"]
      },
      "interactions": ["multi-tap-toggle"]
    },
    {
      "id": "COMP-PROGRESS-BAR",
      "name": "플랜 생성 프로그레스",
      "type": "progress",
      "props": {
        "animated": true,
        "steps": ["부상 데이터 분석", "안전 규칙 검증 (1차)", "안전 규칙 검증 (2차)", "4주 플랜 생성"]
      },
      "interactions": []
    },
    {
      "id": "COMP-CARD-DAILY",
      "name": "일일 운동 요약 카드",
      "type": "card",
      "props": {
        "fields": ["date", "exercises[5]", "completionRate", "estimatedTime"],
        "swipeAction": "skip"
      },
      "interactions": ["tap-enter-session", "swipe-skip", "batch-complete"]
    },
    {
      "id": "COMP-BTN-BATCH-COMPLETE",
      "name": "일괄 완료 버튼",
      "type": "button",
      "props": {
        "label": "오늘의 운동 일괄 완료",
        "variant": "secondary"
      },
      "interactions": ["one-tap-bulk-complete"]
    },
    {
      "id": "COMP-SET-ROW",
      "name": "세트 행 컴포넌트",
      "type": "list-item",
      "props": {
        "fields": ["setNumber", "weight_kg", "reps", "completed"],
        "swipeAction": "delete"
      },
      "interactions": ["swipe-delete", "tap-weight", "tap-reps"]
    },
    {
      "id": "COMP-CHECKBOX-COMPLETE",
      "name": "세트 완료 체크박스",
      "type": "checkbox",
      "props": {
        "size": 44,
        "triggerTimer": true
      },
      "interactions": ["one-tap-complete"]
    },
    {
      "id": "COMP-TIMER-REST",
      "name": "휴식 카운트다운 타이머",
      "type": "timer",
      "props": {
        "defaultSeconds": 60,
        "autoStart": true,
        "dismissOnTap": true
      },
      "interactions": ["tap-dismiss"]
    },
    {
      "id": "COMP-OVERLAY-QUICKEDIT",
      "name": "무게/횟수 퀵 수정 오버레이",
      "type": "bottom-sheet",
      "props": {
        "weightChips": ["-5kg", "-1kg", "+1kg", "+5kg"],
        "repsChips": ["-1회", "+1회"]
      },
      "interactions": ["tap-chip-adjust"]
    },
    {
      "id": "COMP-BTN-ADD-SET",
      "name": "세트 추가 버튼",
      "type": "button",
      "props": {
        "label": "+ 세트 추가",
        "variant": "ghost"
      },
      "interactions": ["one-tap-clone-set"]
    },
    {
      "id": "COMP-MODAL-FEEDBACK",
      "name": "통증 피드백 모달",
      "type": "modal",
      "props": {
        "title": "오늘 통증은 어떠셨나요?",
        "prefillLastScore": true
      },
      "interactions": ["chip-tap-change", "one-tap-save"]
    },
    {
      "id": "COMP-GRAPH-PAIN",
      "name": "통증 추이 선 그래프",
      "type": "line-chart",
      "props": {
        "dataKey": "painScore",
        "period": "7days",
        "tooltip": true
      },
      "interactions": ["tap-datapoint-tooltip", "tab-period-switch"]
    },
    {
      "id": "COMP-GRAPH-COMPLETION",
      "name": "완료율 바 그래프",
      "type": "bar-chart",
      "props": {
        "dataKey": "completionRate",
        "period": "weekly"
      },
      "interactions": []
    },
    {
      "id": "COMP-GRAPH-VOLUME",
      "name": "주간 볼륨 그래프",
      "type": "area-chart",
      "props": {
        "dataKey": "totalVolume",
        "formula": "weight × reps × sets",
        "period": "weekly"
      },
      "interactions": ["tap-datapoint-tooltip"]
    },
    {
      "id": "COMP-TAB-PERIOD",
      "name": "기간 탭",
      "type": "tab-bar",
      "props": {
        "tabs": ["주간", "월간"]
      },
      "interactions": ["one-tap-switch"]
    },
    {
      "id": "COMP-CARD-WEEKLY-REPORT",
      "name": "주간 AI 미세조정 카드",
      "type": "card",
      "props": {
        "fields": ["weekSummary", "painDelta", "volumeDelta", "aiAdjustments"]
      },
      "interactions": []
    },
    {
      "id": "COMP-BTN-APPLY-PLAN",
      "name": "차주 플랜 적용 버튼",
      "type": "button",
      "props": {
        "label": "차주 플랜 적용하기",
        "variant": "primary"
      },
      "interactions": ["one-tap-apply"]
    },
    {
      "id": "COMP-NAV-BOTTOM",
      "name": "하단 네비게이션 바",
      "type": "navigation",
      "props": {
        "tabs": [
          {"icon": "home", "label": "홈", "route": "/home"},
          {"icon": "chart", "label": "통계", "route": "/analytics"},
          {"icon": "settings", "label": "설정", "route": "/settings"}
        ]
      },
      "interactions": ["one-tap-navigate"]
    },
    {
      "id": "COMP-BTN-PRIMARY",
      "name": "기본 CTA 버튼",
      "type": "button",
      "props": {"variant": "primary", "fullWidth": true},
      "interactions": ["one-tap"]
    },
    {
      "id": "COMP-BTN-NEXT",
      "name": "다음 버튼",
      "type": "button",
      "props": {"label": "다음", "variant": "primary", "fullWidth": true},
      "interactions": ["one-tap"]
    },
    {
      "id": "COMP-BTN-RETRY",
      "name": "재시도 버튼",
      "type": "button",
      "props": {"label": "재시도", "variant": "secondary"},
      "interactions": ["one-tap"]
    },
    {
      "id": "COMP-BTN-SAVE",
      "name": "저장 및 종료 버튼",
      "type": "button",
      "props": {"label": "저장 및 종료", "variant": "primary", "fullWidth": true},
      "interactions": ["one-tap"]
    },
    {
      "id": "COMP-ANIMATION-LOADING",
      "name": "플랜 생성 로딩 애니메이션",
      "type": "animation",
      "props": {"type": "pulse", "icon": "dumbbell"},
      "interactions": []
    }
  ],
  "design_tokens": {
    "colors": {
      "primary": "#2E7D6B",
      "primary_light": "#4CAF95",
      "primary_dark": "#1B5E4F",
      "secondary": "#F4A261",
      "secondary_light": "#F7C08A",
      "background": "#F8FAF9",
      "surface": "#FFFFFF",
      "surface_alt": "#F0F4F2",
      "text_primary": "#1A2420",
      "text_secondary": "#5A7068",
      "text_disabled": "#A0B4AE",
      "border": "#D4E0DB",
      "success": "#27AE60",
      "warning": "#F39C12",
      "error": "#E74C3C",
      "pain_low": "#27AE60",
      "pain_mid": "#F39C12",
      "pain_high": "#E74C3C",
      "chip_selected_bg": "#2E7D6B",
      "chip_selected_text": "#FFFFFF",
      "chip_unselected_bg": "#F0F4F2",
      "chip_unselected_text": "#1A2420"
    },
    "typography": {
      "font_family": "'Pretendard', 'Apple SD Gothic Neo', sans-serif",
      "scale": {
        "h1": {"size": "28px", "weight": 700, "line_height": "36px"},
        "h2": {"size": "22px", "weight": 700, "line_height": "30px"},
        "h3": {"size": "18px", "weight": 600, "line_height": "26px"},
        "body1": {"size": "16px", "weight": 400, "line_height": "24px"},
        "body2": {"size": "14px", "weight": 400, "line_height": "22px"},
        "caption": {"size": "12px", "weight": 400, "line_height": "18px"},
        "label": {"size": "14px", "weight": 600, "line_height": "20px"}
      }
    },
    "spacing": {
      "xs": "4px",
      "sm": "8px",
      "md": "16px",
      "lg": "24px",
      "xl": "32px",
      "xxl": "48px"
    },
    "border_radius": {
      "sm": "8px",
      "md": "12px",
      "lg": "16px",
      "xl": "24px",
      "full": "9999px"
    },
    "shadows": {
      "card": "0 2px 12px rgba(0,0,0,0.08)",
      "modal": "0 8px 32px rgba(0,0,0,0.16)",
      "overlay": "0 -4px 20px rgba(0,0,0,0.12)"
    },
    "touch_targets": {
      "min": "44px",
      "recommended": "48px"
    },
    "animation": {
      "duration_fast": "150ms",
      "duration_normal": "250ms",
      "duration_slow": "400ms",
      "easing": "cubic-bezier(0.4, 0, 0.2, 1)"
    }
  }
}
```

---

## SCENARIO:ATM-5

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-5 | 온보딩 - 부상/통증 입력 & 목표 설정</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: 'Apple SD Gothic Neo', sans-serif; background: #F8FAF9; display: flex; justify-content: center; align-items: flex-start; min-height: 100vh; padding: 20px; }
  .phone { width: 390px; background: #fff; border-radius: 40px; box-shadow: 0 20px 60px rgba(0,0,0,0.15); overflow: hidden; border: 2px solid #e0e0e0; }
  .status-bar { background: #2E7D6B; color: white; padding: 12px 24px 8px; display: flex; justify-content: space-between; font-size: 12px; font-weight: 600; }
  .screen { display: none; }
  .screen.active { display: block; }

  /* 온보딩 공통 */
  .onboard-header { background: #2E7D6B; padding: 20px 24px 32px; color: white; }
  .onboard-header .step-indicator { display: flex; gap: 6px; margin-bottom: 16px; }
  .step-dot { width: 28px; height: 4px; border-radius: 2px; background: rgba(255,255,255,0.35); }
  .step-dot.active { background: #fff; }
  .step-dot.done { background: rgba(255,255,255,0.7); }
  .onboard-header h1 { font-size: 22px; font-weight: 700; line-height: 30px; }
  .onboard-header p { font-size: 14px; opacity: 0.85; margin-top: 6px; }
  .onboard-body { padding: 24px; }
  .label { font-size: 13px; font-weight: 600; color: #5A7068; margin-bottom: 10px; letter-spacing: 0.3px; }
  .text-input { width: 100%; border: 1.5px solid #D4E0DB; border-radius: 12px; padding: 14px 16px; font-size: 15px; color: #1A2420; outline: none; background: #F8FAF9; }
  .text-input:focus { border-color: #2E7D6B; background: #fff; }
  .chip-group { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 12px; }
  .chip { padding: 8px 14px; border-radius: 9999px; font-size: 13px; font-weight: 500; border: 1.5px solid #D4E0DB; background: #F0F4F2; color: #1A2420; cursor: pointer; transition: all 150ms; }
  .chip.selected { background: #2E7D6B; color: #fff; border-color: #2E7D6B; }
  .chip.example { font-size: 12px; padding: 7px 12px; }
  .section { margin-bottom: 24px; }
  .btn-primary { width: 100%; padding: 16px; background: #2E7D6B; color: #fff; border: none; border-radius: 14px; font-size: 16px; font-weight: 700; cursor: pointer; margin-top: 8px; }
  .btn-primary:active { background: #1B5E4F; }
  .pain-slider-wrap { margin: 16px 0; }
  .slider { width: 100%; -webkit-appearance: none; height: 6px; border-radius: 3px; background: linear-gradient(to right, #2E7D6B 50%, #D4E0DB 50%); outline: none; }
  .slider::-webkit-slider-thumb { -webkit-appearance: none; width: 28px; height: 28px; border-radius: 50%; background: #2E7D6B; border: 3px solid #fff; box-shadow: 0 2px 8px rgba(0,0,0,0.2); cursor: pointer; }
  .pain-labels { display: flex; justify-content: space-between; font-size: 11px; color: #A0B4AE; margin-top: 6px; }
  .pain-display { text-align: center; font-size: 36px; font-weight: 700; color: #2E7D6B; margin: 8px 0; }
  .pain-badge { font-size: 13px; color: #5A7068; }
  .goal-card { border: 1.5px solid #D4E0DB; border-radius: 14px; padding: 16px; display: flex; align-items: center; gap: 14px; cursor: pointer; margin-bottom: 10px; background: #F8FAF9; }
  .goal-card.selected { border-color: #2E7D6B; background: #EEF7F4; }
  .goal-icon { width: 44px; height: 44px; border-radius: 12px; background: #E0F0EB; display: flex; align-items: center; justify-content: center; font-size: 22px; flex-shrink: 0; }
  .goal-card.selected .goal-icon { background: #2E7D6B; }
  .goal-text h3 { font-size: 15px; font-weight: 600; color: #1A2420; }
  .goal-text p { font-size: 12px; color: #5A7068; margin-top: 2px; }
  .radio-group { display: flex; flex-direction: column; gap: 8px; }
  .radio-item { display: flex; align-items: center; gap: 10px; padding: 12px 16px; border: 1.5px solid #D4E0DB; border-radius: 12px; cursor: pointer; background: #F8FAF9; }
  .radio-item.selected { border-color: #2E7D6B; background: #EEF7F4; }
  .radio-dot { width: 20px; height: 20px; border-radius: 50%; border: 2px solid #D4E0DB; display: flex; align-items: center; justify-content: center; }
  .radio-item.selected .radio-dot { border-color: #2E7D6B; }
  .radio-inner { width: 10px; height: 10px; border-radius: 50%; background: #2E7D6B; display: none; }
  .radio-item.selected .radio-inner { display: block; }
  .check-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  .check-item { display: flex; align-items: center; gap: 8px; padding: 12px 14px; border: 1.5px solid #D4E0DB; border-radius: 12px; cursor: pointer; background: #F8FAF9; font-size: 14px; font-weight: 500; color: #1A2420; }
  .check-item.selected { border-color: #2E7D6B; background: #EEF7F4; color: #2E7D6B; }
  .check-box { width: 20px; height: 20px; border-radius: 6px; border: 2px solid #D4E0DB; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
  .check-item.selected .check-box { background: #2E7D6B; border-color: #2E7D6B; color: white; font-size: 12px; }
  .disclaimer-overlay { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); display: flex; align-items: flex-end; z-index: 100; }
  .disclaimer-sheet { background: #fff; border-radius: 24px 24px 0 0; padding: 28px 24px 40px; width: 100%; }
  .disclaimer-sheet .sheet-handle { width: 36px; height: 4px; background: #D4E0DB; border-radius: 2px; margin: 0 auto 20px; }
  .disclaimer-sheet h2 { font-size: 18px; font-weight: 700; color: #1A2420; margin-bottom: 12px; }
  .disclaimer-sheet p { font-size: 14px; color: #5A7068; line-height: 22px; margin-bottom: 20px; }
  .disclaimer-sheet .warn-box { background: #FFF8F0; border: 1px solid #F4A261; border-radius: 10px; padding: 12px 14px; font-size: 13px; color: #E07B2A; margin-bottom: 20px; }
  .phone-relative { position: relative; }
  .nav-tabs { display: flex; gap: 0; border-bottom: 1px solid #E8EEEC; background: #fff; }
  .nav-tab { flex: 1; padding: 10px; text-align: center; font-size: 12px; color: #A0B4AE; cursor: pointer; border-bottom: 2px solid transparent; }
  .nav-tab.active { color: #2E7D6B; border-bottom-color: #2E7D6B; font-weight: 600; }
  .step-badge { display: inline-block; background: rgba(255,255,255,0.25); border-radius: 9999px; padding: 3px 10px; font-size: 11px; margin-bottom: 10px; }
</style>
</head>
<body>
<div class="phone phone-relative">
  <!-- STATUS BAR -->
  <div class="status-bar">
    <span