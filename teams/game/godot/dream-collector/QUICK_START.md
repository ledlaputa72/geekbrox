# 🚀 Godot UI 구현 - 빠른 시작 가이드

## 1️⃣ 첫 번째: UITheme Autoload 등록 (2분)

**Godot 에디터에서:**

1. `Project` → `Project Settings`
2. `Autoload` 탭 클릭
3. `Path:` 클릭 → `scripts/UITheme.gd` 선택
4. `Node Name:` `UITheme` (기본값 유지)
5. `Add` 버튼 클릭
6. `Close`

**확인:**
- Autoload 리스트에 `UITheme` 표시되면 성공 ✅

---

## 2️⃣ 두 번째: BottomTabBar 만들기 (30분)

### Step 1: 새 씬 만들기

1. `Scene` → `New Scene` (Ctrl+N)
2. `Other Node` 클릭
3. 검색창에 `Control` 입력 → 선택
4. `Create` 클릭
5. 좌측 Scene 패널에서 `Control` 노드 우클릭 → `Rename`
6. `BottomTabBar` 입력 → Enter
7. `Scene` → `Save Scene` (Ctrl+S)
8. 경로: `ui/components/BottomTabBar.tscn`로 저장

### Step 2: 노드 추가하기

**Background 추가:**
1. `BottomTabBar` 노드 선택 상태에서
2. 상단 `+` 버튼 클릭 (Add Child Node)
3. 검색: `Panel` → `Create`
4. 이름: `Background` (기본값)

**TabContainer 추가:**
1. `BottomTabBar` 노드 선택
2. `+` 버튼 → `HBoxContainer` → `Create`
3. 이름: `TabContainer`

**5개 버튼 추가:**
1. `TabContainer` 노드 선택
2. `+` 버튼 → `Button` → `Create` (5번 반복)
3. 각각 이름 변경:
   - `HomeTab`
   - `CardsTab`
   - `UpgradeTab`
   - `ProgressTab`
   - `ShopTab`

**최종 트리 구조:**
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

### Step 3: 각 노드 설정

**BottomTabBar (Control):**
1. 선택 → 우측 Inspector 패널
2. `Layout` → `Anchors Preset` → `Bottom Wide` 클릭 (하단 중앙 버튼)
3. `Control` → `Custom Minimum Size`
   - x: `390`
   - y: `60`

**Background (Panel):**
1. 선택 → Inspector
2. `Layout` → `Anchors Preset` → `Full Rect` (우하단 버튼)

**TabContainer (HBoxContainer):**
1. 선택 → Inspector
2. `Layout` → `Anchors Preset` → `Full Rect`
3. `BoxContainer` → `Alignment` → `Center`
4. `Theme Overrides` → `Constants` → `+` 버튼
5. `separation` 추가 → 값: `0`

**각 버튼 (HomeTab ~ ShopTab):**
1. 각각 선택 → Inspector
2. `Control` → `Custom Minimum Size`
   - x: `78`
   - y: `60`
3. `Button` → `Text`:
   - HomeTab: `Home`
   - CardsTab: `Cards`
   - UpgradeTab: `Upgrade`
   - ProgressTab: `Progress`
   - ShopTab: `Shop`

### Step 4: 스크립트 연결

1. 좌측 `FileSystem` 패널
2. `ui/components/` 폴더 우클릭 → `Create New` → `Script`
3. 파일명: `BottomTabBar.gd` → `Create`
4. 자동으로 에디터 열림 → 아래 코드 붙여넣기:

```gdscript
extends Control

enum Tab { HOME, CARDS, UPGRADE, PROGRESS, SHOP }

var current_tab: Tab = Tab.HOME

@onready var background: Panel = $Background
@onready var home_tab: Button = $TabContainer/HomeTab
@onready var cards_tab: Button = $TabContainer/CardsTab
@onready var upgrade_tab: Button = $TabContainer/UpgradeTab
@onready var progress_tab: Button = $TabContainer/ProgressTab
@onready var shop_tab: Button = $TabContainer/ShopTab

var tab_buttons: Array[Button] = []

signal tab_changed(tab: Tab)

func _ready():
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	apply_styles()
	connect_signals()
	set_active_tab(current_tab)

func apply_styles():
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = UITheme.COLORS.panel
	bg_style.border_width_top = UITheme.BORDER.thin
	bg_style.border_color = UITheme.COLORS.bg
	background.add_theme_stylebox_override("panel", bg_style)
	
	for button in tab_buttons:
		apply_tab_button_style(button)

func apply_tab_button_style(button: Button):
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.COLORS.panel_light
	button.add_theme_stylebox_override("hover", hover_style)
	
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)

func connect_signals():
	home_tab.pressed.connect(_on_tab_pressed.bind(Tab.HOME))
	cards_tab.pressed.connect(_on_tab_pressed.bind(Tab.CARDS))
	upgrade_tab.pressed.connect(_on_tab_pressed.bind(Tab.UPGRADE))
	progress_tab.pressed.connect(_on_tab_pressed.bind(Tab.PROGRESS))
	shop_tab.pressed.connect(_on_tab_pressed.bind(Tab.SHOP))

func _on_tab_pressed(tab: Tab):
	set_active_tab(tab)
	tab_changed.emit(tab)
	print("Tab changed to: ", tab)

func set_active_tab(tab: Tab):
	current_tab = tab
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if i == tab:
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
```

5. `Ctrl+S` 저장
6. Scene 탭으로 돌아가기 (상단 탭)
7. `BottomTabBar` 노드 선택 → Inspector → `Script` 섹션
8. 📜 아이콘 옆 폴더 버튼 → `ui/components/BottomTabBar.gd` 선택
9. `Ctrl+S` 씬 저장

### Step 5: 테스트

1. `Scene` → `New Scene`
2. `Control` 노드 생성 → 이름: `Test`
3. `Test` 노드 선택 → `+` 버튼
4. `Quick Load` 탭 → `BottomTabBar.tscn` 검색 → 선택
5. `F6` (현재 씬 실행) 또는 `F5` (프로젝트 실행)
6. 탭 클릭 시 콘솔에 "Tab changed to: X" 출력 확인 ✅

---

## 3️⃣ 세 번째: 첫 화면 만들기 (1시간)

### 간단 버전 (빠른 프로토타입)

1. `Scene` → `New Scene`
2. `Control` 노드 → 이름: `MainLobby`
3. 노드 추가:
   ```
   MainLobby (Control)
   ├── ColorRect (배경)
   ├── Label (타이틀)
   └── BottomTabBar (instance)
   ```

4. **ColorRect 설정:**
   - Anchors: `Full Rect`
   - Color: `#1A1A2E` (Inspector에서 Color 클릭)

5. **Label 설정:**
   - Anchors: `Center`
   - Text: `Dream Collector`
   - Font Size: `32` (Theme Overrides → Font Sizes → font_size)

6. **BottomTabBar 추가:**
   - `+` 버튼 → `Quick Load` → `BottomTabBar.tscn`
   - Anchors: `Bottom Wide` (이미 설정됨)

7. `Scene` → `Save Scene` → `ui/screens/MainLobby.tscn`

8. **Main Scene으로 설정:**
   - `Project` → `Project Settings` → `Application` → `Run`
   - `Main Scene` → `ui/screens/MainLobby.tscn` 선택

9. `F5` 실행! 🎉

---

## 🎯 다음 할 일

**완료된 것:**
- [x] UITheme.gd (디자인 시스템)
- [x] BottomTabBar (공통 컴포넌트)
- [x] MainLobby (간단 버전)

**다음 단계:**
1. **TopBar 컴포넌트** 제작 (30분)
   - `IMPLEMENTATION_GUIDE.md` 섹션 2-2 참고
2. **CardItem 컴포넌트** 제작 (30분)
   - `IMPLEMENTATION_GUIDE.md` 섹션 2-3 참고
3. **MainLobby 완성** (1시간)
   - 캐릭터 디스플레이
   - 4개 액션 버튼
   - 플로팅 애니메이션
   - `IMPLEMENTATION_GUIDE.md` 섹션 3-1 참고

---

## 💡 꿀팁

### 듀얼 모니터 활용
```bash
# HTML 프로토타입을 브라우저로 열어두고 참고
open ~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1/c01-main-lobby.html
```

### Godot 단축키
- `Ctrl+N`: 새 씬
- `Ctrl+S`: 저장
- `F5`: 프로젝트 실행
- `F6`: 현재 씬 실행
- `Ctrl+D`: 노드 복제
- `Ctrl+Z`: 실행 취소

### 자주 쓰는 Anchors Preset
- `Full Rect`: 부모 전체 채우기
- `Top Wide`: 상단 가로 전체
- `Bottom Wide`: 하단 가로 전체
- `Center`: 정중앙

### Inspector에서 색상 입력
1. Color 속성 클릭
2. HEX 값 복붙 (예: `#1A1A2E`)
3. Enter

---

## 📚 전체 가이드

**상세 구현 가이드:**
- `IMPLEMENTATION_GUIDE.md` - 모든 화면 상세 가이드
- `GODOT_UI_WORKFLOW.md` - 전체 워크플로우 설명

**HTML 프로토타입:**
- `~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1/`

**디자인 스펙:**
- `~/Projects/geekbrox/teams/game/interface/UPDATED_SCREEN_SPECS_v1.1.md`

---

## ❓ 문제 해결

### UITheme 오류 발생
→ Autoload 등록 확인 (`Project Settings` → `Autoload` → `UITheme` 있는지 체크)

### 색상이 안 보임
→ ColorRect/Panel의 `visible` 체크박스 확인

### 버튼 클릭 안 됨
→ 버튼이 다른 노드에 가려졌는지 확인 (Scene 트리 순서)

### 씬 전환 오류
→ 경로 확인 (`res://ui/screens/...` 형식)

---

**작성자:** Atlas  
**작성일:** 2026-02-23
