# UI 개발 워크플로우
## v0 → Figma → Game Engine (Godot / Unity)

**문서 버전:** 1.0
**작성일:** 2026-02-20
**적용 범위:** 꿈 수집가 · 던전 기생충 공통 UI 플랫폼 전체

---

## 📐 전체 파이프라인 개요

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GeekBrox UI 개발 파이프라인                        │
└─────────────────────────────────────────────────────────────────────┘

  [기획 문서]          [v0]              [Figma]         [Game Engine]
  .md 파일들     →  React 프로토타입  →  디자인 시스템  →  실제 게임 UI
  (이 폴더)        (웹 브라우저 확인)   (에셋/토큰 추출)  (Godot/Unity)

  ────────────        ─────────────      ──────────────    ──────────────
  목적:               목적:              목적:             목적:
  구조/로직 확정       빠른 시각화         디자인 확정        실제 동작 구현
                      인터랙션 검증       에셋 내보내기
                      스택홀더 확인

  도구:               도구:              도구:             도구:
  Claude Code         v0.dev             Figma Desktop     Godot 4.x
  텍스트 에디터        React/Tailwind      Variables         또는 Unity 2D
                      shadcn/ui          Auto Layout
```

---

## 🔄 단계별 상세 워크플로우

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PHASE 1 — 기획 확정 (현재 단계 ✅)
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**도구:** Claude Code + `.md` 파일
**산출물:** `teams/game/interface/` 폴더의 모든 기획 문서
**완료 기준:** 화면 목록, 컴포넌트 목록, 테마 변수 확정

```
기획 문서 (완료 ✅)
  ├── COMMON_UI_PLATFORM.md  → 전체 구조 + 테마 시스템
  ├── UI_COMPONENTS.md       → 컴포넌트 상세 사양
  ├── SCREEN_FLOW.md         → 화면 흐름도
  ├── IMPLEMENTATION_GUIDE.md → 엔진 구현 가이드
  └── WORKFLOW_V0_TO_ENGINE.md → 이 문서
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PHASE 2 — v0 프로토타이핑
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**도구:** [v0.dev](https://v0.dev)
**목적:** 실제 화면처럼 보이는 인터랙티브 프로토타입을 빠르게 제작
**기간:** 화면당 30분~2시간
**산출물:** React 컴포넌트 코드 (`.tsx`) + 라이브 미리보기 URL

#### v0 사용 흐름

```
1. v0.dev 접속
   │
2. 프롬프트 입력 (아래 V0_PROMPT_GUIDE.md 참조)
   │
   예시: "모바일 방치형 게임 메인 로비 화면,
         세로 390×844, 상단 재화 바, 중앙 캐릭터 방치 애니,
         하단 대형 수집 버튼, 5탭 내비게이션, 다크 글래스모피즘"
   │
3. v0가 React + Tailwind + shadcn/ui로 생성
   │
4. 실시간 미리보기에서 확인 및 수정 지시
   │
   예시: "하단 탭 아이콘을 더 크게, 카드 모서리를 더 둥글게"
   │
5. 만족스러우면 코드 복사 → 로컬 저장
   │
6. Figma 이전 준비
```

#### v0 작업 우선순위 (제작 순서)

| 순번 | 화면 | 예상 시간 | 비고 |
|------|------|---------|------|
| 1 | 메인 로비 (Dream 테마) | 1~2h | 가장 핵심, 먼저 확정 |
| 2 | 카드 라이브러리 | 1h | 카드 그리드 레이아웃 |
| 3 | 덱 빌더 | 1h | 카드 라이브러리 변형 |
| 4 | 업그레이드 트리 | 1.5h | 노드 연결 구조 |
| 5 | 상점 | 1h | 목록형 레이아웃 |
| 6 | 팝업 시스템 | 0.5h | 카드 획득 등 |
| 7 | 메인 로비 (Dark 테마) | 0.5h | Dream 변형 |
| 8 | 던전 전투 화면 | 2h | 게임별 전용 |

#### v0 산출물 저장 위치

```
teams/game/interface/
  └── v0-exports/
        ├── dream-theme/
        │     ├── main-lobby.tsx
        │     ├── card-library.tsx
        │     ├── deck-builder.tsx
        │     ├── upgrade-tree.tsx
        │     └── shop.tsx
        ├── dark-theme/
        │     └── main-lobby.tsx
        └── shared/
              ├── components/
              │     ├── CurrencyChip.tsx
              │     ├── CardThumbnail.tsx
              │     └── BottomNavBar.tsx
              └── tokens/
                    └── theme-tokens.ts   ← CSS 변수 → 엔진 토큰 브릿지
```

#### v0 → Figma 이전 시 체크리스트

```
v0 단계 완료 기준:
  [ ] 모든 공통 화면 (C-01~C-07) 미리보기 확인 완료
  [ ] 두 테마(Dream/Dark) 전환 확인 완료
  [ ] 모바일 비율(390px 너비) 확인 완료
  [ ] 주요 인터랙션(탭 전환, 팝업) 동작 확인 완료
  [ ] 코드 로컬 저장 완료 (v0-exports/)
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PHASE 3 — Figma 디자인 시스템 구축
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**도구:** Figma Desktop
**목적:** v0 결과물을 디자인 시스템으로 정제 + 에셋 내보내기 준비
**기간:** 화면당 1~3시간 (v0 대비 느리지만 정밀)
**산출물:** Figma 컴포넌트 라이브러리 + 내보내기용 에셋

#### v0 → Figma 이전 방법 (3가지 옵션)

**방법 A: 수동 재현 (권장 — 품질 최고)**
```
1. v0 미리보기를 Figma 옆에 띄워놓고
2. v0의 치수/색상을 직접 측정하여 Figma에서 재현
3. v0 코드에서 색상값/폰트/간격 추출 → Figma Variables에 입력
4. Auto Layout으로 정밀하게 재구성

장점: 가장 정확, Figma 컴포넌트 구조 최적화 가능
단점: 시간 소요 (화면당 2~3h)
추천: 핵심 화면 (메인 로비, 카드 라이브러리)에 적용
```

**방법 B: Anima 플러그인 활용 (자동화)**
```
1. v0 생성 React 코드를 로컬 프로젝트에 붙여넣기
2. Anima Figma 플러그인 설치
3. Anima의 "HTML to Figma" 기능으로 변환
4. Figma에서 수동 정리 (Auto Layout 재설정 필요)

장점: 빠른 초안 생성
단점: Auto Layout 무너질 수 있음, 수동 정리 필요
추천: 보조 화면 (설정, 퀘스트 등)에 적용
```

**방법 C: html.to.design 플러그인 (웹→Figma)**
```
1. v0 라이브 미리보기 URL 복사
2. Figma → Plugins → html.to.design 실행
3. URL 입력 → Import
4. 레이어 정리 및 컴포넌트화

장점: URL만 있으면 빠름
단점: 레이어 구조 엉킴, 대규모 정리 필요
추천: 빠른 레이아웃 참조용 (실제 에셋 작업은 별도)
```

#### Figma 작업 순서

```
Step 1: Foundation 설정 (v0 토큰 → Figma Variables)
  v0의 theme-tokens.ts 파일에서 값 추출
  → Figma Variables Collection "Theme" 생성
  → Dream / Dark 두 Mode 설정
  → 색상, 폰트, 반경 등 15개 변수 입력

Step 2: 컴포넌트 라이브러리 제작
  v0의 공통 컴포넌트(CurrencyChip, CardThumbnail 등)를
  Figma 네이티브 컴포넌트로 재현
  → Auto Layout 적용
  → Variants 설정 (상태별)
  → 두 테마 Variables 연결

Step 3: 화면별 Hi-Fi 목업
  v0 미리보기 참고하여 각 화면 Figma로 재현
  → 컴포넌트 라이브러리에서 드래그 앤 드롭
  → 실제 게임 에셋(캐릭터 이미지 등) 교체

Step 4: 프로토타입 연결
  Figma의 Prototype 기능으로 화면 간 전환 연결
  → Smart Animate 애니메이션 설정
  → 팀 공유 및 피드백

Step 5: 에셋 내보내기 (엔진 이전 준비)
  → 이미지 에셋: PNG @2x, @3x
  → 9-slice 에셋: 버튼, 패널, 카드 프레임
  → 아이콘: SVG
  → 폰트: .ttf / .otf
  → 색상 토큰: JSON 내보내기 (Tokens Studio 플러그인)
```

#### Figma 완성 기준 체크리스트

```
  [ ] Variables 설정: Dream/Dark 두 Mode 완성
  [ ] 컴포넌트: 모든 Atoms/Molecules 라이브러리 완성
  [ ] 화면: 공통 9개 화면 Hi-Fi 완성
  [ ] 화면: 게임별 인게임 4개 화면 완성
  [ ] 두 테마 스위칭 테스트 통과
  [ ] 안전 영역(Safe Area) 반영 확인
  [ ] 에셋 내보내기 완료 (PNG + SVG + JSON 토큰)
  [ ] 개발팀 Handoff 공유 링크 생성
```

---

### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
### PHASE 4 — Game Engine 구현
### ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

**도구:** Godot 4.x (또는 Unity 2D)
**목적:** Figma 에셋을 실제 게임 UI로 구현
**참조 문서:** `IMPLEMENTATION_GUIDE.md`

#### Figma → Godot 이전 체크리스트

```
에셋 준비:
  [ ] PNG 스프라이트: res://UI/Assets/ 폴더에 배치
  [ ] 폰트 파일: res://UI/Fonts/ 폴더에 배치
  [ ] 9-Slice 에셋: AtlasTexture 또는 StyleBoxTexture 설정
  [ ] 색상 토큰 JSON → GDScript 상수 또는 Theme Resource로 변환

구현 순서:
  1. ThemeManager 싱글톤 구현 (res://UI/Common/ThemeManager.gd)
  2. 공통 Atoms 씬 제작 (CurrencyChip.tscn, CardThumbnail.tscn 등)
  3. 공통 Organisms 씬 제작 (TopBar.tscn, BottomNavBar.tscn)
  4. 공통 화면 씬 제작 (MainLobby.tscn, CardLibrary.tscn 등)
  5. Dream 테마 에셋 연결 (꿈 수집가)
  6. Dark 테마 에셋 연결 (던전 기생충)
  7. 게임별 인게임 씬 연결
```

#### Figma → Unity 이전 체크리스트

```
에셋 준비:
  [ ] PNG: Assets/UI/Sprites/ 폴더에 배치
  [ ] 폰트: TextMesh Pro 폰트 에셋으로 변환 (Window→TMP→Font Asset Creator)
  [ ] 9-Slice: Sprite Editor에서 슬라이싱 설정
  [ ] 색상 토큰 JSON → ScriptableObject(ThemeData)에 수동 입력

구현 순서:
  1. ThemeManager.cs ScriptableObject 구현
  2. 공통 Prefab 제작 (CurrencyChip, CardThumbnail 등)
  3. Canvas 레이어 구조 설정 (HUD/Content/Popup/Toast)
  4. 공통 화면 Prefab 완성
  5. 두 게임별 ThemeData 연결
```

---

## 🔧 도구별 역할 분담 요약

| 단계 | 도구 | 누가 | 산출물 |
|------|------|------|--------|
| 기획 | Claude Code + .md | Steve + Claude | 구조/사양 문서 |
| 시각화 | **v0.dev** | Steve | React 프로토타입 |
| 디자인 확정 | **Figma** | Steve | 컴포넌트 라이브러리 + 에셋 |
| 엔진 구현 | **Godot/Unity** | Steve + OpenClaw팀 | 실제 게임 UI |

---

## ⚡ 각 도구의 강점과 한계

### v0

| 강점 | 한계 |
|------|------|
| 기획 → 시각화 속도가 압도적으로 빠름 | 모바일 게임 특화 컴포넌트 부족 |
| 인터랙션 즉시 확인 가능 | Figma Variables처럼 테마 관리 불가 |
| 코드(React)로 Figma 이전 가능 | 에셋 내보내기 기능 없음 |
| shadcn/ui 컴포넌트로 빠른 레이아웃 | 게임 엔진 직접 연동 불가 |

### Figma

| 강점 | 한계 |
|------|------|
| Variables로 테마 관리 완벽 | v0 대비 초기 작업 느림 |
| Handoff (개발자 스펙 공유) | 인터랙션 표현 한계 |
| 에셋 내보내기 (PNG/SVG) | 코드 생성 품질 불안정 |
| 컴포넌트 Variants 시스템 | |

### Godot / Unity

| 강점 | 한계 |
|------|------|
| 실제 게임과 동일한 환경 | 수정 반영 속도 느림 |
| 애니메이션/사운드/햅틱 통합 | 디자인 변경 시 재작업 필요 |
| 게임 로직과 UI 직접 연동 | |

---

## 📦 v0 → Figma 이전 시 핵심 매핑 규칙

### Tailwind 색상 → Figma Variables 매핑

v0는 Tailwind CSS를 사용하므로, 코드에서 색상을 추출할 때:

```typescript
// v0가 생성한 theme-tokens.ts 예시
export const dreamTheme = {
  // Tailwind 커스텀 → Figma Variable 이름 매핑
  primary:     "#7B9EF0",  // → color/primary (Dream)
  secondary:   "#C4A8E8",  // → color/secondary (Dream)
  accent:      "#F5F0FF",  // → color/accent (Dream)
  bgMain:      "#0D1B3E",  // → color/bg/main (Dream)
  bgPanel:     "rgba(255,255,255,0.10)", // → color/bg/panel (Dream)
  currency1:   "#FFE066",  // → color/currency/1 (Dream)
  currency2:   "#E8D5FF",  // → color/currency/2 (Dream)
}

export const darkTheme = {
  primary:     "#8B1A1A",  // → color/primary (Dark)
  secondary:   "#4A3060",  // → color/secondary (Dark)
  accent:      "#00CED1",  // → color/accent (Dark)
  bgMain:      "#0A0A0A",  // → color/bg/main (Dark)
  bgPanel:     "rgba(20,5,5,0.85)", // → color/bg/panel (Dark)
  currency1:   "#00CED1",  // → color/currency/1 (Dark)
  currency2:   "#FFD700",  // → color/currency/2 (Dark)
}
```

### Tailwind 간격 → Figma 스페이싱 매핑

```
Tailwind    →   실제 픽셀   →   Figma 스페이싱 토큰
p-1              4px             space-xs
p-2              8px             space-sm
p-3             12px             space-md
p-4             16px             space-lg
p-6             24px             space-xl
p-8             32px             space-xxl
rounded-md       6px             radius/button (Dark)
rounded-xl      12px             radius/panel
rounded-2xl     16px             radius/card (Dream)
rounded-full    999px            radius/chip
```

### shadcn/ui 컴포넌트 → Figma 컴포넌트 매핑

| v0 / shadcn 컴포넌트 | Figma 컴포넌트 | 비고 |
|---------------------|--------------|------|
| `<Button>` | `MainActionButton` | 크기/색상 교체 |
| `<Badge>` | `CurrencyChip`, `RarityBadge` | 용도별 분리 |
| `<Card>` | `CardThumbnail`, `ShopItem` | 게임 특화 재설계 |
| `<Tabs>` | `BottomNavBar` | 하단 고정으로 변형 |
| `<Dialog>` | `CommonPopup` | 게임 팝업 스타일 적용 |
| `<Progress>` | `ProgressBar` | 디자인만 변경 |
| `<ScrollArea>` | `CardGrid`, `DeckSlotRow` | 스크롤 방향 변환 |

---

## 🗂️ 폴더 구조 (전체 업데이트)

```
teams/game/interface/
  │
  ├── 📄 README.md
  ├── 📄 WORKFLOW_V0_TO_ENGINE.md     ← 이 문서
  ├── 📄 COMMON_UI_PLATFORM.md        ← 기획 핵심
  ├── 📄 UI_COMPONENTS.md             ← 컴포넌트 사양
  ├── 📄 SCREEN_FLOW.md               ← 화면 흐름도
  ├── 📄 IMPLEMENTATION_GUIDE.md      ← 엔진 구현 가이드
  ├── 📄 V0_PROMPT_GUIDE.md           ← v0 프롬프트 템플릿
  │
  ├── 📁 v0-exports/                  ← v0 생성 코드 저장
  │     ├── dream-theme/
  │     ├── dark-theme/
  │     └── shared/
  │           └── tokens/
  │                 └── theme-tokens.ts
  │
  ├── 📁 figma-exports/               ← Figma 내보내기 에셋
  │     ├── sprites/
  │     │     ├── dream/
  │     │     └── dark/
  │     ├── icons/
  │     │     └── (SVG 아이콘)
  │     ├── fonts/
  │     └── tokens/
  │           └── design-tokens.json  ← Tokens Studio 내보내기
  │
  └── 📁 engine-assets/               ← 엔진 준비 완료 에셋
        ├── godot/
        │     └── (Godot 프로젝트 폴더 구조)
        └── unity/
              └── (Unity Assets 폴더 구조)
```

---

## 📅 전체 일정 제안

```
Week 1 (현재):
  ✅ 기획 문서 완성
  ⬜ v0 메인 로비 (Dream) 제작
  ⬜ v0 카드 라이브러리 제작

Week 2:
  ⬜ v0 나머지 공통 화면 완성 (덱빌더, 업그레이드, 상점)
  ⬜ v0 Dark 테마 메인 로비
  ⬜ Figma 프로젝트 설정 + Variables 구성

Week 3:
  ⬜ Figma 컴포넌트 라이브러리 구축 (v0 → Figma 이전)
  ⬜ Figma 공통 화면 5개 Hi-Fi 완성

Week 4:
  ⬜ Figma 나머지 화면 + 인게임 화면
  ⬜ Figma 에셋 내보내기
  ⬜ 엔진 ThemeManager + 기본 컴포넌트 구현 시작
```

---

## 💡 자주 하는 실수 및 주의사항

### v0 단계
```
❌ 실수: 인게임 전투 화면까지 v0로 만들려고 함
✅ 올바름: 인게임은 엔진에서 직접 제작, v0는 메타 UI만

❌ 실수: v0 코드를 그대로 게임 엔진에 쓰려고 함
✅ 올바름: v0는 시각 참고용, 엔진 코드는 별도 작성

❌ 실수: Dark 테마를 처음부터 따로 만들기
✅ 올바름: Dream 테마 완성 후 CSS 변수만 바꿔서 파생
```

### Figma 단계
```
❌ 실수: v0 레이아웃을 그대로 복붙하여 Auto Layout 없이 고정 크기로
✅ 올바름: 반드시 Auto Layout 적용 (반응형 보장)

❌ 실수: 색상을 하드코딩 (#7B9EF0)으로 직접 입력
✅ 올바름: 반드시 Variables 참조 (테마 스위칭 가능하도록)

❌ 실수: 폰트를 설치하지 않고 작업하다 깨짐
✅ 올바름: 작업 전 Noto Sans KR, Nunito 폰트 먼저 설치
```

### 엔진 단계
```
❌ 실수: Figma 에셋 @1x 해상도로 가져오기
✅ 올바름: @2x 또는 @3x로 가져와 엔진에서 스케일 다운

❌ 실수: 텍스트 하드코딩
✅ 올바름: 다국어 대응을 위해 CSV/JSON 기반 로컬라이제이션

❌ 실수: 두 게임의 UI 씬을 완전히 별개로 만들기
✅ 올바름: 공통 씬 상속 + 테마 데이터만 교체
```

---

_Workflow Document v1.0 | GeekBrox 게임팀 | 2026-02-20_
