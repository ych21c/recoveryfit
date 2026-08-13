# UX Designer
Project: c052dd6b | Stage: design

# RecoveryFit Design Specification — c052dd6b

## 1. Design JSON Specification

```json
{
  "screens": [
    {
      "id": "SCR-00", "name": "스플래시 화면", "route": "/splash",
      "step": 0, "components": ["COMP-SPLASH-LOGO", "COMP-SPLASH-TAGLINE", "COMP-SPLASH-LOADER"], "flow_next": "SCR-01"
    },
    {
      "id": "SCR-01", "name": "법적 면책 동의", "route": "/onboarding/disclaimer",
      "step": 1, "components": ["COMP-MODAL-DISCLAIMER", "COMP-BTN-PRIMARY"], "flow_next": "SCR-02"
    },
    {
      "id": "SCR-02", "name": "부상/통증 입력", "route": "/onboarding/injury",
      "step": 1, "components": ["COMP-TEXT-INPUT", "COMP-CHIP-EXAMPLE", "COMP-BTN-NEXT"], "flow_next": "SCR-03"
    },
    {
      "id": "SCR-03", "name": "통증 수준 선택", "route": "/onboarding/pain-level",
      "step": 1, "components": ["COMP-SLIDER-PAIN", "COMP-CHIP-NUMBER", "COMP-BTN-NEXT"], "flow_next": "SCR-04"
    },
    {
      "id": "SCR-04", "name": "단기 목표 선택", "route": "/onboarding/short-goal",
      "step": 1, "components": ["COMP-CHIP-GOAL", "COMP-BTN-NEXT"], "flow_next": "SCR-05"
    },
    {
      "id": "SCR-05", "name": "장기 목표 선택", "route": "/onboarding/long-goal",
      "step": 1, "components": ["COMP-CHIP-GOAL", "COMP-BTN-NEXT"], "flow_next": "SCR-06"
    },
    {
      "id": "SCR-06", "name": "운동 환경 & 장비 설정", "route": "/onboarding/environment",
      "step": 1, "components": ["COMP-CHIP-FREQ", "COMP-RADIO-LOCATION", "COMP-CHECK-EQUIPMENT", "COMP-BTN-GENERATE"], "flow_next": "SCR-07"
    },
    {
      "id": "SCR-07", "name": "AI 플랜 생성 중", "route": "/plan/generating",
      "step": 2, "components": ["COMP-PROGRESS-BAR", "COMP-ANIMATION-LOADING", "COMP-BTN-RETRY"], "flow_next": "SCR-08"
    },
    {
      "id": "SCR-08", "name": "메인 홈 대시보드", "route": "/home",
      "step": 3, "components": ["COMP-CARD-DAILY", "COMP-BTN-BATCH-COMPLETE", "COMP-NAV-BOTTOM"], "flow_next": "SCR-09"
    },
    {
      "id": "SCR-09", "name": "세션 상세 & 세트 기록", "route": "/session/:id",
      "step": "4+5", "components": ["COMP-SET-ROW", "COMP-CHECKBOX-COMPLETE", "COMP-TIMER-REST", "COMP-OVERLAY-QUICKEDIT", "COMP-BTN-ADD-SET"], "flow_next": "SCR-10"
    },
    {
      "id": "SCR-10", "name": "세션 종료 & 피드백", "route": "/session/:id/complete",
      "step": 6, "components": ["COMP-MODAL-FEEDBACK", "COMP-CHIP-NUMBER", "COMP-BTN-SAVE"], "flow_next": "SCR-11"
    },
    {
      "id": "SCR-11", "name": "통계 & 진척도 대시보드", "route": "/analytics",
      "step": 7, "components": ["COMP-GRAPH-PAIN", "COMP-GRAPH-COMPLETION", "COMP-GRAPH-VOLUME", "COMP-TAB-PERIOD"], "flow_next": "SCR-12"
    },
    {
      "id": "SCR-12", "name": "주간 리포트 & AI 미세조정", "route": "/weekly-report",
      "step": 8, "components": ["COMP-CARD-WEEKLY-REPORT", "COMP-BTN-APPLY-PLAN"], "flow_next": "SCR-08"
    }
  ],
  "components": [
    {
      "id": "COMP-SPLASH-LOGO", "name": "스플래시 로고", "type": "image",
      "props": { "icon": "🏃", "appName": "RecoveryFit", "size": "80px" }, "interactions": []
    },
    {
      "id": "COMP-SPLASH-TAGLINE", "name": "스플래시 슬로건", "type": "text",
      "props": { "text": "부상을 딛고, 더 강하게", "style": "caption" }, "interactions": []
    },
    {
      "id": "COMP-SPLASH-LOADER", "name": "스플래시 로딩 인디케이터", "type": "progress",
      "props": { "animated": true, "style": "dots" }, "interactions": []
    },
    {
      "id": "COMP-MODAL-DISCLAIMER", "name": "면책 동의 모달", "type": "modal",
      "props": { "title": "이용 전 꼭 확인하세요", "cta": "동의하고 시작" }, "interactions": ["one-tap-dismiss"]
    },
    {
      "id": "COMP-TEXT-INPUT", "name": "부상 텍스트 입력창", "type": "input",
      "props": { "placeholder": "부상이나 통증 부위를 입력해주세요", "maxLength": 200 }, "interactions": ["keyboard-edit"]
    },
    {
      "id": "COMP-CHIP-EXAMPLE", "name": "예시 칩 버튼", "type": "chip-group",
      "props": { "chips": ["무릎 인대 나갔어요", "허리 디스크 초기", "어깨 회전근개 통증"], "mode": "single-fill" }, "interactions": ["one-tap-autofill"]
    },
    {
      "id": "COMP-SLIDER-PAIN", "name": "통증 슬라이더", "type": "slider",
      "props": { "min": 1, "max": 10, "default": 5, "step": 1 }, "interactions": ["drag", "chip-tap"]
    },
    {
      "id": "COMP-CHIP-NUMBER", "name": "숫자 칩 버튼", "type": "chip-group",
      "props": { "chips": [1,2,3,4,5,6,7,8,9,10], "mode": "single-select" }, "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-CHIP-GOAL", "name": "목표 선택 칩", "type": "chip-group",
      "props": { "mode": "single-select", "defaultSelected": 0 }, "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-CHIP-FREQ", "name": "주당 빈도 칩", "type": "chip-group",
      "props": { "chips": ["주 2회", "주 3회", "주 4회", "주 5회"], "defaultSelected": 1 }, "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-RADIO-LOCATION", "name": "운동 장소 라디오", "type": "radio-group",
      "props": { "options": ["집", "헬스장", "둘 다"], "defaultSelected": "집" }, "interactions": ["one-tap-select"]
    },
    {
      "id": "COMP-CHECK-EQUIPMENT", "name": "장비 복수 체크박스", "type": "checkbox-group",
      "props": { "options": ["맨몸", "덤벨", "밴드", "철봉"], "defaultChecked": ["맨몸"] }, "interactions": ["multi-tap-toggle"]
    },
    {
      "id": "COMP-PROGRESS-BAR", "name": "플랜 생성 프로그레스", "type": "progress",
      "props": { "animated": true, "steps": ["부상 데이터 분석", "안전 규칙 검증 (1차)", "안전 규칙 검증 (2차)", "4주 플랜 생성"] }, "interactions": []
    },
    {
      "id": "COMP-CARD-DAILY", "name": "일일 운동 요약 카드", "type": "card",
      "props": { "fields": ["date", "exercises[5]", "completionRate", "estimatedTime"], "swipeAction": "skip" }, "interactions": ["tap-enter-session", "swipe-skip", "batch-complete"]
    },
    {
      "id": "COMP-SET-ROW", "name": "세트 행 컴포넌트", "type": "list-item",
      "props": { "fields": ["setNumber", "weight_kg", "reps", "completed"], "swipeAction": "delete" }, "interactions": ["swipe-delete", "tap-weight", "tap-reps"]
    },
    {
      "id": "COMP-CHECKBOX-COMPLETE", "name": "세트 완료 체크박스", "type": "checkbox",
      "props": { "size": 44, "triggerTimer": true }, "interactions": ["one-tap-complete"]
    },
    {
      "id": "COMP-TIMER-REST", "name": "휴식 카운트다운 타이머", "type": "timer",
      "props": { "defaultSeconds": 60, "autoStart": true, "dismissOnTap": true }, "interactions": ["tap-dismiss"]
    },
    {
      "id": "COMP-OVERLAY-QUICKEDIT", "name": "무게/횟수 퀵 수정 오버레이", "type": "bottom-sheet",
      "props": { "weightChips": ["-5kg", "-1kg", "+1kg", "+5kg"], "repsChips": ["-1회", "+1회"] }, "interactions": ["tap-chip-adjust"]
    },
    {
      "id": "COMP-BTN-ADD-SET", "name": "세트 추가 버튼", "type": "button",
      "props": { "label": "+ 세트 추가", "variant": "ghost" }, "interactions": ["one-tap-clone-set"]
    },
    {
      "id": "COMP-MODAL-FEEDBACK", "name": "통증 피드백 모달", "type": "modal",
      "props": { "title": "오늘 통증은 어떠셨나요?", "prefillLastScore": true }, "interactions": ["chip-tap-change", "one-tap-save"]
    },
    {
      "id": "COMP-GRAPH-PAIN", "name": "통증 추이 선 그래프", "type": "line-chart",
      "props": { "dataKey": "painScore", "period": "7days", "tooltip": true }, "interactions": ["tap-datapoint-tooltip", "tab-period-switch"]
    },
    {
      "id": "COMP-GRAPH-COMPLETION", "name": "완료율 바 그래프", "type": "bar-chart",
      "props": { "dataKey": "completionRate", "period": "weekly" }, "interactions": []
    },
    {
      "id": "COMP-GRAPH-VOLUME", "name": "주간 볼륨 그래프", "type": "area-chart",
      "props": { "dataKey": "totalVolume", "formula": "weight × reps × sets", "period": "weekly" }, "interactions": ["tap-datapoint-tooltip"]
    },
    {
      "id": "COMP-TAB-PERIOD", "name": "기간 탭", "type": "tab-bar",
      "props": { "tabs": ["주간", "월간"] }, "interactions": ["one-tap-switch"]
    },
    {
      "id": "COMP-CARD-WEEKLY-REPORT", "name": "주간 AI 미세조정 카드", "type": "card",
      "props": { "fields": ["weekSummary", "painDelta", "volumeDelta", "aiAdjustments"] }, "interactions": []
    },
    {
      "id": "COMP-BTN-APPLY-PLAN", "name": "차주 플랜 적용 버튼", "type": "button",
      "props": { "label": "차주 플랜 적용하기", "variant": "primary" }, "interactions": ["one-tap-apply"]
    },
    {
      "id": "COMP-NAV-BOTTOM", "name": "하단 네비게이션 바", "type": "navigation",
      "props": { "tabs": [{"icon":"home","label":"홈","route":"/home"},{"icon":"chart","label":"통계","route":"/analytics"},{"icon":"settings","label":"설정","route":"/settings"}] }, "interactions": ["one-tap-navigate"]
    },
    {
      "id": "COMP-BTN-PRIMARY", "name": "기본 CTA 버튼", "type": "button",
      "props": { "variant": "primary", "fullWidth": true }, "interactions": ["one-tap"]
    },
    {
      "id": "COMP-BTN-NEXT", "name": "다음 버튼", "type": "button",
      "props": { "label": "다음", "variant": "primary", "fullWidth": true }, "interactions": ["one-tap"]
    },
    {
      "id": "COMP-BTN-SAVE", "name": "저장 및 종료 버튼", "type": "button",
      "props": { "label": "저장 및 종료", "variant": "primary", "fullWidth": true }, "interactions": ["one-tap"]
    },
    {
      "id": "COMP-BATCH-COMPLETE", "name": "일괄 완료 버튼", "type": "button",
      "props": { "label": "오늘의 운동 일괄 완료", "variant": "secondary" }, "interactions": ["one-tap-bulk-complete"]
    }
  ],
  "design_tokens": {
    "colors": {
      "primary": "#4F8EF7",
      "primary_light": "#7AAEF9",
      "primary_dark": "#2B6FD9",
      "secondary": "#10B981",
      "accent": "#F59E0B",
      "background": "#F8FAFC",
      "background_gradient_start": "#EFF6FF",
      "background_gradient_end": "#F8FAFC",
      "surface": "#FFFFFF",
      "surface_alt": "#F0F5FF",
      "text_primary": "#0F172A",
      "text_secondary": "#475569",
      "text_disabled": "#94A3B8",
      "border": "#DBEAFE",
      "success": "#10B981",
      "warning": "#F59E0B",
      "error": "#EF4444",
      "pain_low": "#10B981",
      "pain_mid": "#F59E0B",
      "pain_high": "#EF4444",
      "chip_selected_bg": "#4F8EF7",
      "chip_selected_text": "#FFFFFF",
      "chip_unselected_bg": "#EFF6FF",
      "chip_unselected_text": "#0F172A",
      "splash_gradient_start": "#EFF6FF",
      "splash_gradient_end": "#F8FAFC"
    },
    "typography": {
      "font_family": "'Pretendard', 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif",
      "scale": {
        "h1": { "size": "28px", "weight": 800, "line_height": "36px" },
        "h2": { "size": "22px", "weight": 700, "line_height": "30px" },
        "h3": { "size": "18px", "weight": 600, "line_height": "26px" },
        "body1": { "size": "16px", "weight": 400, "line_height": "24px" },
        "body2": { "size": "14px", "weight": 400, "line_height": "22px" },
        "caption": { "size": "12px", "weight": 400, "line_height": "18px" },
        "label": { "size": "13px", "weight": 600, "line_height": "20px" }
      }
    },
    "spacing": {
      "xs": "4px", "sm": "8px", "md": "16px",
      "lg": "24px", "xl": "32px", "xxl": "48px"
    },
    "border_radius": {
      "sm": "8px", "md": "12px", "lg": "16px",
      "xl": "24px", "full": "9999px"
    },
    "shadows": {
      "card": "0 2px 12px rgba(79,142,247,0.08)",
      "modal": "0 8px 32px rgba(0,0,0,0.16)",
      "overlay": "0 -4px 20px rgba(0,0,0,0.12)",
      "splash_logo": "0 16px 48px rgba(79,142,247,0.25)"
    },
    "touch_targets": { "min": "44px", "recommended": "48px" },
    "animation": {
      "duration_fast": "150ms",
      "duration_normal": "250ms",
      "duration_slow": "400ms",
      "easing": "cubic-bezier(0.4, 0, 0.2, 1)",
      "splash_fade_in": "600ms ease-out",
      "splash_logo_scale": "800ms cubic-bezier(0.34,1.56,0.64,1)"
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
<title>ATM-5 | 스플래시 → 면책동의 → 부상입력</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }

  /* ── 공통 폰 프레임 ── */
  .phone{
    width:375px;
    height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22), 0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;
    flex-direction:column;
    position:relative;
    flex-shrink:0;
  }
  .status-bar{
    background:transparent;
    padding:16px 28px 8px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    font-size:11px;
    font-weight:700;
    color:#0F172A;
    flex-shrink:0;
    position:relative;
    z-index:2;
  }
  .status-bar.light{ color:#fff; }
  .screen-tag{
    position:absolute;
    top:0; left:0; right:0;
    background:#1E3A5F;
    color:#93C5FD;
    font-size:9px;
    font-weight:700;
    letter-spacing:1.2px;
    text-align:center;
    padding:5px;
    z-index:10;
  }

  /* ── 스플래시 ── */
  .splash-bg{
    flex:1;
    background:linear-gradient(160deg, #EFF6FF 0%, #DBEAFE 40%, #F8FAFC 100%);
    display:flex;
    flex-direction:column;
    align-items:center;
    justify-content:center;
    padding:0 32px;
    position:relative;
  }
  .splash-rings{
    position:absolute;
    width:260px; height:260px;
    border-radius:50%;
    border:1px solid rgba(79,142,247,0.12);
    top:50%; left:50%;
    transform:translate(-50%,-50%);
  }
  .splash-rings::before{
    content:'';
    position:absolute;
    inset:-40px;
    border-radius:50%;
    border:1px solid rgba(79,142,247,0.07);
  }
  .splash-rings::after{
    content:'';
    position:absolute;
    inset:40px;
    border-radius:50%;
    border:1px solid rgba(79,142,247,0.18);
  }
  .splash-logo-wrap{
    width:100px; height:100px;
    border-radius:28px;
    background:linear-gradient(135deg, #4F8EF7 0%, #2B6FD9 100%);
    box-shadow:0 16px 48px rgba(79,142,247,0.35);
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:52px;
    margin-bottom:28px;
    position:relative;
    z-index:1;
  }
  .splash-app-name{
    font-size:30px;
    font-weight:800;
    color:#0F172A;
    letter-spacing:-0.5px;
    margin-bottom:10px;
    position:relative; z-index:1;
  }
  .splash-app-name span{ color:#4F8EF7; }
  .splash-tagline{
    font-size:14px;
    color:#475569;
    letter-spacing:0.3px;
    margin-bottom:52px;
    position:relative; z-index:1;
  }
  .splash-dots{
    display:flex; gap:8px;
    position:relative; z-index:1;
  }
  .splash-dot{
    width:8px; height:8px;
    border-radius:50%;
    background:#BFDBFE;
  }
  .splash-dot.active{
    background:#4F8EF7;
    width:24px;
    border-radius:4px;
  }
  .splash-version{
    position:absolute;
    bottom:28px;
    font-size:11px;
    color:#94A3B8;
    z-index:1;
  }

  /* ── 온보딩 공통 ── */
  .ob-header{
    background:linear-gradient(135deg, #4F8EF7 0%, #2B6FD9 100%);
    padding:20px 24px 28px;
    color:#fff;
    flex-shrink:0;
  }
  .step-pips{
    display:flex; gap:6px;
    margin-bottom:16px;
  }
  .pip{
    height:4px; border-radius:2px;
    background:rgba(255,255,255,0.25);
    flex:1;
  }
  .pip.done{ background:rgba(255,255,255,0.65); }
  .pip.active{ background:#fff; }
  .ob-step-badge{
    display:inline-block;
    background:rgba(255,255,255,0.2);
    border-radius:99px;
    padding:4px 12px;
    font-size:11px;
    font-weight:700;
    margin-bottom:10px;
  }
  .ob-title{
    font-size:22px;
    font-weight:800;
    line-height:30px;
    margin-bottom:6px;
  }
  .ob-desc{
    font-size:13px;
    opacity:.8;
    line-height:19px;
  }
  .ob-body{
    flex:1;
    padding:22px 20px;
    overflow-y:auto;
  }
  .field-label{
    font-size:11px;
    font-weight:700;
    color:#475569;
    letter-spacing:.8px;
    text-transform:uppercase;
    margin-bottom:10px;
  }
  .ob-footer{
    padding:16px 20px 32px;
    background:#F8FAFC;
    border-top:1px solid #EFF6FF;
    flex-shrink:0;
  }

  /* ── 버튼 ── */
  .btn-primary{
    width:100%;
    padding:16px;
    background:linear-gradient(135deg, #4F8EF7, #2B6FD9);
    color:#fff;
    border:none;
    border-radius:16px;
    font-size:16px;
    font-weight:700;
    cursor:pointer;
    box-shadow:0 4px 16px rgba(79,142,247,0.35);
  }
  .btn-ghost{
    width:100%;
    padding:14px;
    background:transparent;
    color:#475569;
    border:1.5px solid #DBEAFE;
    border-radius:16px;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
    margin-top:8px;
  }

  /* ── 텍스트 인풋 ── */
  .txt-input{
    width:100%;
    border:1.5px solid #DBEAFE;
    border-radius:14px;
    padding:14px 16px;
    font-size:14px;
    color:#0F172A;
    background:#fff;
    outline:none;
    margin-bottom:16px;
    resize:none;
    line-height:22px;
  }
  .txt-input.filled{ border-color:#4F8EF7; }

  /* ── 칩 ── */
  .chips{ display:flex; flex-wrap:wrap; gap:8px; margin-bottom:20px; }
  .chip{
    padding:9px 16px;
    border-radius:99px;
    font-size:12px;
    font-weight:600;
    border:1.5px solid #DBEAFE;
    background:#EFF6FF;
    color:#0F172A;
    cursor:pointer;
  }
  .chip.selected{
    background:#4F8EF7;
    color:#fff;
    border-color:#4F8EF7;
  }
  .chip.example{
    background:#F0F9FF;
    border-color:#BAE6FD;
    color:#0369A1;
  }
  .chip.example.selected{
    background:#4F8EF7;
    color:#fff;
    border-color:#4F8EF7;
  }

  /* ── 면책 시트 ── */
  .disc-fullscreen{
    flex:1;
    background:linear-gradient(160deg, #EFF6FF 0%, #F8FAFC 100%);
    display:flex;
    flex-direction:column;
    align-items:center;
    justify-content:flex-end;
  }
  .disc-sheet{
    background:#fff;
    border-radius:28px 28px 0 0;
    padding:28px 24px 36px;
    width:100%;
    box-shadow:0 -4px 24px rgba(0,0,0,0.1);
  }
  .sheet-handle{
    width:40px; height:4px;
    border-radius:2px;
    background:#DBEAFE;
    margin:0 auto 24px;
  }
  .disc-icon-wrap{
    width:60px; height:60px;
    border-radius:18px;
    background:linear-gradient(135deg, #EFF6FF, #DBEAFE);
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:30px;
    margin-bottom:16px;
    border:1.5px solid #BFDBFE;
  }
  .disc-title{
    font-size:20px;
    font-weight:800;
    color:#0F172A;
    margin-bottom:10px;
  }
  .disc-body{
    font-size:13px;
    color:#475569;
    line-height:21px;
    margin-bottom:14px;
  }
  .warn-box{
    background:#FFFBEB;
    border:1.5px solid #FCD34D;
    border-radius:12px;
    padding:12px 14px;
    font-size:12px;
    color:#92400E;
    margin-bottom:24px;
    line-height:19px;
  }

  /* ── 팁 박스 ── */
  .tip-box{
    background:#EFF6FF;
    border-radius:12px;
    padding:14px;
    border-left:3px solid #4F8EF7;
  }
  .tip-box .tip-title{
    font-size:12px;
    color:#4F8EF7;
    font-weight:700;
    margin-bottom:4px;
  }
  .tip-box .tip-body{
    font-size:12px;
    color:#475569;
    line-height:19px;
  }

  /* ── 라벨 텍스트 ── */
  .hint-text{
    font-size:11px;
    color:#94A3B8;
    text-align:center;
    margin-top:10px;
  }
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 스플래시 화면 (SCR-00)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-00 · 스플래시 화면 — RecoveryFit 브랜드 런치 스크린</div>
  <div class="status-bar" style="color:#0F172A;">
    <span>9:41</span>
    <span style="display:flex;gap:4px;align-items:center;">
      <span>●●●</span>
      <span>WiFi</span>
      <span>🔋</span>
    </span>
  </div>
  <div class="splash-bg">
    <div class="splash-rings"></div>
    <div class="splash-logo-wrap">🏃</div>
    <div class="splash-app-name">Recovery<span>Fit</span></div>
    <div class="splash-tagline">부상을 딛고, 더 강하게</div>
    <div class="splash-dots">
      <div class="splash-dot"></div>
      <div class="splash-dot active"></div>
      <div class="splash-dot"></div>
    </div>
    <div class="splash-version">v1.1.0 · AI 기반 재활 운동 플래너</div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: 법적 면책 동의 (SCR-01)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-01 · 법적 면책 동의 — Step 1.1 (최초 1회)</div>
  <div class="status-bar" style="color:#0F172A;">
    <span>9:42</span>
    <span>●●● WiFi 🔋</span>
  </div>

  <!-- 배경: 상단에 앱 브랜딩 -->
  <div class="disc-fullscreen">
    <div style="
      flex:1;
      display:flex;
      flex-direction:column;
      align-items:center;
      justify-content:center;
      padding:0 32px;
    ">
      <div style="
        width:72px; height:72px;
        border-radius:22px;
        background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
        box-shadow:0 12px 36px rgba(79,142,247,0.3);
        display:flex;
        align-items:center;
        justify-content:center;
        font-size:38px;
        margin-bottom:16px;
      ">🏃</div>
      <div style="font-size:22px;font-weight:800;color:#0F172A;margin-bottom:6px;">RecoveryFit</div>
      <div style="font-size:13px;color:#475569;">AI 기반 재활 운동 플래너</div>
    </div>

    <div class="disc-sheet">
      <div class="sheet-handle"></div>
      <div class="disc-icon-wrap">⚕️</div>
      <div class="disc-title">이용 전 꼭 확인하세요</div>
      <div class="disc-body">
        RecoveryFit은 <strong>의료기기가 아닙니다.</strong><br>
        전문 의료인의 진단을 대체하지 않으며, 제공되는 운동 플랜은 일반적인 재활 가이드라인을 참고로 생성됩니다.
      </div>
      <div class="warn-box">
        ⚠️ 급성 통증·골절·수술 직후 회복 중인 경우<br>
        반드시 <strong>전문의와 상담</strong> 후 이용하세요.
      </div>
      <button class="btn-primary">동의하고 시작</button>
      <button class="btn-ghost">자세히 읽기</button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 3: 부상/통증 입력 (SCR-02)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-02 · 부상/통증 자유 텍스트 입력 — Step 1.2</div>
  <div class="status-bar light" style="
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  ">
    <span>9:43</span>
    <span>●●● WiFi 🔋</span>
  </div>

  <div class="ob-header">
    <div class="step-pips">
      <div class="pip done"></div>
      <div class="pip active"></div>
      <div class="pip"></div>
      <div class="pip"></div>
      <div class="pip"></div>
      <div class="pip"></div>
    </div>
    <div class="ob-step-badge">단계 1 / 6</div>
    <div class="ob-title">어디가 불편하신가요?</div>
    <div class="ob-desc">부상 부위나 통증 상황을 자유롭게 알려주세요</div>
  </div>

  <div class="ob-body">
    <div class="field-label">부상 · 통증 설명</div>
    <textarea
      class="txt-input filled"
      rows="3"
      placeholder="예: 무릎 인대를 다쳤어요, 3주 됐어요"
    >무릎 인대 나갔어요</textarea>

    <div class="field-label">빠른 선택 예시</div>
    <div class="chips">
      <span class="chip example selected">무릎 인대 나갔어요</span>
      <span class="chip example">허리 디스크 초기</span>
      <span class="chip example">어깨 회전근개 통증</span>
    </div>

    <div class="tip-box">
      <div class="tip-title">💡 원터치 자동완성</div>
      <div class="tip-body">
        예시 칩을 탭하면 입력창에 즉시 채워집니다.<br>
        내용을 직접 수정하거나 키보드로 새로 입력해도 됩니다.
      </div>
    </div>
  </div>

  <div class="ob-footer">
    <button class="btn-primary">다음</button>
    <div class="hint-text">최소 5자 이상 입력 시 다음 단계 활성화</div>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-6

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-6 | 통증수준 → 단기목표 → 장기목표</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px;
    height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;
    flex-direction:column;
    position:relative;
    flex-shrink:0;
  }
  .screen-tag{
    position:absolute;
    top:0;left:0;right:0;
    background:#1E3A5F;
    color:#93C5FD;
    font-size:9px;
    font-weight:700;
    letter-spacing:1.2px;
    text-align:center;
    padding:5px;
    z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;
    justify-content:space-between;
    font-size:11px;
    font-weight:700;
    color:#fff;
    flex-shrink:0;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  }
  .ob-header{
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    padding:4px 24px 28px;
    color:#fff;
    flex-shrink:0;
  }
  .step-pips{display:flex;gap:6px;margin-bottom:16px;}
  .pip{height:4px;border-radius:2px;background:rgba(255,255,255,.25);flex:1;}
  .pip.done{background:rgba(255,255,255,.65);}
  .pip.active{background:#fff;}
  .ob-step-badge{
    display:inline-block;
    background:rgba(255,255,255,.2);
    border-radius:99px;
    padding:4px 12px;
    font-size:11px;font-weight:700;
    margin-bottom:10px;
  }
  .ob-title{font-size:21px;font-weight:800;line-height:29px;margin-bottom:6px;}
  .ob-desc{font-size:13px;opacity:.8;line-height:19px;}
  .ob-body{flex:1;padding:20px;overflow-y:auto;}
  .field-label{
    font-size:11px;font-weight:700;
    color:#475569;
    letter-spacing:.8px;
    text-transform:uppercase;
    margin-bottom:10px;
  }
  .ob-footer{
    padding:14px 20px 30px;
    background:#F8FAFC;
    border-top:1px solid #EFF6FF;
    flex-shrink:0;
  }
  .btn-primary{
    width:100%;padding:16px;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    color:#fff;border:none;border-radius:16px;
    font-size:16px;font-weight:700;cursor:pointer;
    box-shadow:0 4px 16px rgba(79,142,247,.35);
  }

  /* ── 통증 슬라이더 화면 ── */
  .pain-display{
    text-align:center;
    margin:8px 0 20px;
  }
  .pain-number{
    font-size:64px;
    font-weight:900;
    color:#F59E0B;
    line-height:1;
  }
  .pain-label{
    font-size:14px;
    color:#475569;
    margin-top:6px;
    font-weight:600;
  }
  .slider-track{
    position:relative;
    margin-bottom:6px;
  }
  input[type=range]{
    width:100%;
    -webkit-appearance:none;
    height:10px;
    border-radius:5px;
    outline:none;
    background:linear-gradient(
      to right,
      #10B981 0%, #10B981 20%,
      #F59E0B 20%, #F59E0B 50%,
      #EF4444 50%, #EF4444 100%
    );
    cursor:pointer;
  }
  input[type=range]::-webkit-slider-thumb{
    -webkit-appearance:none;
    width:32px;height:32px;
    border-radius:50%;
    background:#F59E0B;
    border:3px solid #fff;
    box-shadow:0 2px 10px rgba(0,0,0,.2);
    cursor:pointer;
  }
  .pain-scale-labels{
    display:flex;
    justify-content:space-between;
    font-size:10px;
    color:#94A3B8;
    margin-top:4px;
    padding:0 4px;
  }
  .num-chips{
    display:flex;
    gap:5px;
    flex-wrap:wrap;
    margin-top:16px;
    margin-bottom:16px;
  }
  .num-chip{
    flex:1; min-width:28px;
    padding:9px 4px;
    text-align:center;
    border-radius:10px;
    font-size:13px;
    font-weight:700;
    border:1.5px solid #DBEAFE;
    background:#EFF6FF;
    color:#0F172A;
    cursor:pointer;
  }
  .num-chip.selected{
    box-shadow:0 0 0 2px #F59E0B;
    border-color:#F59E0B;
    background:#FFFBEB;
    color:#92400E;
  }
  .pain-legend{
    display:flex;
    justify-content:space-between;
    font-size:11px;
    font-weight:600;
    margin-bottom:14px;
  }
  .default-note{
    background:#EFF6FF;
    border-radius:12px;
    padding:12px 14px;
    border-left:3px solid #4F8EF7;
    font-size:12px;
    color:#475569;
  }
  .default-note strong{color:#4F8EF7;}

  /* ── 목표 카드 ── */
  .goal-card{
    display:flex;
    align-items:center;
    gap:14px;
    padding:16px;
    border:1.5px solid #DBEAFE;
    border-radius:16px;
    margin-bottom:10px;
    cursor:pointer;
    background:#fff;
    transition:all .15s;
  }
  .goal-card.selected{
    border-color:#4F8EF7;
    background:#EFF6FF;
    box-shadow:0 0 0 2px rgba(79,142,247,.15);
  }
  .goal-icon-wrap{
    width:50px;height:50px;
    border-radius:14px;
    background:#EFF6FF;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:26px;
    flex-shrink:0;
  }
  .goal-card.selected .goal-icon-wrap{
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  }
  .goal-text{ flex:1; }
  .goal-name{
    font-size:15px;
    font-weight:700;
    color:#0F172A;
  }
  .goal-desc{
    font-size:12px;
    color:#475569;
    margin-top:3px;
    line-height:17px;
  }
  .radio-circle{
    width:22px;height:22px;
    border-radius:50%;
    border:2px solid #DBEAFE;
    display:flex;
    align-items:center;
    justify-content:center;
    flex-shrink:0;
  }
  .goal-card.selected .radio-circle{border-color:#4F8EF7;}
  .radio-dot{
    width:11px;height:11px;
    border-radius:50%;
    background:#4F8EF7;
    display:none;
  }
  .goal-card.selected .radio-dot{display:block;}

  .default-chip-note{
    background:#EFF6FF;
    border-radius:10px;
    padding:10px 14px;
    font-size:12px;
    color:#2B6FD9;
    font-weight:600;
    margin-top:2px;
  }
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 통증 수준 선택 (SCR-03)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-03 · 통증 수준 선택 (NRS 1-10) — Step 1.3</div>
  <div class="status-bar">
    <span>9:44</span><span>●●● WiFi 🔋</span>
  </div>
  <div class="ob-header">
    <div class="step-pips">
      <div class="pip done"></div><div class="pip done"></div>
      <div class="pip active"></div>
      <div class="pip"></div><div class="pip"></div><div class="pip"></div>
    </div>
    <div class="ob-step-badge">단계 2 / 6</div>
    <div class="ob-title">지금 통증이 얼마나<br>심한가요?</div>
    <div class="ob-desc">NRS 척도로 현재 통증 강도를 알려주세요</div>
  </div>

  <div class="ob-body">
    <div class="pain-display">
      <div class="pain-number">5</div>
      <div class="pain-label">⚡ 중등도 — 활동 시 불편하지만 참을 수 있음</div>
    </div>

    <div class="slider-track">
      <input type="range" min="1" max="10" value="5">
      <div class="pain-scale-labels">
        <span>1 · 없음</span>
        <span>5 · 중등도</span>
        <span>10 · 극심</span>
      </div>
    </div>

    <div class="field-label" style="margin-top:18px;">숫자로 직접 선택</div>
    <div class="num-chips">
      <div class="num-chip" style="background:#D1FAE5;border-color:#6EE7B7;color:#065F46;">1</div>
      <div class="num-chip" style="background:#D1FAE5;border-color:#6EE7B7;color:#065F46;">2</div>
      <div class="num-chip" style="background:#D1FAE5;border-color:#6EE7B7;color:#065F46;">3</div>
      <div class="num-chip" style="background:#FEF9C3;border-color:#FDE047;color:#713F12;">4</div>
      <div class="num-chip selected">5</div>
      <div class="num-chip" style="background:#FEF9C3;border-color:#FDE047;color:#713F12;">6</div>
      <div class="num-chip" style="background:#FED7AA;border-color:#FB923C;color:#7C2D12;">7</div>
      <div class="num-chip" style="background:#FECACA;border-color:#F87171;color:#7F1D1D;">8</div>
      <div class="num-chip" style="background:#FECACA;border-color:#F87171;color:#7F1D1D;">9</div>
      <div class="num-chip" style="background:#FCA5A5;border-color:#EF4444;color:#7F1D1D;">10</div>
    </div>

    <div class="pain-legend">
      <span style="color:#10B981;">🟢 경미 (1-3)</span>
      <span style="color:#F59E0B;">🟡 중등도 (4-6)</span>
      <span style="color:#EF4444;">🔴 심함 (7-10)</span>
    </div>

    <div class="default-note">
      <strong>기본값 5점</strong>이 선택되어 있습니다.<br>
      변화가 없다면 바로 '다음'을 눌러 원터치로 통과하세요.
    </div>
  </div>

  <div class="ob-footer">
    <button class="btn-primary">다음</button>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: 단기 목표 선택 (SCR-04)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-04 · 단기 목표 선택 — Step 1.4</div>
  <div class="status-bar">
    <span>9:45</span><span>●●● WiFi 🔋</span>
  </div>
  <div class="ob-header">
    <div class="step-pips">
      <div class="pip done"></div><div class="pip done"></div>
      <div class="pip done"></div><div class="pip active"></div>
      <div class="pip"></div><div class="pip"></div>
    </div>
    <div class="ob-step-badge">단계 3 / 6</div>
    <div class="ob-title">지금 당장 원하는<br>변화는 뭔가요?</div>
    <div class="ob-desc">단기 목표 1개를 선택해주세요</div>
  </div>

  <div class="ob-body">
    <div class="goal-card selected">
      <div class="goal-icon-wrap">🩹</div>
      <div class="goal-text">
        <div class="goal-name">통증 완화</div>
        <div class="goal-desc">현재 통증을 줄이고 일상 생활을 편안하게</div>
      </div>
      <div class="radio-circle"><div class="radio-dot"></div></div>
    </div>

    <div class="goal-card">
      <div class="goal-icon-wrap">🦵</div>
      <div class="goal-text">
        <div class="goal-name">관절 가동성 회복</div>
        <div class="goal-desc">굳어진 관절 범위를 정상으로 되돌리기</div>
      </div>
      <div class="radio-circle"><div class="radio-dot"></div></div>
    </div>

    <div class="goal-card">
      <div class="goal-icon-wrap">🔄</div>
      <div class="goal-text">
        <div class="goal-name">부상 재활</div>
        <div class="goal-desc">단계적 재활로 부상 부위 기능 완전 회복</div>
      </div>
      <div class="radio-circle"><div class="radio-dot"></div></div>
    </div>

    <div class="default-chip-note">
      ✅ <strong>통증 완화</strong>가 기본 선택됩니다.<br>
      다른 목표 카드를 탭하면 즉시 변경됩니다.
    </div>
  </div>

  <div class="ob-footer">
    <button class="btn-primary">다음</button>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 3: 장기 목표 선택 (SCR-05)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-05 · 장기 목표 선택 — Step 1.5</div>
  <div class="status-bar">
    <span>9:46</span><span>●●● WiFi 🔋</span>
  </div>
  <div class="ob-header">
    <div class="step-pips">
      <div class="pip done"></div><div class="pip done"></div>
      <div class="pip done"></div><div class="pip done"></div>
      <div class="pip active"></div><div class="pip"></div>
    </div>
    <div class="ob-step-badge">단계 4 / 6</div>
    <div class="ob-title">궁극적으로 원하는<br>변화는 무엇인가요?</div>
    <div class="ob-desc">장기 목표 1개를 선택해주세요</div>
  </div>

  <div class="ob-body">
    <div class="goal-card selected">
      <div class="goal-icon-wrap">⚡</div>
      <div class="goal-text">
        <div class="goal-name">스태미나 / 체력 향상</div>
        <div class="goal-desc">오래 걷고 뛰어도 지치지 않는 체력 만들기</div>
      </div>
      <div class="radio-circle"><div class="radio-dot"></div></div>
    </div>

    <div class="goal-card">
      <div class="goal-icon-wrap">💪</div>
      <div class="goal-text">
        <div class="goal-name">근육량 증가</div>
        <div class="goal-desc">안전하게 근력을 키우고 체형 개선하기</div>
      </div>
      <div class="radio-circle"><div class="radio-dot"></div></div>
    </div>

    <div class="goal-card">
      <div class="goal-icon-wrap">⚖️</div>
      <div class="goal-text">
        <div class="goal-name">체중 감량</div>
        <div class="goal-desc">부상 없이 칼로리 소모, 체중 관리하기</div>
      </div>
      <div class="radio-circle"><div class="radio-dot"></div></div>
    </div>

    <div class="default-chip-note">
      ✅ <strong>스태미나 / 체력 향상</strong>이 기본 선택됩니다.<br>
      다른 목표 카드를 탭하면 즉시 변경됩니다.
    </div>
  </div>

  <div class="ob-footer">
    <button class="btn-primary">다음</button>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-7

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-7 | 운동환경 설정 → AI 플랜 생성</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px; height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;
    flex-direction:column;
    position:relative;
    flex-shrink:0;
  }
  .screen-tag{
    position:absolute;
    top:0;left:0;right:0;
    background:#1E3A5F;color:#93C5FD;
    font-size:9px;font-weight:700;
    letter-spacing:1.2px;
    text-align:center;padding:5px;
    z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:700;
    color:#fff;flex-shrink:0;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  }
  .ob-header{
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    padding:4px 24px 28px;color:#fff;flex-shrink:0;
  }
  .step-pips{display:flex;gap:6px;margin-bottom:16px;}
  .pip{height:4px;border-radius:2px;background:rgba(255,255,255,.25);flex:1;}
  .pip.done{background:rgba(255,255,255,.65);}
  .pip.active{background:#fff;}
  .ob-step-badge{
    display:inline-block;
    background:rgba(255,255,255,.2);
    border-radius:99px;
    padding:4px 12px;font-size:11px;font-weight:700;margin-bottom:10px;
  }
  .ob-title{font-size:21px;font-weight:800;line-height:29px;margin-bottom:6px;}
  .ob-desc{font-size:13px;opacity:.8;line-height:19px;}
  .ob-body{flex:1;padding:20px;overflow-y:auto;}
  .section-label{
    font-size:11px;font-weight:700;
    color:#475569;letter-spacing:.8px;
    text-transform:uppercase;margin-bottom:10px;
  }
  .ob-footer{
    padding:14px 20px 30px;
    background:#F8FAFC;border-top:1px solid #EFF6FF;flex-shrink:0;
  }
  .btn-generate{
    width:100%;padding:16px;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    color:#fff;border:none;border-radius:16px;
    font-size:16px;font-weight:700;cursor:pointer;
    box-shadow:0 4px 16px rgba(79,142,247,.35);
    display:flex;align-items:center;justify-content:center;gap:8px;
  }

  /* 칩 */
  .chip-row{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px;}
  .chip{
    padding:10px 18px;
    border-radius:99px;font-size:13px;font-weight:600;
    border:1.5px solid #DBEAFE;background:#EFF6FF;color:#0F172A;cursor:pointer;
  }
  .chip.sel{background:#4F8EF7;color:#fff;border-color:#4F8EF7;}

  /* 라디오 */
  .radio-list{display:flex;flex-direction:column;gap:8px;margin-bottom:20px;}
  .radio-item{
    display:flex;align-items:center;gap:12px;
    padding:13px 16px;
    border:1.5px solid #DBEAFE;border-radius:14px;
    cursor:pointer;background:#fff;
  }
  .radio-item.sel{border-color:#4F8EF7;background:#EFF6FF;}
  .r-circle{
    width:22px;height:22px;border-radius:50%;
    border:2px solid #DBEAFE;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
  }
  .radio-item.sel .r-circle{border-color:#4F8EF7;}
  .r-dot{width:11px;height:11px;border-radius:50%;background:#4F8EF7;display:none;}
  .radio-item.sel .r-dot{display:block;}
  .radio-item span{font-size:14px;font-weight:600;color:#0F172A;}

  /* 체크박스 그리드 */
  .check-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:20px;}
  .check-item{
    display:flex;align-items:center;gap:8px;
    padding:13px 14px;
    border:1.5px solid #DBEAFE;border-radius:14px;
    cursor:pointer;background:#fff;
    font-size:14px;font-weight:600;color:#0F172A;
  }
  .check-item.sel{border-color:#4F8EF7;background:#EFF6FF;color:#2B6FD9;}
  .check-box{
    width:22px;height:22px;border-radius:6px;
    border:2px solid #DBEAFE;
    display:flex;align-items:center;justify-content:center;
    font-size:12px;color:#fff;flex-shrink:0;
  }
  .check-item.sel .check-box{background:#4F8EF7;border-color:#4F8EF7;}

  /* ── 플랜 생성 화면 ── */
  .gen-body{
    flex:1;
    display:flex;flex-direction:column;
    align-items:center;justify-content:center;
    padding:32px 24px;
    background:#F8FAFC;
  }
  .gen-logo{
    width:88px;height:88px;
    border-radius:26px;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    box-shadow:0 12px 36px rgba(79,142,247,.35);
    display:flex;align-items:center;justify-content:center;
    font-size:44px;margin-bottom:24px;
  }
  .gen-title{font-size:21px;font-weight:800;color:#0F172A;margin-bottom:8px;text-align:center;}
  .gen-sub{font-size:13px;color:#475569;text-align:center;line-height:20px;margin-bottom:32px;}
  .progress-steps{width:100%;margin-bottom:28px;}
  .p-step{
    display:flex;align-items:center;gap:12px;
    padding:12px 14px;
    border-radius:14px;margin-bottom:8px;
    border:1.5px solid #DBEAFE;background:#fff;
  }
  .p-step.done{background:#EFF6FF;border-color:#4F8EF7;}
  .p-step.active{background:#fff;border-color:#F59E0B;box-shadow:0 2px 12px rgba(245,158,11,.2);}
  .p-icon-wrap{
    width:34px;height:34px;border-radius:50%;
    background:#DBEAFE;
    display:flex;align-items:center;justify-content:center;
    font-size:15px;flex-shrink:0;
  }
  .p-step.done .p-icon-wrap{background:#4F8EF7;color:#fff;}
  .p-step.active .p-icon-wrap{background:#F59E0B;color:#fff;}
  .p-info{flex:1;}
  .p-name{font-size:13px;font-weight:700;color:#0F172A;}
  .p-step.done .p-name{color:#2B6FD9;}
  .p-detail{font-size:11px;color:#475569;margin-top:2px;}
  .p-badge{font-size:11px;font-weight:700;}
  .p-badge.done{color:#4F8EF7;}
  .p-badge.active{color:#F59E0B;}
  .p-badge.wait{color:#94A3B8;}
  .prog-bar-wrap{width:100%;}
  .prog-bar-bg{
    width:100%;height:8px;
    background:#DBEAFE;border-radius:4px;
    overflow:hidden;margin-bottom:6px;
  }
  .prog-bar-fill{
    height:100%;width:65%;
    background:linear-gradient(90deg,#4F8EF7,#7AAEF9);
    border-radius:4px;
  }
  .prog-pct{
    text-align:right;font-size:12px;
    color:#4F8EF7;font-weight:700;
  }
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 운동 환경 & 장비 설정 (SCR-06)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-06 · 운동 환경 & 장비 설정 — Step 1.6 (마지막 온보딩 단계)</div>
  <div class="status-bar"><span>9:47</span><span>●●● WiFi 🔋</span></div>
  <div class="ob-header">
    <div class="step-pips">
      <div class="pip done"></div><div class="pip done"></div>
      <div class="pip done"></div><div class="pip done"></div>
      <div class="pip done"></div><div class="pip active"></div>
    </div>
    <div class="ob-step-badge">단계 5 / 6</div>
    <div class="ob-title">운동 환경을<br>알려주세요</div>
    <div class="ob-desc">기본값 그대로 바로 플랜 생성도 가능합니다 ✨</div>
  </div>

  <div class="ob-body">
    <div class="section-label">주당 운동 빈도</div>
    <div class="chip-row">
      <span class="chip">주 2회</span>
      <span class="chip sel">주 3회</span>
      <span class="chip">주 4회</span>
      <span class="chip">주 5회</span>
    </div>

    <div class="section-label">운동 장소</div>
    <div class="radio-list">
      <div class="radio-item sel">
        <div class="r-circle"><div class="r-dot"></div></div>
        <span>🏠 집</span>
      </div>
      <div class="radio-item">
        <div class="r-circle"><div class="r-dot"></div></div>
        <span>🏋️ 헬스장</span>
      </div>
      <div class="radio-item">
        <div class="r-circle"><div class="r-dot"></div></div>
        <span>🔄 집 + 헬스장 둘 다</span>
      </div>
    </div>

    <div class="section-label">보유 장비 (복수 선택 가능)</div>
    <div class="check-grid">
      <div class="check-item sel">
        <div class="check-box">✓</div>맨몸
      </div>
      <div class="check-item">
        <div class="check-box"></div>덤벨
      </div>
      <div class="check-item">
        <div class="check-box"></div>밴드
      </div>
      <div class="check-item">
        <div class="check-box"></div>철봉
      </div>
    </div>

    <div style="
      background:#EFF6FF;border-radius:12px;
      padding:12px 14px;border-left:3px solid #4F8EF7;
      font-size:12px;color:#475569;line-height:19px;
    ">
      <span style="color:#4F8EF7;font-weight:700;">💡 기본값 안내</span><br>
      주 3회 · 집 · 맨몸이 선택되어 있습니다.<br>
      변경 없이 바로 <strong>'AI 플랜 생성하기'</strong>를 탭하세요.
    </div>
  </div>

  <div class="ob-footer">
    <button class="btn-generate">🤖 AI 플랜 생성하기</button>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: AI 플랜 생성 중 (SCR-07)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-07 · AI 플랜 생성 중 — Step 2 (이중 안전 검증)</div>
  <div class="status-bar"><span>9:48</span><span>●●● WiFi 🔋</span></div>

  <div class="gen-body">
    <div class="gen-logo">🤖</div>
    <div class="gen-title">맞춤 플랜을 만들고 있어요</div>
    <div class="gen-sub">
      무릎 부상 데이터를 분석하고<br>
      15개 안전 규칙을 검증한 후<br>
      4주 재활 운동 플랜을 생성합니다
    </div>

    <div class="progress-steps">
      <div class="p-step done">
        <div class="p-icon-wrap">✓</div>
        <div class="p-info">
          <div class="p-name">부상 데이터 분석</div>
          <div class="p-detail">무릎 인대 손상 패턴 분석 완료</div>
        </div>
        <span class="p-badge done">완료</span>
      </div>

      <div class="p-step done">
        <div class="p-icon-wrap">✓</div>
        <div class="p-info">
          <div class="p-name">안전 규칙 검증 (1차)</div>
          <div class="p-detail">프롬프트 레벨 Claude Haiku 제약 완료</div>
        </div>
        <span class="p-badge done">완료</span>
      </div>

      <div class="p-step active">
        <div class="p-icon-wrap">⚙</div>
        <div class="p-info">
          <div class="p-name">안전 규칙 검증 (2차)</div>
          <div class="p-detail">서버 사이드 15개 규칙 재검증 중...</div>
        </div>
        <span class="p-badge active">진행 중</span>
      </div>

      <div class="p-step">
        <div class="p-icon-wrap" style="background:#DBEAFE;">📋</div>
        <div class="p-info">
          <div class="p-name">4주 플랜 JSON 생성</div>
          <div class="p-detail">개인화 루틴 작성 대기 중</div>
        </div>
        <span class="p-badge wait">대기</span>
      </div>
    </div>

    <div class="prog-bar-wrap">
      <div class="prog-bar-bg">
        <div class="prog-bar-fill"></div>
      </div>
      <div class="prog-pct">65% 완료</div>
    </div>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-8

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-8 | 메인 홈 대시보드</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px; height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;flex-direction:column;
    position:relative;flex-shrink:0;
  }
  .screen-tag{
    position:absolute;top:0;left:0;right:0;
    background:#1E3A5F;color:#93C5FD;
    font-size:9px;font-weight:700;letter-spacing:1.2px;
    text-align:center;padding:5px;z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:700;color:#fff;flex-shrink:0;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  }

  /* ── 홈 헤더 ── */
  .home-header{
    background:linear-gradient(135deg,#4F8EF7 0%,#2B6FD9 100%);
    padding:6px 22px 24px;color:#fff;flex-shrink:0;
  }
  .header-top{
    display:flex;justify-content:space-between;
    align-items:center;margin-bottom:16px;
  }
  .greeting{font-size:13px;opacity:.8;margin-bottom:3px;}
  .date-text{font-size:20px;font-weight:800;}
  .notif-btn{
    width:40px;height:40px;border-radius:50%;
    background:rgba(255,255,255,.2);
    display:flex;align-items:center;justify-content:center;font-size:18px;
  }
  .stats-strip{display:flex;gap:8px;}
  .stat-pill{
    flex:1;background:rgba(255,255,255,.18);
    border-radius:12px;padding:10px 8px;text-align:center;
  }
  .stat-val{font-size:16px;font-weight:800;}
  .stat-lbl{font-size:10px;opacity:.8;margin-top:2px;}

  /* ── 스크롤 바디 ── */
  .scroll-body{flex:1;overflow-y:auto;padding:14px 16px 0;}

  /* ── 주간 진척 바 ── */
  .week-card{
    background:#fff;border-radius:16px;padding:16px;
    margin-bottom:12px;
    box-shadow:0 2px 12px rgba(79,142,247,.08);
  }
  .week-card-label{font-size:12px;font-weight:700;color:#475569;margin-bottom:10px;}
  .progress-bg{
    height:8px;background:#DBEAFE;border-radius:4px;
    overflow:hidden;margin-bottom:4px;
  }
  .progress-fill{
    height:100%;
    background:linear-gradient(90deg,#4F8EF7,#7AAEF9);
    border-radius:4px;
  }
  .progress-pct{font-size:11px;color:#4F8EF7;font-weight:700;text-align:right;}
  .day-dots{display:flex;gap:6px;margin-top:12px;justify-content:center;}
  .day-dot{text-align:center;}
  .day-circle{
    width:36px;height:36px;border-radius:50%;
    background:#EFF6FF;color:#94A3B8;
    display:flex;align-items:center;justify-content:center;
    font-size:12px;font-weight:700;margin-bottom:3px;
  }
  .day-circle.done{background:#4F8EF7;color:#fff;}
  .day-circle.today{
    background:#4F8EF7;color:#fff;
    box-shadow:0 0 0 3px rgba(79,142,247,.3);
  }
  .day-label{font-size:10px;color:#94A3B8;}

  /* ── 섹션 헤더 ── */
  .section-row{
    display:flex;justify-content:space-between;
    align-items:center;margin-bottom:10px;
  }
  .section-title{font-size:14px;font-weight:700;color:#0F172A;}
  .section-link{font-size:12px;color:#4F8EF7;font-weight:600;}

  /* ── 일괄 완료 ── */
  .batch-btn{
    width:100%;padding:12px;
    background:#EFF6FF;
    border:1.5px solid #4F8EF7;
    border-radius:12px;
    color:#2B6FD9;font-size:13px;font-weight:700;
    cursor:pointer;margin-bottom:12px;
    display:flex;align-items:center;justify-content:center;gap:6px;
  }

  /* ── 운동 카드 ── */
  .ex-card{
    background:#fff;border-radius:14px;
    padding:14px 16px;margin-bottom:8px;
    box-shadow:0 2px 8px rgba(79,142,247,.07);
    display:flex;align-items:center;gap:12px;
    cursor:pointer;
    border:1.5px solid transparent;
  }
  .ex-card.current{border-color:#4F8EF7;box-shadow:0 0 0 2px rgba(79,142,247,.15);}
  .ex-type-icon{
    width:42px;height:42px;border-radius:12px;
    display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;
  }
  .icon-warm{background:#EFF6FF;}
  .icon-rehab{background:#FFFBEB;}
  .icon-main{background:#EDE9FE;}
  .ex-info{flex:1;}
  .ex-name{font-size:14px;font-weight:700;color:#0F172A;}
  .ex-detail{font-size:12px;color:#475569;margin-top:2px;}
  .ex-tag{
    display:inline-block;
    padding:2px 8px;border-radius:99px;
    font-size:10px;font-weight:700;margin-top:5px;
  }
  .tag-warm{background:#EFF6FF;color:#4F8EF7;}
  .tag-rehab{background:#FFFBEB;color:#92400E;}
  .tag-main{background:#EDE9FE;color:#6D28D9;}
  .ex-check{
    width:30px;height:30px;border-radius:50%;
    border:2px solid #DBEAFE;
    display:flex;align-items:center;justify-content:center;flex-shrink:0;
  }
  .ex-check.done{background:#10B981;border-color:#10B981;color:#fff;font-size:14px;}

  /* ── 스와이프 힌트 ── */
  .swipe-hint{
    font-size:11px;color:#94A3B8;
    text-align:center;padding:10px;
  }

  /* ── 스와이프 카드 ── */
  .swipe-container{
    position:relative;margin-bottom:8px;
    border-radius:14px;overflow:hidden;
  }
  .swipe-action{
    position:absolute;right:0;top:0;bottom:0;width:76px;
    background:#EF4444;
    display:flex;flex-direction:column;
    align-items:center;justify-content:center;
    color:#fff;font-size:11px;font-weight:700;gap:2px;
  }

  /* ── 네비 바 ── */
  .nav-bar{
    display:flex;background:#fff;
    border-top:1px solid #EFF6FF;flex-shrink:0;
  }
  .nav-item{flex:1;padding:10px 0 14px;text-align:center;cursor:pointer;}
  .nav-icon{font-size:20px;}
  .nav-lbl{font-size:10px;color:#94A3B8;margin-top:2px;font-weight:600;}
  .nav-item.active .nav-lbl{color:#4F8EF7;}
  .nav-item.active .nav-icon{filter:none;}
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 메인 홈 대시보드 기본 뷰 (SCR-08)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-08 · 메인 홈 대시보드 — Step 3 (기본 뷰)</div>
  <div class="status-bar"><span>9:50</span><span>●●● WiFi 🔋</span></div>

  <div class="home-header">
    <div class="header-top">
      <div>
        <div class="greeting">좋은 아침이에요 👋</div>
        <div class="date-text">1월 31일 금요일</div>
      </div>
      <div class="notif-btn">🔔</div>
    </div>
    <div class="stats-strip">
      <div class="stat-pill">
        <div class="stat-val">5→3</div>
        <div class="stat-lbl">통증 ▼</div>
      </div>
      <div class="stat-pill">
        <div class="stat-val">🔥 8일</div>
        <div class="stat-lbl">연속 운동</div>
      </div>
      <div class="stat-pill">
        <div class="stat-val">75%</div>
        <div class="stat-lbl">주간 달성률</div>
      </div>
    </div>
  </div>

  <div class="scroll-body">
    <!-- 주간 진척도 -->
    <div class="week-card">
      <div class="week-card-label">이번 주 진척도 (3 / 4회 완료)</div>
      <div class="progress-bg">
        <div class="progress-fill" style="width:75%;"></div>
      </div>
      <div class="progress-pct">75%</div>
      <div class="day-dots">
        <div class="day-dot">
          <div class="day-circle done">✓</div>
          <div class="day-label">월</div>
        </div>
        <div class="day-dot">
          <div class="day-circle done">✓</div>
          <div class="day-label">화</div>
        </div>
        <div class="day-dot">
          <div class="day-circle done">✓</div>
          <div class="day-label">수</div>
        </div>
        <div class="day-dot">
          <div class="day-circle">-</div>
          <div class="day-label">목</div>
        </div>
        <div class="day-dot">
          <div class="day-circle today">●</div>
          <div class="day-label">금</div>
        </div>
        <div class="day-dot">
          <div class="day-circle">-</div>
          <div class="day-label">토</div>
        </div>
        <div class="day-dot">
          <div class="day-circle">-</div>
          <div class="day-label">일</div>
        </div>
      </div>
    </div>

    <!-- 오늘 운동 섹션 -->
    <div class="section-row">
      <div class="section-title">오늘의 운동 5개</div>
      <div class="section-link">전체 보기</div>
    </div>

    <button class="batch-btn">⚡ 오늘의 운동 일괄 완료 (원터치)</button>

    <div class="ex-card">
      <div class="ex-type-icon icon-warm">🌡️</div>
      <div class="ex-info">
        <div class="ex-name">무릎 관절 워밍업</div>
        <div class="ex-detail">2세트 × 10회</div>
        <span class="ex-tag tag-warm">준비운동</span>
      </div>
      <div class="ex-check done">✓</div>
    </div>

    <div class="ex-card">
      <div class="ex-type-icon icon-rehab">🩹</div>
      <div class="ex-info">
        <div class="ex-name">쿼드 스트레칭</div>
        <div class="ex-detail">3세트 × 30초</div>
        <span class="ex-tag tag-rehab">재활</span>
      </div>
      <div class="ex-check done">✓</div>
    </div>

    <div class="ex-card current">
      <div class="ex-type-icon icon-rehab">🔄</div>
      <div class="ex-info">
        <div class="ex-name">레그 레이즈 (재활)</div>
        <div class="ex-detail">3세트 × 12회</div>
        <span class="ex-tag tag-rehab">재활 / 보조</span>
      </div>
      <div class="ex-check"></div>
    </div>

    <div class="ex-card">
      <div class="ex-type-icon icon-main">💪</div>
      <div class="ex-info">
        <div class="ex-name">월 스쿼트 (가벼운)</div>
        <div class="ex-detail">3세트 × 10회 · 추천 5kg</div>
        <span class="ex-tag tag-main">메인</span>
      </div>
      <div class="ex-check"></div>
    </div>

    <div class="ex-card">
      <div class="ex-type-icon icon-main">🏃</div>
      <div class="ex-info">
        <div class="ex-name">스텝 업 (낮은 박스)</div>
        <div class="ex-detail">3세트 × 8회</div>
        <span class="ex-tag tag-main">메인</span>
      </div>
      <div class="ex-check"></div>
    </div>

    <div class="swipe-hint">← 카드를 왼쪽으로 밀면 운동 스킵 →</div>
    <div style="height:10px;"></div>
  </div>

  <div class="nav-bar">
    <div class="nav-item active">
      <div class="nav-icon">🏠</div>
      <div class="nav-lbl" style="color:#4F8EF7;">홈</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">📊</div>
      <div class="nav-lbl">통계</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">⚙️</div>
      <div class="nav-lbl">설정</div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: 스와이프 스킵 상태 (Quick-Edit)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-08b · 홈 카드 스와이프 스킵 — Quick-Edit 인터랙션</div>
  <div class="status-bar"><span>9:51</span><span>●●● WiFi 🔋</span></div>

  <div class="home-header">
    <div class="header-top">
      <div>
        <div class="greeting">Quick-Edit 시연 📖</div>
        <div class="date-text">카드 스와이프 스킵</div>
      </div>
      <div class="notif-btn">📖</div>
    </div>
    <div style="
      background:rgba(255,255,255,.15);
      border-radius:10px;padding:10px 12px;
      font-size:12px;opacity:.9;line-height:18px;
    ">
      ← 운동 카드를 왼쪽으로 밀면 [스킵] 버튼이 나타납니다
    </div>
  </div>

  <div class="scroll-body">
    <button class="batch-btn">⚡ 오늘의 운동 일괄 완료 (원터치)</button>

    <!-- 일반 카드 -->
    <div class="ex-card">
      <div class="ex-type-icon icon-warm">🌡️</div>
      <div class="ex-info">
        <div class="ex-name">무릎 관절 워밍업</div>
        <div class="ex-detail">2세트 × 10회</div>
        <span class="ex-tag tag-warm">준비운동</span>
      </div>
      <div class="ex-check done">✓</div>
    </div>

    <!-- 스와이프된 카드 -->
    <div class="swipe-container">
      <div class="swipe-action">
        <span style="font-size:18px;">🚫</span>
        <span>스킵</span>
      </div>
      <div class="ex-card" style="
        margin-bottom:0;transform:translateX(-68px);
        border-radius:14px;
        border-color:#FECACA;background:#FFF5F5;
      ">
        <div class="ex-type-icon icon-rehab">🩹</div>
        <div class="ex-info">
          <div class="ex-name" style="color:#DC2626;">쿼드 스트레칭</div>
          <div class="ex-detail">3세트 × 30초</div>
          <span class="ex-tag tag-rehab">재활</span>
        </div>
        <div class="ex-check"></div>
      </div>
    </div>

    <div class="ex-card current">
      <div class="ex-type-icon icon-rehab">🔄</div>
      <div class="ex-info">
        <div class="ex-name">레그 레이즈 (재활)</div>
        <div class="ex-detail">3세트 × 12회</div>
        <span class="ex-tag tag-rehab">재활 / 보조</span>
      </div>
      <div class="ex-check"></div>
    </div>

    <div class="ex-card">
      <div class="ex-type-icon icon-main">💪</div>
      <div class="ex-info">
        <div class="ex-name">월 스쿼트 (가벼운)</div>
        <div class="ex-detail">3세트 × 10회</div>
        <span class="ex-tag tag-main">메인</span>
      </div>
      <div class="ex-check"></div>
    </div>

    <div class="ex-card">
      <div class="ex-type-icon icon-main">🏃</div>
      <div class="ex-info">
        <div class="ex-name">스텝 업 (낮은 박스)</div>
        <div class="ex-detail">3세트 × 8회</div>
        <span class="ex-tag tag-main">메인</span>
      </div>
      <div class="ex-check"></div>
    </div>

    <div style="
      background:#FFFBEB;border-radius:12px;
      padding:12px 14px;margin:10px 0;
      border-left:3px solid #F59E0B;
      font-size:12px;color:#92400E;
    ">
      ⚠️ <strong>스킵 확인:</strong> '쿼드 스트레칭'을 스킵하면 오늘 세션에서 제외됩니다.
    </div>
  </div>

  <div class="nav-bar">
    <div class="nav-item active">
      <div class="nav-icon">🏠</div>
      <div class="nav-lbl" style="color:#4F8EF7;">홈</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">📊</div>
      <div class="nav-lbl">통계</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">⚙️</div>
      <div class="nav-lbl">설정</div>
    </div>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-9

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-9 | 세션 상세 & 세트 기록 & Quick-Edit</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px; height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;flex-direction:column;
    position:relative;flex-shrink:0;
  }
  .screen-tag{
    position:absolute;top:0;left:0;right:0;
    background:#1E3A5F;color:#93C5FD;
    font-size:9px;font-weight:700;letter-spacing:1.2px;
    text-align:center;padding:5px;z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:700;
    color:#fff;flex-shrink:0;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  }

  /* ── 세션 헤더 ── */
  .sess-header{
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    padding:4px 20px 22px;color:#fff;flex-shrink:0;
  }
  .back-row{
    font-size:13px;opacity:.8;margin-bottom:8px;cursor:pointer;
    display:flex;align-items:center;gap:4px;
  }
  .sess-name{font-size:21px;font-weight:800;margin-bottom:8px;}
  .sess-meta{
    display:flex;flex-wrap:wrap;gap:10px;
    font-size:12px;opacity:.8;
  }
  .sess-meta span{display:flex;align-items:center;gap:3px;}

  /* ── 프리필 배너 ── */
  .prefill-banner{
    background:#EFF6FF;
    border-bottom:1px solid #DBEAFE;
    padding:8px 20px;
    font-size:12px;color:#2B6FD9;font-weight:600;
    display:flex;align-items:center;gap:6px;
    flex-shrink:0;
  }

  /* ── 스크롤 바디 ── */
  .scroll-body{flex:1;overflow-y:auto;padding:14px 16px;}

  /* ── 가이드 박스 ── */
  .guide-box{
    background:#fff;border-radius:14px;
    padding:14px 16px;margin-bottom:14px;
    box-shadow:0 2px 8px rgba(79,142,247,.07);
  }
  .guide-title{
    font-size:11px;font-weight:700;
    color:#475569;letter-spacing:.6px;
    text-transform:uppercase;margin-bottom:8px;
  }
  .guide-text{font-size:13px;color:#0F172A;line-height:21px;}

  /* ── 세트 테이블 ── */
  .set-header{
    display:flex;padding:0 4px;margin-bottom:6px;
  }
  .col{font-size:11px;font-weight:700;color:#94A3B8;letter-spacing:.3px;}
  .col-num{width:34px;}
  .col-weight{flex:1;text-align:center;}
  .col-reps{flex:1;text-align:center;}
  .col-check{width:52px;text-align:center;}

  .set-row{
    display:flex;align-items:center;
    padding:10px 4px;
    border-radius:14px;margin-bottom:6px;
    background:#fff;
    box-shadow:0 1px 6px rgba(79,142,247,.07);
  }
  .set-row.done{background:#EFF6FF;}
  .set-row.current{
    background:#fff;
    border:1.5px solid #4F8EF7;
    box-shadow:0 0 0 2px rgba(79,142,247,.12);
  }
  .set-num{
    width:34px;
    font-size:13px;font-weight:700;color:#475569;
  }
  .set-num.active{color:#4F8EF7;}
  .set-val{flex:1;text-align:center;}
  .val-chip{
    display:inline-block;
    padding:7px 16px;border-radius:10px;
    font-size:14px;font-weight:700;
    background:#EFF6FF;color:#0F172A;
    cursor:pointer;border:1.5px solid #DBEAFE;
  }
  .set-row.done .val-chip{
    background:#DBEAFE;color:#1E40AF;border-color:#BFDBFE;
  }
  .set-row.current .val-chip{
    background:#EFF6FF;color:#2B6FD9;border-color:#4F8EF7;
  }
  .set-check{width:52px;display:flex;justify-content:center;}
  .check-circle{
    width:38px;height:38px;border-radius:50%;
    border:2px solid #DBEAFE;background:#fff;
    display:flex;align-items:center;justify-content:center;
    cursor:pointer;font-size:16px;
  }
  .check-circle.done{background:#10B981;border-color:#10B981;color:#fff;}
  .check-circle.active{border-color:#4F8EF7;}

  /* ── 버튼 ── */
  .add-set-btn{
    width:100%;padding:12px;
    border:1.5px dashed #BFDBFE;border-radius:12px;
    background:transparent;color:#4F8EF7;
    font-size:13px;font-weight:700;cursor:pointer;margin-top:4px;
  }
  .end-btn{
    width:100%;padding:15px;background:#EF4444;color:#fff;
    border:none;border-radius:16px;
    font-size:15px;font-weight:700;cursor:pointer;margin-top:12px;
  }

  /* ── 타이머 바 ── */
  .timer-bar{
    position:absolute;bottom:0;left:0;right:0;
    background:linear-gradient(135deg,#1E3A5F,#2B6FD9);
    color:#fff;
    padding:12px 20px;
    display:flex;align-items:center;
    justify-content:space-between;z-index:10;
  }
  .timer-count{font-size:26px;font-weight:900;}
  .timer-lbl{font-size:11px;opacity:.8;margin-top:1px;}
  .timer-skip{
    background:rgba(255,255,255,.2);border:none;
    color:#fff;padding:9px 16px;border-radius:10px;
    font-size:12px;font-weight:700;cursor:pointer;
  }
  .timer-prog{
    position:absolute;bottom:0;left:0;
    height:3px;background:#7AAEF9;width:42%;
  }

  /* ── QuickEdit 오버레이 ── */
  .qe-overlay{
    position:absolute;bottom:0;left:0;right:0;
    background:#fff;border-radius:28px 28px 0 0;
    padding:22px 20px 36px;
    box-shadow:0 -4px 28px rgba(0,0,0,.15);z-index:20;
  }
  .qe-handle{
    width:40px;height:4px;border-radius:2px;
    background:#DBEAFE;margin:0 auto 18px;
  }
  .qe-label{font-size:13px;font-weight:700;color:#475569;margin-bottom:4px;}
  .qe-current{font-size:32px;font-weight:900;color:#4F8EF7;margin-bottom:18px;}
  .qe-section{margin-bottom:14px;}
  .qe-section-lbl{
    font-size:11px;font-weight:700;color:#475569;
    letter-spacing:.6px;text-transform:uppercase;margin-bottom:8px;
  }
  .qe-chips{display:flex;gap:8px;}
  .qe-chip{
    flex:1;padding:12px 6px;
    border-radius:12px;font-size:13px;font-weight:700;
    text-align:center;cursor:pointer;
    border:1.5px solid #DBEAFE;background:#EFF6FF;color:#0F172A;
  }
  .qe-chip.minus{color:#EF4444;border-color:#FECACA;background:#FFF5F5;}
  .qe-chip.plus{color:#4F8EF7;border-color:#BFDBFE;background:#EFF6FF;}
  .qe-confirm{
    width:100%;padding:14px;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    color:#fff;border:none;border-radius:14px;
    font-size:14px;font-weight:700;cursor:pointer;
    margin-top:4px;
    box-shadow:0 4px 14px rgba(79,142,247,.3);
  }
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 세션 상세 (Pre-fill + 타이머 바)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-09 · 세션 상세 & 세트 기록 — Step 4+5 (Pre-fill 완료 + 타이머)</div>
  <div class="status-bar"><span>9:55</span><span>●●● WiFi 🔋</span></div>

  <div class="sess-header">
    <div class="back-row">← 오늘의 운동</div>
    <div class="sess-name">레그 레이즈 (재활)</div>
    <div class="sess-meta">
      <span>🩹 재활 / 보조</span>
      <span>⏱ 예상 8분</span>
      <span>📋 3세트</span>
    </div>
  </div>

  <div class="prefill-banner">
    ✨ 이전 세션 기록이 자동으로 채워졌습니다
  </div>

  <div class="scroll-body">
    <div class="guide-box">
      <div class="guide-title">운동 가이드</div>
      <div class="guide-text">
        • 바닥에 누워 무릎 부상 부위에 무리 없도록<br>
        • 복근으로 다리를 들어올리고 천천히 내려요<br>
        • 통증이 느껴지면 즉시 중단하세요
      </div>
    </div>

    <div class="set-header">
      <div class="col col-num">세트</div>
      <div class="col col-weight">무게 (kg)</div>
      <div class="col col-reps">횟수 (회)</div>
      <div class="col col-check">완료</div>
    </div>

    <div class="set-row done">
      <div class="set-num">1</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">12 회</span></div>
      <div class="set-check"><div class="check-circle done">✓</div></div>
    </div>

    <div class="set-row done">
      <div class="set-num">2</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">12 회</span></div>
      <div class="set-check"><div class="check-circle done">✓</div></div>
    </div>

    <div class="set-row current">
      <div class="set-num active">3</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">12 회</span></div>
      <div class="set-check"><div class="check-circle active">○</div></div>
    </div>

    <button class="add-set-btn">+ 세트 추가</button>
    <button class="end-btn">세션 종료</button>
    <div style="height:72px;"></div>
  </div>

  <!-- 타이머 바 -->
  <div class="timer-bar">
    <div class="timer-prog"></div>
    <div>
      <div class="timer-count">0:25</div>
      <div class="timer-lbl">휴식 타이머 중</div>
    </div>
    <button class="timer-skip">건너뛰기 ▶</button>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: Quick-Edit 오버레이 (무게/횟수 수정)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-09b · 무게 & 횟수 Quick-Edit 오버레이 — Step 5.3</div>
  <div class="status-bar"><span>9:57</span><span>●●● WiFi 🔋</span></div>

  <div class="sess-header">
    <div class="back-row">← 오늘의 운동</div>
    <div class="sess-name">월 스쿼트 (메인)</div>
    <div class="sess-meta">
      <span>💪 메인 운동</span>
      <span>⏱ 예상 12분</span>
    </div>
  </div>

  <div class="prefill-banner">
    ✨ 지난 세션: 5kg × 10회 × 3세트
  </div>

  <div class="scroll-body">
    <div class="set-header">
      <div class="col col-num">세트</div>
      <div class="col col-weight">무게 (kg)</div>
      <div class="col col-reps">횟수 (회)</div>
      <div class="col col-check">완료</div>
    </div>

    <div class="set-row done">
      <div class="set-num">1</div>
      <div class="set-val"><span class="val-chip">5 kg</span></div>
      <div class="set-val"><span class="val-chip">10 회</span></div>
      <div class="set-check"><div class="check-circle done">✓</div></div>
    </div>

    <div class="set-row current" style="opacity:.6;">
      <div class="set-num active">2</div>
      <div class="set-val"><span class="val-chip">5 kg</span></div>
      <div class="set-val"><span class="val-chip">10 회</span></div>
      <div class="set-check"><div class="check-circle active">○</div></div>
    </div>

    <div class="set-row" style="opacity:.45;">
      <div class="set-num">3</div>
      <div class="set-val"><span class="val-chip">5 kg</span></div>
      <div class="set-val"><span class="val-chip">10 회</span></div>
      <div class="set-check"><div class="check-circle">○</div></div>
    </div>

    <div style="height:340px;"></div>
  </div>

  <!-- QuickEdit 오버레이 -->
  <div class="qe-overlay">
    <div class="qe-handle"></div>
    <div class="qe-label">2세트 무게 수정</div>
    <div class="qe-current">5 kg</div>

    <div class="qe-section">
      <div class="qe-section-lbl">무게 조절 (kg)</div>
      <div class="qe-chips">
        <div class="qe-chip minus">-5kg</div>
        <div class="qe-chip minus">-1kg</div>
        <div class="qe-chip plus">+1kg</div>
        <div class="qe-chip plus">+5kg</div>
      </div>
    </div>

    <div class="qe-section">
      <div class="qe-section-lbl">횟수 조절 (회)</div>
      <div class="qe-chips">
        <div class="qe-chip minus" style="flex:none;width:90px;">-1회</div>
        <div style="
          flex:1;display:flex;align-items:center;
          justify-content:center;
          font-size:26px;font-weight:900;color:#0F172A;
        ">10 회</div>
        <div class="qe-chip plus" style="flex:none;width:90px;">+1회</div>
      </div>
    </div>

    <button class="qe-confirm">확인 · 적용</button>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 3: 세트 추가 / 삭제 Quick-Edit
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-09c · 세트 추가 & 스와이프 삭제 — Step 5.2</div>
  <div class="status-bar"><span>10:02</span><span>●●● WiFi 🔋</span></div>

  <div class="sess-header">
    <div class="back-row">← 오늘의 운동</div>
    <div class="sess-name">스텝 업 (낮은 박스)</div>
    <div class="sess-meta">
      <span>💪 메인 운동</span>
      <span>⏱ 예상 10분</span>
      <span>📋 4세트</span>
    </div>
  </div>

  <div class="prefill-banner">
    ✨ 세트 추가됨: 이전 세트와 동일한 값으로 자동 생성
  </div>

  <div class="scroll-body">
    <div class="set-header">
      <div class="col col-num">세트</div>
      <div class="col col-weight">무게 (kg)</div>
      <div class="col col-reps">횟수 (회)</div>
      <div class="col col-check">완료</div>
    </div>

    <div class="set-row done">
      <div class="set-num">1</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">8 회</span></div>
      <div class="set-check"><div class="check-circle done">✓</div></div>
    </div>

    <div class="set-row done">
      <div class="set-num">2</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">8 회</span></div>
      <div class="set-check"><div class="check-circle done">✓</div></div>
    </div>

    <!-- 스와이프 삭제 상태 -->
    <div style="position:relative;margin-bottom:6px;border-radius:14px;overflow:hidden;">
      <div style="
        position:absolute;right:0;top:0;bottom:0;width:72px;
        background:#EF4444;
        display:flex;flex-direction:column;
        align-items:center;justify-content:center;
        color:#fff;font-size:11px;font-weight:700;gap:2px;
        border-radius:0 14px 14px 0;
      ">
        <span style="font-size:16px;">🗑</span>
        <span>삭제</span>
      </div>
      <div class="set-row current" style="
        margin-bottom:0;transform:translateX(-64px);
        border-radius:14px;
      ">
        <div class="set-num active">3</div>
        <div class="set-val"><span class="val-chip">0 kg</span></div>
        <div class="set-val"><span class="val-chip">8 회</span></div>
        <div class="set-check"><div class="check-circle active">○</div></div>
      </div>
    </div>

    <div class="set-row" style="
      border:1.5px dashed #BFDBFE;background:#F0F9FF;
    ">
      <div class="set-num" style="color:#94A3B8;">4</div>
      <div class="set-val">
        <span class="val-chip" style="background:#F0F9FF;border-color:#BAE6FD;color:#0369A1;">0 kg</span>
      </div>
      <div class="set-val">
        <span class="val-chip" style="background:#F0F9FF;border-color:#BAE6FD;color:#0369A1;">8 회</span>
      </div>
      <div class="set-check"><div class="check-circle" style="border-color:#BAE6FD;">○</div></div>
    </div>

    <div style="
      display:flex;align-items:center;gap:6px;
      font-size:11px;color:#0369A1;
      padding:6px 4px;margin-bottom:8px;
    ">
      ✨ <span>세트 4 — 자동 추가됨 (세트 3과 동일한 값)</span>
    </div>

    <button class="add-set-btn">+ 세트 추가</button>
    <button class="end-btn">세션 종료</button>
    <div style="height:20px;"></div>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-10

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-10 | 세션 종료 & 통증 피드백</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px; height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;flex-direction:column;
    position:relative;flex-shrink:0;
  }
  .screen-tag{
    position:absolute;top:0;left:0;right:0;
    background:#1E3A5F;color:#93C5FD;
    font-size:9px;font-weight:700;letter-spacing:1.2px;
    text-align:center;padding:5px;z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:700;flex-shrink:0;
  }

  /* ── 완료 요약 ── */
  .complete-body{
    flex:1;
    display:flex;flex-direction:column;
    align-items:center;
    padding:28px 22px;
    overflow-y:auto;
    background:#F8FAFC;
  }
  .complete-icon{
    width:88px;height:88px;border-radius:50%;
    background:linear-gradient(135deg,#10B981,#059669);
    display:flex;align-items:center;justify-content:center;
    font-size:44px;margin-bottom:18px;
    box-shadow:0 10px 30px rgba(16,185,129,.3);
  }
  .complete-title{font-size:24px;font-weight:900;color:#0F172A;margin-bottom:6px;}
  .complete-sub{font-size:14px;color:#475569;margin-bottom:24px;text-align:center;}
  .summary-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;width:100%;margin-bottom:20px;}
  .summary-card{
    background:#fff;border-radius:16px;padding:16px;
    text-align:center;
    box-shadow:0 2px 10px rgba(79,142,247,.08);
  }
  .sv{font-size:22px;font-weight:800;color:#4F8EF7;}
  .sl{font-size:11px;color:#475569;margin-top:3px;}
  .ex-done-list{
    width:100%;background:#fff;border-radius:16px;
    padding:16px;margin-bottom:20px;
    box-shadow:0 2px 10px rgba(79,142,247,.08);
  }
  .ex-done-title{font-size:11px;font-weight:700;color:#475569;letter-spacing:.6px;text-transform:uppercase;margin-bottom:10px;}
  .ex-done-item{
    display:flex;align-items:center;gap:10px;
    padding:8px 0;border-bottom:1px solid #F0F5FF;
  }
  .ex-done-item:last-child{border-bottom:none;}
  .done-check-circle{
    width:24px;height:24px;border-radius:50%;
    background:#10B981;color:#fff;
    display:flex;align-items:center;justify-content:center;
    font-size:12px;flex-shrink:0;
  }
  .done-name{font-size:13px;font-weight:600;color:#0F172A;flex:1;}
  .done-vol{font-size:11px;color:#475569;}
  .end-btn{
    width:100%;padding:15px;background:#EF4444;
    color:#fff;border:none;border-radius:16px;
    font-size:15px;font-weight:700;cursor:pointer;
    box-shadow:0 4px 14px rgba(239,68,68,.3);
  }

  /* ── 피드백 모달 ── */
  .modal-backdrop{
    position:absolute;top:0;left:0;right:0;bottom:0;
    background:rgba(15,23,42,.55);
    display:flex;align-items:flex-end;z-index:20;
  }
  .modal-sheet{
    background:#fff;border-radius:28px 28px 0 0;
    padding:24px 22px 40px;width:100%;
    box-shadow:0 -4px 32px rgba(0,0,0,.15);
  }
  .modal-handle{
    width:40px;height:4px;border-radius:2px;
    background:#DBEAFE;margin:0 auto 20px;
  }
  .modal-icon-wrap{text-align:center;font-size:36px;margin-bottom:10px;}
  .modal-title{font-size:20px;font-weight:800;color:#0F172A;text-align:center;margin-bottom:4px;}
  .modal-sub{font-size:13px;color:#475569;text-align:center;margin-bottom:16px;}
  .modal-prefill{
    background:#EFF6FF;border-radius:12px;
    padding:10px 14px;margin-bottom:16px;
    font-size:12px;color:#2B6FD9;font-weight:600;text-align:center;
  }
  .pain-grid{
    display:flex;flex-wrap:wrap;gap:7px;
    justify-content:center;margin-bottom:12px;
  }
  .p-num{
    width:44px;height:44px;border-radius:12px;
    display:flex;align-items:center;justify-content:center;
    font-size:16px;font-weight:800;
    border:1.5px solid #DBEAFE;background:#EFF6FF;color:#0F172A;
    cursor:pointer;
  }
  .p-num.low{background:#D1FAE5;border-color:#6EE7B7;color:#065F46;}
  .p-num.mid{background:#FEF9C3;border-color:#FDE047;color:#713F12;}
  .p-num.high{background:#FECACA;border-color:#FCA5A5;color:#7F1D1D;}
  .p-num.selected{
    box-shadow:0 0 0 3px rgba(79,142,247,.4);
    border-color:#4F8EF7;
    transform:scale(1.1);
  }
  .pain-legend-row{
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:600;margin-bottom:18px;
  }
  .save-btn{
    width:100%;padding:16px;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    color:#fff;border:none;border-radius:16px;
    font-size:16px;font-weight:700;cursor:pointer;
    box-shadow:0 4px 16px rgba(79,142,247,.35);
  }
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 세션 완료 요약 화면
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-09d · 세션 완료 요약 — Step 6 진입 전</div>
  <div class="status-bar" style="background:#F8FAFC;color:#0F172A;">
    <span>10:15</span><span>●●● WiFi 🔋</span>
  </div>

  <div class="complete-body">
    <div class="complete-icon">🎉</div>
    <div class="complete-title">운동 완료!</div>
    <div class="complete-sub">오늘의 재활 루틴을 모두 마쳤어요 🏆</div>

    <div class="summary-grid">
      <div class="summary-card">
        <div class="sv">24분</div>
        <div class="sl">총 운동 시간</div>
      </div>
      <div class="summary-card">
        <div class="sv">9세트</div>
        <div class="sl">완료 세트 수</div>
      </div>
      <div class="summary-card">
        <div class="sv" style="color:#10B981;">420</div>
        <div class="sl">총 볼륨 (kg)</div>
      </div>
      <div class="summary-card">
        <div class="sv" style="color:#F59E0B;">🔥 8일</div>
        <div class="sl">연속 운동 기록</div>
      </div>
    </div>

    <div class="ex-done-list">
      <div class="ex-done-title">완료된 운동 목록</div>
      <div class="ex-done-item">
        <div class="done-check-circle">✓</div>
        <div class="done-name">무릎 관절 워밍업</div>
        <div class="done-vol">2 × 10</div>
      </div>
      <div class="ex-done-item">
        <div class="done-check-circle">✓</div>
        <div class="done-name">레그 레이즈 (재활)</div>
        <div class="done-vol">3 × 12</div>
      </div>
      <div class="ex-done-item">
        <div class="done-check-circle">✓</div>
        <div class="done-name">월 스쿼트</div>
        <div class="done-vol">3 × 10 · 5kg</div>
      </div>
      <div class="ex-done-item">
        <div style="
          width:24px;height:24px;border-radius:50%;
          background:#94A3B8;color:#fff;
          display:flex;align-items:center;justify-content:center;
          font-size:12px;flex-shrink:0;
        ">⏭</div>
        <div class="done-name" style="color:#94A3B8;">쿼드 스트레칭 (스킵)</div>
        <div class="done-vol">-</div>
      </div>
    </div>

    <button class="end-btn">세션 종료 및 피드백 입력</button>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: 통증 피드백 모달 (기본값 선택 상태)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-10 · 통증 피드백 모달 — Step 6 (기본값: 지난 세션 5점)</div>
  <div class="status-bar" style="background:#F8FAFC;color:#0F172A;opacity:.45;">
    <span>10:15</span><span>●●● WiFi 🔋</span>
  </div>

  <!-- 배경 흐림 처리 -->
  <div style="flex:1;opacity:.3;padding:28px 22px;background:#F8FAFC;">
    <div style="text-align:center;font-size:40px;margin-bottom:16px;">🎉</div>
    <div style="font-size:20px;font-weight:800;text-align:center;color:#0F172A;">운동 완료!</div>
  </div>

  <!-- 모달 -->
  <div class="modal-backdrop">
    <div class="modal-sheet">
      <div class="modal-handle"></div>
      <div class="modal-icon-wrap">🤔</div>
      <div class="modal-title">오늘 통증은 어떠셨나요?</div>
      <div class="modal-sub">운동 전·후 통증 변화를 알려주세요</div>
      <div class="modal-prefill">
        📌 지난 세션 통증: <strong>5점</strong> · 변화 없으면 바로 저장 가능
      </div>

      <div class="pain-grid">
        <div class="p-num low">1</div>
        <div class="p-num low">2</div>
        <div class="p-num low">3</div>
        <div class="p-num mid">4</div>
        <div class="p-num mid selected">5</div>
        <div class="p-num mid">6</div>
        <div class="p-num high">7</div>
        <div class="p-num high">8</div>
        <div class="p-num high">9</div>
        <div class="p-num high">10</div>
      </div>

      <div class="pain-legend-row">
        <span style="color:#10B981;">🟢 1 = 통증 없음</span>
        <span style="color:#EF4444;">🔴 10 = 극심한 통증</span>
      </div>

      <button class="save-btn">저장 및 종료 (원터치)</button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 3: 통증 수치 변경 후 저장 (Quick-Edit)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-10b · 통증 피드백 — Quick-Edit: 3점으로 변경 후 저장</div>
  <div class="status-bar" style="background:#F8FAFC;color:#0F172A;opacity:.45;">
    <span>10:15</span><span>●●● WiFi 🔋</span>
  </div>

  <div style="flex:1;opacity:.3;padding:28px 22px;background:#F8FAFC;">
    <div style="text-align:center;font-size:40px;margin-bottom:16px;">🎉</div>
    <div style="font-size:20px;font-weight:800;text-align:center;color:#0F172A;">운동 완료!</div>
  </div>

  <div class="modal-backdrop">
    <div class="modal-sheet">
      <div class="modal-handle"></div>
      <div class="modal-icon-wrap">😊</div>
      <div class="modal-title">통증이 나아졌군요!</div>
      <div class="modal-sub">지난 세션보다 통증이 감소했어요</div>
      <div class="modal-prefill" style="background:#D1FAE5;color:#065F46;">
        📉 지난 세션 5점 → 오늘 <strong>3점</strong> (▼ 40% 감소!) 🎊
      </div>

      <div class="pain-grid">
        <div class="p-num low">1</div>
        <div class="p-num low">2</div>
        <div class="p-num low selected" style="box-shadow:0 0 0 3px rgba(16,185,129,.5);border-color:#10B981;">3</div>
        <div class="p-num mid">4</div>
        <div class="p-num mid">5</div>
        <div class="p-num mid">6</div>
        <div class="p-num high">7</div>
        <div class="p-num high">8</div>
        <div class="p-num high">9</div>
        <div class="p-num high">10</div>
      </div>

      <div class="pain-legend-row">
        <span style="color:#10B981;">🟢 1 = 통증 없음</span>
        <span style="color:#EF4444;">🔴 10 = 극심한 통증</span>
      </div>

      <button class="save-btn" style="background:linear-gradient(135deg,#10B981,#059669);box-shadow:0 4px 16px rgba(16,185,129,.35);">
        저장 및 종료 (3점 기록)
      </button>
    </div>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-11

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-11 | 통계 & 진척도 시각화</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px; height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;flex-direction:column;
    position:relative;flex-shrink:0;
  }
  .screen-tag{
    position:absolute;top:0;left:0;right:0;
    background:#1E3A5F;color:#93C5FD;
    font-size:9px;font-weight:700;letter-spacing:1.2px;
    text-align:center;padding:5px;z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:700;color:#fff;flex-shrink:0;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
  }

  /* ── 분석 헤더 ── */
  .analytics-header{
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    padding:4px 22px 22px;color:#fff;flex-shrink:0;
  }
  .analytics-header h2{font-size:21px;font-weight:800;margin-bottom:4px;}
  .analytics-header p{font-size:13px;opacity:.8;}
  .period-tabs{
    display:flex;gap:0;
    background:rgba(255,255,255,.15);
    border-radius:12px;padding:4px;margin-top:14px;
  }
  .period-tab{
    flex:1;padding:8px;text-align:center;
    font-size:13px;font-weight:700;
    color:rgba(255,255,255,.7);
    border-radius:9px;cursor:pointer;
  }
  .period-tab.active{background:#fff;color:#2B6FD9;}

  /* ── 스크롤 바디 ── */
  .scroll-body{flex:1;overflow-y:auto;padding:14px 16px 0;}

  /* ── KPI 카드 ── */
  .kpi-row{display:flex;gap:10px;margin-bottom:12px;}
  .kpi-card{
    flex:1;background:#fff;border-radius:16px;
    padding:14px;text-align:center;
    box-shadow:0 2px 10px rgba(79,142,247,.08);
  }
  .kv{font-size:22px;font-weight:900;color:#4F8EF7;}
  .kl{font-size:11px;color:#475569;margin-top:3px;}
  .kd{font-size:12px;font-weight:700;margin-top:4px;}
  .kd.pos{color:#10B981;}
  .kd.neg{color:#EF4444;}

  /* ── 차트 카드 ── */
  .chart-card{
    background:#fff;border-radius:16px;
    padding:16px;margin-bottom:12px;
    box-shadow:0 2px 10px rgba(79,142,247,.08);
  }
  .chart-title{font-size:14px;font-weight:700;color:#0F172A;margin-bottom:3px;}
  .chart-sub{font-size:11px;color:#475569;margin-bottom:12px;}

  /* ── 선 그래프 (SVG) ── */
  .chart-area{position:relative;margin-bottom:6px;}
  .svg-chart{width:100%;height:110px;}
  .x-labels{
    display:flex;justify-content:space-between;
    font-size:10px;color:#94A3B8;padding:0 4px;
  }

  /* ── 바 차트 (완료율) ── */
  .bar-group{
    display:flex;align-items:flex-end;gap:5px;height:90px;
    margin-bottom:6px;
  }
  .bar-item{flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;}
  .bar-fill{width:100%;border-radius:6px 6px 0 0;min-height:4px;}
  .bar-pct{font-size:10px;font-weight:700;color:#4F8EF7;}
  .bar-label{font-size:10px;color:#94A3B8;}

  /* ── 볼륨 차트 ── */
  .vol-bars{display:flex;align-items:flex-end;gap:6px;height:80px;margin-bottom:8px;}
  .vol-bar{
    flex:1;border-radius:6px 6px 0 0;
    background:linear-gradient(180deg,#7AAEF9,#4F8EF7);
    min-height:4px;
  }
  .vol-labels{
    display:flex;justify-content:space-between;
    font-size:10px;color:#94A3B8;
  }

  /* ── 네비 바 ── */
  .nav-bar{
    display:flex;background:#fff;
    border-top:1px solid #EFF6FF;flex-shrink:0;
  }
  .nav-item{flex:1;padding:10px 0 14px;text-align:center;cursor:pointer;}
  .nav-icon{font-size:20px;}
  .nav-lbl{font-size:10px;color:#94A3B8;margin-top:2px;font-weight:600;}
  .nav-item.active .nav-lbl{color:#4F8EF7;}
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 통계 대시보드 — 주간 뷰
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-11 · 통계 & 진척도 대시보드 — Step 7 (주간 뷰)</div>
  <div class="status-bar"><span>10:22</span><span>●●● WiFi 🔋</span></div>

  <div class="analytics-header">
    <h2>📊 나의 진척도</h2>
    <p>재활 운동 효과를 한눈에 확인하세요</p>
    <div class="period-tabs">
      <div class="period-tab active">주간</div>
      <div class="period-tab">월간</div>
    </div>
  </div>

  <div class="scroll-body">

    <!-- KPI 요약 -->
    <div class="kpi-row">
      <div class="kpi-card">
        <div class="kv" style="color:#10B981;">5→3</div>
        <div class="kl">주간 통증 점수</div>
        <div class="kd pos">▼ 40% 감소</div>
      </div>
      <div class="kpi-card">
        <div class="kv">75%</div>
        <div class="kl">주간 완료율</div>
        <div class="kd pos">▲ +15%p</div>
      </div>
    </div>

    <!-- 통증 추이 선 그래프 -->
    <div class="chart-card">
      <div class="chart-title">😌 통증 추이 (NRS 1~10)</div>
      <div class="chart-sub">최근 7일 · 데이터 포인트를 탭하면 상세 정보가 표시됩니다</div>
      <div class="chart-area">
        <svg class="svg-chart" viewBox="0 0 320 110" preserveAspectRatio="none">
          <defs>
            <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#4F8EF7" stop-opacity="0.18"/>
              <stop offset="100%" stop-color="#4F8EF7" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <!-- 그리드 -->
          <line x1="0" y1="22" x2="320" y2="22" stroke="#EFF6FF" stroke-width="1"/>
          <line x1="0" y1="55" x2="320" y2="55" stroke="#EFF6FF" stroke-width="1"/>
          <line x1="0" y1="88" x2="320" y2="88" stroke="#EFF6FF" stroke-width="1"/>
          <!-- Y축 라벨 -->
          <text x="4" y="20" fill="#94A3B8" font-size="9">10</text>
          <text x="4" y="53" fill="#94A3B8" font-size="9">5</text>
          <text x="4" y="86" fill="#94A3B8" font-size="9">1</text>
          <!-- 영역 채우기 (통증 데이터: 7,6,5,6,4,3,3) -->
          <path d="M 20,44 L 66,55 L 112,66 L 158,55 L 204,77 L 250,88 L 296,88 L 296,110 L 20,110 Z"
                fill="url(#areaGrad)"/>
          <!-- 선 -->
          <polyline
            points="20,44 66,55 112,66 158,55 204,77 250,88 296,88"
            fill="none" stroke="#4F8EF7" stroke-width="2.5"
            stroke-linecap="round" stroke-linejoin="round"/>
          <!-- 데이터 포인트 -->
          <circle cx="20" cy="44" r="4.5" fill="#4F8EF7" stroke="#fff" stroke-width="2"/>
          <circle cx="66" cy="55" r="4.5" fill="#4F8EF7" stroke="#fff" stroke-width="2"/>
          <circle cx="112" cy="66" r="4.5" fill="#4F8EF7" stroke="#fff" stroke-width="2"/>
          <circle cx="158" cy="55" r="4.5" fill="#4F8EF7" stroke="#fff" stroke-width="2"/>
          <circle cx="204" cy="77" r="4.5" fill="#4F8EF7" stroke="#fff" stroke-width="2"/>
          <!-- 최저점 강조 (3점) -->
          <circle cx="250" cy="88" r="6" fill="#10B981" stroke="#fff" stroke-width="2.5"/>
          <circle cx="296" cy="88" r="6" fill="#10B981" stroke="#fff" stroke-width="2.5"/>
          <!-- 툴팁 -->
          <rect x="218" y="68" width="68" height="22" rx="6" fill="#0F172A"/>
          <text x="252" y="83" fill="#fff" font-size="11" font-weight="bold" text-anchor="middle">오늘 3점</text>
        </svg>
      </div>
      <div class="x-labels">
        <span>월</span><span>화</span><span>수</span><span>목</span>
        <span>금</span><span>토</span><span>오늘</span>
      </div>
    </div>

    <!-- 완료율 바 차트 -->
    <div class="chart-card">
      <div class="chart-title">✅ 주간 완료율</div>
      <div class="chart-sub">각 운동 세션의 목표 달성 비율</div>
      <div class="bar-group">
        <div class="bar-item">
          <div class="bar-pct">100%</div>
          <div class="bar-fill" style="height:80px;background:#4F8EF7;border-radius:6px 6px 0 0;"></div>
          <div class="bar-label">월</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct">80%</div>
          <div class="bar-fill" style="height:64px;background:#7AAEF9;"></div>
          <div class="bar-label">화</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct">100%</div>
          <div class="bar-fill" style="height:80px;background:#4F8EF7;"></div>
          <div class="bar-label">수</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct">-</div>
          <div class="bar-fill" style="height:4px;background:#DBEAFE;"></div>
          <div class="bar-label" style="color:#CBD5E1;">목</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct" style="color:#F59E0B;">75%</div>
          <div class="bar-fill" style="height:60px;background:#F59E0B;"></div>
          <div class="bar-label">금</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct" style="color:#CBD5E1;">-</div>
          <div class="bar-fill" style="height:4px;background:#DBEAFE;"></div>
          <div class="bar-label" style="color:#CBD5E1;">토</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct" style="color:#CBD5E1;">-</div>
          <div class="bar-fill" style="height:4px;background:#DBEAFE;"></div>
          <div class="bar-label" style="color:#CBD5E1;">일</div>
        </div>
      </div>
    </div>

    <!-- 볼륨 추이 -->
    <div class="chart-card">
      <div class="chart-title">📈 주간 운동 볼륨 추이</div>
      <div class="chart-sub">총 볼륨 = Σ (무게 × 횟수 × 세트) kg</div>
      <div class="vol-bars">
        <div class="vol-bar" style="height:28px;opacity:.55;" title="1주: 280kg"></div>
        <div class="vol-bar" style="height:44px;opacity:.65;" title="2주: 420kg"></div>
        <div class="vol-bar" style="height:54px;opacity:.8;" title="3주: 510kg"></div>
        <div class="vol-bar" style="height:70px;background:linear-gradient(180deg,#F59E0B,#D97706);" title="이번주: 650kg"></div>
      </div>
      <div class="vol-labels">
        <span>1주 280</span>
        <span>2주 420</span>
        <span>3주 510</span>
        <span style="color:#F59E0B;font-weight:700;">이번주 650</span>
      </div>
      <div style="text-align:right;font-size:12px;color:#10B981;font-weight:700;margin-top:8px;">
        ▲ 주간 볼륨 +27% 성장
      </div>
    </div>

    <div style="height:10px;"></div>
  </div>

  <div class="nav-bar">
    <div class="nav-item">
      <div class="nav-icon">🏠</div>
      <div class="nav-lbl">홈</div>
    </div>
    <div class="nav-item active">
      <div class="nav-icon">📊</div>
      <div class="nav-lbl" style="color:#4F8EF7;">통계</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">⚙️</div>
      <div class="nav-lbl">설정</div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: 월간 뷰 (탭 전환 후)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-11b · 통계 대시보드 — 월간 탭 전환 후 (Quick-Edit)</div>
  <div class="status-bar"><span>10:23</span><span>●●● WiFi 🔋</span></div>

  <div class="analytics-header">
    <h2>📊 나의 진척도</h2>
    <p>재활 운동 효과를 한눈에 확인하세요</p>
    <div class="period-tabs">
      <div class="period-tab">주간</div>
      <div class="period-tab active">월간</div>
    </div>
  </div>

  <div class="scroll-body">

    <div class="kpi-row">
      <div class="kpi-card">
        <div class="kv" style="color:#10B981;">7→3</div>
        <div class="kl">월간 통증 변화</div>
        <div class="kd pos">▼ 57% 감소</div>
      </div>
      <div class="kpi-card">
        <div class="kv">82%</div>
        <div class="kl">월간 완료율</div>
        <div class="kd pos">▲ +32%p</div>
      </div>
    </div>

    <!-- 월간 통증 그래프 -->
    <div class="chart-card">
      <div class="chart-title">😌 월간 통증 추이 (4주)</div>
      <div class="chart-sub">4주간 NRS 평균 통증 점수 변화</div>
      <div class="chart-area">
        <svg class="svg-chart" viewBox="0 0 320 110" preserveAspectRatio="none">
          <defs>
            <linearGradient id="monthGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#4F8EF7" stop-opacity="0.18"/>
              <stop offset="100%" stop-color="#4F8EF7" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <line x1="0" y1="22" x2="320" y2="22" stroke="#EFF6FF" stroke-width="1"/>
          <line x1="0" y1="55" x2="320" y2="55" stroke="#EFF6FF" stroke-width="1"/>
          <line x1="0" y1="88" x2="320" y2="88" stroke="#EFF6FF" stroke-width="1"/>
          <path d="M 40,33 L 120,44 L 200,66 L 280,88 L 280,110 L 40,110 Z"
                fill="url(#monthGrad)"/>
          <polyline points="40,33 120,44 200,66 280,88"
                fill="none" stroke="#4F8EF7" stroke-width="2.5"
                stroke-linecap="round" stroke-linejoin="round"/>
          <circle cx="40" cy="33" r="6" fill="#EF4444" stroke="#fff" stroke-width="2.5"/>
          <circle cx="120" cy="44" r="5" fill="#F59E0B" stroke="#fff" stroke-width="2"/>
          <circle cx="200" cy="66" r="5" fill="#4F8EF7" stroke="#fff" stroke-width="2"/>
          <circle cx="280" cy="88" r="6" fill="#10B981" stroke="#fff" stroke-width="2.5"/>
          <!-- 라벨 -->
          <text x="30" y="26" fill="#EF4444" font-size="10" font-weight="bold">7점</text>
          <text x="110" y="38" fill="#F59E0B" font-size="10" font-weight="bold">5점</text>
          <text x="190" y="60" fill="#4F8EF7" font-size="10" font-weight="bold">4점</text>
          <text x="270" y="82" fill="#10B981" font-size="10" font-weight="bold">3점</text>
        </svg>
      </div>
      <div class="x-labels">
        <span>1주차</span><span>2주차</span><span>3주차</span><span>4주차</span>
      </div>
    </div>

    <!-- 월간 완료율 -->
    <div class="chart-card">
      <div class="chart-title">✅ 월간 주차별 완료율</div>
      <div class="chart-sub">주차별 세션 달성 비율</div>
      <div class="bar-group">
        <div class="bar-item">
          <div class="bar-pct" style="color:#F59E0B;">60%</div>
          <div class="bar-fill" style="height:48px;background:#F59E0B;"></div>
          <div class="bar-label">1주차</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct">80%</div>
          <div class="bar-fill" style="height:64px;background:#7AAEF9;"></div>
          <div class="bar-label">2주차</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct">88%</div>
          <div class="bar-fill" style="height:70px;background:#4F8EF7;"></div>
          <div class="bar-label">3주차</div>
        </div>
        <div class="bar-item">
          <div class="bar-pct" style="color:#10B981;">100%</div>
          <div class="bar-fill" style="height:80px;background:#10B981;"></div>
          <div class="bar-label">4주차</div>
        </div>
      </div>
    </div>

    <!-- 월간 볼륨 -->
    <div class="chart-card">
      <div class="chart-title">📈 월간 볼륨 성장 추이</div>
      <div class="chart-sub">Σ (무게 × 횟수 × 세트) — 주차별 누적 볼륨</div>
      <div class="vol-bars">
        <div class="vol-bar" style="height:22px;opacity:.5;"></div>
        <div class="vol-bar" style="height:40px;opacity:.65;"></div>
        <div class="vol-bar" style="height:54px;opacity:.8;"></div>
        <div class="vol-bar" style="height:70px;background:linear-gradient(180deg,#10B981,#059669);"></div>
      </div>
      <div class="vol-labels">
        <span>1주 1.2k</span>
        <span>2주 1.8k</span>
        <span>3주 2.3k</span>
        <span style="color:#10B981;font-weight:700;">4주 3.1k</span>
      </div>
      <div style="text-align:right;font-size:12px;color:#10B981;font-weight:700;margin-top:8px;">
        ▲ 월간 볼륨 총 158% 성장
      </div>
    </div>

    <div style="height:10px;"></div>
  </div>

  <div class="nav-bar">
    <div class="nav-item">
      <div class="nav-icon">🏠</div>
      <div class="nav-lbl">홈</div>
    </div>
    <div class="nav-item active">
      <div class="nav-icon">📊</div>
      <div class="nav-lbl" style="color:#4F8EF7;">통계</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">⚙️</div>
      <div class="nav-lbl">설정</div>
    </div>
  </div>
</div>

</body>
</html>
```

---

## SCENARIO:ATM-12

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-12 | 주간 리포트 & AI 미세조정</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0;}
  body{
    font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
    background:#E2ECF8;
    display:flex;
    justify-content:center;
    align-items:flex-start;
    padding:32px 16px;
    gap:24px;
    flex-wrap:wrap;
    min-height:100vh;
  }
  .phone{
    width:375px; height:812px;
    background:#F8FAFC;
    border-radius:50px;
    box-shadow:0 28px 72px rgba(15,23,42,0.22),0 0 0 2px #CBD5E1;
    overflow:hidden;
    display:flex;flex-direction:column;
    position:relative;flex-shrink:0;
  }
  .screen-tag{
    position:absolute;top:0;left:0;right:0;
    background:#1E3A5F;color:#93C5FD;
    font-size:9px;font-weight:700;letter-spacing:1.2px;
    text-align:center;padding:5px;z-index:10;
  }
  .status-bar{
    padding:22px 28px 8px;
    display:flex;justify-content:space-between;
    font-size:11px;font-weight:700;flex-shrink:0;
  }

  /* ── 푸시 알림 화면 ── */
  .notif-screen{
    flex:1;background:#F0F5FF;padding:16px 18px;overflow-y:auto;
  }
  .notif-header{
    font-size:18px;font-weight:800;color:#0F172A;margin-bottom:4px;
  }
  .notif-sub{font-size:12px;color:#475569;margin-bottom:16px;}
  .time-section{font-size:11px;color:#94A3B8;font-weight:600;margin-bottom:10px;}
  .notif-card{
    background:#fff;border-radius:16px;padding:16px;
    margin-bottom:10px;
    box-shadow:0 2px 10px rgba(79,142,247,.1);
    display:flex;gap:12px;align-items:flex-start;
    border-left:4px solid #4F8EF7;
  }
  .notif-icon{font-size:26px;flex-shrink:0;}
  .n-time{font-size:10px;color:#94A3B8;margin-bottom:4px;}
  .n-title{font-size:14px;font-weight:700;color:#0F172A;margin-bottom:4px;}
  .n-body{font-size:12px;color:#475569;line-height:18px;}
  .n-cta{
    display:inline-block;
    margin-top:8px;padding:7px 14px;
    background:#EFF6FF;color:#2B6FD9;
    border-radius:8px;font-size:12px;font-weight:700;cursor:pointer;
  }

  /* ── 주간 리포트 화면 ── */
  .report-header{
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    padding:4px 22px 24px;color:#fff;flex-shrink:0;
  }
  .report-badge{
    display:inline-block;
    background:rgba(255,255,255,.2);border-radius:99px;
    padding:4px 12px;font-size:11px;font-weight:700;margin-bottom:10px;
  }
  .report-title{font-size:20px;font-weight:800;margin-bottom:6px;}
  .report-desc{font-size:13px;opacity:.8;line-height:19px;}
  .scroll-body{flex:1;overflow-y:auto;padding:14px 16px;}
  .summary-strip{display:flex;gap:8px;margin-bottom:14px;}
  .strip-card{
    flex:1;background:#fff;border-radius:12px;padding:12px;
    text-align:center;box-shadow:0 2px 8px rgba(79,142,247,.08);
  }
  .strip-v{font-size:18px;font-weight:900;}
  .strip-l{font-size:10px;color:#475569;margin-top:2px;}
  .strip-d{font-size:11px;font-weight:700;margin-top:4px;}
  .strip-d.pos{color:#10B981;}
  .section-head{
    font-size:13px;font-weight:700;color:#0F172A;
    margin-bottom:10px;display:flex;align-items:center;gap:6px;
  }
  .ai-adjust-card{
    background:#fff;border-radius:16px;padding:16px;
    margin-bottom:10px;
    box-shadow:0 2px 10px rgba(79,142,247,.08);
  }
  .ai-badge{
    display:inline-block;padding:3px 10px;border-radius:99px;
    font-size:11px;font-weight:700;margin-bottom:9px;
  }
  .badge-reduce{background:#D1FAE5;color:#065F46;}
  .badge-increase{background:#EDE9FE;color:#5B21B6;}
  .badge-maintain{background:#FEF9C3;color:#713F12;}
  .ai-title{font-size:14px;font-weight:700;color:#0F172A;margin-bottom:4px;}
  .ai-desc{font-size:12px;color:#475569;line-height:18px;}
  .before-after{
    display:flex;align-items:center;gap:8px;
    margin-top:12px;padding:11px 12px;
    background:#F8FAFC;border-radius:10px;
  }
  .ba-before{font-size:12px;color:#475569;}
  .ba-arrow{font-size:14px;color:#4F8EF7;font-weight:700;flex-shrink:0;}
  .ba-after{font-size:12px;color:#2B6FD9;font-weight:700;}
  .safety-note{
    background:#FFFBEB;border:1.5px solid #FCD34D;
    border-radius:14px;padding:12px 14px;margin-bottom:14px;
    display:flex;gap:10px;align-items:flex-start;
  }
  .safety-icon{font-size:18px;flex-shrink:0;}
  .safety-text{font-size:12px;color:#92400E;line-height:18px;}
  .apply-btn{
    width:100%;padding:16px;
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    color:#fff;border:none;border-radius:16px;
    font-size:16px;font-weight:700;cursor:pointer;
    display:flex;align-items:center;justify-content:center;gap:8px;
    margin-bottom:8px;
    box-shadow:0 4px 16px rgba(79,142,247,.35);
  }
  .skip-btn{
    width:100%;padding:13px;background:transparent;
    color:#475569;border:1.5px solid #DBEAFE;border-radius:16px;
    font-size:14px;font-weight:600;cursor:pointer;
  }
  .footer-pad{padding:14px 16px 32px;}
  .nav-bar{
    display:flex;background:#fff;border-top:1px solid #EFF6FF;flex-shrink:0;
  }
  .nav-item{flex:1;padding:10px 0 14px;text-align:center;cursor:pointer;}
  .nav-icon{font-size:20px;}
  .nav-lbl{font-size:10px;color:#94A3B8;margin-top:2px;font-weight:600;}
</style>
</head>
<body>

<!-- ══════════════════════════════════════════
     PHONE 1: 푸시 알림 화면 (Step 8.1)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">Step 8.1 · 주간 리포트 푸시 알림 수신 화면</div>
  <div class="status-bar" style="background:#F0F5FF;color:#0F172A;">
    <span>오전 9:00</span>
    <span>●●● WiFi 🔋</span>
  </div>

  <div style="
    background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
    padding:6px 22px 18px;color:#fff;flex-shrink:0;
  ">
    <div style="font-size:13px;opacity:.8;margin-bottom:3px;">알림 센터</div>
    <div style="font-size:20px;font-weight:800;">오늘 도착한 알림</div>
  </div>

  <div class="notif-screen">
    <div class="time-section">방금 전</div>

    <div class="notif-card">
      <div class="notif-icon">🤖</div>
      <div>
        <div class="n-time">RecoveryFit · 방금</div>
        <div class="n-title">📊 주간 리포트가 도착했습니다</div>
        <div class="n-body">
          지난주 통증이 <strong>5점 → 3점</strong>으로 감소했습니다! 🎉<br>
          AI가 차주 플랜을 미세조정했어요. 확인해보세요.
        </div>
        <span class="n-cta">주간 리포트 보기 →</span>
      </div>
    </div>

    <div class="time-section" style="margin-top:16px;">어제</div>

    <div class="notif-card" style="border-color:#DBEAFE;opacity:.6;">
      <div class="notif-icon">⏰</div>
      <div>
        <div class="n-time">RecoveryFit · 어제 오전 8:00</div>
        <div class="n-title">오늘의 운동을 시작해요!</div>
        <div class="n-body">오늘 루틴: 무릎 재활 3종 + 메인 2종 (예상 25분)</div>
        <span class="n-cta">운동 시작 →</span>
      </div>
    </div>

    <div style="
      background:#EFF6FF;border-radius:14px;
      padding:14px;margin-top:14px;text-align:center;
    ">
      <div style="font-size:13px;color:#4F8EF7;font-weight:700;margin-bottom:5px;">
        💡 원터치 진입 안내
      </div>
      <div style="font-size:12px;color:#475569;line-height:18px;">
        알림을 탭하면 주간 리포트 화면으로<br>
        바로 이동합니다 (추가 탐색 없음)
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 2: 주간 리포트 & AI 미세조정 (Step 8.2)
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-12 · 주간 리포트 & AI 미세조정 — Step 8.2</div>
  <div class="status-bar" style="background:linear-gradient(135deg,#4F8EF7,#2B6FD9);color:#fff;">
    <span>오전 9:01</span><span>●●● WiFi 🔋</span>
  </div>

  <div class="report-header">
    <div class="report-badge">3주차 주간 리포트</div>
    <div class="report-title">🤖 AI 미세조정 완료</div>
    <div class="report-desc">
      지난 7일 기록을 분석하여<br>차주 플랜이 업데이트되었습니다
    </div>
  </div>

  <div class="scroll-body">

    <!-- 주간 요약 수치 -->
    <div class="summary-strip">
      <div class="strip-card">
        <div class="strip-v" style="color:#10B981;">3점</div>
        <div class="strip-l">주간 통증</div>
        <div class="strip-d pos">▼ -2점</div>
      </div>
      <div class="strip-card">
        <div class="strip-v" style="color:#4F8EF7;">75%</div>
        <div class="strip-l">완료율</div>
        <div class="strip-d pos">▲ +15%</div>
      </div>
      <div class="strip-card">
        <div class="strip-v" style="color:#F59E0B;">650</div>
        <div class="strip-l">볼륨 (kg)</div>
        <div class="strip-d pos">▲ +27%</div>
      </div>
    </div>

    <!-- AI 조정 내역 -->
    <div class="section-head">🔧 AI 조정 내역 (Claude Haiku)</div>

    <div class="ai-adjust-card">
      <span class="ai-badge badge-reduce">재활 동작 감소</span>
      <div class="ai-title">단기 재활 보조 동작 비중 조정</div>
      <div class="ai-desc">
        통증이 안정적으로 감소했으므로 재활 전용 동작 비중을 줄이고
        점진적으로 근력 강화 단계로 전환합니다.
      </div>
      <div class="before-after">
        <span class="ba-before">재활 3종 × 3세트</span>
        <span class="ba-arrow">→</span>
        <span class="ba-after">재활 2종 × 3세트 (▼20%)</span>
      </div>
    </div>

    <div class="ai-adjust-card">
      <span class="ai-badge badge-increase">메인 강도 상향</span>
      <div class="ai-title">메인 근력 동작 부하 증가</div>
      <div class="ai-desc">
        볼륨이 안정적으로 성장하고 있어 점진적 과부하 원칙에 따라
        메인 운동 무게를 소폭 올립니다.
      </div>
      <div class="before-after">
        <span class="ba-before">월 스쿼트 5kg × 10회</span>
        <span class="ba-arrow">→</span>
        <span class="ba-after">7.5kg × 10회 (+2.5kg)</span>
      </div>
    </div>

    <div class="ai-adjust-card">
      <span class="ai-badge badge-maintain">빈도 유지</span>
      <div class="ai-title">주 3회 스케줄 유지</div>
      <div class="ai-desc">
        현재 출석률(75%)과 회복 패턴이 최적화되어 있어
        운동 빈도는 그대로 유지합니다.
      </div>
      <div class="before-after">
        <span class="ba-before">주 3회</span>
        <span class="ba-arrow">→</span>
        <span class="ba-after">주 3회 (유지)</span>
      </div>
    </div>

    <div class="safety-note">
      <div class="safety-icon">🛡️</div>
      <div class="safety-text">
        <strong>이중 안전 검증 통과</strong> — 모든 조정 사항이 15개 안전 규칙을 통과했습니다.
        무릎 부상 제약 조건(스쿼트 하중 제한) 준수 확인 완료.
      </div>
    </div>
  </div>

  <div class="footer-pad">
    <button class="apply-btn">⚡ 차주 플랜 적용하기 (원터치)</button>
    <button class="skip-btn">나중에 검토하기</button>
  </div>

  <div class="nav-bar">
    <div class="nav-item">
      <div class="nav-icon">🏠</div>
      <div class="nav-lbl">홈</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">📊</div>
      <div class="nav-lbl">통계</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">⚙️</div>
      <div class="nav-lbl">설정</div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════
     PHONE 3: 플랜 적용 완료 확인 화면
══════════════════════════════════════════ -->
<div class="phone">
  <div class="screen-tag">SCR-12b · 차주 플랜 적용 완료 — 원터치 승인 후 결과 화면</div>
  <div class="status-bar" style="background:#F8FAFC;color:#0F172A;">
    <span>오전 9:02</span><span>●●● WiFi 🔋</span>
  </div>

  <div style="
    flex:1;
    display:flex;flex-direction:column;
    align-items:center;justify-content:center;
    padding:32px 24px;
    background:#F8FAFC;
  ">
    <div style="
      width:96px;height:96px;border-radius:50%;
      background:linear-gradient(135deg,#10B981,#059669);
      display:flex;align-items:center;justify-content:center;
      font-size:48px;margin-bottom:24px;
      box-shadow:0 12px 36px rgba(16,185,129,.3);
    ">✓</div>

    <div style="font-size:24px;font-weight:900;color:#0F172A;margin-bottom:8px;text-align:center;">
      플랜 적용 완료!
    </div>
    <div style="font-size:14px;color:#475569;text-align:center;line-height:22px;margin-bottom:32px;">
      4주차 AI 미세조정 플랜이<br>
      내일부터 자동 적용됩니다 🎊
    </div>

    <div style="width:100%;background:#fff;border-radius:16px;padding:16px;margin-bottom:20px;box-shadow:0 2px 10px rgba(79,142,247,.08);">
      <div style="font-size:12px;font-weight:700;color:#475569;margin-bottom:12px;letter-spacing:.6px;text-transform:uppercase;">
        4주차 주요 변경 내역
      </div>
      <div style="display:flex;flex-direction:column;gap:10px;">
        <div style="display:flex;align-items:center;gap:10px;font-size:13px;">
          <span style="width:20px;height:20px;border-radius:50%;background:#D1FAE5;color:#065F46;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0;">✓</span>
          <span style="color:#0F172A;">재활 동작 3종 → 2종 (20% 감소)</span>
        </div>
        <div style="display:flex;align-items:center;gap:10px;font-size:13px;">
          <span style="width:20px;height:20px;border-radius:50%;background:#EDE9FE;color:#5B21B6;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0;">✓</span>
          <span style="color:#0F172A;">월 스쿼트 무게 5kg → 7.5kg</span>
        </div>
        <div style="display:flex;align-items:center;gap:10px;font-size:13px;">
          <span style="width:20px;height:20px;border-radius:50%;background:#FEF9C3;color:#713F12;display:flex;align-items:center;justify-content:center;font-size:11px;flex-shrink:0;">✓</span>
          <span style="color:#0F172A;">주 3회 빈도 유지</span>
        </div>
      </div>
    </div>

    <div style="
      background:#EFF6FF;border-radius:14px;
      padding:14px;width:100%;
      font-size:12px;color:#2B6FD9;
      text-align:center;line-height:19px;
      margin-bottom:24px;
    ">
      🛡️ 15개 안전 규칙 검증 완료<br>
      다음 주간 리포트: <strong>2월 7일(금)</strong>
    </div>

    <button style="
      width:100%;padding:15px;
      background:linear-gradient(135deg,#4F8EF7,#2B6FD9);
      color:#fff;border:none;border-radius:16px;
      font-size:16px;font-weight:700;cursor:pointer;
      box-shadow:0 4px 16px rgba(79,142,247,.35);
    ">홈으로 돌아가기</button>
  </div>

  <div class="nav-bar">
    <div class="nav-item">
      <div class="nav-icon">🏠</div>
      <div class="nav-lbl">홈</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">📊</div>
      <div class="nav-lbl">통계</div>
    </div>
    <div class="nav-item">
      <div class="nav-icon">⚙️</div>
      <div class="nav-lbl">설정</div>
    </div>
  </div>
</div>

</body>
</html>
```