# 공통 UI 플랫폼 기획안 (Common UI Platform)
## 방치형 덱빌딩 모바일 게임 통합 인터페이스

**문서 버전:** 1.1
**작성일:** 2026-02-20
**최종 수정:** 2026-02-20
**작성자:** GeekBrox 게임팀
**적용 대상:** 꿈 수집가 (Dream Collector) · 던전 기생충 (Dungeon Parasite)
**상태:** 🟢 기획 확정 + v0 워크플로우 수립 완료, v0 프로토타이핑 단계

---

## 📌 개요 및 목적

### 왜 공통 플랫폼인가?

두 게임은 소재와 분위기가 전혀 다르지만, **인게임(전투/탐험) 외의 모든 메타 UI 구조가 동일**합니다.

| 구분 | 꿈 수집가 | 던전 기생충 | 공통 여부 |
|------|-----------|------------|----------|
| 상단 재화 바 | 레버리 + 드림샤드 | DNA 포인트 + 골드 | ✅ 레이아웃 동일 |
| 메인 로비 | 수집가 캐릭터 방치 | 기생체 대기 화면 | ✅ 구조 동일 |
| 메인 액션 버튼 | [수집] 큰 버튼 | [런 시작] 큰 버튼 | ✅ 위치/크기 동일 |
| 카드 라이브러리 | 꿈 카드 목록 | 기생체·숙주 카드 목록 | ✅ 필터/그리드 동일 |
| 업그레이드 트리 | 프레스티지 승천 | DNA 포인트 업그레이드 | ✅ 트리 구조 동일 |
| 상점 | 카드 팩·꾸미기 | DLC·꾸미기 팩 | ✅ 레이아웃 동일 |
| 설정/공통팝업 | 동일 | 동일 | ✅ 100% 재사용 |

**개발 효율 예측:** 메타 UI 코드의 **약 75%** 재사용 가능
→ 두 번째 게임 메타 UI 개발 시간 **50~60% 단축** 예상

---

## 🎨 테마 시스템 (Theme Switching)

### 핵심 원칙: 에셋만 교체, 구조는 불변

```
공통 UI 플랫폼 (구조/로직)
        │
   ┌────┴────┐
   ▼         ▼
Dream      Dark
Theme      Theme
(꿈 수집가) (던전 기생충)
```

### 테마 변수 정의 (Figma Variables / CSS Custom Properties)

| 변수명 | Dream 테마 | Dark 테마 | 설명 |
|--------|-----------|----------|------|
| `--color-primary` | `#7B9EF0` (소프트 블루) | `#8B1A1A` (다크 크림슨) | 주 강조색 |
| `--color-secondary` | `#C4A8E8` (라벤더) | `#4A3060` (다크 퍼플) | 보조색 |
| `--color-accent` | `#F5F0FF` (화이트) | `#00CED1` (청록, 기생체) | 액센트 |
| `--color-bg-main` | `#0D1B3E` (딥 네이비) | `#0A0A0A` (거의 검정) | 배경 메인 |
| `--color-bg-panel` | `rgba(255,255,255,0.10)` | `rgba(20,5,5,0.85)` | 패널 배경 |
| `--color-currency-1` | `#FFE066` (금색, 레버리) | `#00CED1` (청록, DNA) | 재화 1 색상 |
| `--color-currency-2` | `#E8D5FF` (연보라, 드림샤드) | `#FFD700` (금색, 골드) | 재화 2 색상 |
| `--font-display` | `Nunito / 둥근 고딕` | `Crimson Text / 날카로운 고딕` | 제목 폰트 |
| `--font-body` | `Noto Sans KR (Light)` | `Noto Sans KR (Regular)` | 본문 폰트 |
| `--border-radius-card` | `16px` (부드러운) | `4px` (각진) | 카드 모서리 |
| `--shadow-style` | `glow (발광)` | `hard-shadow (어두운 그림자)` | 그림자 스타일 |
| `--particle-color` | `#C4A8E8` (별빛 파티클) | `#00CED1` (감염 파티클) | 파티클 색상 |

---

## 📱 마스터 레이아웃 구조 (세로 모드 기준, 390×844px)

### 전체 화면 구조

```
┌─────────────────────────────┐  ← 390px
│                             │
│  ① 상단 재화 바 (64px)      │
│  [💎재화1: XXX] [💰재화2: X] │
│  [설정⚙️] [알림🔔]          │
│                             │
├─────────────────────────────┤
│                             │
│                             │
│  ② 메인 비주얼 영역         │
│     (360px 높이)            │
│  [캐릭터 애니메이션]        │
│  [배경 파티클 효과]         │
│  [오프라인 수익 팝업]       │
│                             │
│                             │
├─────────────────────────────┤
│                             │
│  ③ 메인 액션 버튼 (72px)    │
│  ┌─────────────────────┐   │
│  │  🎯 [게임별 메인 액션] │   │
│  └─────────────────────┘   │
│                             │
├─────────────────────────────┤
│                             │
│  ④ 보조 정보 바 (48px)      │
│  [진행률/레벨] [오늘 퀘스트] │
│                             │
├─────────────────────────────┤
│                             │
│  ⑤ 하단 내비게이션 (80px)   │
│  [🏠홈][🃏카드][⬆업그][🏪상점][⚙설정] │
│                             │
└─────────────────────────────┘
     ← Safe Area (iPhone 홈 인디케이터) →
```

### 각 영역 상세 사양

#### ① 상단 재화 바
```
높이: 64px (상단 Safe Area 포함 시 108px)
배경: --color-bg-panel + blur(8px)
패딩: 좌우 16px, 상 44px(Safe Area), 하 8px

좌측 영역 (재화 표시):
  ┌──────────┐ ┌──────────┐
  │[아이콘] X│ │[아이콘] X│  ← 재화 칩 컴포넌트
  └──────────┘ └──────────┘
  각 칩: 높이 32px, 패딩 8px 12px, 라운드 16px

우측 영역 (액션 버튼):
  [🔔] [⚙️]  ← 각 32×32px 아이콘 버튼
```

#### ③ 메인 액션 버튼
```
높이: 72px
너비: 화면 너비 - 32px (양쪽 16px 마진)
라운드: 20px
배경: --color-primary (그라데이션 가능)
폰트: --font-display, 20px, Bold
햅틱: Medium Impact
애니메이션: 탭 시 scale(0.96) → scale(1.0), 150ms ease-out
```

#### ⑤ 하단 내비게이션 탭 바
```
높이: 80px (+ 하단 Safe Area ~34px = 총 114px)
배경: --color-bg-main + 상단 border 1px
탭 수: 5개 고정
각 탭: 너비 78px, 아이콘 24px + 텍스트 11px
활성 탭: --color-primary 색상, 아이콘 scale(1.1)
비활성 탭: 회색 (#666)
```

---

## 🗂️ 화면 목록 (전체 13개)

### 공통 화면 (두 게임 완전 동일, 100% 재사용)

| 번호 | 화면명 | 설명 | 우선순위 |
|------|--------|------|---------|
| C-01 | **메인 로비** | 캐릭터 방치 + 메인 액션 버튼 | ⭐ 최고 |
| C-02 | **카드 라이브러리** | 전체 카드 목록 + 필터 | ⭐ 최고 |
| C-03 | **덱 빌더** | 현재 덱 편집 | ⭐ 최고 |
| C-04 | **업그레이드 트리** | 영구 업그레이드 (프레스티지/DNA) | ⭐ 높음 |
| C-05 | **상점** | 패키지/개별 구매 | ⭐ 높음 |
| C-06 | **설정** | 사운드/언어/계정 | 중간 |
| C-07 | **일일 퀘스트** | 오늘의 목표 | 중간 |
| C-08 | **업적** | 달성 목록 | 낮음 |
| C-09 | **공통 팝업 시스템** | 알림/확인/에러 팝업 | ⭐ 최고 |

### 게임별 고유 화면 (인게임)

| 번호 | 화면명 | 꿈 수집가 | 던전 기생충 |
|------|--------|-----------|------------|
| G-01 | **런 준비** | 몽상가 선택 | 계통 선택 |
| G-02 | **인게임 메인** | 꿈의 세계 + 방치 뷰 | 전투 화면 (세로) |
| G-03 | **런 완료** | 레버리 수집 결과 | 전투 보상 + 소비/유지 |
| G-04 | **이벤트 팝업** | 선택 이벤트 카드 | 던전 이벤트/상점 |

---

## 🔄 게임별 UI 매핑 (공통 → 게임별)

### 재화 시스템 매핑

| 공통 슬롯 | 꿈 수집가 | 던전 기생충 |
|----------|-----------|------------|
| 재화 슬롯 1 (주) | 레버리 💎 | DNA 포인트 🧬 |
| 재화 슬롯 2 (프리미엄) | 드림샤드 ✨ | 골드 💰 |
| 재화 슬롯 3 (선택) | — | — |

### 내비게이션 탭 매핑

| 탭 번호 | 꿈 수집가 | 던전 기생충 |
|---------|-----------|------------|
| 탭 1 | 🏠 홈 (기록소) | 🏠 홈 (메인 메뉴) |
| 탭 2 | 🃏 카드 | 🃏 컬렉션 |
| 탭 3 | ⬆️ 업그레이드 | ⬆️ 업그레이드 |
| 탭 4 | 🌙 프레스티지 | 🧬 계통 |
| 탭 5 | 🏪 상점 | 🏪 상점 |

### 메인 액션 버튼 매핑

| 항목 | 꿈 수집가 | 던전 기생충 |
|------|-----------|------------|
| 버튼 텍스트 | 💎 수집하기 (XXX 레버리) | 🎮 런 시작 |
| 보조 텍스트 | 다음 수집까지 X시간 | 예상 시간: 5~15분 |
| 색상 | Dream 테마 Primary | Dark 테마 Primary |

---

## 📐 Atomic Design 컴포넌트 계층

```
Atoms (원자) → Molecules (분자) → Organisms (유기체) → Templates → Pages
```

### Atoms (재사용 최소 단위)
- `CurrencyChip` — 재화 아이콘 + 숫자
- `IconButton` — 아이콘 단독 버튼 (32×32)
- `Badge` — 알림 뱃지 (빨간 점)
- `ProgressBar` — 진행률 바
- `RarityDot` — 희귀도 색상 점 (일반/언커먼/레어/전설)
- `CardFrame` — 카드 외곽 프레임 (테마별 교체)
- `TabItem` — 하단 탭 단일 아이템

### Molecules (복합 컴포넌트)
- `CurrencyBar` — CurrencyChip × 2~3
- `CardThumbnail` — CardFrame + 이미지 + 코스트
- `UpgradeNode` — 아이콘 + 텍스트 + 현재레벨/최대레벨 + 버튼
- `ShopItem` — 상품 이미지 + 이름 + 가격 + 구매버튼
- `QuestRow` — 퀘스트 아이콘 + 텍스트 + 진행바 + 보상

### Organisms (화면 구성 단위)
- `TopBar` — CurrencyBar + 설정버튼 + 알림버튼
- `MainCharacterArea` — 캐릭터 애니메이션 + 배경 + 파티클
- `MainActionButton` — 대형 CTA 버튼 + 보조 텍스트
- `BottomNavBar` — TabItem × 5
- `CardGrid` — CardThumbnail × N + 필터 헤더
- `DeckSlots` — 현재 덱 카드 슬롯 가로 스크롤
- `UpgradeTree` — UpgradeNode + 연결선 SVG
- `ShopGrid` — ShopItem × N + 카테고리 탭

---

## 🎮 인터랙션 표준 규격

### 애니메이션 타이밍 (두 게임 동일 적용)

| 인터랙션 | Duration | Easing | 비고 |
|---------|----------|--------|------|
| 버튼 탭 | 150ms | ease-out | scale 0.96→1.0 |
| 화면 전환 (슬라이드) | 300ms | ease-in-out | 좌→우 또는 하→상 |
| 팝업 등장 | 250ms | spring (overshoot) | scale 0.8→1.05→1.0 |
| 카드 선택 | 200ms | ease-out | scale 1.0→1.08, 상단 이동 |
| 재화 증가 | 500ms | ease-out | 숫자 카운트업 |
| 업그레이드 완료 | 600ms | ease-in-out | 빛나는 파티클 방사 |
| 탭 전환 | 200ms | ease | fade + 탭 아이콘 scale |

### 햅틱 피드백 규격 (iOS/Android 공통)

| 이벤트 | 햅틱 타입 | 강도 |
|--------|----------|------|
| 버튼 탭 (일반) | Light Impact | 낮음 |
| 메인 액션 버튼 | Medium Impact | 중간 |
| 카드 획득 | Notification (Success) | 중간 |
| 업그레이드 완료 | Heavy Impact | 높음 |
| 런 시작 | Medium Impact | 중간 |
| 에러/실패 | Notification (Error) | 중간 |

### 터치 타겟 최소 규격 (WCAG 기준)
- **최소 탭 영역:** 44 × 44pt (= 88 × 88px @2x)
- **카드 터치 영역:** 실제 카드 크기 + 8pt 패딩
- **하단 탭:** 78 × 80pt (충분히 큼)

---

## 🏗️ 개발 구현 가이드라인

### 권장 폴더 구조 (Unity 또는 Godot)

```
/UI
  /Common          ← 공통 컴포넌트 (두 게임 공유)
    /Atoms
    /Molecules
    /Organisms
    /Themes
      /Dream       ← 꿈 수집가 테마 에셋
      /Dark        ← 던전 기생충 테마 에셋
    /Animations
    /Fonts
  /DreamCollector  ← 꿈 수집가 전용 (인게임)
    /IdleView
    /RunScreen
    /EventPopup
  /DungeonParasite ← 던전 기생충 전용 (인게임)
    /CombatScreen
    /HostSelection
    /RewardScreen
```

### 테마 적용 방식 (Unity 예시)

```csharp
// ThemeManager.cs (공통)
public enum GameTheme { Dream, Dark }

public class ThemeManager : MonoBehaviour
{
    public static ThemeManager Instance;
    public ThemeData currentTheme;

    public void ApplyTheme(GameTheme theme)
    {
        currentTheme = theme == GameTheme.Dream
            ? dreamThemeData
            : darkThemeData;

        // 모든 UI 컴포넌트에 테마 브로드캐스트
        OnThemeChanged?.Invoke(currentTheme);
    }
}

// IThemeable.cs (인터페이스)
public interface IThemeable
{
    void OnThemeChanged(ThemeData theme);
}
```

### 테마 적용 방식 (Godot 예시)

```gdscript
# theme_manager.gd
extends Node

enum Theme { DREAM, DARK }

var current_theme: Theme = Theme.DREAM

func apply_theme(theme: Theme) -> void:
    current_theme = theme
    var theme_res = load("res://UI/Themes/" +
        ("Dream" if theme == Theme.DREAM else "Dark") +
        "/theme.tres")
    get_tree().root.theme = theme_res
    emit_signal("theme_changed", theme)
```

---

## 🔄 개발 워크플로우 (v0 → Figma → 게임 엔진)

> 자세한 내용: [`WORKFLOW_V0_TO_ENGINE.md`](WORKFLOW_V0_TO_ENGINE.md)
> v0 프롬프트 가이드: [`V0_PROMPT_GUIDE.md`](V0_PROMPT_GUIDE.md)

### 워크플로우 4단계 요약

```
[1단계: 기획]          [2단계: v0 프로토타입]       [3단계: Figma 디자인]      [4단계: 게임 엔진]
기획 문서 작성    →    v0.dev로 빠른 UI 시안   →    Figma 디자인 시스템    →   Godot / Unity 구현
(현재 문서)            React + Tailwind             Variables + Components      ThemeManager 적용
                        CSS 변수로 테마 전환          Hi-Fi 프로토타입
                        ↓                             ↓
                    v0-exports/ 저장              figma-exports/ 저장
```

### 폴더 구조 (teams/game/interface/ 하위)

```
interface/
├── COMMON_UI_PLATFORM.md     ← 이 문서 (핵심 기획)
├── UI_COMPONENTS.md          ← 컴포넌트 상세 사양
├── SCREEN_FLOW.md            ← 화면 흐름도
├── IMPLEMENTATION_GUIDE.md   ← Figma/엔진 구현 가이드
├── WORKFLOW_V0_TO_ENGINE.md  ← 전체 파이프라인 문서 (NEW)
├── V0_PROMPT_GUIDE.md        ← v0 프롬프트 템플릿 (NEW)
├── v0-exports/               ← v0에서 생성한 코드 저장
│   ├── dream-theme/          ← 꿈 수집가 테마 화면
│   ├── dark-theme/           ← 던전 기생충 테마 화면
│   └── shared/tokens/        ← 공통 디자인 토큰
└── figma-exports/            ← Figma에서 내보낸 에셋
    ├── dream/                ← Dream 테마 에셋
    └── dark/                 ← Dark 테마 에셋
```

---

## 📅 개발 우선순위 및 일정 제안

### Phase 0: v0 프로토타이핑 (이번 주) ← 현재 단계
- [ ] v0로 C-01 메인 로비 Dream/Dark 테마 시안 작성
- [ ] v0로 C-02 카드 라이브러리 시안
- [ ] v0로 C-03 덱 빌더 시안
- [ ] v0로 C-04 업그레이드 트리 시안
- [ ] v0로 C-05 상점 시안
- [ ] 디자인 토큰 추출 (색상, 타이포, 간격)

> 📌 V0_PROMPT_GUIDE.md의 프롬프트 템플릿 활용

### Phase 1: Figma 디자인 시스템 (2주차)
- [ ] Figma Variables 설정 (v0 토큰 기반)
- [ ] 컴포넌트 라이브러리 구축 (Atoms + Molecules)
- [ ] Hi-Fi 화면 목업 (Dream + Dark 테마)
- [ ] 인터랙션 프로토타입 (화면 전환 흐름)

### Phase 2: Unity/Godot 구현 (3~6주차)
- [ ] ThemeManager 시스템 구현
- [ ] Atoms/Molecules 컴포넌트 구현
- [ ] 공통 화면 5개 구현 (C-01 ~ C-05)
- [ ] Dream 테마 에셋 연동

### Phase 3: 게임별 인게임 연동 (7~10주차)
- [ ] 꿈 수집가 인게임 화면 연동
- [ ] 던전 기생충 인게임 화면 연동
- [ ] Dark 테마 에셋 연동
- [ ] 통합 테스트

---

## 📋 관련 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| UI 컴포넌트 상세 사양 | `UI_COMPONENTS.md` | 각 컴포넌트 치수·색상·상태 |
| 화면 흐름도 | `SCREEN_FLOW.md` | 전체 화면 네비게이션 맵 |
| Figma 구현 가이드 | `IMPLEMENTATION_GUIDE.md` | Figma 작업 가이드라인 |
| v0→Figma→엔진 워크플로우 | `WORKFLOW_V0_TO_ENGINE.md` | 전체 파이프라인 상세 |
| v0 프롬프트 가이드 | `V0_PROMPT_GUIDE.md` | 화면별 v0 프롬프트 템플릿 |
| 꿈 수집가 GDD | `../workspace/design/꿈수집가_GDD.md` | 원본 게임 기획 |
| 던전 기생충 GDD | `../workspace/design/던전기생충_GDD.md` | 원본 게임 기획 |

---

_Common UI Platform v1.1 | GeekBrox 게임팀 | 2026-02-20 (v0 워크플로우 반영)_
