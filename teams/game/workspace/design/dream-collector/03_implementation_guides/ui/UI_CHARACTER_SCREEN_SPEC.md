# 🎮 Dream Collector — 캐릭터 탭 UI 화면 설계서

**작성:** PM (Atlas)
**버전:** v1.0
**날짜:** 2026-03-05
**참조:** UI_EQUIPMENT_TAB_DESIGN.md, CHARACTER_EQUIPMENT_SYSTEM.md
**상태:** 📋 설계 완료

---

## 📌 개요

### 목적
캐릭터 탭(Character Tab)의 상세 UI 화면을 정의한다.
유저가 캐릭터를 시각적으로 확인하고, 장비를 착용·관리하며, 스탯을 파악할 수 있는 핵심 화면.

### 화면 구성 3구역
```
┌──────────────────────────────┐
│  ① 캐릭터 + 장비 슬롯 영역    │  (상단 고정)
│  ② 스탯 정보 영역             │  (중단 고정)
│  ③ 보유 아이템 리스트 영역    │  (하단 스크롤)
└──────────────────────────────┘
```

---

## 📐 전체 레이아웃 (세로 모바일 기준: 390×844px)

```
┌────────────────────────────────────────┐  ← 상단바 (44px)
│  ◀  캐릭터                        ⚙️  │
├────────────────────────────────────────┤
│                                        │  ── 영역 ① ──
│  ┌──────┐   ┌──────────────┐  ┌──────┐│  장비슬롯 +
│  │ 무기 │   │              │  │방어구││  캐릭터
│  │      │   │   Nox 스프라 │  │      ││  (340px)
│  └──────┘   │   이트 2x    │  └──────┘│
│             │   (128×128)  │          │
│  ┌──────┐   │              │  ┌──────┐│
│  │반지1 │   │              │  │반지2 ││
│  │      │   └──────────────┘  │      ││
│  └──────┘                     └──────┘│
│                                        │
│  ┌──────┐    ⚔ 전투력: 4,935   ┌──────┐│
│  │목걸이│    ♥ 906  ⚡390  🛡63 │목걸이││
│  │ 1    │                      │ 2    ││
│  └──────┘                      └──────┘│
├────────────────────────────────────────┤
│  ── 영역 ② ──  스탯 패널               │  (160px)
│  ┌─────────────────────────────────┐   │
│  │ Lv.23 Nox           [스탯 상세] │   │
│  │ EXP ███████░░░ 12,400 / 18,000  │   │
│  │                                  │   │
│  │ ♥ HP    906      ⚡ ATK   390   │   │
│  │ 🛡 DEF   63       💨 SPD    28   │   │
│  └─────────────────────────────────┘   │
├────────────────────────────────────────┤
│  ── 영역 ③ ──  보유 아이템             │  (스크롤)
│  [등급순 ▾]  [무기][방어구][반지][목걸이]│
│  ┌──────┬──────┬──────┬──────┬──────┐  │
│  │LV.1  │LV.1  │LV.1  │LV.1  │LV.1  │  │
│  │(아이템│(아이템│(아이템│(아이템│(아이템│  │
│  │아이콘)│아이콘)│아이콘)│아이콘)│아이콘)│  │
│  └──────┴──────┴──────┴──────┴──────┘  │
│  ┌──────┬──────┬──────┬──────┬──────┐  │
│  │      │      │      │      │      │  │
│  └──────┴──────┴──────┴──────┴──────┘  │
│  ...                   (무한 스크롤)    │
├────────────────────────────────────────┤
│  🏠홈  📜카드  ⬆업그레이드  👤캐릭터  🛒│  ← 하단바
└────────────────────────────────────────┘
```

---

## 🎯 영역 ① — 캐릭터 + 장비 슬롯

### 1-1. 캐릭터 스프라이트

| 항목 | 값 |
|------|----|
| 크기 | 전투 화면 기본 크기의 **2배** (예: 전투 64×64 → 여기서 128×128px) |
| 위치 | 화면 수평 정중앙 |
| 애니메이션 | `idle` 루프 (전투 idle과 동일 스프라이트, 재생 속도 0.8배) |
| 배경 | 반투명 원형 그림자 (Shadow circle) |
| 인터랙션 | 탭 시 캐릭터 정보 팝업 표시 |

### 1-2. 장비 슬롯 6개 배치

```
좌측 3개                   우측 3개
─────────────────────────────────────────
[무기]    캐릭터 2x    [방어구]     ← 상단
[반지 1]  스프라이트   [반지 2]     ← 중단
[목걸이1]              [목걸이2]    ← 하단
```

#### 슬롯 개별 사양

| 슬롯 ID | 표시명 | 위치 | 허용 아이템 타입 | 슬롯 아이콘 |
|---------|--------|------|-----------------|------------|
| `slot_weapon` | 무기 | 좌상 | `weapon` | ⚔ 검 실루엣 |
| `slot_ring_1` | 반지 1 | 좌중 | `ring` | 💍 반지 실루엣 |
| `slot_necklace_1` | 목걸이 1 | 좌하 | `necklace` | 📿 목걸이 실루엣 |
| `slot_armor` | 방어구 | 우상 | `armor` | 🛡 갑옷 실루엣 |
| `slot_ring_2` | 반지 2 | 우중 | `ring` | 💍 반지 실루엣 |
| `slot_necklace_2` | 목걸이 2 | 우하 | `necklace` | 📿 목걸이 실루엣 |

### 1-3. 슬롯 시각 디자인

#### 상태별 슬롯 외형

```
[ 빈 슬롯 ]           [ 장착됨 ]            [ 신규 ]
┌──────────┐          ┌──────────┐          ┌──────────┐
│          │          │ ▓▓▓▓▓▓▓▓ │          │ ▓▓▓▓▓▓▓▓ │
│  아이콘  │          │  아이템  │          │  아이템  │
│  (흐림)  │          │  스프라  │          │  스프라  │
│          │          │  이트    │          │  이트    │ 🔴 NEW
│          │          │          │          │          │
│  [슬롯명]│          │  LV.5    │          │  LV.5    │
└──────────┘          └──────────┘          └──────────┘
  점선 테두리           희귀도 색 테두리        희귀도 색 테두리
  배경: #3A3A4A         배경: #2D2D3A          + 빨간 점
  아이콘: 20% 투명도    레벨 표시 (좌상)       (우상단)
```

#### 희귀도별 테두리 색상

| 희귀도 | 테두리 색 | 배경 색 | 참고 |
|--------|----------|---------|------|
| COMMON | `#5DB85D` (초록) | `#2D4A2D` | 스크린샷 초록 슬롯 |
| RARE | `#5B9BD5` (파랑) | `#1E3A5F` | 스크린샷 파란 슬롯 |
| EPIC | `#9B59B6` (보라) | `#3D1F5C` | 스크린샷 보라 슬롯 |
| LEGENDARY | `#F39C12` (금색) | `#4A3000` | 금빛 테두리 |

#### 슬롯 크기 및 간격

```
슬롯 크기: 72×72px
슬롯 사이 간격: 8px
좌/우 슬롯 그룹과 캐릭터 사이 간격: 12px
슬롯 내 아이템 이미지: 52×52px (중앙 정렬)
레벨 텍스트 (LV.X): 좌상단 배지, 폰트 10px Bold
```

### 1-4. 전투력 & 간이 스탯 표시 (슬롯 하단)

캐릭터 스프라이트 바로 아래 중앙:

```
┌────────────────────────────────┐
│  ⚔ 전투력   4,935              │   ← 골드 텍스트, 굵게
│  ♥ 906    ⚡ 390    🛡 63      │   ← 소형 인라인 스탯
└────────────────────────────────┘
```

---

## 📊 영역 ② — 스탯 패널

### 2-1. 기본 레이아웃

```
┌─────────────────────────────────────────────┐
│  👤 Nox                  Lv. 23   [상세 ▶] │
│  ══════════════════════════════════════════  │
│  EXP  [████████████░░░░░░]  12,400 / 18,000 │
│       (다음 레벨까지 5,600 EXP)              │
│  ══════════════════════════════════════════  │
│  ♥  HP       906    │  ⚡ ATK      390      │
│  🛡  DEF       63    │  💨 SPD       28      │
└─────────────────────────────────────────────┘
```

### 2-2. 표시 스탯 목록

| 스탯 아이콘 | 스탯명 | 설명 | 구성 |
|------------|--------|------|------|
| ♥ | HP (체력) | 최대 생명력 | 기본값 + 방어구 + 반지/목걸이 보너스 |
| ⚡ | ATK (공격력) | 기본 공격 데미지 | 무기 ATK + 반지 보너스 |
| 🛡 | DEF (방어력) | 데미지 감소 | 방어구 DEF + 악세서리 보너스 |
| 💨 | SPD (속도) | ATB 충전 속도 | 기본값 + 신발/반지 보너스 |
| ⚔ | 전투력 | 종합 전투 지수 | `(ATK×2 + DEF + HP/10) × LV계수` |

### 2-3. 스탯 상세 팝업 (우측 [상세▶] 클릭 시)

```
┌───────────────────────────────────────┐
│  📊 스탯 상세                      ✕  │
├───────────────────────────────────────┤
│                     기본    장비  합계  │
│  ♥  HP             500   +406   906   │
│  ⚡  ATK            200   +190   390   │
│  🛡  DEF             30    +33    63   │
│  💨  SPD             20     +8    28   │
│  🎯  CRI (치명타율)   5%    +3%    8%  │
│  ⚡  ATK SPD        100%  +10%  110%  │
├───────────────────────────────────────┤
│  * 장비 수치는 착용 장비 합산 기준     │
└───────────────────────────────────────┘
```

---

## 📦 영역 ③ — 보유 아이템 리스트

### 3-1. 레이아웃

```
┌──────────────────────────────────────────┐
│ [등급순 ▾]  [전체][무기][방어구][반지][목걸이] │  ← 필터바 (48px 고정)
├──────────────────────────────────────────┤
│ ┌──────┐┌──────┐┌──────┐┌──────┐┌──────┐│  ← 5열 그리드
│ │LV.1  ││LV.1  ││LV.1  ││LV.1  ││LV.1  ││
│ │      ││      ││      ││      ││      ││  행 높이: 80px
│ │ 아이 ││ 아이 ││ 아이 ││ 아이 ││ 아이 ││
│ │ 콘   ││ 콘   ││ 콘   ││ 콘   ││ 콘   ││
│ └──────┘└──────┘└──────┘└──────┘└──────┘│
│ ┌──────┐┌──────┐┌──────┐...              │
│ ...             (스크롤)                  │
└──────────────────────────────────────────┘
```

### 3-2. 아이템 셀 구조 (72×80px)

```
┌──────────────┐
│ ⬡ LV.5   🔴 │  ← 레벨(좌상) + NEW뱃지(우상, 선택)
│              │
│  [아이템     │
│   스프라이트 │
│   52×52px]   │
│              │
│  강철검      │  ← 이름 (10px, 중앙, 1줄 말줄임)
└──────────────┘
   희귀도 색 테두리
```

**착용 중인 아이템 표시:**
```
┌──────────────┐
│ ⬡ LV.5   ✓ │  ← 우상단에 체크 뱃지 (초록)
│   (이미지)   │
│   밝기 70%   │  ← 살짝 어둡게 처리
│  강철검      │
└──────────────┘
  테두리에 흰색 내부 테두리 추가
```

### 3-3. 정렬 옵션

| 옵션 | 정렬 기준 |
|------|----------|
| 등급순 (기본) | 희귀도 높은 순 → 강화도 높은 순 |
| 강화순 | 강화 레벨 높은 순 |
| 최신순 | 획득 시각 최신 순 |
| 타입순 | 무기 → 방어구 → 반지 → 목걸이 |

### 3-4. 필터 탭

| 탭 | 표시 아이템 |
|----|-----------|
| 전체 | 전체 장비류 |
| 무기 | `type: weapon` |
| 방어구 | `type: armor` |
| 반지 | `type: ring` |
| 목걸이 | `type: necklace` |

---

## 🖱️ 인터랙션 설계

### 흐름 A — 빈 슬롯 탭

```
빈 슬롯 탭
  └→ 하단 아이템 리스트가 해당 타입으로 필터 전환
  └→ 슬롯 강조 (깜빡임 1회)
  └→ "착용할 [무기]를 선택하세요" 토스트 메시지
```

### 흐름 B — 착용된 슬롯 탭

```
착용된 슬롯 탭
  └→ 장비 상세 팝업 오픈
      ├─ [착용 해제] 버튼
      ├─ [강화하기] 버튼 → 강화 화면으로 이동
      └─ [닫기]
```

### 흐름 C — 인벤토리 아이템 탭

```
아이템 탭 (단순 탭)
  └→ 장비 상세 팝업 오픈
      ├─ [착용하기] 버튼 (미착용 아이템일 경우)
      ├─ [착용 해제] 버튼 (착용 중 아이템일 경우)
      ├─ [강화하기] 버튼
      └─ [닫기]

아이템 탭 (슬롯 강조 상태에서)
  └→ 즉시 해당 슬롯에 장착
  └→ "강철검 착용 완료" 토스트 메시지
  └→ 캐릭터 스프라이트 장비 반영 (의상 레이어 업데이트)
```

### 장비 상세 팝업 UI

```
┌────────────────────────────────────┐
│  ⚔ 강철검 +3              [RARE]  │
├────────────────────────────────────┤
│                                    │
│        [아이템 이미지 96×96px]     │
│                                    │
├─────────────────────┬──────────────┤
│  슬롯: 무기          │  강화: +3   │
│  타입: 검            │  최대: +10  │
├─────────────────────┴──────────────┤
│  스탯                               │
│  ATK  +20  →  +23  (강화 +15%)    │
│  CRI   +5%                          │
│  SPD   +5%                          │
├────────────────────────────────────┤
│  [착용하기]  [강화하기]  [판매]    │
└────────────────────────────────────┘
```

---

## 🎨 비주얼 디자인 가이드

### 색상 팔레트

```
배경 (전체 화면):   #1A1A2E   (딥 네이비)
패널 배경:          #16213E   (어두운 블루)
카드/슬롯 배경:     #2D2D3A   (다크 그레이)
텍스트 기본:        #E8E8F0   (밝은 흰색)
텍스트 보조:        #8888AA   (중간 회색)
강조 (골드):        #F4C542   (골든 옐로)
HP 바:             #E74C3C   (레드)
EXP 바:            #3498DB   (블루)
```

### 슬롯 애니메이션

| 상황 | 애니메이션 |
|------|----------|
| 새 아이템 획득 후 진입 | 해당 슬롯 `pulse` 2회 (노란 글로우) |
| 슬롯 선택(대기) 상태 | 슬롯 테두리 `glow` 루프 |
| 아이템 장착 완료 | `pop` 스케일 애니메이션 (1.0 → 1.2 → 1.0) |
| 아이템 해제 | 슬롯 `fade-out` → 빈 슬롯 상태로 |

### 폰트 사이즈 체계

| 용도 | 크기 | 굵기 |
|------|------|------|
| 전투력 수치 | 20px | Bold |
| 레벨 (Lv.23) | 16px | Bold |
| 스탯 수치 | 14px | Regular |
| 슬롯 레벨 배지 | 10px | Bold |
| 아이템 이름 | 10px | Regular |
| 보조 텍스트 | 11px | Regular |

---

## 🔧 Godot 구현 가이드

### 씬 트리 구조

```
CharacterScreen (Control)
├── Header (HBoxContainer)
│   ├── BackButton
│   ├── TitleLabel ("캐릭터")
│   └── SettingsButton
│
├── Section_Character (VBoxContainer)  ← 영역 ①
│   ├── EquipmentLayout (HBoxContainer)
│   │   ├── LeftSlots (VBoxContainer)
│   │   │   ├── SlotWeapon (EquipmentSlot)
│   │   │   ├── SlotRing1 (EquipmentSlot)
│   │   │   └── SlotNecklace1 (EquipmentSlot)
│   │   ├── CharacterDisplay (Control)
│   │   │   ├── CharacterSprite (AnimatedSprite2D)  ← 2x scale
│   │   │   └── ShadowCircle (ColorRect)
│   │   └── RightSlots (VBoxContainer)
│   │       ├── SlotArmor (EquipmentSlot)
│   │       ├── SlotRing2 (EquipmentSlot)
│   │       └── SlotNecklace2 (EquipmentSlot)
│   └── QuickStats (HBoxContainer)
│       ├── PowerLabel
│       ├── HpLabel
│       ├── AtkLabel
│       └── DefLabel
│
├── Section_Stats (PanelContainer)     ← 영역 ②
│   ├── CharacterNameLabel
│   ├── LevelLabel
│   ├── ExpBar (ProgressBar)
│   ├── ExpLabel
│   └── StatsGrid (GridContainer, 2열)
│       ├── HpRow, AtkRow, DefRow, SpdRow
│       └── DetailButton ("상세 ▶")
│
├── Section_Inventory (VBoxContainer)  ← 영역 ③
│   ├── FilterBar (HBoxContainer)
│   │   ├── SortButton (MenuButton)
│   │   └── TypeFilter (HBoxContainer)
│   │       └── [FilterButton × 5]
│   └── ItemGrid (GridContainer, 5열)
│       └── [ItemCell 노드들 동적 생성]
│
└── Popups
    ├── ItemDetailPopup (PopupPanel)
    └── StatDetailPopup (PopupPanel)
```

### 핵심 스크립트 구조

```gdscript
# CharacterScreen.gd
class_name CharacterScreen
extends Control

signal equipment_changed(slot_id: String, item: ItemData)

@onready var character_sprite: AnimatedSprite2D = $Section_Character/EquipmentLayout/CharacterDisplay/CharacterSprite
@onready var item_grid: GridContainer = $Section_Inventory/ItemGrid

var selected_slot: String = ""  # 현재 선택된 슬롯 ID

func _ready():
    _load_character_data()
    _load_equipment_slots()
    _load_inventory_items()
    character_sprite.play("idle")

func _on_slot_pressed(slot_id: String):
    selected_slot = slot_id
    _highlight_slot(slot_id)
    _filter_inventory_by_slot(slot_id)

func _on_item_pressed(item: ItemData):
    if selected_slot != "":
        _equip_item(item, selected_slot)
    else:
        _show_item_detail_popup(item)

func _equip_item(item: ItemData, slot_id: String):
    # 슬롯 타입 검증
    if not _slot_accepts_item(slot_id, item.type):
        _show_toast("이 슬롯에 착용할 수 없는 아이템입니다.")
        return
    # 장착 처리
    GameManager.equip_item(slot_id, item)
    _refresh_equipment_slots()
    _refresh_stats()
    _show_equip_animation(slot_id)
    _show_toast(item.name + " 착용 완료")
    equipment_changed.emit(slot_id, item)
```

```gdscript
# EquipmentSlot.gd
class_name EquipmentSlot
extends PanelContainer

signal slot_pressed(slot_id: String)

@export var slot_id: String
@export var slot_type: String  # "weapon", "armor", "ring", "necklace"
@export var slot_icon: Texture2D  # 빈 슬롯 아이콘

@onready var item_sprite: TextureRect = $ItemSprite
@onready var level_badge: Label = $LevelBadge
@onready var new_badge: TextureRect = $NewBadge

var equipped_item: ItemData = null

func set_item(item: ItemData):
    equipped_item = item
    if item:
        item_sprite.texture = item.icon
        level_badge.text = "LV." + str(item.level)
        level_badge.show()
        _apply_rarity_style(item.rarity)
    else:
        item_sprite.texture = slot_icon
        item_sprite.modulate.a = 0.3  # 투명도
        level_badge.hide()
        _apply_empty_style()
```

### CharacterData 데이터 구조

```gdscript
# CharacterData.gd
class_name CharacterData
extends Resource

var name: String = "Nox"
var level: int = 1
var exp: int = 0
var exp_to_next: int = 1000

# 기본 스탯 (레벨 기반)
var base_hp: int = 100
var base_atk: int = 10
var base_def: int = 5
var base_spd: int = 10

# 착용 장비 슬롯
var equipped: Dictionary = {
    "slot_weapon":     null,
    "slot_armor":      null,
    "slot_ring_1":     null,
    "slot_ring_2":     null,
    "slot_necklace_1": null,
    "slot_necklace_2": null
}

# 계산된 최종 스탯
func get_total_hp() -> int:
    var bonus = 0
    for item in equipped.values():
        if item: bonus += item.get_stat("hp")
    return base_hp + bonus

func get_total_atk() -> int:
    var bonus = 0
    for item in equipped.values():
        if item: bonus += item.get_stat("atk")
    return base_atk + bonus

func get_combat_power() -> int:
    return int((get_total_atk() * 2 + get_total_def() + get_total_hp() / 10) * (1 + level * 0.05))
```

---

## ✅ 구현 체크리스트

### Phase 1 — 기본 화면 구조 (1~2일)
```
[ ] CharacterScreen 씬 생성
[ ] 6개 EquipmentSlot 배치 (좌 3, 우 3)
[ ] CharacterSprite 2x 스케일 표시
[ ] 하단 ItemGrid 5열 그리드 구성
[ ] 기본 데이터 연동 (CharacterData → UI)
```

### Phase 2 — 스탯 & 인터랙션 (1~2일)
```
[ ] 스탯 패널 실시간 업데이트
[ ] EXP 바 표시
[ ] 슬롯 탭 → 인벤토리 필터 연동
[ ] 아이템 탭 → 장착/해제 처리
[ ] 장비 상세 팝업
```

### Phase 3 — 비주얼 폴리시 (1일)
```
[ ] 희귀도별 슬롯 테두리 색상 적용
[ ] 착용중 아이템 체크뱃지 표시
[ ] 신규 아이템 NEW뱃지 표시
[ ] 장착 시 pop 애니메이션
[ ] 토스트 메시지
```

### Phase 4 — 최적화 (0.5일)
```
[ ] 인벤토리 아이템 풀링 (100개 이상 대비)
[ ] 씬 전환 시 부드러운 진입 애니메이션
[ ] 스탯 상세 팝업 정보 완성
```

---

## 📋 Cursor 프롬프트

### 프롬프트 1: 기본 씬 생성

```
UI_CHARACTER_SCREEN_SPEC.md의 씬 트리 구조를 참조해서
캐릭터 탭 화면(CharacterScreen.tscn)을 생성해줘.

요구사항:
1. 상단: 6개 장비 슬롯 + 중앙 캐릭터 스프라이트 (2x 스케일)
   - 좌측: 무기(상), 반지1(중), 목걸이1(하)
   - 우측: 방어구(상), 반지2(중), 목걸이2(하)
2. 중단: 레벨, EXP바, HP/ATK/DEF/SPD 스탯 패널
3. 하단: 5열 아이템 그리드 (스크롤)

씬 경로: scenes/UI/CharacterScreen.tscn
스크립트: scripts/UI/CharacterScreen.gd
```

### 프롬프트 2: 장비 슬롯 컴포넌트

```
UI_CHARACTER_SCREEN_SPEC.md의 "EquipmentSlot" 사양을 참조해서
EquipmentSlot.tscn 컴포넌트를 만들어줘.

표시:
- 아이템 착용 시: 아이템 아이콘 + 레벨 배지 + 희귀도 테두리
- 빈 슬롯 시: 슬롯 타입 아이콘 (30% 투명), 점선 테두리
- 착용중 표시: 우상단 초록 체크 뱃지

신호(Signal):
- slot_pressed(slot_id: String)
```

### 프롬프트 3: 아이템 인벤토리 그리드

```
UI_CHARACTER_SCREEN_SPEC.md의 "영역 ③" 사양을 참조해서
아이템 그리드를 구현해줘.

- 5열 그리드, 셀 크기 72×80px
- 상단 필터바: [전체][무기][방어구][반지][목걸이]
- 정렬 드롭다운: [등급순][강화순][최신순]
- 착용중 아이템은 밝기 70% + 체크 표시
- 스크롤 가능 (ScrollContainer 사용)
- 100개 이상 아이템 풀링 처리
```

---

**작성 완료 ✅ — Game팀이 이 스펙을 기반으로 Cursor에서 구현하면 됩니다.**
