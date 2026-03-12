# 🎮 Dream Collector — 캐릭터 정보 팝업(모달) 사양서

**버전**: v1.0  
**작성일**: 2026-03-12  
**상태**: 개발 준비  
**담당**: Cursor IDE (GDScript + Godot UI)  
**참조**: 
- `CHARACTER_STATS_DETAILED_SYSTEM.md` (데이터 구조)
- `UI_CHARACTER_SCREEN_SPEC.md` (CharacterScreen 전체)
- `ItemDetailPopup.tscn/.gd` (UI 템플릿)

---

## 목차

1. [개요](#개요)
2. [UI 레이아웃](#ui-레이아웃)
3. [데이터 바인딩](#데이터-바인딩)
4. [컴포넌트 상세](#컴포넌트-상세)
5. [스크롤 구조](#스크롤-구조)
6. [색상 & 스타일](#색상--스타일)
7. [Godot 구현](#godot-구현)
8. [개발 체크리스트](#개발-체크리스트)

---

## 개요

### 목적
CharacterScreen의 "스탯 상세" 버튼 클릭 시 표시되는 **모달 팝업**입니다.  
플레이어의 모든 캐릭터 속성(기본/고급/원소/저항/카드효율/최종 수치)을 계층적으로 표시합니다.

### 스타일
- **기본 템플릿**: `ItemDetailPopup.tscn`과 동일한 구조 재사용
- **데이터 구조**: `CHARACTER_STATS_DETAILED_SYSTEM.md`의 8개 섹션 적용
- **표시 방식**: 4-5개 탭 또는 롤링 스크롤 (세로 스크롤)
- **모달 타입**: 반투명 배경 + 중앙 팝업

### 크기 기준
- **프레임**: anchor_top=10%, anchor_bottom=90% (화면 높이 80%)
- **너비**: anchor_left=5%, anchor_right=95% (화면 너비 90%)
- **최대 높이**: 750px (스크롤 활성화)

---

## UI 레이아웃

### 전체 구조

```
┌─────────────────────────────────────────┐
│  DimLayer (반투명 검정 배경)            │
├─────────────────────────────────────────┤
│  ContentPanel (다크 블루-그레이)        │
│  ┌─────────────────────────────────────┐│
│  │  TopSection (고정)                 ││
│  │  ├─ CharacterName: "Nox"           ││
│  │  ├─ Level: "Lv.50"                 ││
│  │  ├─ IconBox: 캐릭터 초상화         ││
│  │  └─ MetaRow: HP/ATK/DEF/SPD        ││
│  ├─ ScrollContainer (스크롤)           ││
│  │  └─ VBoxContainer (5개 섹션)       ││
│  │     ├─ BasicStatsSection           ││
│  │     ├─ AdvancedStatsSection        ││
│  │     ├─ ElementalSection            ││
│  │     ├─ ResistanceSection           ││
│  │     ├─ CardEfficiencySection       ││
│  │     └─ FinalStatsSection           ││
│  └─────────────────────────────────────┘│
│  ButtonsRow (하단 고정)                 │
│  ├─ CloseButton (회색)                  │
│  └─ ...추가 버튼 (선택)                 │
└─────────────────────────────────────────┘
```

### 상세 구조

```
┌─────────────────────────────────────────┐
│ ★ TopSection (40 + 60 + 60px)           │
├─────────────────────────────────────────┤
│ Nox — Lv.50                             │
│ ┌──────┐  ♥ 2000  ⚡ 500  🛡 200  💨100│
│ │ 초상  │                                │
│ │ 화    │                                │
│ │160×160│                                │
│ │px     │  전투력: 1,750                │
│ └──────┘  (ATK×2+DEF+HP/10)×(1+Lv×5%)  │
├─────────────────────────────────────────┤
│ ★ ScrollContainer (스크롤 영역)        │
├─────────────────────────────────────────┤
│                                         │
│ 📌 기본 속성 (Basic Stats)              │
│ ┌───────────────────────────────────┐  │
│ │ HP         2,000 / 2,000          │  │
│ │ 공격력      500                   │  │
│ │ 방어력      200                   │  │
│ │ 속도        100                   │  │
│ │                                   │  │
│ │ 레벨       50                     │  │
│ │ 경험치     15,000 / 24,500        │  │
│ └───────────────────────────────────┘  │
│                                         │
│ 📌 고급 속성 (Advanced Stats)           │
│ ┌───────────────────────────────────┐  │
│ │ 치명타율      15% (Base 5% + 무기) │  │
│ │ 치명타 피해   150%                │  │
│ │ 방어구 관통   10%                 │  │
│ │ 회피율        5%                  │  │
│ │ 피해 경감     10%                 │  │
│ └───────────────────────────────────┘  │
│                                         │
│ 📌 원소 속성 (Elemental Stats)          │
│ ┌───────────────────────────────────┐  │
│ │ 꿈기억 데미지   +0%               │  │
│ │ 불꽃 데미지    +20%              │  │
│ │ 냉기 데미지     +10%              │  │
│ │ 번개 데미지     +15%              │  │
│ │ 암흑 데미지     +5%               │  │
│ └───────────────────────────────────┘  │
│                                         │
│ 📌 저항 & 면역 (Resistance)             │
│ ┌───────────────────────────────────┐  │
│ │ 독 저항          20%              │  │
│ │ 화상 저항        15%              │  │
│ │ 빙결 저항        10%              │  │
│ │ 마비 저항        5%               │  │
│ │ 약화 저항        10%              │  │
│ │ 기절 저항        10%              │  │
│ └───────────────────────────────────┘  │
│                                         │
│ 📌 카드 효율 (Card Efficiency)          │
│ ┌───────────────────────────────────┐  │
│ │ ATTACK 카드    +25%               │  │
│ │ SKILL 카드     +20%               │  │
│ │ POWER 카드     +30%               │  │
│ │ CURSE 카드     +15%               │  │
│ └───────────────────────────────────┘  │
│                                         │
│ 📌 최종 수치 (Final Stats)              │
│ ┌───────────────────────────────────┐  │
│ │ 전투력      1,750                │  │
│ │ 생존도      HIGH                 │  │
│ │ DPS        약 327/턴             │  │
│ │ 안정성     Medium                │  │
│ └───────────────────────────────────┘  │
│                                         │
├─────────────────────────────────────────┤
│ [닫기]                  [세부 복사]      │
└─────────────────────────────────────────┘
```

---

## 데이터 바인딩

### 데이터 출처

**CharacterScreen.gd**에서 호출:
```gdscript
var character_stats = {
    "name": "Nox",
    "level": 50,
    "hp": 2000,
    "atk": 500,
    "def": 200,
    "spd": 100,
    "cri_rate": 0.15,      # 15%
    "cri_damage": 1.5,     # 150%
    "armor_pen": 0.1,      # 10%
    "dodge_rate": 0.05,    # 5%
    "damage_reduction": 0.1, # 10%
    
    # 저항
    "poison_resistance": 0.2,
    "burn_resistance": 0.15,
    "freeze_resistance": 0.1,
    "stun_resistance": 0.1,
    
    # 원소 데미지
    "fire_damage": 0.2,    # +20%
    "cold_damage": 0.1,    # +10%
    "lightning_damage": 0.15,
    
    # 카드 효율
    "attack_bonus": 0.25,
    "skill_bonus": 0.2,
    "power_bonus": 0.3,
    "curse_bonus": 0.15,
    
    # 장비
    "equipped_weapon": equipment_object,
    "equipped_armor": equipment_object,
    "equipped_rings": [ring1, ring2],
    "equipped_necklaces": [necklace1, necklace2]
}

# CharacterInfoPopup 호출
var popup = character_info_popup.instantiate()
popup.set_character_data(character_stats)
add_child(popup)
```

### 계산 함수 (Godot GDScript)

```gdscript
# 전투력 계산
func calculate_combat_power(atk: int, def: int, hp: int, level: int) -> int:
    return int((atk * 2 + def + hp / 10) * (1.0 + level * 0.05))

# 기본 스탯 (레벨에서 파생)
func get_base_stats(level: int) -> Dictionary:
    return {
        "atk": 100 + level * 1.5,
        "def": 50 + level * 1.0,
        "hp": 100 + level * 5.0,
        "spd": 70 + level * 0.3
    }

# 장비 보너스 합산
func calculate_equipment_bonus(equipped: Dictionary) -> Dictionary:
    var bonus = {"atk": 0, "def": 0, "hp": 0, "cri": 0}
    for slot_name in equipped:
        if equipped[slot_name] != null:
            var eq = equipped[slot_name]
            bonus.atk += eq.get_total_atk()
            bonus.def += eq.get_total_def()
            bonus.hp += eq.get_total_hp()
            if slot_name == "weapon":
                bonus.cri += eq.base_cri / 100.0
    return bonus
```

---

## 컴포넌트 상세

### TopSection (캐릭터 헤더)

**구성**:
- 좌상단: IconBox (160×160px, 캐릭터 초상화 이미지)
- 좌하단: LevelLabel ("Lv.50")
- 우상단: NameLabel ("Nox")
- 우중단: MetaRow (♥2000 / ⚡500 / 🛡200 / 💨100)
- 우하단: CombatPowerRow ("⚔ 전투력: 1,750")

**색상**:
- 배경: `Color(0.14, 0.16, 0.22)` (진한 다크 블루-그레이)
- 텍스트: `Color.WHITE`
- 강조: `Color(1.0, 0.85, 0.0)` (금색, 레벨/전투력)

**크기**:
- TopSection 높이: 180px (아이콘 160px + 여백)
- 좌측 아이콘 너비: 160px
- 우측 텍스트 너비: 가변

---

### BasicStatsSection (기본 속성)

**포함 항목**:
```
┌─────────────────────────────┐
│ 📌 기본 속성                │
│ ┌───────────────────────────┤
│ │ HP              2,000     │
│ │ 공격력           500      │
│ │ 방어력           200      │
│ │ 속도             100      │
│ │                          │
│ │ 레벨            50        │
│ │ 경험치    15000 / 24500   │
│ └───────────────────────────┘
└─────────────────────────────┘
```

**구현**: GridContainer (2열) 또는 VBoxContainer (행)
- 항목당 높이: 32px
- 레이블: 좌측 정렬 (가변 너비)
- 값: 우측 정렬 (고정 너비 100px, 숫자 우측 정렬)

**색상**:
- 레이블: `Color.WHITE` (0.9)
- 값: `Color.YELLOW` (높음), `Color.WHITE` (보통)

---

### AdvancedStatsSection (고급 속성)

**포함 항목**:
```
┌─────────────────────────────┐
│ 📌 고급 속성                │
│ ┌───────────────────────────┤
│ │ 치명타율        15%       │
│ │ 치명타 피해     150%      │
│ │ 방어구 관통     10%       │
│ │ 회피율          5%        │
│ │ 피해 경감       10%       │
│ └───────────────────────────┘
└─────────────────────────────┘
```

**특이점**:
- 백분율(%) 표시
- 0%는 회색 처리

---

### ElementalSection (원소 속성)

**포함 항목**:
```
┌─────────────────────────────┐
│ 📌 원소 속성                │
│ ┌───────────────────────────┤
│ │ 🌙 꿈기억      +0%        │
│ │ 🔥 불꽃       +20%       │
│ │ ❄️ 냉기        +10%       │
│ │ ⚡ 번개        +15%       │
│ │ 🌑 암흑        +5%        │
│ └───────────────────────────┘
└─────────────────────────────┘
```

**색상 (원소별)**:
```gdscript
var element_colors = {
    "dream": Color(0.7, 0.7, 0.9),    # 밝은 보라
    "fire": Color(1.0, 0.5, 0.0),     # 주황색
    "cold": Color(0.5, 0.8, 1.0),     # 밝은 파랑
    "lightning": Color(1.0, 1.0, 0.0),# 노란색
    "darkness": Color(0.4, 0.2, 0.6)  # 진한 보라
}
```

---

### ResistanceSection (저항 & 면역)

**포함 항목** (6개):
```
┌─────────────────────────────┐
│ 📌 저항 & 면역              │
│ ┌───────────────────────────┤
│ │ 독 저항        20%        │
│ │ 화상 저항      15%        │
│ │ 빙결 저항      10%        │
│ │ 마비 저항      5%         │
│ │ 약화 저항      10%        │
│ │ 기절 저항      10%        │
│ └───────────────────────────┘
└─────────────────────────────┘
```

**규칙**:
- 0% 저항: 회색 처리
- 25% 이상: 녹색 강조
- 50% 이상: 밝은 녹색 + 이모지 추가 (✓)

---

### CardEfficiencySection (카드 효율)

**포함 항목**:
```
┌─────────────────────────────┐
│ 📌 카드 효율                │
│ ┌───────────────────────────┤
│ │ ⚔️ ATTACK     +25%        │
│ │ 🎯 SKILL      +20%        │
│ │ ✨ POWER      +30%        │
│ │ 🖤 CURSE      +15%        │
│ └───────────────────────────┘
└─────────────────────────────┘
```

**색상 (타입별)**:
```gdscript
var card_type_colors = {
    "ATTACK": Color(1.0, 0.2, 0.2),    # 빨강
    "SKILL": Color(0.2, 0.8, 1.0),     # 파랑
    "POWER": Color(1.0, 0.8, 0.0),     # 금색
    "CURSE": Color(0.6, 0.2, 0.8)      # 보라
}
```

---

### FinalStatsSection (최종 수치)

**포함 항목**:
```
┌─────────────────────────────┐
│ 📌 최종 수치                │
│ ┌───────────────────────────┤
│ │ 전투력        1,750       │
│ │ 생존도        HIGH        │
│ │ DPS          ~327/턴      │
│ │ 안정성       Medium       │
│ └───────────────────────────┘
└─────────────────────────────┘
```

**계산**:
```gdscript
# DPS 예상 (대략적)
var dps = atk * avg_card_multiplier * crit_rate * avg_turns_per_enemy
# 예: 500 × 1.5 × 0.15 × 2.9 ≈ 327

# 생존도 등급
var survivability = "HIGH" if hp + def > 500 else "MEDIUM" if hp + def > 200 else "LOW"

# 안정성 등급
var stability = "HIGH" if dodge_rate > 0.2 and resistance > 0.4 else "MEDIUM" else "LOW"
```

---

## 스크롤 구조

### 방식 1: 단일 롤링 스크롤 (추천)

**장점**:
- 간단한 구현
- 자연스러운 UX
- 모바일 최적화

**구조**:
```
TopSection (고정, 180px)
    ↓
ScrollContainer (스크롤 시작)
├─ VBoxContainer
│  ├─ BasicStatsSection
│  ├─ AdvancedStatsSection
│  ├─ ElementalSection
│  ├─ ResistanceSection
│  ├─ CardEfficiencySection
│  └─ FinalStatsSection
    ↓
ButtonsRow (고정, 60px)
```

**구현** (GDScript):
```gdscript
# ScrollContainer 설정
var scroll = ScrollContainer.new()
scroll.anchor_top = 0.22  # TopSection 아래
scroll.anchor_bottom = 0.92 # ButtonsRow 위
scroll.custom_minimum_size.y = 0  # 자동 높이

var vbox = VBoxContainer.new()
vbox.add_child(basic_section)
vbox.add_child(advanced_section)
vbox.add_child(element_section)
vbox.add_child(resistance_section)
vbox.add_child(card_section)
vbox.add_child(final_section)

scroll.add_child(vbox)
content_panel.add_child(scroll)
```

### 방식 2: 탭 방식 (선택사항)

**장점**: 정보 카테고리별 분류
**단점**: 구현 복잡도 높음

**탭 구성**:
- Tab 1: Basic + Advanced
- Tab 2: Element + Resistance
- Tab 3: Card Efficiency + Final

---

## 색상 & 스타일

### 전체 팔레트

```gdscript
var character_info_colors = {
    "bg_main": Color(0.14, 0.16, 0.22),        # 진한 다크 블루
    "bg_section": Color(0.10, 0.12, 0.18),    # 더 진한 배경
    "text_primary": Color.WHITE,               # 주 텍스트
    "text_secondary": Color(0.8, 0.8, 0.8),   # 부 텍스트
    "text_disabled": Color(0.5, 0.5, 0.5),    # 비활성
    "accent_gold": Color(1.0, 0.85, 0.0),    # 강조 금색
    "accent_green": Color(0.4, 0.9, 0.4),    # 긍정 (저항, 보너스)
    "accent_red": Color(1.0, 0.3, 0.3),       # 부정 (약점, 페널티)
    "border_gold": Color(0.8, 0.7, 0.2)       # 테두리 금색
}
```

### 섹션 헤더 스타일

```
┌─────────────────────────────┐
│ 📌 섹션명              [>]  │  ← 좌측: 이모지 + 텍스트
│ ─────────────────────────     ← 구분선 (선택)
└─────────────────────────────┘
```

**구현**:
- 폰트: 볼드 (14pt)
- 색상: `accent_gold`
- 여백: 상단 12px, 하단 8px
- 구분선: `Color(0.3, 0.3, 0.4)` 3px

---

## Godot 구현

### 파일 구조

```
dream-collector/
├── ui/components/
│   ├── CharacterInfoPopup.gd      ← 메인 로직
│   └── CharacterInfoPopup.tscn    ← UI 씬
├── ui/components/sections/
│   ├── CharStatBasicSection.gd
│   ├── CharStatAdvancedSection.gd
│   ├── CharStatElementSection.gd
│   ├── CharStatResistanceSection.gd
│   ├── CharStatCardSection.gd
│   └── CharStatFinalSection.gd
└── data/
    └── character_data.gd          ← 데이터 구조
```

### CharacterInfoPopup.gd 기본 구조

```gdscript
extends Control
class_name CharacterInfoPopup

# 참조
@onready var dim_layer = $DimLayer
@onready var content_panel = $ContentPanel
@onready var top_section = $ContentPanel/MarginContainer/VBoxContainer/TopSection
@onready var scroll_container = $ContentPanel/MarginContainer/VBoxContainer/ScrollContainer
@onready var vbox = scroll_container.get_child(0)
@onready var buttons_row = $ContentPanel/MarginContainer/VBoxContainer/ButtonsRow

# 데이터
var character_stats: Dictionary = {}

func _ready():
    setup_ui()
    dim_layer.gui_input.connect(_on_dim_layer_input)
    $ContentPanel/MarginContainer/VBoxContainer/ButtonsRow/CloseButton.pressed.connect(close_popup)

func set_character_data(stats: Dictionary) -> void:
    character_stats = stats
    refresh_all_sections()

func setup_ui():
    # TopSection 구성 요소 생성
    var top_container = HBoxContainer.new()
    var icon_box = TextureRect.new()
    icon_box.custom_minimum_size = Vector2(160, 160)
    icon_box.expand_mode = TextureRect.EXPAND_FIT_SIZE
    icon_box.texture = load("res://assets/character/nox_portrait.png")
    top_container.add_child(icon_box)
    
    # 우측 정보
    var right_vbox = VBoxContainer.new()
    var name_label = Label.new()
    name_label.text = character_stats.get("name", "Unknown")
    right_vbox.add_child(name_label)
    # ... 추가 요소들
    
    top_container.add_child(right_vbox)
    top_section.add_child(top_container)

func refresh_all_sections():
    # 기존 섹션 제거
    for child in vbox.get_children():
        child.queue_free()
    
    # 새 섹션 추가
    vbox.add_child(create_basic_stats_section())
    vbox.add_child(create_advanced_stats_section())
    vbox.add_child(create_element_section())
    vbox.add_child(create_resistance_section())
    vbox.add_child(create_card_efficiency_section())
    vbox.add_child(create_final_stats_section())

func create_basic_stats_section() -> Control:
    var section = PanelContainer.new()
    var vbox = VBoxContainer.new()
    
    # 제목
    var title = Label.new()
    title.text = "📌 기본 속성"
    title.add_theme_font_size_override("font_size", 14)
    vbox.add_child(title)
    
    # 각 항목
    var hp_row = create_stat_row("HP", str(character_stats.hp) + " / " + str(character_stats.hp))
    vbox.add_child(hp_row)
    
    var atk_row = create_stat_row("공격력", str(character_stats.atk))
    vbox.add_child(atk_row)
    
    # ... 추가 행들
    
    section.add_child(vbox)
    return section

func create_stat_row(label: String, value: String) -> Control:
    var hbox = HBoxContainer.new()
    
    var label_node = Label.new()
    label_node.text = label
    label_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hbox.add_child(label_node)
    
    var value_node = Label.new()
    value_node.text = value
    value_node.add_theme_color_override("font_color", Color.YELLOW)
    value_node.alignment = HORIZONTAL_ALIGNMENT_RIGHT
    hbox.add_child(value_node)
    
    return hbox

func _on_dim_layer_input(event: InputEvent):
    if event is InputEventMouseButton and event.pressed:
        close_popup()

func close_popup():
    queue_free()
```

### CharacterInfoPopup.tscn 구조

```
CharacterInfoPopup (Control, full screen)
├── DimLayer (ColorRect, 반투명 검정)
└── ContentPanel (PanelContainer, anchor 5%~95%)
    └── MarginContainer (5px margin)
        └── VBoxContainer
            ├── TopSection (180px, 고정)
            ├── ScrollContainer (스크롤)
            │   └── VBoxContainer
            │       ├── BasicStatsSection
            │       ├── AdvancedStatsSection
            │       ├── ElementalSection
            │       ├── ResistanceSection
            │       ├── CardEfficiencySection
            │       └── FinalStatsSection
            └── ButtonsRow (60px, 고정)
                ├── CloseButton
                └── [선택] 추가 버튼
```

### CharScreen.gd 호출 코드

```gdscript
# CharacterScreen.gd

func _on_stat_detail_button_pressed():
    # CharacterInfoPopup 인스턴스 생성
    var popup_scene = preload("res://ui/components/CharacterInfoPopup.tscn")
    var popup = popup_scene.instantiate()
    
    # 현재 캐릭터 데이터 전달
    var stats = gather_character_stats()
    popup.set_character_data(stats)
    
    # 부모에 추가 (보통 CanvasLayer)
    get_tree().root.add_child(popup)

func gather_character_stats() -> Dictionary:
    var level_system = LevelSystem.get_player_level()
    var equipped = get_equipped_items()
    var gacha_system = get_node("/root/GachaSystem")
    
    return {
        "name": "Nox",
        "level": level_system.current_level,
        "hp": level_system.get_total_hp(),
        "atk": level_system.get_total_atk(),
        "def": level_system.get_total_def(),
        "spd": level_system.get_total_spd(),
        "cri_rate": 0.05 + equipped.get("weapon", {}).get("base_cri", 0) / 100.0,
        "cri_damage": 1.5,
        
        # ... 추가 속성들
        
        "equipped_weapon": equipped.get("weapon"),
        "equipped_armor": equipped.get("armor"),
        "equipped_rings": equipped.get("rings", []),
        "equipped_necklaces": equipped.get("necklaces", [])
    }
```

---

## 개발 체크리스트

### 1단계: UI 씬 생성

- [ ] CharacterInfoPopup.tscn 생성 (ItemDetailPopup.tscn 참고)
- [ ] DimLayer (ColorRect) 구성
- [ ] ContentPanel (PanelContainer) 구성
  - [ ] 배경색 설정 (#1A1F37)
  - [ ] 테두리 추가 (2px, 금색)
- [ ] TopSection 레이아웃
  - [ ] IconBox (160×160) 자리
  - [ ] NameLabel, LevelLabel, MetaRow
  - [ ] CombatPowerRow
- [ ] ScrollContainer (중앙)
  - [ ] VBoxContainer 자식
  - [ ] spacing 설정 (8px)
- [ ] ButtonsRow (하단)
  - [ ] CloseButton 구성

### 2단계: 섹션 UI 생성

- [ ] BasicStatsSection (HP, ATK, DEF, SPD, 레벨, EXP)
- [ ] AdvancedStatsSection (치명타, 방어구 관통, 회피, 피해 경감)
- [ ] ElementalSection (5가지 원소 + 이모지)
- [ ] ResistanceSection (6가지 저항)
- [ ] CardEfficiencySection (4가지 카드 타입)
- [ ] FinalStatsSection (전투력, 생존도, DPS, 안정성)

### 3단계: 로직 구현

- [ ] CharacterInfoPopup.gd 작성
- [ ] set_character_data() 함수 구현
- [ ] refresh_all_sections() 함수 구현
- [ ] 각 섹션 생성 함수 구현
- [ ] 색상 및 포맷팅 적용

### 4단계: 데이터 연결

- [ ] CharacterScreen.gd에서 "스탯 상세" 버튼 클릭 연결
- [ ] gather_character_stats() 함수 작성
- [ ] LevelSystem, EquipmentDatabase 연동
- [ ] 동적 데이터 업데이트 테스트

### 5단계: 스타일 & 폴리시

- [ ] 색상 팔레트 적용 (gold, green, red 등)
- [ ] 폰트 크기 및 정렬 조정
- [ ] 여백(padding/margin) 정일치
- [ ] 반응형 레이아웃 테스트

### 6단계: 테스트 & 최적화

- [ ] 스크롤 성능 확인
- [ ] 다양한 레벨의 캐릭터로 테스트
- [ ] 타치 인풋 반응성 확인
- [ ] ItemDetailPopup과의 UI 일관성 검증

---

## 참고 이미지 & 참조

### ItemDetailPopup 참조
```
파일: ui/components/ItemDetailPopup.tscn/.gd
내용: 모달 구조, 스크롤, 색상, 레이아웃 모두 참고 가능
재사용: 아래의 함수들 복사 가능
- _ready()
- _on_dim_layer_input()
- create_stat_row()
```

### CHARACTER_STATS_DETAILED_SYSTEM.md 참조
```
파일: 02_core_design/characters/CHARACTER_STATS_DETAILED_SYSTEM.md
내용: 8개 섹션의 모든 데이터 구조, 색상, 포맷팅 기준
섹션별:
1. 기본 속성 — Core Stats Table
2. 고급 속성 — Advanced Stats Table
3. 원소 속성 — Element Damage Table + 상성 5×5
4. 저항 & 면역 — Resistance Table
5. 카드 효율 — Card Type Bonus Table
6. 데미지 계수 — 7-step Calculation
7. 최종 수치 — Final Stats Example (Lv.50)
8. UI 레이아웃 — 4-Page Structure
```

### 이전 커밋 참조
```
Commit: 814bec1 (2026-03-12)
- DEVELOPMENT_LOG_2026.md: Phase 3 완료 기록
- COMBAT_SYSTEM_MASTER_SPEC.md: v4.1 치명타 시스템

Commit: 5f03164 (2026-03-12)
- CharacterScreen 완성
- ItemDetailPopup 레이아웃
- CLAUDE.md 작성
```

---

## 변경 이력

| 버전 | 날짜 | 주요 변경 |
|------|------|----------|
| v1.0 | 2026-03-12 | 초안 작성 (Cursor 개발용) |

---

**Cursor IDE 개발자용 메모:**
- 이 문서의 모든 코드는 `GDScript 4.0` (Godot 4.x) 기준
- `@onready` 등 최신 Godot 문법 사용
- ItemDetailPopup.tscn을 템플릿으로 즉시 시작 가능
- CHARACTER_STATS_DETAILED_SYSTEM.md와 함께 참조 필수

**작성**: Atlas PM  
**최종 업데이트**: 2026-03-12 14:22 PST
