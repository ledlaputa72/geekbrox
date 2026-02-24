# Dream Collector - Godot UI 구현 가이드

## 📋 목표
HTML/TSX 프로토타입 → Godot 4 게임 UI로 변환

**프로토타입 위치:**
- HTML: `~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1/`
- 디자인 스펙: `~/Projects/geekbrox/teams/game/interface/UPDATED_SCREEN_SPECS_v1.1.md`
- Figma: https://www.figma.com/design/Wo1MKHvWNE9Yl5bsmD4pkK/

---

## 🚀 Phase 1: 기초 설정 (완료 ✅)

### 1-1. UITheme.gd 생성 완료
**위치:** `scripts/UITheme.gd`

**다음 단계:** Autoload로 등록

**Godot 에디터에서:**
1. `Project` → `Project Settings` → `Autoload` 탭
2. `Path:` 클릭 → `scripts/UITheme.gd` 선택
3. `Node Name:` `UITheme`
4. `Add` 클릭

**확인 방법:**
```gdscript
# 아무 스크립트에서 테스트
func _ready():
    print(UITheme.COLORS.primary)  # Color(0.48, 0.62, 0.94, 1)
    print(UITheme.SCREEN_SIZE)     # (390, 844)
```

---

## 🎯 Phase 2: 공통 컴포넌트 제작

### 우선순위:
1. **BottomTabBar** (가장 많이 재사용 - 6개 화면)
2. **TopBar** (모든 화면)
3. **CardItem** (Card Library, Deck Builder)

---

## 📱 2-1. BottomTabBar 컴포넌트 제작

### 단계별 가이드

#### Step 1: 씬 파일 생성
1. Godot 에디터에서 `Scene` → `New Scene`
2. Root 노드: `Control` 선택
3. 이름: `BottomTabBar`
4. 저장: `ui/components/BottomTabBar.tscn`

#### Step 2: 노드 트리 구성

```
BottomTabBar (Control)
├── Background (Panel)
└── TabContainer (HBoxContainer)
    ├── HomeTab (Button)
    ├── CardsTab (Button)
    ├── UpgradeTab (Button)
    ├── ProgressTab (Button)
    └── ShopTab (Button)
```

**노드별 설정:**

**1) BottomTabBar (Control)**
- Anchors Preset: `Bottom Wide`
- Custom Minimum Size: `(390, 60)`
- Size: `(390, 60)`

**2) Background (Panel)**
- Anchors Preset: `Full Rect`
- 스크립트에서 스타일 적용 예정

**3) TabContainer (HBoxContainer)**
- Anchors Preset: `Full Rect`
- Alignment: `Center`
- Add Theme Constant Override:
  - `separation`: `0` (버튼 간격 없음)

**4) HomeTab ~ ShopTab (각 Button)**
- Custom Minimum Size: `(78, 60)` (390 / 5 = 78px)
- Text: 각각 "Home", "Cards", "Upgrade", "Progress", "Shop"
- Icon: 나중에 추가 (현재는 텍스트만)

#### Step 3: 스크립트 작성

**파일 생성:** `ui/components/BottomTabBar.gd`

```gdscript
# BottomTabBar.gd
extends Control

# 탭 enum
enum Tab {
	HOME,
	CARDS,
	UPGRADE,
	PROGRESS,
	SHOP
}

# 현재 활성 탭
var current_tab: Tab = Tab.HOME

# 노드 레퍼런스
@onready var background: Panel = $Background
@onready var home_tab: Button = $TabContainer/HomeTab
@onready var cards_tab: Button = $TabContainer/CardsTab
@onready var upgrade_tab: Button = $TabContainer/UpgradeTab
@onready var progress_tab: Button = $TabContainer/ProgressTab
@onready var shop_tab: Button = $TabContainer/ShopTab

# 탭 버튼 배열
var tab_buttons: Array[Button] = []

# 시그널
signal tab_changed(tab: Tab)

func _ready():
	# 배열 초기화
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	
	# 스타일 적용
	apply_styles()
	
	# 시그널 연결
	connect_signals()
	
	# 초기 탭 설정
	set_active_tab(current_tab)

func apply_styles():
	# 배경 스타일
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.COLORS.panel
	bg_style.border_width_top = UITheme.BORDER.thin
	bg_style.border_color = UITheme.COLORS.bg
	background.add_theme_stylebox_override("panel", bg_style)
	
	# 각 탭 버튼 스타일
	for button in tab_buttons:
		apply_tab_button_style(button)

func apply_tab_button_style(button: Button):
	# Normal (비활성)
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	# Hover
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.COLORS.panel_light
	button.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed (활성)
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = UITheme.COLORS.panel_light
	button.add_theme_stylebox_override("pressed", pressed_style)
	
	# 폰트 색상 (비활성 - 회색)
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	button.add_theme_color_override("font_hover_color", UITheme.COLORS.text)

func connect_signals():
	home_tab.pressed.connect(_on_tab_pressed.bind(Tab.HOME))
	cards_tab.pressed.connect(_on_tab_pressed.bind(Tab.CARDS))
	upgrade_tab.pressed.connect(_on_tab_pressed.bind(Tab.UPGRADE))
	progress_tab.pressed.connect(_on_tab_pressed.bind(Tab.PROGRESS))
	shop_tab.pressed.connect(_on_tab_pressed.bind(Tab.SHOP))

func _on_tab_pressed(tab: Tab):
	set_active_tab(tab)
	tab_changed.emit(tab)
	
	# 화면 전환 로직 (임시)
	match tab:
		Tab.HOME:
			print("Navigate to: Main Lobby")
		Tab.CARDS:
			print("Navigate to: Card Library")
		Tab.UPGRADE:
			print("Navigate to: Upgrade Tree")
		Tab.PROGRESS:
			print("Navigate to: Progress (disabled)")
		Tab.SHOP:
			print("Navigate to: Shop")

func set_active_tab(tab: Tab):
	current_tab = tab
	
	# 모든 탭 비활성 스타일
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if i == tab:
			# 활성 탭 - 흰색 텍스트
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
			button.button_pressed = true
		else:
			# 비활성 탭 - 회색 텍스트
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
			button.button_pressed = false

# 외부에서 탭 변경
func navigate_to_tab(tab: Tab):
	set_active_tab(tab)
```

#### Step 4: 씬에 스크립트 연결

1. `BottomTabBar` 노드 선택
2. Inspector 패널 → `Script` 섹션 → `Attach Script` (📜 아이콘)
3. `ui/components/BottomTabBar.gd` 선택

#### Step 5: 테스트

**테스트 씬 생성:**
1. `Scene` → `New Scene`
2. Root: `Control`
3. 이름: `TestBottomTabBar`
4. 저장: `tests/TestBottomTabBar.tscn`

**노드 추가:**
```
TestBottomTabBar (Control)
└── BottomTabBar (instance of BottomTabBar.tscn)
```

**Godot 실행:**
- `F5` 또는 `Project` → `Run Project`
- `tests/TestBottomTabBar.tscn`을 Main Scene으로 설정
- 탭 클릭 시 콘솔에 메시지 출력 확인

---

## 🏠 2-2. TopBar 컴포넌트 제작

### 단계별 가이드

#### Step 1: 씬 파일 생성
1. `Scene` → `New Scene`
2. Root 노드: `Control`
3. 이름: `TopBar`
4. 저장: `ui/components/TopBar.tscn`

#### Step 2: 노드 트리 구성

```
TopBar (Control)
├── Background (Panel)
├── LeftContainer (HBoxContainer)
│   ├── BackButton (Button)
│   └── TitleLabel (Label)
└── RightContainer (HBoxContainer)
    ├── RevariesCounter (HBoxContainer)
    │   ├── Icon (TextureRect)
    │   └── CountLabel (Label)
    └── SettingsButton (Button)
```

#### Step 3: 스크립트 작성

**파일:** `ui/components/TopBar.gd`

```gdscript
# TopBar.gd
extends Control

# Export 변수 (Inspector에서 설정 가능)
@export var title: String = "Dream Collector"
@export var show_back_button: bool = false
@export var show_revaries: bool = true
@export var show_settings: bool = true

# 노드 레퍼런스
@onready var background: Panel = $Background
@onready var back_button: Button = $LeftContainer/BackButton
@onready var title_label: Label = $LeftContainer/TitleLabel
@onready var revaries_counter: HBoxContainer = $RightContainer/RevariesCounter
@onready var count_label: Label = $RightContainer/RevariesCounter/CountLabel
@onready var settings_button: Button = $RightContainer/SettingsButton

# 시그널
signal back_pressed
signal settings_pressed

func _ready():
	apply_styles()
	update_display()
	connect_signals()

func apply_styles():
	# 배경
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.COLORS.panel
	bg_style.border_width_bottom = UITheme.BORDER.thin
	bg_style.border_color = UITheme.COLORS.bg
	background.add_theme_stylebox_override("panel", bg_style)
	
	# 타이틀
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	title_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.title)
	
	# Count Label
	count_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	count_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.body)

func update_display():
	title_label.text = title
	back_button.visible = show_back_button
	revaries_counter.visible = show_revaries
	settings_button.visible = show_settings

func connect_signals():
	back_button.pressed.connect(_on_back_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_back_pressed():
	back_pressed.emit()

func _on_settings_pressed():
	settings_pressed.emit()

func set_revaries_count(count: int):
	count_label.text = str(count)
```

---

## 🎴 2-3. CardItem 컴포넌트 제작

### 단계별 가이드

#### Step 1: 씬 파일 생성
1. `Scene` → `New Scene`
2. Root 노드: `Panel`
3. 이름: `CardItem`
4. 저장: `ui/components/CardItem.tscn`

#### Step 2: 노드 트리 구성

```
CardItem (Panel)
├── Background (ColorRect)
├── TopSection (VBoxContainer)
│   ├── NameLabel (Label)
│   └── TypeLabel (Label)
├── CostBadge (Label)
├── ArtContainer (Control)
│   └── ArtPlaceholder (ColorRect)
└── BottomSection (VBoxContainer)
    └── DescriptionLabel (Label)
```

#### Step 3: 스크립트 작성

**파일:** `ui/components/CardItem.gd`

```gdscript
# CardItem.gd
extends Panel

# 카드 데이터 구조체
class CardData:
	var id: int
	var name: String
	var type: String  # "attack", "defense", "skill", "power"
	var cost: int
	var description: String
	var rarity: String  # "common", "uncommon", "rare", "epic", "legendary"
	
	func _init(p_id: int, p_name: String, p_type: String, p_cost: int, p_description: String, p_rarity: String):
		id = p_id
		name = p_name
		type = p_type
		cost = p_cost
		description = p_description
		rarity = p_rarity

# Export 변수
@export var card_data: Dictionary

# 노드 레퍼런스
@onready var background: ColorRect = $Background
@onready var name_label: Label = $TopSection/NameLabel
@onready var type_label: Label = $TopSection/TypeLabel
@onready var cost_badge: Label = $CostBadge
@onready var description_label: Label = $BottomSection/DescriptionLabel

# 시그널
signal card_clicked(card_data: Dictionary)

func _ready():
	custom_minimum_size = Vector2(UITheme.CARD.width, UITheme.CARD.height)
	apply_styles()
	if card_data:
		set_card_data(card_data)

func apply_styles():
	# 기본 Panel 스타일
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = UITheme.COLORS.panel_border
	panel_style.corner_radius_top_left = UITheme.RADIUS.medium
	panel_style.corner_radius_top_right = UITheme.RADIUS.medium
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.medium
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.medium
	add_theme_stylebox_override("panel", panel_style)

func set_card_data(data: Dictionary):
	card_data = data
	
	# 데이터 적용
	name_label.text = data.get("name", "Unknown")
	type_label.text = data.get("type", "").capitalize()
	cost_badge.text = str(data.get("cost", 0))
	description_label.text = data.get("description", "")
	
	# 타입별 색상
	var type_str = data.get("type", "attack")
	background.color = UITheme.COLORS.get(type_str, UITheme.COLORS.panel)

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(card_data)
```

---

## 🏗️ Phase 3: 첫 화면 구현 (c01-main-lobby)

### 3-1. Main Lobby 씬 생성

#### Step 1: 씬 파일 생성
1. `Scene` → `New Scene`
2. Root 노드: `Control`
3. 이름: `MainLobby`
4. 저장: `ui/screens/MainLobby.tscn`

#### Step 2: 노드 트리 구성

```
MainLobby (Control)
├── Background (ColorRect)
├── TopBar (instance of TopBar.tscn)
├── CharacterDisplay (Control)
│   ├── CharacterSprite (Sprite2D)
│   └── FloatAnimation (AnimationPlayer)
├── OfflineRewardsBanner (Panel) [optional]
├── ActionGrid (GridContainer)
│   ├── RunStartButton (Button)
│   ├── CardsButton (Button)
│   ├── UpgradeButton (Button)
│   └── ShopButton (Button)
└── BottomTabBar (instance of BottomTabBar.tscn)
```

#### Step 3: 노드별 설정

**MainLobby (Control)**
- Anchors Preset: `Full Rect`
- Custom Minimum Size: `(390, 844)`

**Background (ColorRect)**
- Anchors Preset: `Full Rect`
- Color: `UITheme.COLORS.bg` (Inspector에서 직접 설정: #1A1A2E)

**TopBar (instance)**
- Anchors Preset: `Top Wide`
- Position: `(0, 0)`
- Size: `(390, 60)`

**CharacterDisplay (Control)**
- Anchors Preset: `Center`
- Position: `(195, 300)` (중앙)
- Size: `(200, 200)`

**ActionGrid (GridContainer)**
- Anchors Preset: `Center`
- Position: `(85, 500)`
- Size: `(220, 220)`
- Columns: `2`
- Add Theme Constant Overrides:
  - `h_separation`: `16`
  - `v_separation`: `16`

**각 Button (RunStartButton, etc.)**
- Custom Minimum Size: `(102, 102)` (2×2 그리드)
- Text: "Run Start", "Cards", "Upgrade", "Shop"

**BottomTabBar (instance)**
- Anchors Preset: `Bottom Wide`
- Position: `(0, 784)`
- Size: `(390, 60)`

#### Step 4: 스크립트 작성

**파일:** `ui/screens/MainLobby.gd`

```gdscript
# MainLobby.gd
extends Control

# 노드 레퍼런스
@onready var top_bar = $TopBar
@onready var bottom_tab_bar = $BottomTabBar
@onready var character_sprite = $CharacterDisplay/CharacterSprite
@onready var float_animation = $CharacterDisplay/FloatAnimation
@onready var run_start_button = $ActionGrid/RunStartButton
@onready var cards_button = $ActionGrid/CardsButton
@onready var upgrade_button = $ActionGrid/UpgradeButton
@onready var shop_button = $ActionGrid/ShopButton

func _ready():
	apply_styles()
	setup_signals()
	setup_animation()
	update_revaries_count()

func apply_styles():
	# 액션 버튼 스타일
	UITheme.apply_button_style(run_start_button, "primary")
	UITheme.apply_button_style(cards_button, "info")
	UITheme.apply_button_style(upgrade_button, "success")
	UITheme.apply_button_style(shop_button, "warning")

func setup_signals():
	# Top Bar
	top_bar.settings_pressed.connect(_on_settings_pressed)
	
	# Bottom Tab Bar
	bottom_tab_bar.tab_changed.connect(_on_tab_changed)
	bottom_tab_bar.set_active_tab(BottomTabBar.Tab.HOME)
	
	# Action Buttons
	run_start_button.pressed.connect(_on_run_start_pressed)
	cards_button.pressed.connect(_on_cards_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	shop_button.pressed.connect(_on_shop_pressed)

func setup_animation():
	# Float Animation 생성 (플로팅 효과)
	var animation = Animation.new()
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, "CharacterDisplay/CharacterSprite:position:y")
	
	# Keyframes: 0 → -10 → 0 (2초 사이클)
	animation.track_insert_key(track_index, 0.0, 0.0)
	animation.track_insert_key(track_index, 1.0, -10.0)
	animation.track_insert_key(track_index, 2.0, 0.0)
	
	animation.length = 2.0
	animation.loop_mode = Animation.LOOP_LINEAR
	
	float_animation.add_animation("float", animation)
	float_animation.play("float")

func update_revaries_count():
	# TODO: 실제 게임 데이터에서 가져오기
	top_bar.set_revaries_count(12450)

# Signal Handlers
func _on_settings_pressed():
	print("Settings clicked")
	# TODO: 설정 화면으로 이동

func _on_tab_changed(tab: int):
	match tab:
		BottomTabBar.Tab.HOME:
			pass  # Already here
		BottomTabBar.Tab.CARDS:
			navigate_to_scene("res://ui/screens/CardLibrary.tscn")
		BottomTabBar.Tab.UPGRADE:
			navigate_to_scene("res://ui/screens/UpgradeTree.tscn")
		BottomTabBar.Tab.PROGRESS:
			print("Progress not implemented yet")
		BottomTabBar.Tab.SHOP:
			navigate_to_scene("res://ui/screens/Shop.tscn")

func _on_run_start_pressed():
	print("Run Start clicked")
	navigate_to_scene("res://ui/screens/RunPrep.tscn")

func _on_cards_pressed():
	print("Cards clicked")
	navigate_to_scene("res://ui/screens/CardLibrary.tscn")

func _on_upgrade_pressed():
	print("Upgrade clicked")
	navigate_to_scene("res://ui/screens/UpgradeTree.tscn")

func _on_shop_pressed():
	print("Shop clicked")
	navigate_to_scene("res://ui/screens/Shop.tscn")

func navigate_to_scene(path: String):
	# 씬 전환 (나중에 SceneManager로 교체)
	get_tree().change_scene_to_file(path)
```

#### Step 5: Main Scene으로 설정

1. `Project` → `Project Settings` → `Application` → `Run`
2. `Main Scene` 클릭
3. `ui/screens/MainLobby.tscn` 선택
4. `F5` 실행!

---

## 📊 Phase 4: 진행 상황 체크리스트

### 공통 컴포넌트 (3개)
- [ ] BottomTabBar.tscn + .gd
- [ ] TopBar.tscn + .gd
- [ ] CardItem.tscn + .gd

### 화면 (12개)
- [ ] c01-main-lobby (MainLobby.tscn)
- [ ] c02-card-library (CardLibrary.tscn)
- [ ] c03-deck-builder (DeckBuilder.tscn)
- [ ] c04-upgrade-tree (UpgradeTree.tscn)
- [ ] c05-shop (Shop.tscn)
- [ ] c06-run-prep (RunPrep.tscn)
- [ ] c07-in-run (InRun.tscn)
- [ ] c08-combat (Combat.tscn)
- [ ] c09-victory-screen (VictoryScreen.tscn)
- [ ] c10-defeat-screen (DefeatScreen.tscn)
- [ ] c11-rewards-modal (RewardsModal.tscn)
- [ ] c12-settings (Settings.tscn)

---

## 💡 다음 단계

1. **BottomTabBar 완성** (최우선)
2. **TopBar 완성**
3. **MainLobby 첫 화면 구현**
4. **나머지 화면 순차 구현**

---

## 📚 참고 자료

**HTML 프로토타입:**
```bash
# 브라우저에서 참조용으로 열기
open ~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1/c01-main-lobby.html
```

**Godot 4 UI 문서:**
- https://docs.godotengine.org/en/stable/tutorials/ui/index.html
- Control 노드: https://docs.godotengine.org/en/stable/classes/class_control.html
- Anchors & Containers: https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html

**디자인 스펙:**
- `~/Projects/geekbrox/teams/game/interface/UPDATED_SCREEN_SPECS_v1.1.md`
- Figma: https://www.figma.com/design/Wo1MKHvWNE9Yl5bsmD4pkK/

---

**작성자:** Atlas  
**작성일:** 2026-02-23  
**버전:** 1.0
