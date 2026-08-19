# UX Designer
Project: c052dd6b | Stage: design

# Design Spec — RecoveryFit 시작 페이지 (c052dd6b)

## 1. JSON 스펙

```json
{
  "screens": [
    {
      "id": "SplashScreen",
      "req": "REQ-00-A",
      "description": "앱 최초 진입 로딩 화면",
      "background": "#0D1B2A",
      "elements": ["logo_wordmark", "logo_symbol", "tagline", "loading_dots"],
      "animation": "fadeIn 0.6s → hold 1.2s → fadeOut 0.4s",
      "duration_min": 2000,
      "duration_max": 5000,
      "transitions": {
        "new_user": "LandingScreen",
        "returning_user": "HomeDashboardScreen"
      }
    },
    {
      "id": "LandingScreen",
      "req": "REQ-00-B",
      "description": "신규 사용자 최초 랜딩 — 단일 CTA 진입",
      "layout": "fullscreen_no_scroll",
      "background": "hero_illustration + gradient_overlay",
      "elements": [
        "header_logo",
        "hero_image_zone",
        "main_headline",
        "sub_headline",
        "value_props_3col",
        "cta_button",
        "disclaimer_text"
      ],
      "transitions": {
        "cta_tap": "OnboardingDisclaimerScreen"
      }
    }
  ],
  "components": [
    {
      "id": "LogoWordmark",
      "type": "text",
      "content": "RecoveryFit",
      "color": "#FFFFFF",
      "font": "Bold 28sp"
    },
    {
      "id": "LogoSymbol",
      "type": "icon",
      "icon": "recovery-loop",
      "color": "#00C9A7",
      "size": 48
    },
    {
      "id": "Tagline",
      "type": "text",
      "content": "부상 후, 더 강하게",
      "color": "#FFFFFF",
      "font": "Regular 16sp",
      "letter_spacing": "0.08em"
    },
    {
      "id": "LoadingDots",
      "type": "animation",
      "dots": 3,
      "color": "#00C9A7",
      "animation": "bounce_sequential 0.4s infinite"
    },
    {
      "id": "HeroGradientOverlay",
      "type": "gradient",
      "from": "transparent",
      "to": "rgba(13,27,42,0.60)",
      "direction": "top_to_bottom"
    },
    {
      "id": "MainHeadline",
      "type": "text",
      "content": "부상 후에도\n운동할 수 있어요",
      "color": "#FFFFFF",
      "font": "Bold 28sp",
      "line_height": 1.35
    },
    {
      "id": "SubHeadline",
      "type": "text",
      "content": "AI가 내 부상 상태를 분석하고\n안전한 재활 플랜을 만들어드려요",
      "color": "rgba(255,255,255,0.80)",
      "font": "Regular 15sp",
      "line_height": 1.5,
      "margin_top": 12
    },
    {
      "id": "ValueProps",
      "type": "row_3col",
      "items": [
        { "icon": "shield-check", "color": "#00C9A7", "label": "이중 안전\n검증" },
        { "icon": "brain", "color": "#00C9A7", "label": "AI 개인화\n플랜" },
        { "icon": "touch", "color": "#00C9A7", "label": "터치 최소화\n인터페이스" }
      ],
      "icon_size": 24,
      "text_style": "Regular 12sp rgba(255,255,255,0.70)"
    },
    {
      "id": "CTAButton",
      "type": "button",
      "label": "무료로 시작하기",
      "background": "#00C9A7",
      "text_color": "#0D1B2A",
      "font": "Bold 17sp",
      "border_radius": 14,
      "height": 56,
      "margin_horizontal": 24,
      "press_effect": "scale(0.97) brightness(0.9) 100ms"
    },
    {
      "id": "DisclaimerText",
      "type": "text",
      "content": "의료기기 아님 · 전문의 상담을 대체하지 않습니다",
      "color": "rgba(255,255,255,0.45)",
      "font": "Regular 11sp",
      "align": "center",
      "margin_top": 12
    }
  ],
  "design_tokens": {
    "color": {
      "primary_dark": "#0D1B2A",
      "primary_mint": "#00C9A7",
      "primary_mint_light": "#33D4B8",
      "text_primary": "#FFFFFF",
      "text_secondary": "rgba(255,255,255,0.70)",
      "text_tertiary": "rgba(255,255,255,0.45)",
      "surface_overlay": "rgba(13,27,42,0.60)"
    },
    "typography": {
      "headline_l": "Bold 28sp / 1.35",
      "headline_m": "SemiBold 22sp / 1.4",
      "body_l": "Regular 15sp / 1.5",
      "body_s": "Regular 12sp / 1.4",
      "caption": "Regular 11sp / 1.3",
      "button": "Bold 17sp / letter-spacing 0.01em"
    },
    "motion": {
      "duration_fast": "100ms",
      "duration_normal": "200ms",
      "duration_slow": "400ms",
      "easing": "ease-in-out"
    },
    "radius": {
      "button": "14px",
      "card": "16px",
      "pill": "99px"
    },
    "spacing": {
      "screen_horizontal": "24px",
      "cta_bottom_offset": "32px",
      "section_gap": "24px"
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
<title>ATM-5 | 스플래시 → 랜딩 → 온보딩 Step 1~2</title>
<style>
*{box-sizing:border-box;margin:0;padding:0;}
body{
  font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;
  background:#C8D8D4;
  display:flex;
  justify-content:center;
  padding:32px 16px;
  gap:24px;
  flex-wrap:wrap;
  min-height:100vh;
}

/* ── 공통 폰 프레임 ── */
.phone{
  width:375px;
  min-height:720px;
  border-radius:48px;
  box-shadow:0 32px 80px rgba(0,0,0,0.28);
  overflow:hidden;
  border:2.5px solid rgba(255,255,255,0.3);
  display:flex;
  flex-direction:column;
  position:relative;
}
.screen-badge{
  position:absolute;
  top:12px;
  left:50%;
  transform:translateX(-50%);
  background:rgba(0,0,0,0.55);
  color:#fff;
  font-size:9px;
  font-weight:700;
  letter-spacing:1.2px;
  padding:3px 10px;
  border-radius:99px;
  z-index:100;
  white-space:nowrap;
}
.status-bar{
  display:flex;
  justify-content:space-between;
  align-items:center;
  padding:14px 24px 8px;
  font-size:11px;
  font-weight:700;
  flex-shrink:0;
  z-index:10;
  position:relative;
}

/* ══════════════════════════════════
   SCREEN A: SPLASH
══════════════════════════════════ */
.splash{
  flex:1;
  background:#0D1B2A;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  padding:40px 24px;
}
.splash .status-bar{
  color:rgba(255,255,255,0.7);
  position:absolute;
  top:0;left:0;right:0;
}
.splash-logo-wrap{
  display:flex;
  flex-direction:column;
  align-items:center;
  gap:0;
}
.splash-symbol{
  width:72px;
  height:72px;
  border-radius:22px;
  background:linear-gradient(135deg,#00C9A7 0%,#00957C 100%);
  display:flex;
  align-items:center;
  justify-content:center;
  margin-bottom:18px;
  box-shadow:0 12px 32px rgba(0,201,167,0.35);
}
.splash-symbol svg{
  width:40px;
  height:40px;
}
.splash-wordmark{
  font-size:30px;
  font-weight:800;
  color:#FFFFFF;
  letter-spacing:-0.5px;
  margin-bottom:4px;
}
.splash-wordmark span{
  color:#00C9A7;
}
.splash-tagline{
  font-size:15px;
  color:rgba(255,255,255,0.75);
  letter-spacing:0.08em;
  margin-top:10px;
  margin-bottom:40px;
}
.dots-wrap{
  display:flex;
  gap:8px;
  align-items:center;
}
.dot{
  width:8px;
  height:8px;
  border-radius:50%;
  background:#00C9A7;
  animation:dotBounce 1.2s ease-in-out infinite;
}
.dot:nth-child(2){animation-delay:0.2s;}
.dot:nth-child(3){animation-delay:0.4s;}
@keyframes dotBounce{
  0%,80%,100%{opacity:0.3;transform:scale(0.8);}
  40%{opacity:1;transform:scale(1.2);}
}

/* ══════════════════════════════════
   SCREEN B: LANDING
══════════════════════════════════ */
.landing{
  flex:1;
  background:#0D1B2A;
  display:flex;
  flex-direction:column;
  position:relative;
}
.landing .status-bar{
  color:rgba(255,255,255,0.8);
  background:transparent;
}

/* 히어로 일러스트 영역 */
.hero-zone{
  position:absolute;
  top:0;left:0;right:0;
  height:55%;
  overflow:hidden;
}
.hero-illustration{
  width:100%;
  height:100%;
  background:linear-gradient(160deg,#1A3A4A 0%,#0F2535 60%,#0D1B2A 100%);
  display:flex;
  align-items:center;
  justify-content:center;
  position:relative;
}
/* SVG 일러스트 배치 */
.hero-illustration svg{
  opacity:0.9;
}
/* 그라디언트 오버레이 */
.hero-overlay{
  position:absolute;
  bottom:0;left:0;right:0;
  height:70%;
  background:linear-gradient(to bottom, transparent 0%, rgba(13,27,42,0.6) 50%, #0D1B2A 100%);
}

/* 헤더 로고 */
.landing-header{
  position:relative;
  z-index:10;
  padding:52px 24px 0;
  display:flex;
  align-items:center;
  gap:8px;
}
.landing-logo-icon{
  width:28px;
  height:28px;
  border-radius:8px;
  background:#00C9A7;
  display:flex;
  align-items:center;
  justify-content:center;
}
.landing-logo-text{
  font-size:17px;
  font-weight:800;
  color:#fff;
  letter-spacing:-0.3px;
}

/* 콘텐츠 영역 */
.landing-content{
  position:absolute;
  bottom:0;left:0;right:0;
  padding:0 24px 0;
  z-index:10;
  top:42%;
  display:flex;
  flex-direction:column;
  justify-content:flex-end;
  padding-bottom:28px;
}
.main-headline{
  font-size:28px;
  font-weight:800;
  color:#FFFFFF;
  line-height:1.35;
  margin-bottom:12px;
}
.sub-headline{
  font-size:15px;
  font-weight:400;
  color:rgba(255,255,255,0.80);
  line-height:1.5;
  margin-bottom:24px;
}
/* 가치 포인트 3종 */
.value-row{
  display:flex;
  gap:0;
  margin-bottom:28px;
}
.value-item{
  flex:1;
  display:flex;
  flex-direction:column;
  align-items:center;
  gap:6px;
  text-align:center;
}
.value-icon{
  width:40px;
  height:40px;
  border-radius:12px;
  background:rgba(0,201,167,0.15);
  border:1px solid rgba(0,201,167,0.3);
  display:flex;
  align-items:center;
  justify-content:center;
}
.value-icon svg{
  width:20px;
  height:20px;
}
.value-label{
  font-size:11px;
  font-weight:600;
  color:rgba(255,255,255,0.70);
  line-height:1.4;
}
/* CTA 버튼 */
.cta-btn{
  width:100%;
  height:56px;
  background:#00C9A7;
  color:#0D1B2A;
  border:none;
  border-radius:14px;
  font-size:17px;
  font-weight:800;
  cursor:pointer;
  letter-spacing:0.01em;
  margin-bottom:12px;
  display:flex;
  align-items:center;
  justify-content:center;
  gap:8px;
  box-shadow:0 8px 24px rgba(0,201,167,0.35);
  transition:transform 0.1s, filter 0.1s;
}
.cta-btn:active{
  transform:scale(0.97);
  filter:brightness(0.9);
}
.disclaimer-text{
  font-size:11px;
  color:rgba(255,255,255,0.45);
  text-align:center;
  line-height:1.3;
}

/* ══════════════════════════════════
   SCREEN C: 면책 동의 (기존 유지)
══════════════════════════════════ */
.disc-bg{
  flex:1;
  background:linear-gradient(160deg,#2E7D6B 0%,#1B5E4F 100%);
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:flex-end;
}
.disc-hero{
  padding:40px 24px 24px;
  color:#fff;
  text-align:center;
  flex:1;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
}
.disc-sheet{
  background:#fff;
  border-radius:28px 28px 0 0;
  padding:24px 22px 32px;
  width:100%;
}
.handle{width:40px;height:4px;border-radius:2px;background:#D4E0DB;margin:0 auto 18px;}
.disc-icon-box{
  width:52px;height:52px;border-radius:14px;
  background:#EEF7F4;
  display:flex;align-items:center;justify-content:center;
  font-size:26px;margin-bottom:14px;
}
.disc-sheet h2{font-size:18px;font-weight:700;color:#1A2420;margin-bottom:8px;}
.disc-sheet p{font-size:13px;color:#5A7068;line-height:20px;margin-bottom:12px;}
.warn-box{
  background:#FFF8F0;border:1.5px solid #F4A261;
  border-radius:10px;padding:10px 13px;
  font-size:12px;color:#C96A00;margin-bottom:18px;line-height:18px;
}
.btn-primary{
  width:100%;padding:15px;background:#2E7D6B;
  color:#fff;border:none;border-radius:14px;
  font-size:16px;font-weight:700;cursor:pointer;margin-bottom:8px;
}
.btn-secondary{
  width:100%;padding:12px;background:#F0F4F2;
  color:#5A7068;border:none;border-radius:14px;
  font-size:14px;font-weight:600;cursor:pointer;
}

/* SCREEN D: 부상 입력 (기존 유지) */
.ob-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:20px 22px 26px;color:#fff;flex-shrink:0;}
.step-row{display:flex;gap:5px;margin-bottom:12px;}
.step-pip{height:4px;border-radius:2px;background:rgba(255,255,255,0.3);flex:1;}
.step-pip.done{background:rgba(255,255,255,0.7);}
.step-pip.active{background:#fff;}
.ob-badge{display:inline-block;background:rgba(255,255,255,0.2);border-radius:99px;padding:3px 10px;font-size:11px;margin-bottom:8px;}
.ob-header h1{font-size:20px;font-weight:700;line-height:28px;}
.ob-header p{font-size:13px;opacity:.8;margin-top:4px;}
.ob-body{flex:1;padding:20px 18px;overflow-y:auto;}
.field-label{font-size:11px;font-weight:700;color:#5A7068;letter-spacing:.5px;margin-bottom:8px;text-transform:uppercase;}
.txt-input{
  width:100%;border:1.5px solid #D4E0DB;border-radius:12px;
  padding:12px 14px;font-size:14px;color:#1A2420;
  background:#F8FAF9;outline:none;margin-bottom:14px;
  font-family:inherit;resize:none;
}
.txt-input.filled{border-color:#2E7D6B;background:#fff;}
.chip-wrap{display:flex;flex-wrap:wrap;gap:7px;margin-bottom:18px;}
.chip{padding:8px 12px;border-radius:99px;font-size:12px;font-weight:600;border:1.5px solid #D4E0DB;background:#F0F4F2;color:#1A2420;cursor:pointer;}
.chip.sel{background:#2E7D6B;color:#fff;border-color:#2E7D6B;}
.chip.example{background:#EEF7F4;border-color:#B2D8CF;color:#1B5E4F;}
.ob-footer{padding:14px 18px 26px;flex-shrink:0;}
.hint{font-size:11px;color:#A0B4AE;text-align:center;margin-top:8px;}
.tip-box{background:#EEF7F4;border-radius:12px;padding:12px 14px;border-left:3px solid #2E7D6B;}
.tip-title{font-size:12px;color:#2E7D6B;font-weight:700;margin-bottom:3px;}
.tip-body{font-size:12px;color:#5A7068;line-height:18px;}
</style>
</head>
<body>

<!-- ■ SCREEN A: 스플래시 -->
<div class="phone" style="background:#0D1B2A;">
  <div class="screen-badge">A — SPLASH SCREEN</div>
  <div class="status-bar" style="color:rgba(255,255,255,0.7);position:absolute;top:0;left:0;right:0;z-index:20;">
    <span>9:41</span><span>●●● WiFi 🔋</span>
  </div>
  <div class="splash">
    <div class="splash-logo-wrap">
      <!-- 심볼 아이콘 -->
      <div class="splash-symbol">
        <svg viewBox="0 0 40 40" fill="none">
          <path d="M20 6C12.268 6 6 12.268 6 20s6.268 14 14 14 14-6.268 14-14S27.732 6 20 6z" stroke="#fff" stroke-width="2.5" fill="none"/>
          <path d="M14 20c0-3.314 2.686-6 6-6s6 2.686 6 6" stroke="#fff" stroke-width="2.5" stroke-linecap="round"/>
          <path d="M26 20c0 3.314-2.686 6-6 6" stroke="rgba(255,255,255,0.5)" stroke-width="2.5" stroke-linecap="round" stroke-dasharray="4 3"/>
          <circle cx="20" cy="20" r="3" fill="#fff"/>
          <!-- 화살표 (회복 순환) -->
          <path d="M28 16l2-3 3 1" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
      </div>
      <div class="splash-wordmark">Recovery<span>Fit</span></div>
      <div class="splash-tagline">부상 후, 더 강하게</div>
      <!-- 로딩 도트 -->
      <div class="dots-wrap">
        <div class="dot"></div>
        <div class="dot"></div>
        <div class="dot"></div>
      </div>
    </div>
  </div>
  <!-- 하단 페이드인 설명 -->
  <div style="padding:0 24px 36px;text-align:center;position:relative;z-index:10;">
    <div style="font-size:10px;color:rgba(255,255,255,0.3);letter-spacing:1px;">AI 기반 부상 재활 운동 플랜</div>
  </div>
</div>

<!-- ■ SCREEN B: 랜딩 -->
<div class="phone" style="background:#0D1B2A;">
  <div class="screen-badge">B — LANDING SCREEN</div>

  <!-- 상태바 -->
  <div class="status-bar" style="color:rgba(255,255,255,0.8);position:absolute;top:0;left:0;right:0;z-index:20;">
    <span>9:41</span><span>●●● WiFi 🔋</span>
  </div>

  <!-- 히어로 일러스트 영역 (상단 55%) -->
  <div class="hero-zone">
    <div class="hero-illustration">
      <!-- 재활 운동 일러스트 (인라인 SVG) -->
      <svg viewBox="0 0 375 260" width="375" height="260" fill="none" xmlns="http://www.w3.org/2000/svg">
        <!-- 배경 원형 광원 -->
        <ellipse cx="187" cy="130" rx="120" ry="90" fill="rgba(0,201,167,0.06)"/>
        <ellipse cx="187" cy="130" rx="80" ry="60" fill="rgba(0,201,167,0.08)"/>

        <!-- 인물: 레그 레이즈 자세 (누운 재활 운동) -->
        <!-- 매트 -->
        <rect x="60" y="190" width="255" height="12" rx="6" fill="rgba(0,201,167,0.2)"/>
        <!-- 몸통 -->
        <rect x="100" y="165" width="130" height="28" rx="14" fill="rgba(255,255,255,0.15)"/>
        <!-- 머리 -->
        <circle cx="108" cy="165" r="20" fill="rgba(255,255,255,0.18)"/>
        <!-- 눈 -->
        <circle cx="103" cy="163" r="2.5" fill="rgba(0,201,167,0.8)"/>
        <circle cx="113" cy="163" r="2.5" fill="rgba(0,201,167,0.8)"/>
        <!-- 다리 들어올린 상태 -->
        <rect x="220" y="140" width="90" height="22" rx="11" fill="rgba(255,255,255,0.18)" transform="rotate(-25 220 140)"/>
        <!-- 발 -->
        <ellipse cx="300" cy="120" rx="18" ry="10" fill="rgba(0,201,167,0.3)" transform="rotate(-25 300 120)"/>

        <!-- 상단: 아이콘 박스들 -->
        <!-- 심박 아이콘 -->
        <rect x="42" y="30" width="52" height="52" rx="14" fill="rgba(0,201,167,0.12)" stroke="rgba(0,201,167,0.3)" stroke-width="1.5"/>
        <path d="M56 57l4-8 4 14 4-10 3 4h8" stroke="#00C9A7" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

        <!-- AI 아이콘 -->
        <rect x="282" y="30" width="52" height="52" rx="14" fill="rgba(0,201,167,0.12)" stroke="rgba(0,201,167,0.3)" stroke-width="1.5"/>
        <circle cx="308" cy="52" r="10" stroke="#00C9A7" stroke-width="2"/>
        <circle cx="308" cy="52" r="4" fill="#00C9A7" opacity="0.6"/>
        <line x1="308" y1="38" x2="308" y2="42" stroke="#00C9A7" stroke-width="1.5"/>
        <line x1="308" y1="62" x2="308" y2="66" stroke="#00C9A7" stroke-width="1.5"/>
        <line x1="294" y1="52" x2="298" y2="52" stroke="#00C9A7" stroke-width="1.5"/>
        <line x1="318" y1="52" x2="322" y2="52" stroke="#00C9A7" stroke-width="1.5"/>

        <!-- 통증 감소 그래프 (우측 상단) -->
        <rect x="120" y="20" width="135" height="55" rx="12" fill="rgba(13,27,42,0.6)" stroke="rgba(0,201,167,0.2)" stroke-width="1"/>
        <text x="133" y="38" font-family="Arial" font-size="9" fill="rgba(255,255,255,0.5)">통증 점수 추이</text>
        <polyline points="135,65 155,58 175,52 195,54 215,42 235,30" stroke="#00C9A7" stroke-width="2" stroke-linecap="round" fill="none"/>
        <circle cx="235" cy="30" r="3" fill="#00C9A7"/>

        <!-- 장식 파티클 -->
        <circle cx="70" cy="100" r="3" fill="rgba(0,201,167,0.4)"/>
        <circle cx="310" cy="110" r="2" fill="rgba(0,201,167,0.3)"/>
        <circle cx="160" cy="15" r="2" fill="rgba(255,255,255,0.2)"/>
        <circle cx="240" cy="20" r="1.5" fill="rgba(255,255,255,0.15)"/>
      </svg>
      <div class="hero-overlay"></div>
    </div>
  </div>

  <!-- 헤더 로고 -->
  <div class="landing-header" style="position:relative;z-index:20;padding-top:50px;">
    <div class="landing-logo-icon">
      <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
        <path d="M8 2C4.686 2 2 4.686 2 8s2.686 6 6 6 6-2.686 6-6-2.686-6-6-6z" stroke="#0D1B2A" stroke-width="1.5" fill="none"/>
        <circle cx="8" cy="8" r="2" fill="#0D1B2A"/>
        <path d="M5 8c0-1.657 1.343-3 3-3" stroke="#0D1B2A" stroke-width="1.5" stroke-linecap="round"/>
      </svg>
    </div>
    <div class="landing-logo-text">RecoveryFit</div>
  </div>

  <!-- 메인 콘텐츠 -->
  <div class="landing-content">
    <div class="main-headline">부상 후에도<br>운동할 수 있어요</div>
    <div class="sub-headline">AI가 내 부상 상태를 분석하고<br>안전한 재활 플랜을 만들어드려요</div>

    <!-- 가치 포인트 3종 -->
    <div class="value-row">
      <div class="value-item">
        <div class="value-icon">
          <svg viewBox="0 0 20 20" fill="none">
            <path d="M10 2L3 5v5c0 3.866 2.985 7.481 7 8.478C14.015 17.481 17 13.866 17 10V5l-7-3z" stroke="#00C9A7" stroke-width="1.5" fill="none"/>
            <path d="M7 10l2 2 4-4" stroke="#00C9A7" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <div class="value-label">이중 안전<br>검증</div>
      </div>
      <div class="value-item">
        <div class="value-icon">
          <svg viewBox="0 0 20 20" fill="none">
            <ellipse cx="10" cy="8" rx="6" ry="5" stroke="#00C9A7" stroke-width="1.5"/>
            <path d="M7 13c0 2.21 1.343 4 3 4s3-1.79 3-4" stroke="#00C9A7" stroke-width="1.5" stroke-linecap="round"/>
            <circle cx="8" cy="7" r="1.2" fill="#00C9A7"/>
            <circle cx="12" cy="7" r="1.2" fill="#00C9A7"/>
          </svg>
        </div>
        <div class="value-label">AI 개인화<br>플랜</div>
      </div>
      <div class="value-item">
        <div class="value-icon">
          <svg viewBox="0 0 20 20" fill="none">
            <circle cx="10" cy="8" r="3" stroke="#00C9A7" stroke-width="1.5"/>
            <path d="M10 11v2m-3 2h6" stroke="#00C9A7" stroke-width="1.5" stroke-linecap="round"/>
            <path d="M6 6.5C6 4.015 7.79 2 10 2s4 2.015 4 4.5" stroke="#00C9A7" stroke-width="1.5" stroke-linecap="round" fill="none"/>
          </svg>
        </div>
        <div class="value-label">터치 최소화<br>인터페이스</div>
      </div>
    </div>

    <!-- CTA 버튼 -->
    <button class="cta-btn">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
        <path d="M10 4v12m6-6l-6 6-6-6" stroke="#0D1B2A" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      무료로 시작하기
    </button>

    <!-- 보조 텍스트 -->
    <div class="disclaimer-text">의료기기 아님 · 전문의 상담을 대체하지 않습니다</div>
  </div>
</div>

<!-- ■ SCREEN C: 면책 동의 -->
<div class="phone">
  <div class="screen-badge">C — 면책 동의 (Step 1.1)</div>
  <div class="status-bar" style="background:#2E7D6B;color:#fff;">
    <span>9:41</span><span>●●● WiFi 🔋</span>
  </div>
  <div class="disc-bg">
    <div class="disc-hero">
      <div style="font-size:52px;margin-bottom:14px;">🏃</div>
      <div style="font-size:24px;font-weight:800;color:#fff;">RecoveryFit</div>
      <div style="font-size:13px;color:rgba(255,255,255,0.7);margin-top:5px;">AI 기반 부상 재활 운동 플랜</div>
    </div>
    <div class="disc-sheet">
      <div class="handle"></div>
      <div class="disc-icon-box">⚕️</div>
      <h2>이용 전 꼭 확인하세요</h2>
      <p>RecoveryFit은 <strong>의료기기가 아닙니다.</strong> 전문 의료인의 진단을 대체하지 않으며, 제공되는 운동 플랜은 일반적인 재활 가이드라인을 기반으로 합니다.</p>
      <div class="warn-box">⚠️ 급성 통증·골절·수술 후 회복 중인 경우 반드시 전문의 상담 후 이용하세요.</div>
      <button class="btn-primary">동의하고 시작</button>
      <button class="btn-secondary">나중에 읽기</button>
    </div>
  </div>
</div>

<!-- ■ SCREEN D: 부상 입력 -->
<div class="phone" style="background:#fff;">
  <div class="screen-badge">D — 부상 입력 (Step 1.2)</div>
  <div class="status-bar" style="background:#2E7D6B;color:#fff;">
    <span>9:42</span><span>●●● WiFi 🔋</span>
  </div>
  <div class="ob-header">
    <div class="step-row">
      <div class="step-pip done"></div>
      <div class="step-pip active"></div>
      <div class="step-pip"></div>
      <div class="step-pip"></div>
      <div class="step-pip"></div>
      <div class="step-pip"></div>
    </div>
    <div class="ob-badge">1 / 6 단계</div>
    <h1>어디가 불편하신가요?</h1>
    <p>부상 부위나 통증 상황을 자유롭게 알려주세요</p>
  </div>
  <div class="ob-body">
    <div class="field-label">부상 / 통증 설명</div>
    <textarea class="txt-input filled" rows="3">무릎 인대 나갔어요</textarea>
    <div class="field-label">빠른 선택 예시</div>
    <div class="chip-wrap">
      <span class="chip example sel">무릎 인대 나갔어요</span>
      <span class="chip example">허리 디스크 초기</span>
      <span class="chip example">어깨 회전근개 통증</span>
    </div>
    <div class="tip-box">
      <div class="tip-title">💡 Quick-Edit 안내</div>
      <div class="tip-body">예시 칩을 탭하면 입력창에 자동 완성됩니다. 키보드로 세부 내용을 수정할 수도 있어요.</div>
    </div>
  </div>
  <div class="ob-footer">
    <button class="btn-primary">다음</button>
    <div class="hint">최소 5자 이상 입력 시 다음 단계 활성화</div>
  </div>
</div>

</body>
</html>
```

## SCENARIO:ATM-6

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-6 | 온보딩 Step 3~5: 통증수준 → 목표설정</title>
<style>
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#fff;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;}
.screen-badge{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;flex-shrink:0;}
.ob-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:22px 24px 28px;color:#fff;}
.step-row{display:flex;gap:6px;margin-bottom:14px;}
.step-pip{height:4px;border-radius:2px;background:rgba(255,255,255,0.3);flex:1;}
.step-pip.done{background:rgba(255,255,255,0.7);}
.step-pip.active{background:#fff;}
.ob-badge{display:inline-block;background:rgba(255,255,255,0.2);border-radius:99px;padding:3px 11px;font-size:11px;margin-bottom:10px;}
.ob-header h1{font-size:21px;font-weight:700;line-height:29px;}
.ob-header p{font-size:13px;opacity:.8;margin-top:5px;}
.ob-body{flex:1;padding:22px 20px;overflow-y:auto;}
.field-label{font-size:12px;font-weight:700;color:#5A7068;letter-spacing:.4px;margin-bottom:10px;}
.btn-primary{width:100%;padding:15px;background:#2E7D6B;color:#fff;border:none;border-radius:14px;font-size:16px;font-weight:700;cursor:pointer;}
.ob-footer{padding:16px 20px 28px;}
.pain-value{text-align:center;margin:10px 0;}
.pain-num{font-size:52px;font-weight:800;color:#F39C12;}
.pain-desc{font-size:13px;color:#5A7068;margin-top:2px;}
.slider-wrap{position:relative;padding:10px 0;}
input[type=range]{width:100%;-webkit-appearance:none;height:8px;border-radius:4px;background:linear-gradient(to right,#F39C12 50%,#D4E0DB 50%);outline:none;}
input[type=range]::-webkit-slider-thumb{-webkit-appearance:none;width:30px;height:30px;border-radius:50%;background:#F39C12;border:3px solid #fff;box-shadow:0 2px 8px rgba(0,0,0,0.2);cursor:pointer;}
.pain-labels{display:flex;justify-content:space-between;font-size:10px;color:#A0B4AE;margin-top:4px;}
.num-chips{display:flex;gap:4px;flex-wrap:wrap;margin-top:14px;}
.num-chip{flex:1;min-width:28px;padding:8px 4px;text-align:center;border-radius:8px;font-size:13px;font-weight:600;border:1.5px solid #D4E0DB;background:#F0F4F2;color:#1A2420;cursor:pointer;}
.num-chip.sel{background:#F39C12;color:#fff;border-color:#F39C12;}
.pain-scale{display:flex;justify-content:space-between;font-size:11px;margin-top:6px;}
.goal-card{display:flex;align-items:center;gap:14px;padding:14px 16px;border:1.5px solid #D4E0DB;border-radius:14px;margin-bottom:10px;cursor:pointer;background:#F8FAF9;}
.goal-card.sel{border-color:#2E7D6B;background:#EEF7F4;}
.goal-icon{width:46px;height:46px;border-radius:12px;background:#E0F0EB;display:flex;align-items:center;justify-content:center;font-size:24px;flex-shrink:0;}
.goal-card.sel .goal-icon{background:#2E7D6B;}
.goal-text h3{font-size:15px;font-weight:700;color:#1A2420;}
.goal-text p{font-size:12px;color:#5A7068;margin-top:2px;line-height:17px;}
.radio-row{width:20px;height:20px;border-radius:50%;border:2px solid #D4E0DB;display:flex;align-items:center;justify-content:center;margin-left:auto;flex-shrink:0;}
.goal-card.sel .radio-row{border-color:#2E7D6B;}
.radio-dot{width:10px;height:10px;border-radius:50%;background:#2E7D6B;display:none;}
.goal-card.sel .radio-dot{display:block;}
</style>
</head>
<body>

<!-- PHONE 1: 통증 수준 선택 -->
<div class="phone">
  <div class="status"><span>9:43</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-badge">SCREEN 3 — 통증 수준 선택 (Step 1.3)</div>
  <div class="ob-header">
    <div class="step-row">
      <div class="step-pip done"></div><div class="step-pip done"></div>
      <div class="step-pip active"></div>
      <div class="step-pip"></div><div class="step-pip"></div><div class="step-pip"></div>
    </div>
    <div class="ob-badge">2 / 6 단계</div>
    <h1>지금 통증이 얼마나 심한가요?</h1>
    <p>NRS 척도로 현재 통증 강도를 선택해주세요</p>
  </div>
  <div class="ob-body">
    <div class="pain-value">
      <div class="pain-num">5</div>
      <div class="pain-desc">⚡ 중등도 — 활동 시 불편하지만 참을 수 있음</div>
    </div>
    <div class="slider-wrap">
      <input type="range" min="1" max="10" value="5">
      <div class="pain-labels"><span>1 (없음)</span><span>5 (중등도)</span><span>10 (극심)</span></div>
    </div>
    <div class="field-label" style="margin-top:18px;">숫자로 직접 선택</div>
    <div class="num-chips">
      <div class="num-chip" style="background:#27AE60;color:#fff;border-color:#27AE60;">1</div>
      <div class="num-chip" style="background:#4CAF50;color:#fff;border-color:#4CAF50;">2</div>
      <div class="num-chip" style="background:#8BC34A;color:#fff;border-color:#8BC34A;">3</div>
      <div class="num-chip" style="background:#CDDC39;color:#1A2420;border-color:#CDDC39;">4</div>
      <div class="num-chip sel">5</div>
      <div class="num-chip" style="background:#FFC107;color:#1A2420;border-color:#FFC107;">6</div>
      <div class="num-chip" style="background:#FF9800;color:#fff;border-color:#FF9800;">7</div>
      <div class="num-chip" style="background:#FF5722;color:#fff;border-color:#FF5722;">8</div>
      <div class="num-chip" style="background:#F44336;color:#fff;border-color:#F44336;">9</div>
      <div class="num-chip" style="background:#B71C1C;color:#fff;border-color:#B71C1C;">10</div>
    </div>
    <div class="pain-scale" style="margin-top:8px;">
      <span style="color:#27AE60;">🟢 경미</span>
      <span style="color:#F39C12;">🟡 중등도</span>
      <span style="color:#E74C3C;">🔴 심함</span>
    </div>
    <div style="background:#FFF8F0;border-radius:10px;padding:12px 14px;margin-top:16px;border-left:3px solid #F4A261;">
      <div style="font-size:12px;color:#C96A00;font-weight:700;margin-bottom:3px;">기본값: 5점</div>
      <div style="font-size:12px;color:#5A7068;">변경이 없으면 그대로 '다음'을 누르세요 (원터치 통과)</div>
    </div>
  </div>
  <div class="ob-footer">
    <button class="btn-primary">다음</button>
  </div>
</div>

<!-- PHONE 2: 단기 목표 선택 -->
<div class="phone">
  <div class="status"><span>9:44</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-badge">SCREEN 4 — 단기 목표 선택 (Step 1.4)</div>
  <div class="ob-header">
    <div class="step-row">
      <div class="step-pip done"></div><div class="step-pip done"></div>
      <div class="step-pip done"></div><div class="step-pip active"></div>
      <div class="step-pip"></div><div class="step-pip"></div>
    </div>
    <div class="ob-badge">3 / 6 단계</div>
    <h1>지금 당장 원하는 게 뭔가요?</h1>
    <p>단기 목표를 선택해주세요 (1개 선택)</p>
  </div>
  <div class="ob-body">
    <div class="goal-card sel">
      <div class="goal-icon">🩹</div>
      <div class="goal-text">
        <h3>통증 완화</h3>
        <p>현재 통증을 줄이고 일상 생활을 편하게</p>
      </div>
      <div class="radio-row"><div class="radio-dot"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-icon">🦵</div>
      <div class="goal-text">
        <h3>관절 가동성 회복</h3>
        <p>굳어진 관절 범위를 정상으로 되돌리기</p>
      </div>
      <div class="radio-row"><div class="radio-dot"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-icon">🔄</div>
      <div class="goal-text">
        <h3>부상 재활</h3>
        <p>단계적 재활로 부상 부위 기능 회복</p>
      </div>
      <div class="radio-row"><div class="radio-dot"></div></div>
    </div>
    <div style="background:#EEF7F4;border-radius:10px;padding:10px 14px;margin-top:4px;font-size:12px;color:#2E7D6B;">
      ✅ <strong>통증 완화</strong>가 기본 선택됩니다. 다른 목표를 탭하면 즉시 변경돼요.
    </div>
  </div>
  <div class="ob-footer">
    <button class="btn-primary">다음</button>
  </div>
</div>

<!-- PHONE 3: 장기 목표 선택 -->
<div class="phone">
  <div class="status"><span>9:45</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-badge">SCREEN 5 — 장기 목표 선택 (Step 1.5)</div>
  <div class="ob-header">
    <div class="step-row">
      <div class="step-pip done"></div><div class="step-pip done"></div>
      <div class="step-pip done"></div><div class="step-pip done"></div>
      <div class="step-pip active"></div><div class="step-pip"></div>
    </div>
    <div class="ob-badge">4 / 6 단계</div>
    <h1>궁극적으로 원하는 변화는?</h1>
    <p>장기 목표를 선택해주세요 (1개 선택)</p>
  </div>
  <div class="ob-body">
    <div class="goal-card sel">
      <div class="goal-icon">⚡</div>
      <div class="goal-text">
        <h3>스태미나 / 체력 향상</h3>
        <p>오래 걷고 뛰어도 지치지 않는 체력 만들기</p>
      </div>
      <div class="radio-row"><div class="radio-dot"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-icon">💪</div>
      <div class="goal-text">
        <h3>근육량 증가</h3>
        <p>안전하게 근력을 키우고 체형 개선</p>
      </div>
      <div class="radio-row"><div class="radio-dot"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-icon">⚖️</div>
      <div class="goal-text">
        <h3>체중 감량</h3>
        <p>부상 없이 칼로리 소모, 체중 관리</p>
      </div>
      <div class="radio-row"><div class="radio-dot"></div></div>
    </div>
    <div style="background:#EEF7F4;border-radius:10px;padding:10px 14px;margin-top:4px;font-size:12px;color:#2E7D6B;">
      ✅ <strong>스태미나/체력 향상</strong>이 기본 선택됩니다.
    </div>
  </div>
  <div class="ob-footer">
    <button class="btn-primary">다음</button>
  </div>
</div>

</body>
</html>
```

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
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#fff;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;}
.screen-label{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;}
.ob-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:22px 24px 28px;color:#fff;}
.step-row{display:flex;gap:6px;margin-bottom:14px;}
.step-pip{height:4px;border-radius:2px;background:rgba(255,255,255,0.3);flex:1;}
.step-pip.done{background:rgba(255,255,255,0.7);}
.step-pip.active{background:#fff;}
.ob-badge{display:inline-block;background:rgba(255,255,255,0.2);border-radius:99px;padding:3px 11px;font-size:11px;margin-bottom:10px;}
.ob-header h1{font-size:21px;font-weight:700;line-height:29px;}
.ob-header p{font-size:13px;opacity:.8;margin-top:5px;}
.ob-body{flex:1;padding:22px 20px;overflow-y:auto;}
.section-title{font-size:12px;font-weight:700;color:#5A7068;letter-spacing:.4px;margin-bottom:10px;}
.chip-row{display:flex;flex-wrap:wrap;gap:8px;margin-bottom:20px;}
.chip{padding:10px 18px;border-radius:99px;font-size:13px;font-weight:600;border:1.5px solid #D4E0DB;background:#F0F4F2;color:#1A2420;cursor:pointer;}
.chip.sel{background:#2E7D6B;color:#fff;border-color:#2E7D6B;}
.radio-group{display:flex;flex-direction:column;gap:8px;margin-bottom:20px;}
.radio-item{display:flex;align-items:center;gap:12px;padding:12px 16px;border:1.5px solid #D4E0DB;border-radius:12px;cursor:pointer;background:#F8FAF9;}
.radio-item.sel{border-color:#2E7D6B;background:#EEF7F4;}
.r-dot{width:20px;height:20px;border-radius:50%;border:2px solid #D4E0DB;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.radio-item.sel .r-dot{border-color:#2E7D6B;}
.r-inner{width:10px;height:10px;border-radius:50%;background:#2E7D6B;display:none;}
.radio-item.sel .r-inner{display:block;}
.radio-item span{font-size:14px;font-weight:600;color:#1A2420;}
.check-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:20px;}
.check-item{display:flex;align-items:center;gap:8px;padding:12px 14px;border:1.5px solid #D4E0DB;border-radius:12px;cursor:pointer;background:#F8FAF9;font-size:14px;font-weight:600;color:#1A2420;}
.check-item.sel{border-color:#2E7D6B;background:#EEF7F4;color:#2E7D6B;}
.check-box{width:20px;height:20px;border-radius:6px;border:2px solid #D4E0DB;display:flex;align-items:center;justify-content:center;font-size:12px;color:#fff;flex-shrink:0;}
.check-item.sel .check-box{background:#2E7D6B;border-color:#2E7D6B;}
.btn-generate{width:100%;padding:16px;background:linear-gradient(135deg,#2E7D6B,#1B5E4F);color:#fff;border:none;border-radius:14px;font-size:16px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;}
.ob-footer{padding:16px 20px 28px;}
.gen-body{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:32px 24px;background:#F8FAF9;}
.gen-icon{width:80px;height:80px;border-radius:24px;background:linear-gradient(135deg,#2E7D6B,#1B5E4F);display:flex;align-items:center;justify-content:center;font-size:40px;margin-bottom:24px;box-shadow:0 8px 24px rgba(46,125,107,0.3);}
.gen-title{font-size:20px;font-weight:700;color:#1A2420;margin-bottom:8px;text-align:center;}
.gen-sub{font-size:13px;color:#5A7068;text-align:center;line-height:20px;margin-bottom:32px;}
.progress-steps{width:100%;}
.progress-step{display:flex;align-items:center;gap:12px;padding:12px 16px;border-radius:12px;margin-bottom:8px;background:#fff;border:1.5px solid #D4E0DB;}
.progress-step.done{background:#EEF7F4;border-color:#2E7D6B;}
.progress-step.active{background:#fff;border-color:#F4A261;box-shadow:0 2px 8px rgba(244,162,97,0.2);}
.p-icon{width:32px;height:32px;border-radius:50%;background:#D4E0DB;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;}
.progress-step.done .p-icon{background:#2E7D6B;color:#fff;}
.progress-step.active .p-icon{background:#F4A261;color:#fff;}
.p-text{flex:1;}
.p-text .p-title{font-size:13px;font-weight:600;color:#1A2420;}
.p-text .p-sub{font-size:11px;color:#5A7068;margin-top:1px;}
.progress-step.done .p-text .p-title{color:#2E7D6B;}
.p-status{font-size:11px;font-weight:700;}
.p-status.done{color:#2E7D6B;}
.p-status.ing{color:#F4A261;}
.prog-bar-wrap{width:100%;margin-top:24px;}
.prog-bar-bg{width:100%;height:8px;background:#D4E0DB;border-radius:4px;overflow:hidden;}
.prog-bar-fill{height:100%;width:65%;background:linear-gradient(90deg,#2E7D6B,#4CAF95);border-radius:4px;}
.prog-pct{text-align:right;font-size:12px;color:#2E7D6B;font-weight:700;margin-top:6px;}
</style>
</head>
<body>

<!-- PHONE 1: 운동 환경 & 장비 설정 -->
<div class="phone">
  <div class="status"><span>9:46</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 6 — 운동 환경 & 장비 설정 (Step 1.6)</div>
  <div class="ob-header">
    <div class="step-row">
      <div class="step-pip done"></div><div class="step-pip done"></div>
      <div class="step-pip done"></div><div class="step-pip done"></div>
      <div class="step-pip done"></div><div class="step-pip active"></div>
    </div>
    <div class="ob-badge">5 / 6 단계</div>
    <h1>운동 환경을 알려주세요</h1>
    <p>기본값으로 바로 플랜 생성도 OK</p>
  </div>
  <div class="ob-body">
    <div class="section-title">주당 운동 빈도</div>
    <div class="chip-row">
      <span class="chip">주 2회</span>
      <span class="chip sel">주 3회</span>
      <span class="chip">주 4회</span>
      <span class="chip">주 5회</span>
    </div>
    <div class="section-title">운동 장소</div>
    <div class="radio-group">
      <div class="radio-item sel">
        <div class="r-dot"><div class="r-inner"></div></div>
        <span>🏠 집</span>
      </div>
      <div class="radio-item">
        <div class="r-dot"><div class="r-inner"></div></div>
        <span>🏋️ 헬스장</span>
      </div>
      <div class="radio-item">
        <div class="r-dot"><div class="r-inner"></div></div>
        <span>🔄 둘 다</span>
      </div>
    </div>
    <div class="section-title">보유 장비 (집 선택 시)</div>
    <div class="check-grid">
      <div class="check-item sel"><div class="check-box">✓</div>맨몸</div>
      <div class="check-item"><div class="check-box"></div>덤벨</div>
      <div class="check-item"><div class="check-box"></div>밴드</div>
      <div class="check-item"><div class="check-box"></div>철봉</div>
    </div>
  </div>
  <div class="ob-footer">
    <button class="btn-generate">🤖 AI 플랜 생성하기</button>
  </div>
</div>

<!-- PHONE 2: AI 플랜 생성 중 -->
<div class="phone">
  <div class="status"><span>9:47</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 7 — AI 플랜 생성 중 (Step 2)</div>
  <div class="gen-body">
    <div class="gen-icon">🤖</div>
    <div class="gen-title">AI가 맞춤 플랜을 만들고 있어요</div>
    <div class="gen-sub">무릎 부상 안전 규칙 검증 및<br>4주 재활 운동 플랜을 생성합니다</div>
    <div class="progress-steps">
      <div class="progress-step done">
        <div class="p-icon">✓</div>
        <div class="p-text"><div class="p-title">부상 데이터 분석</div><div class="p-sub">무릎 인대 손상 패턴 분석 완료</div></div>
        <span class="p-status done">완료</span>
      </div>
      <div class="progress-step done">
        <div class="p-icon">✓</div>
        <div class="p-text"><div class="p-title">안전 규칙 검증 (1차)</div><div class="p-sub">프롬프트 레벨 안전 제약 적용</div></div>
        <span class="p-status done">완료</span>
      </div>
      <div class="progress-step active">
        <div class="p-icon">⚙</div>
        <div class="p-text"><div class="p-title">안전 규칙 검증 (2차)</div><div class="p-sub">서버 사이드 10개 규칙 검증 중...</div></div>
        <span class="p-status ing">진행 중</span>
      </div>
      <div class="progress-step">
        <div class="p-icon">📋</div>
        <div class="p-text"><div class="p-title">4주 플랜 생성</div><div class="p-sub">개인화 루틴 JSON 작성</div></div>
        <span class="p-status" style="color:#A0B4AE;">대기</span>
      </div>
    </div>
    <div class="prog-bar-wrap">
      <div class="prog-bar-bg"><div class="prog-bar-fill"></div></div>
      <div class="prog-pct">65% 완료</div>
    </div>
  </div>
</div>

</body>
</html>
```

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
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#F8FAF9;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;max-height:820px;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;flex-shrink:0;}
.screen-label{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;flex-shrink:0;}
.home-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:20px 22px 28px;color:#fff;flex-shrink:0;}
.home-header .top-row{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px;}
.home-header .greeting{font-size:13px;opacity:.8;}
.home-header .date{font-size:20px;font-weight:700;margin-top:2px;}
.notif-btn{width:38px;height:38px;border-radius:50%;background:rgba(255,255,255,0.2);display:flex;align-items:center;justify-content:center;font-size:18px;}
.stats-row{display:flex;gap:10px;}
.stat-pill{flex:1;background:rgba(255,255,255,0.18);border-radius:12px;padding:10px 12px;text-align:center;}
.stat-pill .sv{font-size:18px;font-weight:700;}
.stat-pill .sl{font-size:10px;opacity:.8;margin-top:2px;}
.scroll-body{flex:1;overflow-y:auto;padding:16px 16px 0;}
.section-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;}
.section-title{font-size:14px;font-weight:700;color:#1A2420;}
.section-link{font-size:12px;color:#2E7D6B;font-weight:600;}
.batch-btn{width:100%;padding:12px;background:#EEF7F4;border:1.5px solid #2E7D6B;border-radius:12px;color:#2E7D6B;font-size:13px;font-weight:700;cursor:pointer;margin-bottom:14px;display:flex;align-items:center;justify-content:center;gap:6px;}
.ex-card{background:#fff;border-radius:14px;padding:14px 16px;margin-bottom:10px;box-shadow:0 2px 8px rgba(0,0,0,0.06);display:flex;align-items:center;gap:12px;cursor:pointer;border:1.5px solid transparent;}
.ex-type{width:40px;height:40px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;}
.ex-type.warmup{background:#EEF7F4;}
.ex-type.rehab{background:#FFF8F0;}
.ex-type.main{background:#EEF0FF;}
.ex-info{flex:1;}
.ex-info .ex-name{font-size:14px;font-weight:700;color:#1A2420;}
.ex-info .ex-detail{font-size:12px;color:#5A7068;margin-top:2px;}
.ex-tag{display:inline-block;padding:2px 8px;border-radius:99px;font-size:10px;font-weight:700;margin-top:4px;}
.tag-warmup{background:#EEF7F4;color:#2E7D6B;}
.tag-rehab{background:#FFF8F0;color:#C96A00;}
.tag-main{background:#EEF0FF;color:#5C6BC0;}
.ex-check{width:28px;height:28px;border-radius:50%;border:2px solid #D4E0DB;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.ex-check.done{background:#2E7D6B;border-color:#2E7D6B;color:#fff;font-size:14px;}
.week-bar-wrap{background:#fff;border-radius:14px;padding:16px;margin-bottom:12px;box-shadow:0 2px 8px rgba(0,0,0,0.06);}
.week-label{font-size:12px;font-weight:700;color:#5A7068;margin-bottom:10px;}
.week-bar-bg{height:8px;background:#D4E0DB;border-radius:4px;overflow:hidden;margin-bottom:4px;}
.week-bar-fill{height:100%;background:linear-gradient(90deg,#2E7D6B,#4CAF95);border-radius:4px;}
.week-pct{font-size:11px;color:#2E7D6B;font-weight:700;text-align:right;}
.day-dots{display:flex;gap:6px;justify-content:center;margin-top:10px;}
.day-dot{width:34px;text-align:center;}
.day-dot .dd{width:34px;height:34px;border-radius:50%;background:#F0F4F2;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#A0B4AE;margin-bottom:3px;}
.day-dot .dd.done{background:#2E7D6B;color:#fff;}
.day-dot .dd.today{background:#2E7D6B;color:#fff;box-shadow:0 0 0 3px rgba(46,125,107,0.3);}
.day-dot .dl{font-size:10px;color:#A0B4AE;}
.nav-bar{display:flex;background:#fff;border-top:1px solid #E8EEEC;flex-shrink:0;}
.nav-item{flex:1;padding:10px 0 12px;text-align:center;cursor:pointer;}
.nav-item .nav-icon{font-size:20px;}
.nav-item .nav-label{font-size:10px;color:#A0B4AE;margin-top:2px;font-weight:600;}
.swipe-hint{font-size:11px;color:#A0B4AE;text-align:center;padding:8px;background:#F8FAF9;}
</style>
</head>
<body>

<div class="phone">
  <div class="status"><span>9:48</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 8 — 메인 홈 대시보드 (Step 3)</div>
  <div class="home-header">
    <div class="top-row">
      <div>
        <div class="greeting">안녕하세요 👋</div>
        <div class="date">1월 31일 금요일</div>
      </div>
      <div class="notif-btn">🔔</div>
    </div>
    <div class="stats-row">
      <div class="stat-pill"><div class="sv">통증 5→3</div><div class="sl">통증 점수 ▼</div></div>
      <div class="stat-pill"><div class="sv">🔥 7일</div><div class="sl">연속 운동</div></div>
      <div class="stat-pill"><div class="sv">75%</div><div class="sl">주간 달성률</div></div>
    </div>
  </div>
  <div class="scroll-body">
    <div class="week-bar-wrap">
      <div class="week-label">이번 주 진척도 (3/4회 완료)</div>
      <div class="week-bar-bg"><div class="week-bar-fill" style="width:75%;"></div></div>
      <div class="week-pct">75%</div>
      <div class="day-dots">
        <div class="day-dot"><div class="dd done">✓</div><div class="dl">월</div></div>
        <div class="day-dot"><div class="dd done">✓</div><div class="dl">화</div></div>
        <div class="day-dot"><div class="dd done">✓</div><div class="dl">수</div></div>
        <div class="day-dot"><div class="dd">-</div><div class="dl">목</div></div>
        <div class="day-dot"><div class="dd today">●</div><div class="dl">금</div></div>
        <div class="day-dot"><div class="dd">-</div><div class="dl">토</div></div>
        <div class="day-dot"><div class="dd">-</div><div class="dl">일</div></div>
      </div>
    </div>
    <div class="section-header">
      <div class="section-title">오늘의 운동 (5개)</div>
      <div class="section-link">전체 보기</div>
    </div>
    <button class="batch-btn">⚡ 오늘의 운동 일괄 완료</button>
    <div class="ex-card">
      <div class="ex-type warmup">🌡️</div>
      <div class="ex-info">
        <div class="ex-name">무릎 관절 워밍업</div>
        <div class="ex-detail">2세트 × 10회</div>
        <span class="ex-tag tag-warmup">준비운동</span>
      </div>
      <div class="ex-check done">✓</div>
    </div>
    <div class="ex-card">
      <div class="ex-type rehab">🩹</div>
      <div class="ex-info">
        <div class="ex-name">쿼드 스트레칭</div>
        <div class="ex-detail">3세트 × 30초 유지</div>
        <span class="ex-tag tag-rehab">재활</span>
      </div>
      <div class="ex-check done">✓</div>
    </div>
    <div class="ex-card" style="border-color:#2E7D6B;box-shadow:0 0 0 2px rgba(46,125,107,0.15);">
      <div class="ex-type rehab">🔄</div>
      <div class="ex-info">
        <div class="ex-name">레그 레이즈 (재활)</div>
        <div class="ex-detail">3세트 × 12회</div>
        <span class="ex-tag tag-rehab">재활/보조</span>
      </div>
      <div class="ex-check"></div>
    </div>
    <div class="ex-card">
      <div class="ex-type main">💪</div>
      <div class="ex-info">
        <div class="ex-name">월 스쿼트 (가벼운 무게)</div>
        <div class="ex-detail">3세트 × 10회 · 추천 5kg</div>
        <span class="ex-tag tag-main">메인</span>
      </div>
      <div class="ex-check"></div>
    </div>
    <div class="ex-card">
      <div class="ex-type main">🏃</div>
      <div class="ex-info">
        <div class="ex-name">스텝 업 (낮은 박스)</div>
        <div class="ex-detail">3세트 × 8회</div>
        <span class="ex-tag tag-main">메인</span>
      </div>
      <div class="ex-check"></div>
    </div>
    <div class="swipe-hint">← 카드 좌우 스와이프로 운동 스킵 →</div>
    <div style="height:12px;"></div>
  </div>
  <div class="nav-bar">
    <div class="nav-item active"><div class="nav-icon">🏠</div><div class="nav-label" style="color:#2E7D6B;">홈</div></div>
    <div class="nav-item"><div class="nav-icon">📊</div><div class="nav-label">통계</div></div>
    <div class="nav-item"><div class="nav-icon">⚙️</div><div class="nav-label">설정</div></div>
  </div>
</div>

<div class="phone">
  <div class="status"><span>9:48</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 8b — 홈 카드 스와이프 스킵 (Quick-Edit)</div>
  <div class="home-header">
    <div class="top-row">
      <div><div class="greeting">Quick-Edit: 운동 스킵</div><div class="date">카드 스와이프 상태</div></div>
      <div class="notif-btn">🔔</div>
    </div>
    <div style="font-size:12px;opacity:.8;margin-top:4px;">← 운동 카드를 좌로 밀면 스킵 버튼이 나타납니다</div>
  </div>
  <div class="scroll-body">
    <button class="batch-btn">⚡ 오늘의 운동 일괄 완료</button>
    <div class="ex-card">
      <div class="ex-type warmup">🌡️</div>
      <div class="ex-info"><div class="ex-name">무릎 관절 워밍업</div><div class="ex-detail">2세트 × 10회</div><span class="ex-tag tag-warmup">준비운동</span></div>
      <div class="ex-check done">✓</div>
    </div>
    <div style="position:relative;margin-bottom:10px;border-radius:14px;overflow:hidden;">
      <div style="position:absolute;right:0;top:0;bottom:0;width:80px;background:#E74C3C;display:flex;align-items:center;justify-content:center;border-radius:0 14px 14px 0;font-size:12px;font-weight:700;color:#fff;flex-direction:column;gap:2px;">
        <span>🚫</span><span>스킵</span>
      </div>
      <div class="ex-card" style="margin-bottom:0;transform:translateX(-70px);border-radius:14px;border-color:#FEE2E2;background:#FEF9F9;">
        <div class="ex-type rehab">🩹</div>
        <div class="ex-info"><div class="ex-name">쿼드 스트레칭</div><div class="ex-detail">3세트 × 30초 유지</div><span class="ex-tag tag-rehab">재활</span></div>
        <div class="ex-check"></div>
      </div>
    </div>
    <div class="ex-card">
      <div class="ex-type rehab">🔄</div>
      <div class="ex-info"><div class="ex-name">레그 레이즈 (재활)</div><div class="ex-detail">3세트 × 12회</div><span class="ex-tag tag-rehab">재활/보조</span></div>
      <div class="ex-check"></div>
    </div>
    <div class="ex-card">
      <div class="ex-type main">💪</div>
      <div class="ex-info"><div class="ex-name">월 스쿼트</div><div class="ex-detail">3세트 × 10회</div><span class="ex-tag tag-main">메인</span></div>
      <div class="ex-check"></div>
    </div>
    <div class="ex-card">
      <div class="ex-type main">🏃</div>
      <div class="ex-info"><div class="ex-name">스텝 업</div><div class="ex-detail">3세트 × 8회</div><span class="ex-tag tag-main">메인</span></div>
      <div class="ex-check"></div>
    </div>
  </div>
  <div class="nav-bar">
    <div class="nav-item active"><div class="nav-icon">🏠</div><div class="nav-label" style="color:#2E7D6B;">홈</div></div>
    <div class="nav-item"><div class="nav-icon">📊</div><div class="nav-label">통계</div></div>
    <div class="nav-item"><div class="nav-icon">⚙️</div><div class="nav-label">설정</div></div>
  </div>
</div>

</body>
</html>
```

## SCENARIO:ATM-9

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ATM-9 | 세션 상세 & 세트 기록</title>
<style>
*{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#F8FAF9;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;max-height:820px;position:relative;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;flex-shrink:0;}
.screen-label{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;flex-shrink:0;}
.sess-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:16px 20px 22px;color:#fff;flex-shrink:0;}
.sess-header .back{font-size:13px;opacity:.8;margin-bottom:6px;cursor:pointer;}
.sess-header h2{font-size:20px;font-weight:700;}
.sess-header .meta{font-size:12px;opacity:.75;margin-top:4px;display:flex;gap:10px;}
.prefill-banner{background:#EEF7F4;border-bottom:1px solid #C8E6DD;padding:8px 18px;font-size:12px;color:#2E7D6B;font-weight:600;display:flex;align-items:center;gap:6px;flex-shrink:0;}
.scroll-body{flex:1;overflow-y:auto;padding:14px 16px;}
.set-header{display:flex;padding:0 4px;margin-bottom:6px;}
.set-col{font-size:11px;font-weight:700;color:#A0B4AE;letter-spacing:.3px;}
.set-col.c-set{width:36px;}
.set-col.c-weight{flex:1;text-align:center;}
.set-col.c-reps{flex:1;text-align:center;}
.set-col.c-done{width:48px;text-align:center;}
.set-row{display:flex;align-items:center;padding:10px 4px;border-radius:12px;margin-bottom:6px;background:#fff;box-shadow:0 1px 4px rgba(0,0,0,0.06);}
.set-row.completed{background:#EEF7F4;}
.set-num{width:36px;font-size:13px;font-weight:700;color:#5A7068;}
.set-val{flex:1;text-align:center;}
.val-chip{display:inline-block;padding:6px 14px;border-radius:8px;font-size:14px;font-weight:700;background:#F0F4F2;color:#1A2420;cursor:pointer;border:1.5px solid #D4E0DB;}
.set-row.completed .val-chip{background:#D4EDE5;color:#1B5E4F;border-color:#B2D8CF;}
.set-check{width:48px;display:flex;justify-content:center;}
.check-btn{width:36px;height:36px;border-radius:50%;border:2px solid #D4E0DB;background:#fff;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:16px;}
.check-btn.done{background:#2E7D6B;border-color:#2E7D6B;color:#fff;}
.add-set-btn{width:100%;padding:12px;border:1.5px dashed #D4E0DB;border-radius:12px;background:transparent;color:#2E7D6B;font-size:13px;font-weight:700;cursor:pointer;margin-top:4px;}
.end-btn{width:100%;padding:14px;background:#E74C3C;color:#fff;border:none;border-radius:14px;font-size:15px;font-weight:700;cursor:pointer;margin-top:12px;}
.timer-bar{position:absolute;bottom:0;left:0;right:0;background:#1B5E4F;color:#fff;padding:12px 20px;display:flex;align-items:center;justify-content:space-between;z-index:10;}
.timer-left{display:flex;align-items:center;gap:10px;}
.timer-count{font-size:24px;font-weight:800;}
.timer-label{font-size:12px;opacity:.8;}
.timer-skip{background:rgba(255,255,255,0.2);border:none;color:#fff;padding:8px 14px;border-radius:8px;font-size:12px;font-weight:700;cursor:pointer;}
.qe-overlay{position:absolute;bottom:0;left:0;right:0;background:#fff;border-radius:24px 24px 0 0;padding:20px 20px 32px;box-shadow:0 -4px 24px rgba(0,0,0,0.15);z-index:20;}
.qe-handle{width:40px;height:4px;background:#D4E0DB;border-radius:2px;margin:0 auto 16px;}
.qe-title{font-size:14px;font-weight:700;color:#1A2420;margin-bottom:4px;}
.qe-current{font-size:26px;font-weight:800;color:#2E7D6B;margin-bottom:16px;}
.qe-section{margin-bottom:14px;}
.qe-section-label{font-size:11px;font-weight:700;color:#5A7068;margin-bottom:8px;letter-spacing:.3px;}
.qe-chips{display:flex;gap:8px;}
.qe-chip{flex:1;padding:11px 6px;border-radius:10px;font-size:13px;font-weight:700;text-align:center;border:1.5px solid #D4E0DB;background:#F0F4F2;color:#1A2420;cursor:pointer;}
.qe-chip.minus{color:#E74C3C;border-color:#FCCACA;background:#FFF5F5;}
.qe-chip.plus{color:#2E7D6B;border-color:#C8E6DD;background:#EEF7F4;}
.qe-done{width:100%;padding:13px;background:#2E7D6B;color:#fff;border:none;border-radius:12px;font-size:14px;font-weight:700;cursor:pointer;margin-top:4px;}
</style>
</head>
<body>

<div class="phone">
  <div class="status"><span>9:52</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 9 — 세션 상세 (Step 4+5)</div>
  <div class="sess-header">
    <div class="back">← 오늘의 운동</div>
    <h2>레그 레이즈 (재활)</h2>
    <div class="meta">
      <span>🩹 재활/보조</span>
      <span>⏱ 예상 8분</span>
      <span>📋 3세트</span>
    </div>
  </div>
  <div class="prefill-banner">✨ 이전 세션 기록이 자동으로 채워졌습니다</div>
  <div class="scroll-body">
    <div style="background:#fff;border-radius:14px;padding:14px 16px;margin-bottom:14px;box-shadow:0 1px 6px rgba(0,0,0,0.06);">
      <div style="font-size:12px;color:#5A7068;margin-bottom:8px;font-weight:700;">운동 가이드</div>
      <div style="font-size:13px;color:#1A2420;line-height:20px;">• 바닥에 누워 무릎 부상 부위에 무리가 가지 않게<br>• 복근으로 다리를 들어올리고 천천히 내려요<br>• 통증 시 즉시 중단하세요</div>
    </div>
    <div class="set-header">
      <div class="set-col c-set">세트</div>
      <div class="set-col c-weight">무게(kg)</div>
      <div class="set-col c-reps">횟수(회)</div>
      <div class="set-col c-done">완료</div>
    </div>
    <div class="set-row completed">
      <div class="set-num">1</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">12 회</span></div>
      <div class="set-check"><div class="check-btn done">✓</div></div>
    </div>
    <div class="set-row completed">
      <div class="set-num">2</div>
      <div class="set-val"><span class="val-chip">0 kg</span></div>
      <div class="set-val"><span class="val-chip">12 회</span></div>
      <div class="set-check"><div class="check-btn done">✓</div></div>
    </div>
    <div class="set-row" style="border:1.5px solid #2E7D6B;">
      <div class="set-num" style="color:#2E7D6B;">3</div>
      <div class="set-val"><span class="val-chip" style="border-color:#2E7D6B;background:#EEF7F4;color:#1B5E4F;">0 kg</span></div>
      <div class="set-val"><span class="val-chip" style="border-color:#2E7D6B;background:#EEF7F4;color:#1B5E4F;">12 회</span></div>
      <div class="set-check"><div class="check-btn">○</div></div>
    </div>
    <button class="add-set-btn">+ 세트 추가</button>
    <button class="end-btn">세션 종료</button>
    <div style="height:60px;"></div>
  </div>
  <div class="timer-bar">
    <div class="timer-left">
      <div>
        <div class="timer-count">0:25</div>
        <div class="timer-label">휴식 타이머</div>
      </div>
    </div>
    <button class="timer-skip">건너뛰기 ▶</button>
  </div>
</div>

<div class="phone">
  <div class="status"><span>9:53</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 9b — 무게/횟수 Quick-Edit (Step 5.3)</div>
  <div class="sess-header">
    <div class="back">← 오늘의 운동</div>
    <h2>월 스쿼트 (메인)</h2>
    <div class="meta"><span>💪 메인 운동</span><span>⏱ 예상 12분</span></div>
  </div>
  <div class="prefill-banner">✨ 지난 세션: 5kg × 10회 × 3세트</div>
  <div class="scroll-body">
    <div class="set-header">
      <div class="set-col c-set">세트</div>
      <div class="set-col c-weight">무게(kg)</div>
      <div class="set-col c-reps">횟수(회)</div>
      <div class="set-col c-done">완료</div>
    </div>
    <div class="set-row completed">
      <div class="set-num">1</div>
      <div class="set-val"><span class="val-chip">5 kg</span></div>
      <div class="set-val"><span class="val-chip">10 회</span></div>
      <div class="set-check"><div class="check-btn done">✓</div></div>
    </div>
    <div class="set-row" style="border:1.5px solid #F4A261;opacity:.5;">
      <div class="set-num">2</div>
      <div class="set-val"><span class="val-chip">5 kg</span></div>
      <div class="set-val"><span class="val-chip">10 회</span></div>
      <div class="set-check"><div class="check-btn">○</div></div>
    </div>
    <div class="set-row" style="opacity:.5;">
      <div class="set-num">3</div>
      <div class="set-val"><span class="val-chip">5 kg</span></div>
      <div class="set-val"><span class="val-chip">10 회</span></div>
      <div class="set-check"><div class="check-btn">○</div></div>
    </div>
    <div style="height:280px;"></div>
  </div>
  <div class="qe-overlay">
    <div class="qe-handle"></div>
    <div class="qe-title">2세트 무게 수정</div>
    <div class="qe-current">5 kg</div>
    <div class="qe-section">
      <div class="qe-section-label">무게 (KG)</div>
      <div class="qe-chips">
        <div class="qe-chip minus">-5kg</div>
        <div class="qe-chip minus">-1kg</div>
        <div class="qe-chip plus">+1kg</div>
        <div class="qe-chip plus">+5kg</div>
      </div>
    </div>
    <div class="qe-section">
      <div class="qe-section-label">횟수 (회)</div>
      <div class="qe-chips">
        <div class="qe-chip minus" style="flex:none;width:80px;">-1회</div>
        <div style="flex:1;display:flex;align-items:center;justify-content:center;font-size:22px;font-weight:800;color:#1A2420;">10 회</div>
        <div class="qe-chip plus" style="flex:none;width:80px;">+1회</div>
      </div>
    </div>
    <button class="qe-done">확인</button>
  </div>
</div>

</body>
</html>
```

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
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#F8FAF9;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;position:relative;max-height:820px;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;flex-shrink:0;}
.screen-label{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;flex-shrink:0;}
.complete-body{flex:1;display:flex;flex-direction:column;align-items:center;padding:28px 22px;overflow-y:auto;}
.complete-icon{width:80px;height:80px;border-radius:50%;background:linear-gradient(135deg,#2E7D6B,#4CAF95);display:flex;align-items:center;justify-content:center;font-size:40px;margin-bottom:18px;box-shadow:0 8px 24px rgba(46,125,107,0.3);}
.complete-title{font-size:22px;font-weight:800;color:#1A2420;margin-bottom:6px;}
.complete-sub{font-size:14px;color:#5A7068;margin-bottom:24px;text-align:center;}
.summary-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;width:100%;margin-bottom:24px;}
.summary-card{background:#fff;border-radius:14px;padding:14px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.06);}
.summary-card .sv{font-size:22px;font-weight:800;color:#2E7D6B;}
.summary-card .sl{font-size:11px;color:#5A7068;margin-top:3px;}
.ex-done-list{width:100%;background:#fff;border-radius:14px;padding:14px 16px;margin-bottom:24px;box-shadow:0 2px 8px rgba(0,0,0,0.06);}
.ex-done-title{font-size:12px;font-weight:700;color:#5A7068;margin-bottom:10px;}
.ex-done-item{display:flex;align-items:center;gap:10px;padding:7px 0;border-bottom:1px solid #F0F4F2;}
.ex-done-item:last-child{border-bottom:none;}
.done-check{width:22px;height:22px;border-radius:50%;background:#2E7D6B;color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0;}
.done-text{font-size:13px;color:#1A2420;font-weight:600;flex:1;}
.done-vol{font-size:11px;color:#5A7068;}
.end-btn{width:100%;padding:15px;background:#E74C3C;color:#fff;border:none;border-radius:14px;font-size:15px;font-weight:700;cursor:pointer;}
.modal-overlay{position:absolute;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);display:flex;align-items:flex-end;z-index:10;}
.modal-sheet{background:#fff;border-radius:24px 24px 0 0;padding:24px 22px 36px;width:100%;}
.modal-handle{width:40px;height:4px;background:#D4E0DB;border-radius:2px;margin:0 auto 18px;}
.modal-icon{font-size:32px;margin-bottom:10px;text-align:center;}
.modal-title{font-size:18px;font-weight:700;color:#1A2420;margin-bottom:4px;text-align:center;}
.modal-sub{font-size:13px;color:#5A7068;text-align:center;margin-bottom:18px;}
.modal-prefill-note{background:#EEF7F4;border-radius:10px;padding:8px 12px;font-size:12px;color:#2E7D6B;font-weight:600;text-align:center;margin-bottom:14px;}
.pain-chips{display:flex;flex-wrap:wrap;gap:6px;justify-content:center;margin-bottom:20px;}
.p-chip{width:42px;height:42px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:15px;font-weight:800;border:2px solid #D4E0DB;background:#F0F4F2;color:#1A2420;cursor:pointer;}
.p-chip.low{background:#E8F5E9;border-color:#A5D6A7;color:#27AE60;}
.p-chip.mid{background:#FFF8E1;border-color:#FFE082;color:#F39C12;}
.p-chip.high{background:#FFEBEE;border-color:#EF9A9A;color:#E74C3C;}
.p-chip.sel{box-shadow:0 0 0 3px rgba(46,125,107,0.4);border-color:#2E7D6B;transform:scale(1.08);}
.save-btn{width:100%;padding:15px;background:#2E7D6B;color:#fff;border:none;border-radius:14px;font-size:16px;font-weight:700;cursor:pointer;}
</style>
</head>
<body>

<div class="phone">
  <div class="status"><span>10:12</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 9c — 세션 완료 요약 (Step 6 전)</div>
  <div class="complete-body">
    <div class="complete-icon">🎉</div>
    <div class="complete-title">운동 완료!</div>
    <div class="complete-sub">오늘의 재활 루틴을 모두 마쳤어요 🎊</div>
    <div class="summary-grid">
      <div class="summary-card"><div class="sv">24분</div><div class="sl">총 운동 시간</div></div>
      <div class="summary-card"><div class="sv">5세트</div><div class="sl">완료 세트 수</div></div>
      <div class="summary-card"><div class="sv">420</div><div class="sl">총 볼륨 (kg)</div></div>
      <div class="summary-card"><div class="sv">🔥 8일</div><div class="sl">연속 운동 기록</div></div>
    </div>
    <div class="ex-done-list">
      <div class="ex-done-title">완료된 운동</div>
      <div class="ex-done-item"><div class="done-check">✓</div><div class="done-text">무릎 관절 워밍업</div><div class="done-vol">2×10</div></div>
      <div class="ex-done-item"><div class="done-check">✓</div><div class="done-text">쿼드 스트레칭</div><div class="done-vol">3×30초</div></div>
      <div class="ex-done-item"><div class="done-check">✓</div><div class="done-text">레그 레이즈</div><div class="done-vol">3×12</div></div>
      <div class="ex-done-item" style="opacity:.5;">
        <div style="width:22px;height:22px;border-radius:50%;background:#A0B4AE;color:#fff;display:flex;align-items:center;justify-content:center;font-size:12px;">⏭</div>
        <div class="done-text" style="color:#A0B4AE;">쿼드 스트레칭 (스킵)</div>
        <div class="done-vol">-</div>
      </div>
    </div>
    <button class="end-btn">세션 종료 및 피드백</button>
  </div>
</div>

<div class="phone">
  <div class="status"><span>10:12</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 10 — 통증 피드백 모달 (Step 6)</div>
  <div class="complete-body" style="opacity:.4;">
    <div class="complete-icon">🎉</div>
    <div class="complete-title">운동 완료!</div>
    <div class="complete-sub">배경 화면</div>
  </div>
  <div class="modal-overlay">
    <div class="modal-sheet">
      <div class="modal-handle"></div>
      <div class="modal-icon">🤔</div>
      <div class="modal-title">오늘 통증은 어떠셨나요?</div>
      <div class="modal-sub">운동 후 통증 변화를 알려주세요</div>
      <div class="modal-prefill-note">📌 지난 세션 통증: 5점 (기본 선택됨)</div>
      <div class="pain-chips">
        <div class="p-chip low">1</div>
        <div class="p-chip low">2</div>
        <div class="p-chip low">3</div>
        <div class="p-chip mid">4</div>
        <div class="p-chip mid sel">5</div>
        <div class="p-chip mid">6</div>
        <div class="p-chip high">7</div>
        <div class="p-chip high">8</div>
        <div class="p-chip high">9</div>
        <div class="p-chip high">10</div>
      </div>
      <div style="display:flex;justify-content:space-between;font-size:11px;color:#A0B4AE;margin-bottom:16px;padding:0 4px;">
        <span style="color:#27AE60;">1 = 통증 없음</span>
        <span style="color:#E74C3C;">10 = 극심한 통증</span>
      </div>
      <button class="save-btn">저장 및 종료 (원터치)</button>
    </div>
  </div>
</div>

</body>
</html>
```

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
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#F8FAF9;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;max-height:820px;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;flex-shrink:0;}
.screen-label{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;flex-shrink:0;}
.analytics-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:18px 22px 22px;color:#fff;flex-shrink:0;}
.analytics-header h2{font-size:20px;font-weight:700;}
.analytics-header p{font-size:12px;opacity:.8;margin-top:3px;}
.period-tabs{display:flex;gap:0;background:rgba(255,255,255,0.15);border-radius:10px;padding:3px;margin-top:12px;}
.period-tab{flex:1;padding:7px;text-align:center;font-size:13px;font-weight:600;color:rgba(255,255,255,.7);border-radius:8px;cursor:pointer;}
.period-tab.active{background:#fff;color:#2E7D6B;}
.scroll-body{flex:1;overflow-y:auto;padding:16px;}
.chart-card{background:#fff;border-radius:16px;padding:16px;margin-bottom:14px;box-shadow:0 2px 8px rgba(0,0,0,0.06);}
.chart-title{font-size:14px;font-weight:700;color:#1A2420;margin-bottom:3px;}
.chart-sub{font-size:11px;color:#5A7068;margin-bottom:14px;}
.chart-area{position:relative;height:120px;margin-bottom:8px;}
.line-svg{width:100%;height:100%;}
.x-labels{display:flex;justify-content:space-between;font-size:10px;color:#A0B4AE;padding:0 4px;}
.bar-group{display:flex;align-items:flex-end;gap:6px;height:90px;padding-bottom:0;}
.bar-item{flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;}
.bar-fill{width:100%;border-radius:6px 6px 0 0;min-height:6px;}
.bar-label{font-size:10px;color:#A0B4AE;}
.bar-pct{font-size:10px;font-weight:700;color:#2E7D6B;}
.vol-bars{display:flex;align-items:flex-end;gap:5px;height:80px;}
.vol-bar{flex:1;border-radius:4px 4px 0 0;background:linear-gradient(180deg,#4CAF95,#2E7D6B);min-height:4px;}
.vol-labels{display:flex;justify-content:space-between;font-size:10px;color:#A0B4AE;margin-top:6px;}
.kpi-row{display:flex;gap:10px;margin-bottom:14px;}
.kpi-card{flex:1;background:#fff;border-radius:14px;padding:14px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.06);}
.kpi-card .kv{font-size:22px;font-weight:800;color:#2E7D6B;}
.kpi-card .kl{font-size:11px;color:#5A7068;margin-top:2px;}
.kpi-card .kd{font-size:12px;font-weight:700;margin-top:3px;}
.kd.positive{color:#27AE60;}
.nav-bar{display:flex;background:#fff;border-top:1px solid #E8EEEC;flex-shrink:0;}
.nav-item{flex:1;padding:10px 0 12px;text-align:center;cursor:pointer;}
.nav-item .nav-icon{font-size:20px;}
.nav-item .nav-label{font-size:10px;color:#A0B4AE;margin-top:2px;font-weight:600;}
</style>
</head>
<body>

<div class="phone">
  <div class="status"><span>10:20</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 11 — 통계 & 진척도 대시보드 (Step 7)</div>
  <div class="analytics-header">
    <h2>📊 나의 진척도</h2>
    <p>재활 운동의 효과를 한눈에 확인하세요</p>
    <div class="period-tabs">
      <div class="period-tab active">주간</div>
      <div class="period-tab">월간</div>
    </div>
  </div>
  <div class="scroll-body">
    <div class="kpi-row">
      <div class="kpi-card">
        <div class="kv">3→1</div>
        <div class="kl">주간 통증 점수</div>
        <div class="kd positive">▼ 66% 감소</div>
      </div>
      <div class="kpi-card">
        <div class="kv">75%</div>
        <div class="kl">주간 완료율</div>
        <div class="kd positive">▲ +15%</div>
      </div>
    </div>
    <div class="chart-card">
      <div class="chart-title">😌 통증 추이 (NRS 1~10)</div>
      <div class="chart-sub">최근 7일 — 탭하면 상세 정보가 표시됩니다</div>
      <div class="chart-area">
        <svg class="line-svg" viewBox="0 0 300 100" preserveAspectRatio="none">
          <defs>
            <linearGradient id="painGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stop-color="#2E7D6B" stop-opacity="0.2"/>
              <stop offset="100%" stop-color="#2E7D6B" stop-opacity="0"/>
            </linearGradient>
          </defs>
          <line x1="0" y1="20" x2="300" y2="20" stroke="#F0F4F2" stroke-width="1"/>
          <line x1="0" y1="50" x2="300" y2="50" stroke="#F0F4F2" stroke-width="1"/>
          <line x1="0" y1="80" x2="300" y2="80" stroke="#F0F4F2" stroke-width="1"/>
          <path d="M 0,70 L 50,60 L 100,50 L 150,60 L 200,40 L 250,25 L 300,15 L 300,100 L 0,100 Z" fill="url(#painGrad)"/>
          <polyline points="0,70 50,60 100,50 150,60 200,40 250,25 300,15" fill="none" stroke="#2E7D6B" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
          <circle cx="0" cy="70" r="4" fill="#2E7D6B" stroke="#fff" stroke-width="2"/>
          <circle cx="50" cy="60" r="4" fill="#2E7D6B" stroke="#fff" stroke-width="2"/>
          <circle cx="100" cy="50" r="4" fill="#2E7D6B" stroke="#fff" stroke-width="2"/>
          <circle cx="150" cy="60" r="4" fill="#2E7D6B" stroke="#fff" stroke-width="2"/>
          <circle cx="200" cy="40" r="4" fill="#2E7D6B" stroke="#fff" stroke-width="2"/>
          <circle cx="250" cy="25" r="6" fill="#F4A261" stroke="#fff" stroke-width="2"/>
          <circle cx="300" cy="15" r="4" fill="#27AE60" stroke="#fff" stroke-width="2"/>
          <rect x="215" y="2" width="60" height="22" rx="4" fill="#1A2420"/>
          <text x="245" y="16" fill="#fff" font-size="11" font-weight="bold" text-anchor="middle">3점</text>
        </svg>
      </div>
      <div class="x-labels"><span>월</span><span>화</span><span>수</span><span>목</span><span>금</span><span>토</span><span>오늘</span></div>
    </div>
    <div class="chart-card">
      <div class="chart-title">✅ 주간 완료율</div>
      <div class="chart-sub">각 운동 세션의 달성 비율</div>
      <div class="bar-group">
        <div class="bar-item"><div class="bar-pct">100%</div><div class="bar-fill" style="height:80px;background:#2E7D6B;"></div><div class="bar-label">월</div></div>
        <div class="bar-item"><div class="bar-pct">80%</div><div class="bar-fill" style="height:64px;background:#4CAF95;"></div><div class="bar-label">화</div></div>
        <div class="bar-item"><div class="bar-pct">100%</div><div class="bar-fill" style="height:80px;background:#2E7D6B;"></div><div class="bar-label">수</div></div>
        <div class="bar-item"><div class="bar-pct">-</div><div class="bar-fill" style="height:6px;background:#D4E0DB;"></div><div class="bar-label">목</div></div>
        <div class="bar-item"><div class="bar-pct">75%</div><div class="bar-fill" style="height:60px;background:#F4A261;"></div><div class="bar-label">금</div></div>
        <div class="bar-item"><div class="bar-pct">-</div><div class="bar-fill" style="height:6px;background:#D4E0DB;"></div><div class="bar-label">토</div></div>
        <div class="bar-item"><div class="bar-pct">-</div><div class="bar-fill" style="height:6px;background:#D4E0DB;"></div><div class="bar-label">일</div></div>
      </div>
    </div>
    <div class="chart-card">
      <div class="chart-title">📈 주간 운동 볼륨 추이</div>
      <div class="chart-sub">총 볼륨 = 무게 × 횟수 × 세트 (kg)</div>
      <div class="vol-bars">
        <div class="vol-bar" style="height:30px;"></div>
        <div class="vol-bar" style="height:45px;"></div>
        <div class="vol-bar" style="height:55px;"></div>
        <div class="vol-bar" style="height:70px;background:linear-gradient(180deg,#F4A261,#E07B2A);"></div>
      </div>
      <div class="vol-labels">
        <span>1주차 280</span><span>2주차 420</span><span>3주차 510</span><span style="color:#F4A261;font-weight:700;">이번주 650</span>
      </div>
      <div style="text-align:right;font-size:11px;color:#27AE60;font-weight:700;margin-top:6px;">▲ 볼륨 +27% 성장</div>
    </div>
    <div style="height:10px;"></div>
  </div>
  <div class="nav-bar">
    <div class="nav-item"><div class="nav-icon">🏠</div><div class="nav-label">홈</div></div>
    <div class="nav-item active"><div class="nav-icon">📊</div><div class="nav-label" style="color:#2E7D6B;">통계</div></div>
    <div class="nav-item"><div class="nav-icon">⚙️</div><div class="nav-label">설정</div></div>
  </div>
</div>

</body>
</html>
```

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
body{font-family:'Apple SD Gothic Neo','Noto Sans KR',sans-serif;background:#E8F0EE;display:flex;justify-content:center;padding:24px 12px;gap:20px;flex-wrap:wrap;}
.phone{width:375px;background:#F8FAF9;border-radius:44px;box-shadow:0 24px 64px rgba(0,0,0,0.18);overflow:hidden;border:2px solid #ccc;display:flex;flex-direction:column;max-height:820px;}
.status{background:#2E7D6B;color:#fff;padding:14px 24px 10px;display:flex;justify-content:space-between;font-size:11px;font-weight:700;flex-shrink:0;}
.screen-label{text-align:center;padding:6px;background:#1B5E4F;color:#a8d5c7;font-size:10px;font-weight:600;letter-spacing:1px;flex-shrink:0;}
.notif-body{flex:1;padding:20px 18px;overflow-y:auto;}
.notif-card{background:#fff;border-radius:16px;padding:16px;box-shadow:0 2px 10px rgba(0,0,0,0.08);margin-bottom:12px;display:flex;gap:12px;align-items:flex-start;border-left:4px solid #2E7D6B;}
.notif-icon{font-size:28px;flex-shrink:0;}
.notif-text .n-time{font-size:11px;color:#A0B4AE;margin-bottom:3px;}
.notif-text .n-title{font-size:14px;font-weight:700;color:#1A2420;margin-bottom:4px;}
.notif-text .n-body{font-size:12px;color:#5A7068;line-height:18px;}
.notif-text .n-cta{display:inline-block;margin-top:8px;padding:6px 14px;background:#EEF7F4;color:#2E7D6B;border-radius:8px;font-size:12px;font-weight:700;cursor:pointer;}
.report-header{background:linear-gradient(135deg,#2E7D6B,#1B5E4F);padding:20px 22px 26px;color:#fff;flex-shrink:0;}
.report-header .week-badge{display:inline-block;background:rgba(255,255,255,.2);border-radius:99px;padding:4px 12px;font-size:11px;margin-bottom:10px;}
.report-header h2{font-size:20px;font-weight:700;}
.report-header p{font-size:13px;opacity:.8;margin-top:4px;}
.scroll-body{flex:1;overflow-y:auto;padding:16px;}
.summary-strip{display:flex;gap:8px;margin-bottom:14px;}
.strip-card{flex:1;background:#fff;border-radius:12px;padding:12px;text-align:center;box-shadow:0 2px 6px rgba(0,0,0,0.06);}
.strip-card .sv{font-size:18px;font-weight:800;}
.strip-card .sl{font-size:10px;color:#5A7068;margin-top:2px;}
.strip-card .sd{font-size:11px;font-weight:700;margin-top:3px;}
.sd.pos{color:#27AE60;}
.section-head{font-size:13px;font-weight:700;color:#1A2420;margin-bottom:10px;display:flex;align-items:center;gap:6px;}
.ai-card{background:#fff;border-radius:14px;padding:16px;margin-bottom:10px;box-shadow:0 2px 8px rgba(0,0,0,0.06);}
.ai-card .ai-badge{display:inline-block;padding:3px 10px;border-radius:99px;font-size:11px;font-weight:700;margin-bottom:8px;}
.badge-reduce{background:#E8F5E9;color:#27AE60;}
.badge-increase{background:#EEF0FF;color:#5C6BC0;}
.badge-maintain{background:#FFF8F0;color:#C96A00;}
.ai-card .ai-title{font-size:14px;font-weight:700;color:#1A2420;margin-bottom:4px;}
.ai-card .ai-desc{font-size:12px;color:#5A7068;line-height:18px;}
.ai-card .ai-before-after{display:flex;align-items:center;gap:8px;margin-top:10px;padding:10px;background:#F8FAF9;border-radius:10px;}
.ai-before{font-size:13px;color:#5A7068;}
.ai-arrow{font-size:14px;color:#2E7D6B;font-weight:700;}
.ai-after{font-size:13px;color:#2E7D6B;font-weight:700;}
.safety-note{background:#FFF8F0;border:1.5px solid #F4A261;border-radius:12px;padding:12px 14px;margin-bottom:16px;display:flex;gap:10px;align-items:flex-start;}
.safety-note .si{font-size:18px;flex-shrink:0;}
.safety-note .st{font-size:12px;color:#C96A00;line-height:18px;}
.apply-btn{width:100%;padding:16px;background:linear-gradient(135deg,#2E7D6B,#1B5E4F);color:#fff;border:none;border-radius:14px;font-size:16px;font-weight:700;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:8px;margin-bottom:8px;}
.skip-btn{width:100%;padding:12px;background:transparent;color:#5A7068;border:1.5px solid #D4E0DB;border-radius:14px;font-size:14px;font-weight:600;cursor:pointer;}
.footer-pad{padding:16px 16px 28px;}
.nav-bar{display:flex;background:#fff;border-top:1px solid #E8EEEC;flex-shrink:0;}
.nav-item{flex:1;padding:10px 0 12px;text-align:center;cursor:pointer;}
.nav-item .nav-icon{font-size:20px;}
.nav-item .nav-label{font-size:10px;color:#A0B4AE;margin-top:2px;font-weight:600;}
</style>
</head>
<body>

<div class="phone">
  <div class="status"><span>오전 9:00</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">알림 센터 — 주간 리포트 알림 (Step 8.1)</div>
  <div style="background:#2E7D6B;padding:16px 20px;color:#fff;flex-shrink:0;">
    <div style="font-size:13px;opacity:.8;margin-bottom:2px;">알림 센터</div>
    <div style="font-size:18px;font-weight:700;">오늘 도착한 알림</div>
  </div>
  <div class="notif-body">
    <div style="font-size:11px;color:#A0B4AE;margin-bottom:10px;">방금 전</div>
    <div class="notif-card">
      <div class="notif-icon">🤖</div>
      <div class="notif-text">
        <div class="n-time">RecoveryFit · 지금</div>
        <div class="n-title">📊 주간 리포트가 도착했습니다</div>
        <div class="n-body">지난주 통증이 <strong>5점 → 3점</strong>으로 감소했습니다. 🎉<br>AI가 차주 플랜을 미세조정했어요. 확인해보세요!</div>
        <span class="n-cta">주간 리포트 보기 →</span>
      </div>
    </div>
    <div style="font-size:11px;color:#A0B4AE;margin-bottom:10px;margin-top:16px;">어제</div>
    <div class="notif-card" style="border-left-color:#D4E0DB;opacity:.6;">
      <div class="notif-icon">⏰</div>
      <div class="notif-text">
        <div class="n-time">RecoveryFit · 어제 오전 8:00</div>
        <div class="n-title">오늘의 운동을 시작해요!</div>
        <div class="n-body">오늘 루틴: 무릎 재활 3종 · 메인 2종 (예상 25분)</div>
        <span class="n-cta">운동 시작 →</span>
      </div>
    </div>
    <div style="background:#EEF7F4;border-radius:12px;padding:14px;margin-top:8px;text-align:center;">
      <div style="font-size:13px;color:#2E7D6B;font-weight:700;margin-bottom:4px;">💡 원터치 진입</div>
      <div style="font-size:12px;color:#5A7068;">알림을 탭하면 주간 리포트 화면으로 바로 이동합니다</div>
    </div>
  </div>
</div>

<div class="phone">
  <div class="status"><span>오전 9:01</span><span>●●● WiFi 🔋</span></div>
  <div class="screen-label">SCREEN 12 — 주간 리포트 & AI 미세조정 (Step 8.2)</div>
  <div class="report-header">
    <div class="week-badge">3주차 리포트</div>
    <h2>🤖 AI 주간 미세조정 완료</h2>
    <p>지난 7일 데이터를 분석하여 차주 플랜을 업데이트했습니다</p>
  </div>
  <div class="scroll-body">
    <div class="summary-strip">
      <div class="strip-card">
        <div class="sv" style="color:#27AE60;">3점</div>
        <div class="sl">이번 주 통증</div>
        <div class="sd pos">▼ -2점</div>
      </div>
      <div class="strip-card">
        <div class="sv" style="color:#2E7D6B;">75%</div>
        <div class="sl">완료율</div>
        <div class="sd pos">▲ +15%</div>
      </div>
      <div class="strip-card">
        <div class="sv" style="color:#F4A261;">650</div>
        <div class="sl">볼륨 (kg)</div>
        <div class="sd pos">▲ +27%</div>
      </div>
    </div>
    <div class="section-head">🔧 AI 조정 내역 (Haiku 모델)</div>
    <div class="ai-card">
      <span class="ai-badge badge-reduce">재활 동작 감소</span>
      <div class="ai-title">단기 재활 보조 동작 조정</div>
      <div class="ai-desc">통증이 감소했으므로 재활 전용 동작 비중을 줄이고 근력 강화로 전환합니다.</div>
      <div class="ai-before-after">
        <span class="ai-before">재활 3종 × 3세트</span>
        <span class="ai-arrow">→</span>
        <span class="ai-after">재활 2종 × 3세트 (▼20%)</span>
      </div>
    </div>
    <div class="ai-card">
      <span class="ai-badge badge-increase">메인 강도 상향</span>
      <div class="ai-title">메인 근력 동작 부하 증가</div>
      <div class="ai-desc">볼륨이 안정적으로 증가하고 있어 점진적 과부하 원칙에 따라 무게를 소폭 올립니다.</div>
      <div class="ai-before-after">
        <span class="ai-before">월 스쿼트 5kg × 10회</span>
        <span class="ai-arrow">→</span>
        <span class="ai-after">7.5kg × 10회 (+2.5kg)</span>
      </div>
    </div>
    <div class="ai-card">
      <span class="ai-badge badge-maintain">빈도 유지</span>
      <div class="ai-title">주 3회 스케줄 유지</div>
      <div class="ai-desc">현재 출석률과 회복 패턴이 최적화되어 있어 주 3회 빈도를 유지합니다.</div>
      <div class="ai-before-after">
        <span class="ai-before">주 3회</span>
        <span class="ai-arrow">→</span>
        <span class="ai-after">주 3회 (유지)</span>
      </div>
    </div>
    <div class="safety-note">
      <div class="si">🛡️</div>
      <div class="st">이중 안전 검증 완료 — 모든 조정 사항이 10개 안전 규칙을 통과하였습니다. 무릎 부상 제약 조건 준수.</div>
    </div>
  </div>
  <div class="footer-pad">
    <button class="apply-btn">⚡ 차주 플랜 적용하기 (원터치)</button>
    <button class="skip-btn">나중에 검토하기</button>
  </div>
  <div class="nav-bar">
    <div class="nav-item"><div class="nav-icon">🏠</div><div class="nav-label">홈</div></div>
    <div class="nav-item"><div class="nav-icon">📊</div><div class="nav-label">통계</div></div>
    <div class="nav-item"><div class="nav-icon">⚙️</div><div class="nav-label">설정</div></div>
  </div>
</div>

</body>
</html>
```

---

> **산출물 위치**: `/workspace/c052dd6b/design_spec.md`
>
> **주요 변경 사항 (ATM-5)**
> - **Screen A (Splash)**: `#0D1B2A` 풀스크린 + 인라인 SVG 심볼 아이콘 + Recovery**Fit** 워드마크(민트 강조) + 바운스 도트 3개 애니메이션
> - **Screen B (Landing)**: 딥 네이비 배경 위 인라인 SVG 히어로 일러스트(재활 인물 + 그래프 패널) + 그라디언트 오버레이 + 민트 CTA 버튼 + 가치 포인트 3종 SVG 아이콘
> - **ATM-6 ~ ATM-12**: 기존 목업 원본 유지하되 `font-family` 폴백 추가 및 미세 정리