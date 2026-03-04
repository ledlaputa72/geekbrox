# 🎮 Dream Collector — 장비 시스템 Godot 구현 설계서

**작성:** Game팀 (구현 설계)  
**기준:** CHARACTER_EQUIPMENT_SYSTEM.md + CHARACTER_TRAITS_ENHANCED.md  
**버전:** v1.0  
**상태:** 📋 구현 설계 완료

---

## 📌 개요

**목적:** Godot 4.x에서 장비 시스템을 구현하기 위한 기술 설계서

**범위:**
- 장비 데이터 구조 (66종)
- 캐릭터 장비 슬롯 시스템
- 기본 공격(ATB) 데미지 공식
- 특성 계산 로직
- UI 설계 (4개 슬롯 표시, 강화 화면 등)

---

## 📂 파일 구조

```
dream-collector/
├── godot/dream-collector/
│   ├── src/
│   │   ├── systems/
│   │   │   ├── equipment/
│   │   │   │   ├── EquipmentDatabase.gd ✨ NEW
│   │   │   │   ├── Equipment.gd ✨ NEW
│   │   │   │   ├── EquipmentSlot.gd ✨ NEW
│   │   │   │   ├── EquipmentTraits.gd ✨ NEW
│   │   │   │   └── EquipmentSetEffect.gd ✨ NEW
│   │   │   │
│   │   │   ├── combat/
│   │   │   │   ├── CombatCalculator.gd (수정)
│   │   │   │   └── ATBSystem.gd (수정)
│   │   │   │
│   │   │   └── character/
│   │   │       ├── Character.gd (수정)
│   │   │       └── CharacterTraits.gd (수정)
│   │   │
│   │   └── ui/
│   │       ├── equipment/
│   │       │   ├── EquipmentScreen.gd ✨ NEW
│   │       │   ├── EquipmentSlotPanel.gd ✨ NEW
│   │       │   ├── EquipmentListPanel.gd ✨ NEW
│   │       │   ├── EquipmentEnhancePanel.gd ✨ NEW
│   │       │   ├── EquipmentTraitsPanel.gd ✨ NEW
│   │       │   └── SetEffectDisplay.gd ✨ NEW
│   │       │
│   │       └── combat/
│   │           └── ATBDisplay.gd (수정 - 장비 효과 표시)
│   │
│   ├── data/
│   │   ├── equipment/
│   │   │   ├── equipment_database.json ✨ NEW
│   │   │   └── set_effects.json ✨ NEW
│   │   │
│   │   └── cards/
│   │       └── cards_200_v2.json (기존)
│   │
│   └── scenes/
│       ├── ui/equipment/
│       │   ├── EquipmentScreen.tscn ✨ NEW
│       │   ├── EquipmentSlotPanel.tscn ✨ NEW
│       │   ├── EquipmentListPanel.tscn ✨ NEW
│       │   └── EquipmentEnhancePanel.tscn ✨ NEW
│       │
│       └── character/
│           └── Character.tscn (수정)
```

---

## 🔧 1. EquipmentDatabase.gd 설계

### 데이터 구조

```gdscript
class_name EquipmentDatabase
extends Node

# 장비 데이터 로드
var equipment_data: Dictionary = {}
var set_effects: Dictionary = {}

# 5가지 슬롯 (제로 인덱스 고려, 0=weapon, 1=armor, 2=accessory, 3=offhand)
const SLOT_NAMES = ["weapon", "armor", "accessory", "offhand"]
const SLOT_COUNT = 4

func _ready() -> void:
	load_equipment_database()
	load_set_effects()

func load_equipment_database() -> void:
	# ~/godot/dream-collector/data/equipment/equipment_database.json 로드
	var file = FileAccess.open("user://data/equipment/equipment_database.json", FileAccess.READ)
	if file:
		equipment_data = JSON.parse_string(file.get_as_text())

func get_equipment(equipment_id: String) -> Dictionary:
	# 장비 ID로 장비 데이터 반환
	if equipment_id in equipment_data:
		return equipment_data[equipment_id]
	return {}

func get_all_equipment_by_slot(slot: int) -> Array:
	# 슬롯별 모든 장비 반환
	var slot_name = SLOT_NAMES[slot]
	var result = []
	for equip_id in equipment_data.keys():
		if equipment_data[equip_id]["slot"] == slot_name:
			result.append(equipment_data[equip_id])
	return result

func get_equipment_by_rarity(rarity: String) -> Array:
	# 희귀도별 장비 반환
	var result = []
	for equip_id in equipment_data.keys():
		if equipment_data[equip_id]["rarity"] == rarity:
			result.append(equipment_data[equip_id])
	return result
```

### equipment_database.json 구조

```json
{
  "weapon_001": {
    "id": "weapon_001",
    "name": "검의 파편",
    "name_kr": "검의 파편",
    "slot": "weapon",
    "type": "sword",
    "rarity": "COMMON",
    "stats": {
      "atk": 10,
      "cri": 0,
      "spd": 0
    },
    "effects": [],
    "description": "가장 기본적인 검"
  },
  "weapon_002": {
    "id": "weapon_002",
    "name": "Iron Sword",
    "name_kr": "철 검",
    "slot": "weapon",
    "type": "sword",
    "rarity": "COMMON",
    "stats": {
      "atk": 15,
      "cri": 2,
      "spd": 0
    },
    "effects": [],
    "description": "철로 만든 일반적인 검"
  }
  // ... 66종 모두
}
```

---

## 🎯 2. Equipment.gd 클래스 설계

```gdscript
class_name Equipment
extends Resource

@export var id: String
@export var name: String
@export var name_kr: String
@export var slot: String  # weapon, armor, accessory, offhand
@export var type: String  # sword, axe, staff, plate, robe, ring, etc.
@export var rarity: String  # COMMON, RARE, SPECIAL, LEGENDARY
@export var base_stats: Dictionary  # atk, def, cri, spd, hp, res
@export var effects: Array[String]  # 특수 효과
@export var enhancement_level: int = 0  # +0 ~ +10

func get_enhanced_stats() -> Dictionary:
	"""강화 수준에 따른 최종 스탯 반환"""
	var enhanced = base_stats.duplicate()
	
	# 각 강화 레벨마다 5~10% 증가
	var enhancement_bonus = 1.0 + (enhancement_level * 0.05)
	for stat in enhanced.keys():
		if stat in ["atk", "def", "hp", "cri", "spd", "res"]:
			enhanced[stat] *= enhancement_bonus
	
	return enhanced

func can_enhance() -> bool:
	"""강화 가능 여부 확인"""
	return enhancement_level < 10

func enhance() -> bool:
	"""강화 시도 (위험도 있음)"""
	if not can_enhance():
		return false
	
	# +7부터 실패 가능
	if enhancement_level >= 7:
		var fail_rate = (enhancement_level - 6) * 0.15  # 7:15%, 8:30%, 9:45%, 10:60%
		if randf() < fail_rate:
			enhancement_level -= 1  # 강화 단계 하락
			return false
	
	enhancement_level += 1
	return true

func get_enhancement_cost() -> int:
	"""강화에 필요한 골드"""
	var base_cost = 1000
	return int(base_cost * pow(1.5, enhancement_level))  # 지수적 증가
```

---

## 👥 3. Character.gd 수정 (장비 슬롯 추가)

```gdscript
class_name Character
extends Node

# 기존 속성들
var name: String
var level: int = 1
var hp: int = 100
var max_hp: int = 100

# ✨ 장비 슬롯 추가
var equipped_weapon: Equipment = null
var equipped_armor: Equipment = null
var equipped_accessory: Equipment = null
var equipped_offhand: Equipment = null

# 장비 배열 (관리 편의)
var equipment_slots: Array[Equipment] = [null, null, null, null]  # [weapon, armor, accessory, offhand]

# ✨ 특성 시스템
var traits: CharacterTraits = CharacterTraits.new()

func equip_weapon(equipment: Equipment) -> bool:
	if equipment.slot != "weapon":
		return false
	equipped_weapon = equipment
	equipment_slots[0] = equipment
	update_combat_stats()
	return true

func equip_armor(equipment: Equipment) -> bool:
	if equipment.slot != "armor":
		return false
	equipped_armor = equipment
	equipment_slots[1] = equipment
	update_combat_stats()
	return true

func equip_accessory(equipment: Equipment) -> bool:
	if equipment.slot != "accessory":
		return false
	equipped_accessory = equipment
	equipment_slots[2] = equipment
	update_combat_stats()
	return true

func equip_offhand(equipment: Equipment) -> bool:
	if equipment.slot != "offhand":
		return false
	equipped_offhand = equipment
	equipment_slots[3] = equipment
	update_combat_stats()
	return true

func get_all_equipped_equipment() -> Array[Equipment]:
	"""모든 장착된 장비 반환"""
	var result: Array[Equipment] = []
	for slot in equipment_slots:
		if slot != null:
			result.append(slot)
	return result

func update_combat_stats() -> void:
	"""장비 변경 시 전투 스탯 재계산"""
	recalculate_base_attack()
	recalculate_defense()
	check_active_set_effects()
```

---

## ⚔️ 4. 기본 공격 데미지 공식

```gdscript
class_name CombatCalculator
extends Node

# 기본 공격 데미지 계산
func calculate_basic_attack(attacker: Character, defender: Character) -> int:
	"""기본 공격(ATB) 데미지 계산"""
	
	# Step 1: 기본 공격력 (무기 + 보조 무기)
	var weapon_atk = 0.0
	if attacker.equipped_weapon:
		weapon_atk = attacker.equipped_weapon.get_enhanced_stats()["atk"]
	
	var offhand_dmg = 0.0
	if attacker.equipped_offhand:
		offhand_dmg = attacker.equipped_offhand.get_enhanced_stats().get("dmg", 0)
	
	var base_damage = weapon_atk + offhand_dmg
	
	# Step 2: 무기 마스터리 적용 (+5% ~ +30%)
	var weapon_mastery = attacker.traits.get_weapon_mastery_bonus()
	base_damage *= (1.0 + weapon_mastery)
	
	# Step 3: 악세서리 동조 적용 (+0% ~ +20% 시너지)
	var accessory_synergy = attacker.traits.get_accessory_synergy_bonus()
	base_damage *= (1.0 + accessory_synergy)
	
	# Step 4: 장비 연쇄 적용 (+0% ~ +20%)
	var set_effect = attacker.traits.get_equipment_set_bonus()
	base_damage *= (1.0 + set_effect)
	
	# Step 5: 치명타 판정
	var critical_multiplier = 1.0
	var crit_chance = 0.0
	if attacker.equipped_weapon:
		crit_chance = attacker.equipped_weapon.get_enhanced_stats()["cri"]
	crit_chance += attacker.traits.get_weapon_mastery_critical()  # 추가 치명타율
	
	if randf() < crit_chance / 100.0:
		critical_multiplier = 1.5  # 50% 추가 데미지
	
	var final_damage = int(base_damage * critical_multiplier)
	
	# Step 6: 방어력 적용 (감소)
	var defense = calculate_defense(defender)
	final_damage -= defense
	
	return max(1, final_damage)  # 최소 1 데미지

func calculate_defense(character: Character) -> int:
	"""방어력 계산"""
	var base_def = 0.0
	if character.equipped_armor:
		base_def = character.equipped_armor.get_enhanced_stats()["def"]
	
	# 방어 강화 특성 적용
	var defense_mastery = character.traits.get_defense_mastery_bonus()
	base_def *= (1.0 + defense_mastery)
	
	# 악세서리 방어력 보너스
	if character.equipped_accessory:
		var acc_def = character.equipped_accessory.get_enhanced_stats().get("def", 0)
		base_def += acc_def
	
	return int(base_def)

func calculate_basic_attack_with_recovery(attacker: Character, defender: Character) -> Dictionary:
	"""기본 공격 + 회복 (흡혈 효과 포함)"""
	var damage = calculate_basic_attack(attacker, defender)
	var recovery = 0
	
	# 흡혈 효과 (악세서리에서)
	if attacker.equipped_accessory:
		var effects = attacker.equipped_accessory.effects
		if "lifesteal" in effects:
			recovery = int(damage * 0.3)  # 30% 회복
	
	return {
		"damage": damage,
		"recovery": recovery,
		"crit": false  # 치명타 여부는 별도 처리
	}
```

---

## 🌟 5. CharacterTraits.gd (특성 계산)

```gdscript
class_name CharacterTraits
extends Node

var character: Character = null

# 특성별 계산
func get_weapon_mastery_bonus() -> float:
	"""무기 마스터리: 무기 ATK +5% ~ +30%"""
	if not character or not character.equipped_weapon:
		return 0.0
	
	var enhancement = character.equipped_weapon.enhancement_level
	# Lv1(+0): +5%, Lv2(+2): +10%, Lv3(+4): +15%, ... Lv6(+10): +30%
	return (enhancement + 1) * 0.05

func get_weapon_mastery_critical() -> float:
	"""무기 마스터리: 추가 치명타율"""
	if not character or not character.equipped_weapon:
		return 0.0
	
	var enhancement = character.equipped_weapon.enhancement_level
	return enhancement  # +0: 1%, +1: 2%, ... +10: 10%

func get_defense_mastery_bonus() -> float:
	"""방어 강화: 방어구 DEF +5% ~ +30%"""
	if not character or not character.equipped_armor:
		return 0.0
	
	var enhancement = character.equipped_armor.enhancement_level
	return (enhancement + 1) * 0.05

func get_accessory_synergy_bonus() -> float:
	"""악세서리 동조: 시너지 +0% ~ +20%"""
	if not character:
		return 0.0
	
	var accessory_count = 1 if character.equipped_accessory else 0
	# 현재는 1개만 지원, 향후 다중 악세서리 추가 가능
	return 0.0  # 1개: 0%, 2개: +10%, 3개: +20%

func get_equipment_set_bonus() -> float:
	"""장비 연쇄: 세트 효과 +0% ~ +20%"""
	# 나중에 세트 효과 로직 구현
	return 0.0
```

---

## 🎨 6. UI 설계

### 장비 슬롯 화면 (EquipmentScreen.tscn)

```
┌─────────────────────────────────────┐
│         [캐릭터명] 장비 화면          │
├─────────────────────────────────────┤
│                                     │
│  [Weapon Slot]    [Armor Slot]      │
│   무기: 빛의 검     갑옷: 신성한 갑옷  │
│   ATK +30%         DEF +30%         │
│                                     │
│  [Accessory Slot] [OffHand Slot]    │
│   반지: 왕의 반지   방패: 신성한 방패  │
│   시너지 +20%      추가 +200%        │
│                                     │
├─────────────────────────────────────┤
│  📊 최종 스탯:                       │
│  공격력: 65.52 (기본 35 + 보너스)     │
│  방어력: 37.4 (기본 25 + 보너스)      │
│  추가 공격: 35% 확률                  │
│                                     │
├─────────────────────────────────────┤
│  🎯 활성 특성:                       │
│  ✓ 무기 마스터리 Lv6 (+30%)         │
│  ✓ 방어 강화 Lv6 (+30%)             │
│  ✓ 악세서리 동조 Lv1 (+0%)          │
│  ✓ 듀얼 웰드 Lv6 (+200%)            │
│  ✓ 장비 연쇄 (검 세트 4/4) +20%     │
│                                     │
├─────────────────────────────────────┤
│  [장비 변경]  [강화]  [판매]  [닫기]  │
└─────────────────────────────────────┘
```

### 강화 화면 (EquipmentEnhancePanel.tscn)

```
┌─────────────────────────────────────┐
│      빛의 검 강화 (+10)              │
├─────────────────────────────────────┤
│  강화도: [████████████░░] +10 (MAX) │
│                                     │
│  현재 스탯:                         │
│  ATK: 30 → 30 (최대)               │
│  CRI: 15% → 15% (최대)             │
│  SPD: +20% → +20% (최대)           │
│                                     │
│  다음 강화 비용: 불가능 (MAX)       │
│  성공률: N/A                        │
│                                     │
├─────────────────────────────────────┤
│  [뒤로]                [닫기]        │
└─────────────────────────────────────┘
```

---

## 📊 7. 데이터 플로우 다이어그램

```
게임 시작
  ↓
EquipmentDatabase 로드 (equipment_database.json)
  ↓
Character 생성 + 기본 장비 장착
  ↓
장비 변경 이벤트
  ↓
Character.update_combat_stats() 호출
  ├─ Character.recalculate_base_attack()
  ├─ Character.recalculate_defense()
  └─ Character.check_active_set_effects()
  ↓
CombatCalculator.calculate_basic_attack()
  ├─ 기본 공격력 (무기 + 보조)
  ├─ 무기 마스터리 보너스 적용
  ├─ 악세서리 동조 보너스 적용
  ├─ 장비 연쇄 보너스 적용
  ├─ 치명타 판정
  └─ 방어력 감소
  ↓
최종 데미지 반환 → ATBSystem에서 적용
```

---

## 🧪 8. 구현 체크리스트

### Phase 1: 데이터 구조 (1-2일)
- [ ] equipment_database.json 생성 (66종 모두)
- [ ] set_effects.json 생성 (4가지 세트)
- [ ] EquipmentDatabase.gd 구현
- [ ] Equipment.gd 클래스 구현

### Phase 2: 캐릭터 통합 (1-2일)
- [ ] Character.gd 수정 (4개 슬롯 추가)
- [ ] CharacterTraits.gd 구현 (5가지 특성)
- [ ] EquipmentSetEffect.gd 구현

### Phase 3: 전투 시스템 (1-2일)
- [ ] CombatCalculator.gd 수정 (기본 공격 공식)
- [ ] ATBSystem.gd 수정 (장비 효과 반영)
- [ ] 테스트: 기본 공격 데미지 계산 검증

### Phase 4: UI 구현 (2-3일)
- [ ] EquipmentScreen.tscn 구현
- [ ] EquipmentSlotPanel.gd 구현
- [ ] EquipmentListPanel.gd 구현
- [ ] EquipmentEnhancePanel.gd 구현
- [ ] EquipmentTraitsPanel.gd 구현
- [ ] 테스트: UI 상호작용 검증

### Phase 5: 통합 & QA (1-2일)
- [ ] 전체 게임 흐름에서 테스트
- [ ] 장비 변경 → 데미지 변화 검증
- [ ] 강화 시스템 테스트
- [ ] 세트 효과 활성화 검증
- [ ] 성능 최적화

---

## 💾 파일 저장 위치

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/
├── EQUIPMENT_SYSTEM_COST_ANALYSIS.md
├── CHARACTER_EQUIPMENT_SYSTEM.md
├── CHARACTER_TRAITS_ENHANCED.md
└── EQUIPMENT_IMPLEMENTATION_DESIGN.md (이 파일)

~/Projects/geekbrox/teams/game/godot/dream-collector/
├── src/systems/equipment/
│   ├── EquipmentDatabase.gd
│   ├── Equipment.gd
│   ├── EquipmentSlot.gd
│   ├── EquipmentTraits.gd
│   └── EquipmentSetEffect.gd
├── src/systems/combat/
│   └── CombatCalculator.gd (수정)
├── data/equipment/
│   ├── equipment_database.json
│   └── set_effects.json
└── scenes/ui/equipment/
    ├── EquipmentScreen.tscn
    ├── EquipmentSlotPanel.tscn
    ├── EquipmentListPanel.tscn
    └── EquipmentEnhancePanel.tscn
```

---

**상태:** ✅ 구현 설계 완료

**다음:** OPS팀 밸런스 검증 진행
