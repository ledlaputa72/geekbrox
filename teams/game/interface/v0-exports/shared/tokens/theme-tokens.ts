/**
 * GeekBrox 공통 디자인 토큰
 * v0 → Figma Variables → 게임 엔진 공통 브릿지 파일
 *
 * 사용법:
 *  - v0: 이 파일의 값을 CSS Custom Properties로 적용
 *  - Figma: Variables Collection "Theme" 에 Dream/Dark 모드로 입력
 *  - 게임 엔진: GDScript 상수 또는 Unity ScriptableObject로 변환
 */

// ─── Dream 테마 (꿈 수집가) ───────────────────────────────────────────────
export const dreamTheme = {
  // 색상
  primary:     "#7B9EF0",              // 주 강조색 (소프트 블루)
  secondary:   "#C4A8E8",              // 보조색 (라벤더)
  accent:      "#F5F0FF",              // 액센트 (화이트)
  bgMain:      "#0D1B3E",              // 배경 메인 (딥 네이비)
  bgPanel:     "rgba(255,255,255,0.10)", // 패널 배경 (글래스)
  currency1:   "#FFE066",              // 재화 1 (레버리 — 금색)
  currency2:   "#E8D5FF",              // 재화 2 (드림샤드 — 연보라)
  textPrimary: "#FFFFFF",
  textSecondary: "#AABBDD",
  border:      "rgba(255,255,255,0.15)",

  // 타이포그래피
  fontDisplay: "'Nunito', '둥근 고딕', sans-serif",
  fontBody:    "'Noto Sans KR', sans-serif",
  fontWeightDisplay: 700,
  fontWeightBody: 300,

  // 레이아웃
  radiusCard:   16,    // px
  radiusButton: 20,    // px
  radiusChip:   999,   // px (완전 원형)
  radiusPanel:  12,    // px

  // 그림자 / 이펙트
  shadowStyle:   "glow",
  particleColor: "#C4A8E8",  // 별빛 파티클

  // 애니메이션 (ms)
  durationButtonTap:    150,
  durationScreenSlide:  300,
  durationPopup:        250,
  durationCardSelect:   200,
} as const;

// ─── Dark 테마 (던전 기생충) ─────────────────────────────────────────────
export const darkTheme = {
  // 색상
  primary:     "#8B1A1A",              // 주 강조색 (다크 크림슨)
  secondary:   "#4A3060",              // 보조색 (다크 퍼플)
  accent:      "#00CED1",              // 액센트 (청록, 기생체)
  bgMain:      "#0A0A0A",              // 배경 메인 (거의 검정)
  bgPanel:     "rgba(20,5,5,0.85)",   // 패널 배경
  currency1:   "#00CED1",              // 재화 1 (DNA 포인트 — 청록)
  currency2:   "#FFD700",              // 재화 2 (골드)
  textPrimary: "#E8E8E8",
  textSecondary: "#888888",
  border:      "rgba(139,26,26,0.40)",

  // 타이포그래피
  fontDisplay: "'Crimson Text', '날카로운 고딕', serif",
  fontBody:    "'Noto Sans KR', sans-serif",
  fontWeightDisplay: 700,
  fontWeightBody: 400,

  // 레이아웃
  radiusCard:   4,     // px (각진)
  radiusButton: 6,     // px
  radiusChip:   4,     // px
  radiusPanel:  6,     // px

  // 그림자 / 이펙트
  shadowStyle:   "hard-shadow",
  particleColor: "#00CED1",  // 감염 파티클

  // 애니메이션 (ms) — Dream과 동일
  durationButtonTap:    150,
  durationScreenSlide:  300,
  durationPopup:        250,
  durationCardSelect:   200,
} as const;

// ─── 공통 레이아웃 상수 (테마 무관) ─────────────────────────────────────
export const layout = {
  // 화면 기준
  screenWidth:  390,   // px
  screenHeight: 844,   // px

  // 영역 높이
  topBarHeight:     64,   // px (Safe Area 제외)
  topBarWithSafe:   108,  // px (Safe Area 포함)
  actionButtonHeight: 72, // px
  bottomNavHeight:  80,   // px
  bottomNavWithSafe: 114, // px

  // 여백
  screenPaddingH: 16,  // px (좌우)
  cardGap:         8,  // px
  sectionGap:     24,  // px

  // 터치 최소 영역
  minTouchTarget: 44,  // px (WCAG 기준)
} as const;

// ─── Figma Variables 입력 가이드 ─────────────────────────────────────────
/**
 * Figma에서 Variables Collection "Theme" 생성 후:
 *
 * Mode: Dream  →  dreamTheme 값 입력
 * Mode: Dark   →  darkTheme 값 입력
 *
 * 변수 계층 구조 (Figma 폴더 구조):
 *   color/
 *     primary, secondary, accent
 *     bg/main, bg/panel
 *     currency/1, currency/2
 *     text/primary, text/secondary
 *   radius/
 *     card, button, chip, panel
 *   spacing/
 *     screen-h, card-gap, section-gap
 *   animation/
 *     button-tap, screen-slide, popup, card-select
 */
