# CLAUDE.md — Dream Collector 프로젝트 컨텍스트

> Claude Code가 이 파일을 자동으로 읽습니다. 새 세션 시작 시 별도 로드 불필요.  
> **최종 업데이트**: 2026-03-04

---

## 📌 프로젝트 기본 정보

| 항목 | 내용 |
|------|------|
| **게임 이름** | Dream Collector (꿈수집가) |
| **장르** | Roguelike + Idle RPG |
| **엔진** | Godot 4.3 |
| **언어** | GDScript + 한국어 UI |
| **해상도** | 390×844 (세로, 모바일) |
| **루트 경로** | `~/Projects/geekbrox/teams/game/godot/dream-collector/` |

---

## 📂 파일 구조 (핵심만)

```
dream-collector/
├── scripts/
│   ├── GameManager.gd              # 글로벌 상태 싱글톤 (재화: gems, reveries, energy)
│   ├── UITheme.gd                  # 색상/스타일 공통 테마
│   ├── MainLobbyUI.gd              # 메인 로비 컨트롤러
│   ├── combat/
│   │   ├── shared/
│   │   │   ├── Card.gd             # 카드 리소스 클래스 (200종)
│   │   │   ├── CardDatabase.gd     # 카드 DB (JSON 로드)
│   │   │   ├── Equipment.gd        # 장비 리소스 클래스 ★
│   │   │   ├── EquipmentDatabase.gd# 장비 66종 DB ★
│   │   │   └── Monster.gd          # 몬스터 데이터
│   │   └── atb/
│   │       ├── CombatManagerATB.gd # ATB 전투 중앙 관리자 ★
│   │       ├── ATBComboSystem.gd   # 콤보 시스템
│   │       ├── ATBReactionManager.gd
│   │       ├── ATBAutoAI.gd
│   │       └── ...
│   └── systems/
│       ├── LevelSystem.gd          # 성장 시스템 (무한 레벨) ★
│       ├── GachaSystem.gd          # 가챠 시스템
│       ├── MilestoneRewardSystem.gd
│       └── ContentUnlockManager.gd
│
├── ui/
│   ├── screens/
│   │   ├── CharacterScreen.gd/.tscn  # 캐릭터/장비 탭 ★ (최근 대규모 작업)
│   │   ├── CardLibrary.gd/.tscn
│   │   ├── DeckBuilder.gd/.tscn
│   │   ├── Shop.gd/.tscn
│   │   ├── UpgradeTree.gd/.tscn
│   │   └── RunPrep.gd/.tscn
│   └── components/
│       ├── BottomNav.gd/.tscn        # 5탭 하단 네비게이션 ★
│       ├── EquipmentSlot.gd/.tscn    # 72×72 장비 슬롯 컴포넌트 ★
│       ├── ItemDetailPopup.gd/.tscn  # 장비 세부정보 모달 ★
│       └── ...
│
├── scenes/
│   └── MainLobby.tscn              # 진입점 씬
│
├── CLAUDE.md                       # 이 파일
├── PROJECT_CONTEXT.md              # 공통 컨텍스트 (구버전)
└── CHANGELOG.md                    # 변경 이력
```

---

## 🎮 4대 핵심 시스템

### 1. 카드 시스템 (200종)
- 타입: ATTACK(42) / SKILL(60) / POWER(50) / CURSE(48)
- 희귀도: COMMON 40% / RARE 35% / SPECIAL 15% / LEGENDARY 10%
- 강화: 동일 카드 ×2 (또는 + Gold), **100% 성공**, 최대 +10
- 데이터: `data/cards_200_v2.json` (124KB)
- 스크립트: `scripts/combat/shared/Card.gd`, `CardDatabase.gd`

### 2. 장비 시스템 (66종, 4슬롯)
- 슬롯: WEAPON / ARMOR / ACCESSORY(반지) / OFF_HAND(목걸이)
- 스탯: ATK, DEF, HP, SPD, CRI(치명타율, 무기만)
- 강화: **100% 성공**, +10까지, 스탯 10%/레벨
- 스크립트: `scripts/combat/shared/Equipment.gd`, `EquipmentDatabase.gd`

### 3. 성장 시스템 (무한 레벨)
- 레벨 범위: Lv 1 ~ 1000+
- EXP 공식: `100 × (현재_레벨 ^ 1.2)`
- 자동 스탯 배분 (플레이어 선택 없음):
  - ATK +1.5 / DEF +1.0 / HP +5.0 / SPD +0.3 (레벨당)
- 스크립트: `scripts/systems/LevelSystem.gd`

### 4. 가챠 시스템
- 장비 가챠: COMMON 55% / RARE 30% / SPECIAL 13% / LEGENDARY 2%
- 카드 가챠: COMMON 45% / RARE 35% / SPECIAL 15% / LEGENDARY 5%
- 보장: 50연 RARE / 100연 SPECIAL / 150연 LEGENDARY
- 스크립트: `scripts/systems/GachaSystem.gd`

---

## ⚠️ 절대 하지 말 것

```
❌ 특성 마스터리 시스템 추가 (완전 제외됨)
❌ 수동 스탯 포인트 배분 (자동 전용)
❌ 강화 실패 메카닉 (100% 성공만)
❌ 장비↔카드 크로스 강화 (금지)
❌ 하단 메인 메뉴바(BottomNav), 상단 메뉴바 수정
```

---

## 🏗️ 구현 완료 현황

### ✅ 완료된 시스템

| 시스템 | 파일 | 상태 |
|--------|------|------|
| Card 리소스 | `Card.gd` | ✅ 완료 |
| CardDatabase (200종) | `CardDatabase.gd` | ✅ 완료 |
| Equipment 리소스 | `Equipment.gd` | ✅ 완료 (base_cri 포함) |
| EquipmentDatabase (66종) | `EquipmentDatabase.gd` | ✅ 완료 (무기 CRI 포함) |
| LevelSystem | `LevelSystem.gd` | ✅ 완료 |
| GachaSystem | `GachaSystem.gd` | ✅ 완료 |
| MilestoneRewardSystem | `MilestoneRewardSystem.gd` | ✅ 완료 |
| ATB 전투 관리자 | `CombatManagerATB.gd` | ✅ 완료 (치명타 판정 포함) |
| ATB 콤보 시스템 | `ATBComboSystem.gd` | ✅ 완료 |
| GameManager | `GameManager.gd` | ✅ 완료 |
| BottomNav (5탭) | `BottomNav.gd/.tscn` | ✅ 완료 |
| CharacterScreen (장비탭) | `CharacterScreen.gd/.tscn` | ✅ 완료 |
| EquipmentSlot 컴포넌트 | `EquipmentSlot.gd/.tscn` | ✅ 완료 |
| ItemDetailPopup 모달 | `ItemDetailPopup.gd/.tscn` | ✅ 완료 |

---

## 📋 주요 스크립트 상세

### Equipment.gd
```gdscript
class_name Equipment
extends Resource

@export var id: int
@export var name: String          # 영문명
@export var name_ko: String       # 한국어명
@export var slot: String          # "WEAPON" | "ARMOR" | "ACCESSORY" | "OFF_HAND"
@export var rarity: String        # "COMMON" | "RARE" | "SPECIAL" | "LEGENDARY"
@export var base_atk: float
@export var base_def: float
@export var base_hp: float
@export var base_spd: float
@export var base_cri: float       # 치명타율 % (0~25, 무기만 비어있음)
@export var enhancement_level: int  # 0~10

# 스탯 메서드: 강화 레벨 반영
func get_total_atk() -> float     # base_atk * (1 + level * 0.1)
func get_total_def() -> float
func get_total_hp() -> float
func get_total_spd() -> float
func get_total_cri() -> float     # base_cri + level * 0.5
func enhance() -> bool            # +1 강화, 레벨 10 한도
func duplicate_equipment() -> Equipment
```

### CharacterScreen.gd
```gdscript
# 하단 탭 인덱스 3 = Character 탭
# 장착 슬롯 6개: slot_weapon, slot_armor, slot_ring_1/2, slot_necklace_1/2
# SLOT_TO_TYPE: 슬롯ID → 허용 장비 타입 매핑
# equipped: Dictionary { slot_id → Equipment }

# 주요 함수:
_on_slot_pressed(slot_id)    # 빈 슬롯→선택모드, 장착됨→세부창 열기
_on_inventory_item_pressed(eq)  # selected_slot 있으면 장착, 없으면 세부창
_refresh_stats()             # LevelSystem + 장착 장비 합산 스탯 표시
_refresh_inventory()         # 보유 장비 목록 갱신 (5열 그리드)
_on_sort_pressed()           # 등급순/강화순/종류순 순환

# 전투력 공식:
# power = int((atk×2 + def + hp/10) × (1 + level×0.05))
```

### CombatManagerATB.gd
```gdscript
# ATB 기본 공격에 치명타 판정 구현됨:
var cri_chance: float = player_data.get("cri", 0.0)
var is_crit := randf() * 100.0 < cri_chance
if is_crit:
    dmg = int(dmg * 1.5)
    battle_log("치명타! 데미지 %d" % dmg)

# 시그널 (Godot 4 최신 문법):
combo_system.combo_triggered.emit("완벽한 방어", 10)  # ← 이 방식 사용
# emit_signal() 사용 금지 (Godot 3 방식)
```

### BottomNav 탭 인덱스
```
0: Home    → scenes/MainLobby.tscn
1: Cards   → ui/screens/CardLibrary.tscn
2: Upgrade → ui/screens/UpgradeTree.tscn
3: Character → ui/screens/CharacterScreen.tscn   ← Progress 탭이었다가 변경됨
4: Shop    → ui/screens/Shop.tscn
```

---

## 🎨 UI 규칙

### 색상 팔레트 (CharacterScreen)
| 용도 | 색상 |
|------|------|
| 화면 배경 | `Color(0.102, 0.102, 0.18)` (진한 남색) |
| 캐릭터 섹션 배경 | `#faeacb` (밝은 베이지) |
| COMMON 테두리/배경 | `#5DB85D` / `#2D4A2D` |
| RARE 테두리/배경 | `#5B9BD5` / `#1E3A5F` |
| SPECIAL/EPIC 테두리/배경 | `#9B59B6` / `#3D1F5C` |
| LEGENDARY 테두리/배경 | `#F39C12` / `#4A3000` |

### EquipmentSlot 컴포넌트
- 크기: 72×72px (`SLOT_SIZE = 72`)
- 구성: LV 배지(좌상단) + 슬롯타입 아이콘(중앙) + 장비타입명(하단) + ✓ 배지(우상단)
- `set_item(eq: Equipment)` — 아이템 표시
- `set_empty()` — 빈 슬롯 표시
- `set_check_visible(bool)` — ✓ 뱃지 표시/숨김

### ItemDetailPopup 레이아웃
- 앵커: `anchor_top=0.1, anchor_bottom=0.9` (화면 80% 높이)
- 배경: 다크 블루-그레이 `Color(0.14, 0.16, 0.22)`
- 내부 여백: `content_margin = 5px` (전방향)
- 섹션: TopSection → BasicStatsSection → SkillSection → OptionsSection → UsageSection → ButtonsRow
- 버튼: 장착(파랑) / 강화(보라) / 닫기(회색) / 해제(빨강)

### 인벤토리 그리드
- 열 수: 5열 (`columns = 5`)
- 간격: `h_separation = 4`, `v_separation = 4`
- 헤더: InventoryHeader (336~416px) — 타이틀 + 정렬 버튼
- 정렬: 등급순 → 강화순 → 종류순 (순환)
- 가로 스크롤: 비활성화 (`horizontal_scroll_mode = 0`)

---

## 🔧 코딩 컨벤션

```gdscript
# 명명 규칙
snake_case          # 변수, 함수
PascalCase          # 클래스명
UPPER_CASE          # 상수

# Godot 4 시그널 문법 (필수!)
signal_name.emit(arg1, arg2)    # ✅ 올바른 방법
emit_signal("name", arg1)       # ❌ Godot 3 방식, 사용 금지

# 노드 참조
@onready var label: Label = $Path/To/Label   # ✅ 타입 명시
get_node_or_null("Path")                      # ✅ 안전한 접근

# null 체크 패턴
if node:
    node.do_something()     # ✅
node.do_something()         # ❌ 크래시 위험
```

---

## 💡 자주 발생한 버그와 해결법

### 1. 시그널 인수 불일치
- **증상**: `Method expected 0 argument(s), but called with 1`
- **원인**: GameManager 시그널이 값을 전달하는데 연결된 함수가 인수 없음
- **해결**: 래퍼 함수 패턴 사용
```gdscript
GameManager.gems_changed.connect(_on_gems_changed)
func _on_gems_changed(_v: int) -> void: _update_currency()
```

### 2. EquipmentSlot _draw_slot() 이중 호출
- **증상**: 슬롯 아이콘이 2개 겹쳐 표시
- **원인**: `set_item()` → `_draw_slot()` 후, `_ready()` → `_draw_slot()` 재호출
- **해결**: `_ready()`에서 `_slot_` prefix 자식 존재 시 스킵
```gdscript
func _ready():
    var already_drawn := false
    for c in get_children():
        if c.name.begins_with("_slot_"):
            already_drawn = true; break
    if not already_drawn:
        _draw_slot()
```

### 3. ATBComboSystem "연타" 콤보 미발동
- **원인**: 카드 타입 `"ATK"` vs `"ATTACK"` 불일치
- **해결**: 양쪽 모두 체크
```gdscript
if _last_n_type(card_history, 3, "ATTACK") or _last_n_type(card_history, 3, "ATK"):
```

### 4. .tscn 파일 수정 후 Godot 충돌
- **해결**: Godot 완전 종료 → .tscn 수정 → Godot 재시작

---

## 🏃 작업 시작 체크리스트

```bash
# 1. 최신 코드 가져오기
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
git pull origin main

# 2. Godot 닫기 (.tscn 수정 시 필수!)

# 3. 작업 후 테스트
# Godot 에디터 Output 패널에서 에러 확인
```

---

## 📐 씬 트리 구조 참조

### CharacterScreen.tscn
```
CharacterScreen (Control)
├── Background (ColorRect) — 진한 남색
├── Header (HBoxContainer) — TitleLabel + CurrencyBar(gems/gold/energy)
├── Section_Character (PanelContainer, #faeacb)
│   └── CharacterVBox
│       ├── LevelLabel
│       ├── EquipmentLayout (HBoxContainer)
│       │   ├── LeftSlots (VBoxContainer) — SlotWeapon, SlotRing1, SlotNecklace1
│       │   ├── CharacterDisplay (CenterContainer) — PlayerSpriteAnimator
│       │   └── RightSlots (VBoxContainer) — SlotArmor, SlotRing2, SlotNecklace2
│       ├── CombatPowerRow — ⚔ 전투력 [값]
│       └── StatsRow — ❤HP ⚔ATK 🛡DEF 💨SPD
├── InventoryHeader (HBoxContainer, 336~416px)
│   ├── InventoryTitleLabel — "보유 장비"
│   └── SortButton — "등급순 ▾"
├── Section_Inventory (VBoxContainer, 416px~)
│   └── InventoryScroll (ScrollContainer, 가로스크롤 비활성)
│       └── ItemGrid (GridContainer, 5열)
└── BottomNav (instance)
```

### ItemDetailPopup.tscn
```
ItemDetailPopup (Control, fullscreen)
├── DimLayer (ColorRect, 반투명 검정)
└── ContentPanel (PanelContainer, anchor 10%~90%)
    └── Scroll (ScrollContainer)
        └── VBox (VBoxContainer)
            ├── TopSection — IconBox + TitleLabel + MetaRow
            ├── BasicStatsSection — 공격력, 방어력, 치명타율
            ├── SkillSection — 장비 스킬
            ├── OptionsSection — 추가 옵션 (HP, SPD 등)
            ├── UsageSection — 사용 가능 횟수
            └── ButtonsRow — EquipButton, EnhanceButton, CloseButton, UnequipButton
```

---

## 📊 현재 GameManager 재화 시스템

```gdscript
# GameManager 싱글톤 (autoload)
var gems: int          # 💎 보석 (가챠용 프리미엄 재화)
var reveries: float    # 🪙 골드 (일반 재화 "추억")
var energy: int        # ⚡ 에너지 (전투 스태미나)

# 시그널
signal gems_changed(new_val: int)
signal reveries_changed(new_val: float)
signal energy_changed(new_val: int)
```

---

## 🗂️ 설계 문서 위치

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/
├── CARD_200_DETAILED_DESIGN_GUIDE.md   # 200카드 시스템
├── CHARACTER_EQUIPMENT_SYSTEM.md        # 장비 66종 상세
├── PROGRESSION_SYSTEM_REDESIGNED.md    # 성장 시스템
├── GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md
├── EQUIPMENT_IMPLEMENTATION_DESIGN.md
├── UI_CHARACTER_SCREEN_SPEC.md         # 캐릭터 화면 UI 스펙
├── 02_core_design/data_field_csv/      # ⭐ 데이터 필드 정의 (2026-03-04 추가)
│   ├── 01_data_field_definitions.csv   # 108개 데이터 필드 (ID, 타입, 기본값, 캡)
│   ├── 02_element_compatibility.csv    # 원소 상성표 (5원소 × 5원소)
│   ├── 03_damage_formula.csv           # 7단계 데미지 계산 공식
│   └── 04_cap_balance_guide.csv        # 주요 수치 캡 & 밸런스 가이드
└── data/
    ├── cards_200_v2.json               # 카드 데이터 (124KB)
    └── cards_200_v2.csv
```

---

## ⚔️ 데미지 계산 공식 (7단계, 03_damage_formula.csv 기준)

```
Step 1: Base = ATK × Card_Multiplier
         (SGL 150~300%, MLT 70%×N회, POWER 200%+)

Step 2: × (1 + Weapon_All_Eff% + Card_Type_Bonus%)
         (무기 전체효과 + 목걸이 카드타입 보너스)

Step 3: × 상태이상 보정
         (VULNERABLE +50%, WEAK -25%, STRENGTH +절대값)

Step 4: × Crit_DMG (if rand() < Crit_Rate)
         (Crit_Rate = 5% + DEX×0.1% + 장비CRI)
         (Crit_DMG 기본 150%)

Step 5: × Elem_Multiplier
         (약점 ×1.5, 저항 ×0.5, 중립 ×1.0)

Step 6: Monster.take_damage()에서 처리
         × (1 - DEF/(DEF+100)) × (1 - Armor_Pen%)

Step 7: Final = max(1, dmg × Dmg_Amplify%)
```

## 📊 주요 수치 캡 (04_cap_balance_guide.csv)

| 항목 | 기본값 | 소프트캡 | 하드캡 |
|------|--------|----------|--------|
| 치명타율 | 5% | 50% | 75% |
| 치명타 피해 | 150% | 500% | 999% |
| 회피율 | 0% | — | **50%** |
| 방어구 관통 | 0% | 50% | 70% |
| 피해 경감 | 0% | 60% | **75%** |
| 연타 횟수 | 1 | — | **5** |
| 원소 저항 | 0% | 75% | 90% |
| 반격 확률 | 0% | 40% | 60% |
| 흡혈율 | 0% | 30% | 50% |

## 🌀 원소 상성 (02_element_compatibility.csv)

| 공격\방어 | 꿈기억 | 불꽃 | 냉기 | 번개 | 암흑 |
|----------|--------|------|------|------|------|
| **꿈기억** | 100% | 100% | **150%** | 100% | **150%** |
| **불꽃** | 100% | 100% | 50% | **150%** | 100% |
| **냉기** | 100% | **150%** | 100% | 100% | 50% |
| **번개** | **150%** | 50% | 100% | 100% | 100% |
| **암흑** | 100% | 100% | 50% | 50% | 100% |

## 📋 주요 데이터 필드 ID (01_data_field_definitions.csv)

| 한국어명 | 필드 ID | 기본값 | 레이어 |
|----------|---------|--------|--------|
| 최대 HP | `max_hp` | 1000 | Layer 0 |
| 공격력 | `atk` | 100 | Layer 0 |
| 방어력 | `def_val` | 50 | Layer 0 |
| 속도 | `spd` | 100 | Layer 0 |
| 치명타율 | `crit_rate` | 5% | Layer 1 |
| 치명타 피해 | `crit_dmg` | 150% | Layer 1 |
| 회피율 | `dodge_rate` | 0% | Layer 1 |
| 방어막 | `shield_val` | 0 | Layer 1 |
| 피해 경감 | `dmg_reduction` | 0% | Layer 1 |
| 반격 확률 | `counter_rate` | 0% | Layer 1 |
| 흡혈율 | `life_steal` | 0% | Layer 1 |
| ATTACK 카드 데미지 | `card_atk_dmg` | 0% | Layer 2 |
| SKILL 카드 효율 | `card_skl_eff` | 0% | Layer 2 |
| POWER 카드 배율 | `card_pow_dmg` | 0% | Layer 2 |
| CURSE 카드 효율 | `card_crs_eff` | 0% | Layer 2 |
| 콤보 보너스 | `combo_bonus` | 0% | Layer 2 |
| 불꽃 데미지 | `elem_fire_dmg` | 0% | Layer 3 |
| 피해 증폭 | `dmg_amplify` | 100% | Layer 1 |

---

## 🎭 CharacterInfoPopup 모달 (신규 2026-03-12)

**목적**: CharacterScreen의 "스탯 상세" 버튼 클릭 시 표시되는 상세 정보 모달

**개발 가이드**: `/design/dream-collector/03_implementation_guides/ui/CHARACTER_INFO_POPUP_SPEC.md` ⭐ 필독

**데이터 참조**: `/design/dream-collector/02_core_design/characters/CHARACTER_STATS_DETAILED_SYSTEM.md`

**구성**:
```
CharacterInfoPopup (Control, fullscreen modal)
├── DimLayer (ColorRect, 반투명 검정 배경)
└── ContentPanel (PanelContainer, anchor 5%~95%)
    ├── TopSection (고정 180px, 캐릭터 초상화 + 기본 정보)
    │  ├─ IconBox (160×160px, 캐릭터 초상화)
    │  ├─ NameLabel ("Nox")
    │  ├─ LevelLabel ("Lv.50")
    │  ├─ MetaRow (♥HP ⚡ATK 🛡DEF 💨SPD)
    │  └─ CombatPowerRow (전투력 계산: (ATK×2+DEF+HP/10)×(1+Lv×5%))
    │
    ├── ScrollContainer (스크롤, 5개 섹션)
    │  ├─ BasicStatsSection (HP, ATK, DEF, SPD, 레벨, EXP)
    │  ├─ AdvancedStatsSection (치명타율, 치명타 피해, 방어구관통, 회피, 피해경감)
    │  ├─ ElementalSection (5원소 데미지: 꿈기억, 불꽃, 냉기, 번개, 암흑)
    │  ├─ ResistanceSection (6가지 저항: 독, 화상, 빙결, 마비, 약화, 기절)
    │  ├─ CardEfficiencySection (4카드 타입 보너스: ATTACK, SKILL, POWER, CURSE)
    │  └─ FinalStatsSection (최종 수치: 전투력, 생존도, DPS, 안정성)
    │
    └── ButtonsRow (고정 60px, 닫기 + 선택 버튼)
```

**데이터 바인딩**:
```gdscript
# CharacterScreen.gd에서 호출
func _on_stat_detail_button_pressed():
    var popup = preload("res://ui/components/CharacterInfoPopup.tscn").instantiate()
    var stats = gather_character_stats()  # 현재 캐릭터 모든 스탯 수집
    popup.set_character_data(stats)
    get_tree().root.add_child(popup)

func gather_character_stats() -> Dictionary:
    var level_system = LevelSystem.get_player_level()
    var equipped = get_equipped_items()
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

**색상 팔레트**:
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

**개발 체크리스트** (CHARACTER_INFO_POPUP_SPEC.md 참조):
- [ ] CharacterInfoPopup.tscn 생성 (ItemDetailPopup.tscn 템플릿)
- [ ] 5개 섹션 UI 구성
- [ ] CharacterInfoPopup.gd 로직 작성
- [ ] 데이터 바인딩 (LevelSystem, EquipmentDatabase 연동)
- [ ] 색상 및 스타일 적용
- [ ] 스크롤 성능 최적화
- [ ] 다양한 레벨로 테스트

---

*이 파일은 Cursor IDE와 Claude Code가 공통으로 참조합니다.*  
*프로젝트 대규모 변경 시 이 파일도 업데이트해 주세요.*
