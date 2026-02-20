# 구현 가이드 (Implementation Guide)
## Figma → Unity/Godot 개발 워크플로우

**문서 버전:** 1.0
**작성일:** 2026-02-20

---

## 🎨 Figma 작업 순서 및 가이드

### Step 1: 프로젝트 파일 구조 설정

```
Figma 프로젝트: "GeekBrox Common UI Platform"
│
├── 📁 🔧 Foundation
│   ├── Colors (Variables)        ← Dream/Dark 테마 변수
│   ├── Typography                ← 폰트 스타일
│   ├── Spacing & Grid            ← 4px 기준 그리드
│   └── Effects & Shadows         ← 그림자, blur 효과
│
├── 📁 🧩 Components
│   ├── Atoms                     ← CurrencyChip, IconButton 등
│   ├── Molecules                 ← CardThumbnail, UpgradeNode 등
│   └── Organisms                 ← TopBar, BottomNavBar 등
│
├── 📁 📱 Screens — Dream Theme
│   ├── C-01 Main Lobby
│   ├── C-02 Card Library
│   ├── C-03 Deck Builder
│   ├── C-04 Upgrade Tree
│   ├── C-05 Shop
│   ├── C-06 Settings
│   ├── C-07 Daily Quest
│   ├── C-09 Popups
│   └── G-01~04 Dream Game Screens
│
├── 📁 📱 Screens — Dark Theme
│   └── (Dream 화면 복사 후 테마 변수만 스위칭)
│
└── 📁 🔄 Prototypes
    ├── Main Flow Prototype
    └── Onboarding Flow
```

### Step 2: Variables (테마 변수) 설정 우선

Figma Variables 패널에서 Collection 생성:

```
Collection 이름: "Theme"

Variable Group: Colors
  color/primary         → Dream: #7B9EF0  │  Dark: #8B1A1A
  color/secondary       → Dream: #C4A8E8  │  Dark: #4A3060
  color/accent          → Dream: #F5F0FF  │  Dark: #00CED1
  color/bg/main         → Dream: #0D1B3E  │  Dark: #0A0A0A
  color/bg/panel        → Dream: rgba(255,255,255,0.10) │ Dark: rgba(20,5,5,0.85)
  color/currency/1      → Dream: #FFE066  │  Dark: #00CED1
  color/currency/2      → Dream: #E8D5FF  │  Dark: #FFD700
  color/text/primary    → Dream: #FFFFFF  │  Dark: #FFFFFF
  color/text/secondary  → Dream: #AAAAAA  │  Dark: #888888

Variable Group: Radius
  radius/card           → Dream: 16  │  Dark: 4
  radius/button         → Dream: 20  │  Dark: 6
  radius/panel          → Dream: 16  │  Dark: 8
  radius/chip           → Dream: 16  │  Dark: 4

Variable Group: Typography (Font Family)
  font/display          → Dream: "Nunito"        │  Dark: "Crimson Text"
  font/body             → Dream: "Noto Sans KR"  │  Dark: "Noto Sans KR"
```

### Step 3: Atomic Design 순서로 컴포넌트 제작

#### 제작 우선순위 (이번 주 완료 목표)

**Day 1-2: Atoms**
- [ ] `CurrencyChip` (2개: 재화1, 재화2)
- [ ] `IconButton` (32px, 48px 2가지)
- [ ] `RarityBadge` (4종: Common/Uncommon/Rare/Legendary)
- [ ] `ProgressBar` (기본형, 얇은형)
- [ ] `FilterChip` (활성/비활성 상태)
- [ ] `TabItem` (아이콘+텍스트, 활성/비활성)

**Day 3-4: Molecules**
- [ ] `CurrencyBar` (재화칩 2개 묶음)
- [ ] `CardThumbnail` (5가지 크기 Variant)
- [ ] `UpgradeNode` (가능/최대/잠김 상태)
- [ ] `QuestRow` (진행중/완료 상태)

**Day 5: Organisms + 1개 화면**
- [ ] `TopBar`
- [ ] `BottomNavBar`
- [ ] `MainActionButton`
- [ ] C-01 메인 로비 완성 (Dream 테마)

### Step 4: 컴포넌트 Variants 활용

모든 컴포넌트에 Variant 설정으로 상태 관리:

```
CardThumbnail Variants:
  Size: Small / Medium / Large / InDeck / Detail
  State: Default / Selected / InDeck / Locked / New
  Rarity: Common / Uncommon / Rare / Legendary
  Theme: Dream / Dark
  → 총 5×5×4×2 = 200개 Variant (자동 생성 가능)
```

**⚠️ Figma 팁:** "Create component set"으로 Variant 자동 구성,
Property 이름을 Unity/Godot 코드와 일치시켜 혼선 방지.

### Step 5: Auto Layout 필수 적용 규칙

- **모든 컴포넌트:** Auto Layout 사용 (고정 크기 금지)
- **카드 그리드:** Auto Layout + Wrap
- **하단 탭바:** 5개 항목 균등 분배 (Space between)
- **팝업 내부:** 수직 Auto Layout + 가변 중간 영역

### Step 6: 프로토타입 연결 순서

1. 메인 로비 → 런 준비 (메인 버튼)
2. 탭바 5개 연결
3. 카드 라이브러리 → 카드 상세 팝업
4. 팝업 닫기 인터랙션
5. 화면 전환 애니메이션 (Smart Animate 활용)

---

## 🎮 Unity 구현 가이드

### 프로젝트 설정

```
Unity 버전: 2022.3 LTS (안정성 권장)
렌더 파이프라인: URP (Universal Render Pipeline)
  → 2D Renderer 선택
  → 모바일 최적화 기본 포함

해상도 설정:
  Reference: 390 × 844 (iPhone 14 기준)
  Scale Mode: Scale With Screen Size
  Match: 0.5 (Width-Height 혼합)
```

### UI 시스템 아키텍처

```
Canvas (Screen Space - Overlay)
│
├── HUD Layer (Order: 10)      ← TopBar, BottomNavBar
├── Content Layer (Order: 0)   ← 화면별 메인 콘텐츠
├── Popup Layer (Order: 20)    ← 팝업 (Dim 포함)
└── Toast Layer (Order: 30)    ← 토스트 메시지
```

### ThemeManager 구현

```csharp
// /UI/Common/ThemeManager.cs
using UnityEngine;
using UnityEngine.Events;

[CreateAssetMenu(fileName = "ThemeManager", menuName = "GeekBrox/ThemeManager")]
public class ThemeManager : ScriptableObject
{
    public static ThemeManager Instance { get; private set; }

    [Header("테마 데이터")]
    public ThemeData dreamTheme;
    public ThemeData darkTheme;

    private ThemeData _currentTheme;
    public ThemeData CurrentTheme => _currentTheme;

    public UnityEvent<ThemeData> OnThemeChanged = new();

    public void Initialize(GameType gameType)
    {
        _currentTheme = gameType == GameType.DreamCollector
            ? dreamTheme : darkTheme;
        Instance = this;
    }

    public void ApplyTheme()
    {
        OnThemeChanged?.Invoke(_currentTheme);
    }
}

// ThemeData.cs (ScriptableObject)
[CreateAssetMenu(fileName = "ThemeData", menuName = "GeekBrox/ThemeData")]
public class ThemeData : ScriptableObject
{
    [Header("색상")]
    public Color primary;
    public Color secondary;
    public Color accent;
    public Color bgMain;
    public Color bgPanel;
    public Color currency1;
    public Color currency2;

    [Header("폰트")]
    public TMP_FontAsset displayFont;
    public TMP_FontAsset bodyFont;

    [Header("스프라이트")]
    public Sprite cardFrameCommon;
    public Sprite cardFrameUncommon;
    public Sprite cardFrameRare;
    public Sprite cardFrameLegendary;
    public Sprite currency1Icon;
    public Sprite currency2Icon;

    [Header("수치")]
    public float cardBorderRadius = 16f;  // Dream: 16, Dark: 4
    public float buttonBorderRadius = 20f;
}
```

### 공통 컴포넌트 베이스 클래스

```csharp
// /UI/Common/Atoms/BaseUIComponent.cs
public abstract class BaseUIComponent : MonoBehaviour, IThemeable
{
    protected ThemeData Theme => ThemeManager.Instance?.CurrentTheme;

    protected virtual void Awake()
    {
        ThemeManager.Instance?.OnThemeChanged.AddListener(OnThemeChanged);
    }

    protected virtual void OnDestroy()
    {
        ThemeManager.Instance?.OnThemeChanged.RemoveListener(OnThemeChanged);
    }

    public abstract void OnThemeChanged(ThemeData theme);
    public abstract void Refresh();
}

// /UI/Common/Molecules/CardThumbnail.cs
public class CardThumbnailUI : BaseUIComponent
{
    [Header("UI 요소")]
    public Image cardArt;
    public Image cardFrame;
    public TMP_Text cardName;
    public TMP_Text cardEffect;
    public TMP_Text energyCost;
    public Image rarityIndicator;

    private CardData _data;

    public void Setup(CardData data)
    {
        _data = data;
        Refresh();
    }

    public override void Refresh()
    {
        if (_data == null || Theme == null) return;

        cardArt.sprite = _data.artwork;
        cardName.text = _data.cardName;
        cardName.font = Theme.displayFont;
        cardEffect.text = _data.effectDescription;
        energyCost.text = _data.cost.ToString();

        // 희귀도 프레임 적용
        cardFrame.sprite = _data.rarity switch
        {
            Rarity.Common     => Theme.cardFrameCommon,
            Rarity.Uncommon   => Theme.cardFrameUncommon,
            Rarity.Rare       => Theme.cardFrameRare,
            Rarity.Legendary  => Theme.cardFrameLegendary,
            _ => Theme.cardFrameCommon
        };
    }

    public override void OnThemeChanged(ThemeData theme) => Refresh();
}
```

### CurrencyBar 구현 예시

```csharp
// /UI/Common/Organisms/CurrencyBarUI.cs
public class CurrencyBarUI : BaseUIComponent
{
    [Header("재화 슬롯")]
    public CurrencyChipUI currency1Chip;
    public CurrencyChipUI currency2Chip;

    // GameManager에서 재화 변경 시 호출
    public void UpdateCurrencies(long currency1, long currency2)
    {
        currency1Chip.AnimateTo(currency1);
        currency2Chip.AnimateTo(currency2);
    }

    public override void OnThemeChanged(ThemeData theme)
    {
        currency1Chip.SetIcon(theme.currency1Icon);
        currency1Chip.SetColor(theme.currency1);
        currency2Chip.SetIcon(theme.currency2Icon);
        currency2Chip.SetColor(theme.currency2);
    }

    public override void Refresh() { }
}

// 숫자 포맷 유틸
public static class NumberFormatter
{
    public static string Format(long value) => value switch
    {
        >= 1_000_000_000 => $"{value / 1_000_000_000f:F1}B",
        >= 1_000_000     => $"{value / 1_000_000f:F1}M",
        >= 10_000        => $"{value / 1_000f:F1}K",
        _                => value.ToString("N0")
    };
}
```

---

## 🐦 Godot 4.x 구현 가이드

### 프로젝트 설정

```
Godot 버전: 4.3 이상
렌더러: Forward+ 또는 Mobile (모바일 권장: Mobile)
기준 해상도: 390 × 844
스트레칭 모드: canvas_items
비율: expand
```

### 씬 구조

```
Main.tscn
└── CanvasLayer (layer=0, Content)
│   └── MainLobby.tscn
│       ├── TopBar.tscn
│       ├── CharacterArea
│       └── MainActionButton.tscn
│
└── CanvasLayer (layer=10, HUD)
│   └── BottomNavBar.tscn
│
└── CanvasLayer (layer=20, Popups)
    └── PopupManager.tscn
```

### 테마 시스템 (Godot)

```gdscript
# /UI/Common/theme_manager.gd
extends Node

enum GameType { DREAM_COLLECTOR, DUNGEON_PARASITE }

const DREAM_THEME_PATH = "res://UI/Themes/Dream/dream_theme.tres"
const DARK_THEME_PATH  = "res://UI/Themes/Dark/dark_theme.tres"

signal theme_changed(theme_data: ThemeData)

var current_theme: ThemeData

func initialize(game_type: GameType) -> void:
    var path = DREAM_THEME_PATH if game_type == GameType.DREAM_COLLECTOR \
               else DARK_THEME_PATH
    current_theme = load(path)
    get_tree().root.theme = current_theme.godot_theme
    theme_changed.emit(current_theme)
```

```gdscript
# /UI/Common/Molecules/card_thumbnail.gd
extends Control

@onready var card_art: TextureRect = $CardArt
@onready var card_frame: TextureRect = $CardFrame
@onready var card_name: Label = $CardName
@onready var energy_cost: Label = $EnergyCost

var card_data: CardData

func setup(data: CardData) -> void:
    card_data = data
    refresh()

func refresh() -> void:
    if not card_data:
        return
    card_art.texture = card_data.artwork
    card_name.text = card_data.card_name
    energy_cost.text = str(card_data.cost)

    var theme_mgr = get_node("/root/ThemeManager")
    var rarity_frame = theme_mgr.get_rarity_frame(card_data.rarity)
    card_frame.texture = rarity_frame
```

---

## 📤 Figma → 엔진 에셋 내보내기 규칙

### 이미지 내보내기 설정

| 에셋 종류 | 형식 | 해상도 | 비고 |
|---------|------|--------|------|
| 카드 일러스트 | PNG | @2x, @3x | 알파 채널 유지 |
| 카드 프레임 | PNG | @2x | 9-slice 설정 |
| 아이콘 | SVG → PNG | @2x | 단색 아이콘은 SVG 권장 |
| 배경 | JPG | @2x | 알파 불필요 시 JPG |
| 파티클 스프라이트 | PNG | @2x | 알파 채널 필수 |
| 버튼 배경 | PNG | @2x | 9-slice (모서리 보존) |

### 9-Slice (Slicing) 가이드

버튼, 패널, 카드 프레임 등 크기가 변하는 요소:

```
Figma에서 내보낼 때:
1. 컴포넌트 선택 → Export
2. "Export Constraints" 해제
3. @2x로 내보내기
4. Unity: Sprite Editor → 9-Slice 설정
   Godot: TextureRect → Region 설정

9-Slice 경계 기준:
  카드 프레임 (100×140px @1x 기준):
    Left: 8px, Right: 8px, Top: 8px, Bottom: 8px
```

### 폰트 설정

```
사용 폰트:
  - Noto Sans KR (Google Fonts, 무료 상업 사용 가능)
    다운로드: fonts.google.com/specimen/Noto+Sans+KR
    필요 Weight: 300, 400, 500, 700

  - Nunito (Google Fonts, 무료 상업 사용 가능)
    다운로드: fonts.google.com/specimen/Nunito
    필요 Weight: 600, 700, 800

Unity: TextMesh Pro 폰트 에셋으로 변환 필요
  Window → TextMeshPro → Font Asset Creator
  Character Set: Unicode Range (한국어 포함)
  Atlas Resolution: 4096×4096

Godot: DynamicFont 리소스 생성 후 .ttf 직접 참조
```

---

## ✅ 품질 체크리스트 (화면 완성 전 확인사항)

### Figma 완성 기준
- [ ] Auto Layout 적용됨 (고정 크기 없음)
- [ ] Variables (테마 변수) 100% 사용 (하드코딩 색상 없음)
- [ ] 모든 상태 (Default/Hover/Disabled/Active) Variant 존재
- [ ] Dream/Dark 테마 스위칭 테스트 완료
- [ ] iPhone SE(375px) ~ iPhone 14 Pro Max(430px) 너비 테스트
- [ ] 안전 영역(Safe Area) 고려됨 (상단 44px, 하단 34px)
- [ ] 텍스트 크기 최소 11px 이상
- [ ] 탭 타겟 최소 44×44pt 이상

### Unity/Godot 완성 기준
- [ ] ThemeManager.OnThemeChanged 이벤트 구독됨
- [ ] 하드코딩 색상 없음 (모두 ThemeData 참조)
- [ ] 60 FPS 유지 확인 (iPhone 8 기준)
- [ ] 메모리 300MB 이하
- [ ] 세로 모드 + 가로 모드 대응 (가로는 선택)
- [ ] Safe Area 반영됨 (Unity: Device Simulator 테스트)
- [ ] 한국어 텍스트 깨짐 없음 (Noto Sans KR 폰트 적용)
- [ ] 햅틱 피드백 연동됨

---

## 📞 팀 협업 규칙

### 브랜치 전략 (이 폴더 기준)

```
main
  └── feature/ui-common-platform    ← 현재 작업 브랜치
        ├── feat/topbar-component
        ├── feat/card-thumbnail
        └── feat/main-lobby-screen
```

### 파일명 규칙

```
Figma 컴포넌트: PascalCase (CardThumbnail, CurrencyChip)
Unity C#:       PascalCase (CardThumbnailUI.cs)
Godot GDScript: snake_case (card_thumbnail.gd)
에셋 파일:      kebab-case (card-frame-rare.png)
씬 파일:        PascalCase (CardThumbnail.tscn)
```

### 업데이트 방식

이 폴더(`teams/game/interface/`)의 변경사항은:
1. 기획 변경 → `.md` 파일 수정 → `git commit` → `git push`
2. OpenClaw 팀 에이전트가 다음 세션 시작 시 자동으로 변경사항 인식
3. 맥북에서 OpenClaw 에이전트가 실제 Figma/코드 작업 지시 진행

---

_Implementation Guide v1.0 | GeekBrox 게임팀 | 2026-02-20_
