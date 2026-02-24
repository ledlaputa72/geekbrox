# Godot UI 개발 워크플로우

## 목표
HTML/TSX 프로토타입 → Godot 게임 UI로 효율적 변환

---

## 🎯 추천 워크플로우: 하이브리드 접근

### Phase 1: 디자인 토큰 추출 (1시간)

```gdscript
# res://autoload/UITheme.gd
extends Node

# Dream Theme Design System
const COLORS = {
    "primary": Color("#7B9EF0"),
    "bg": Color("#1A1A2E"),
    "panel": Color("#2C2C3E"),
    "panel_light": Color("#3A3A52"),
    "text": Color("#FFFFFF"),
    "text_dim": Color("#B0B0C8"),
    "danger": Color("#FF6B6B"),
    "success": Color("#51CF66"),
    "warning": Color("#FFD93D")
}

const SPACING = {
    "xs": 4,
    "sm": 8,
    "md": 16,
    "lg": 24,
    "xl": 32
}

const FONT_SIZES = {
    "small": 12,
    "body": 14,
    "subtitle": 16,
    "title": 20,
    "header": 24
}

const SCREEN_SIZE = Vector2(390, 844) # Mobile portrait
```

---

### Phase 2: 스크린별 변환 전략

#### **스크린 타입 A: 정적 UI (Card Library, Shop)**
→ **수동 재구성** (Control 노드 트리)

**예시: c02-card-library**
```
CardLibrary (Control)
├── TopBar (Panel)
│   ├── BackButton (TextureButton)
│   ├── TitleLabel (Label)
│   └── FilterButton (TextureButton)
├── FilterBar (HBoxContainer)
│   ├── AllButton (Button)
│   ├── AttackButton (Button)
│   └── DefenseButton (Button)
├── CardGrid (GridContainer)
│   └── [85x CardItem scenes instantiated]
└── BottomTabBar (Panel)
    └── [5x TabButton]
```

**작업 시간:** 스크린당 2-3시간

---

#### **스크린 타입 B: 동적 UI (Combat, In-Run)**
→ **게임 로직 우선 설계** → UI는 나중에 연결

**예시: c08-combat**
```gdscript
# res://scenes/combat/CombatScreen.gd
extends Control

# Game State (우선)
var player_hp: int = 100
var enemy_hp: int = 80
var hand: Array[Card] = []
var energy: int = 3

# UI References (나중)
@onready var player_hp_bar = $PlayerHPBar
@onready var hand_container = $HandContainer

func _ready():
    setup_combat_state()
    update_ui()

func play_card(card: Card):
    # 게임 로직 실행
    apply_card_effects(card)
    # UI 업데이트
    update_hand_display()
    trigger_animation(card)
```

**작업 시간:** 스크린당 4-6시간 (로직 포함)

---

### Phase 3: 재사용 컴포넌트 제작 (핵심 효율화)

**공통 컴포넌트 목록:**
```
res://ui/components/
├── BottomTabBar.tscn (6개 화면 재사용)
├── CardItem.tscn (Card Library, Deck Builder)
├── UpgradeNode.tscn (Upgrade Tree)
├── RewardCard.tscn (Victory, Defeat, Rewards)
├── TopBar.tscn (모든 화면)
└── Modal.tscn (설정, 보상 선택 등)
```

**컴포넌트 제작 우선순위:**
1. **BottomTabBar** (가장 많이 재사용)
2. **CardItem** (85장 카드)
3. **TopBar** (모든 화면)
4. 나머지...

---

## 🛠️ 실전 변환 프로세스

### 스크린 하나 변환하기 (예: c01-main-lobby)

**1단계: HTML/Figma에서 구조 분석 (10분)**
```
- 상단바 (60px 높이)
- 캐릭터 디스플레이 (중앙, 플로팅 애니메이션)
- 오프라인 보상 배너 (조건부)
- 2x2 액션 그리드 (Run Start, Cards, Upgrade, Shop)
- 하단 탭바 (60px 높이, 5개 탭)
```

**2단계: Godot 씬 트리 생성 (30분)**
```
MainLobby.tscn
├── Background (TextureRect)
├── TopBar (Panel)
│   ├── RevariesCounter (HBoxContainer)
│   │   ├── Icon (TextureRect)
│   │   └── CountLabel (Label)
│   └── SettingsButton (TextureButton)
├── CharacterDisplay (Control)
│   ├── CharacterSprite (Sprite2D)
│   └── FloatAnimation (AnimationPlayer)
├── OfflineRewardsBanner (Panel) [conditional]
├── ActionGrid (GridContainer)
│   ├── RunStartButton (TextureButton)
│   ├── CardsButton (TextureButton)
│   ├── UpgradeButton (TextureButton)
│   └── ShopButton (TextureButton)
└── BottomTabBar (instance of BottomTabBar.tscn)
```

**3단계: 스타일 적용 (20분)**
```gdscript
# MainLobby.gd
extends Control

func _ready():
    apply_theme()
    setup_signals()

func apply_theme():
    $Background.color = UITheme.COLORS.bg
    $TopBar.self_modulate = UITheme.COLORS.panel
    # ... 나머지 스타일
```

**4단계: 애니메이션 추가 (30분)**
```gdscript
# FloatAnimation
[animation player keyframes]
- 0.0s: position.y = 0
- 1.0s: position.y = -10
- 2.0s: position.y = 0
[loop]
```

**5단계: 시그널 연결 (10분)**
```gdscript
func _on_run_start_pressed():
    get_tree().change_scene_to_file("res://scenes/run_prep/RunPrep.tscn")

func _on_cards_pressed():
    get_tree().change_scene_to_file("res://scenes/card_library/CardLibrary.tscn")
```

**총 소요 시간:** ~1.5시간/화면

---

## 📊 효율성 비교

| 방법 | 속도 | 품질 | 유지보수성 | 게임 통합 |
|------|------|------|------------|-----------|
| 자동 변환 도구 | ⚡⚡⚡ | ⭐⭐ | ⭐ | ⭐ |
| Figma 수동 참조 | ⚡⚡ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 처음부터 재설계 | ⚡ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**결론:** **Figma 수동 참조** 방식이 최적 (속도 + 품질 균형)

---

## 🚀 실전 타임라인 (12 화면)

### Week 1: 기초 설정 + 공통 컴포넌트
- [ ] 디자인 토큰 추출 (`UITheme.gd`) - 1시간
- [ ] `BottomTabBar.tscn` 제작 - 2시간
- [ ] `TopBar.tscn` 제작 - 1시간
- [ ] `CardItem.tscn` 제작 - 2시간
- [ ] c01-main-lobby 완성 (첫 화면) - 2시간
- **총 8시간**

### Week 2: 메타 화면 (c02-c06)
- [ ] c02-card-library - 3시간
- [ ] c03-deck-builder - 3시간
- [ ] c04-upgrade-tree - 4시간 (트리 구조 복잡)
- [ ] c05-shop - 3시간
- [ ] c06-run-prep - 2시간
- **총 15시간**

### Week 3: 인게임 화면 (c07-c08)
- [ ] c07-in-run - 4시간 (노드 맵 인터랙션)
- [ ] c08-combat - 6시간 (게임 로직 핵심)
- **총 10시간**

### Week 4: 모달/보조 화면 (c09-c12)
- [ ] c09-victory-screen - 2시간
- [ ] c10-defeat-screen - 2시간
- [ ] c11-rewards-modal - 2시간
- [ ] c12-settings - 3시간
- **총 9시간**

**전체 예상 시간:** 42시간 (~5.5일 풀타임)

---

## 💡 추가 최적화 팁

### 1. HTML 프로토타입 활용
```bash
# HTML 화면을 브라우저에서 열고 실시간 참조
open ~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1/c01-main-lobby.html
```
→ 듀얼 모니터로 HTML 보면서 Godot 작업

### 2. 스크린샷 기반 레이아웃
```bash
# Figma에서 각 화면 PNG 익스포트 (390x844)
# Godot에서 TextureRect로 배경에 임시 배치
# 그 위에 Control 노드 정렬 (pixel-perfect)
```

### 3. Grid System 활용
```gdscript
# res://ui/GridSystem.gd
# 8px 기준 그리드 스냅
const GRID_SIZE = 8

func snap_to_grid(pos: Vector2) -> Vector2:
    return Vector2(
        floor(pos.x / GRID_SIZE) * GRID_SIZE,
        floor(pos.y / GRID_SIZE) * GRID_SIZE
    )
```

### 4. Theme Resource 사용
```gdscript
# res://themes/dream_theme.tres
# Godot의 Theme 시스템으로 글로벌 스타일 관리
# 모든 Button/Label/Panel에 자동 적용
```

---

## 🎯 다음 스텝

**즉시 시작 가능:**
1. `UITheme.gd` 생성 (디자인 토큰 추출)
2. `BottomTabBar.tscn` 제작 (가장 많이 재사용)
3. c01-main-lobby 첫 화면 완성

**준비해야 할 것:**
- Nunito 폰트 파일 다운로드
- 아이콘 에셋 (emoji → PNG 변환 or Font Awesome)
- 캐릭터 스프라이트 (임시 placeholder)

---

## 📚 참고 자료

**Godot UI Best Practices:**
- https://docs.godotengine.org/en/stable/tutorials/ui/index.html
- Control vs Node2D 선택 기준
- 앵커/마진 시스템

**모바일 최적화:**
- https://docs.godotengine.org/en/stable/tutorials/platform/android/index.html
- Safe Area 처리 (노치/홈 버튼)
- Touch Input 핸들링

**파일 위치:**
- HTML 프로토타입: `~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1/`
- 디자인 스펙: `~/Projects/geekbrox/teams/game/interface/UPDATED_SCREEN_SPECS_v1.1.md`
- Figma: https://www.figma.com/design/Wo1MKHvWNE9Yl5bsmD4pkK/

---

**작성자:** Atlas  
**작성일:** 2026-02-23  
**버전:** 1.0
