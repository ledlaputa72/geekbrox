# 🎮 Dream Collector — Character Data Schema v1.0

**문서 상태:** Schema Definition  
**최종 업데이트:** 2026-03-05  
**작성자:** Atlas PM  
**목적:** 캐릭터 데이터 구조 표준화 (JSON/CSV 호환)

---

## 📋 목차

1. [개요](#개요)
2. [캐릭터 기본 정보](#캐릭터-기본-정보)
3. [캐릭터 기본 스탯](#캐릭터-기본-스탯)
4. [캐릭터 특성 (Trait)](#캐릭터-특성-trait)
5. [캐릭터 능력 (Ability)](#캐릭터-능력-ability)
6. [착용 장비 (Equipped Items)](#착용-장비-equipped-items)
7. [경험치 & 레벨 시스템](#경험치--레벨-시스템)
8. [캐릭터 상태 (Status)](#캐릭터-상태-status)
9. [JSON 예시](#json-예시)
10. [CSV 형식 가이드](#csv-형식-가이드)

---

## 개요

### 캐릭터 데이터의 계층 구조

```
Character (캐릭터)
├─ Basic Info (기본 정보)
│  ├─ id
│  ├─ name
│  ├─ characterClass
│  ├─ level
│  ├─ profileImage
│  └─ createdAt
├─ Base Stat (기본 스탯)
│  ├─ hp
│  ├─ atk
│  ├─ def
│  ├─ mana
│  ├─ critRate
│  ├─ evasionRate
│  └─ ... (기본값, 착용 장비 제외)
├─ Traits (특성)
│  ├─ traitId_1
│  ├─ traitName_1
│  └─ ...
├─ Abilities (능력)
│  ├─ abilityId_1
│  ├─ abilityName_1
│  └─ ...
├─ Equipped Items (착용 장비)
│  ├─ weapon
│  ├─ armor
│  ├─ ring_1
│  ├─ ring_2
│  ├─ necklace_1
│  └─ necklace_2
├─ Experience & Level
│  ├─ currentExp
│  ├─ expToNextLevel
│  ├─ totalExp
│  └─ levelProgression
└─ Status (현재 상태)
   ├─ currentHp
   ├─ currentMana
   ├─ statusAilments
   └─ buffs/debuffs
```

---

## 캐릭터 기본 정보

### Basic Info 필드

| 필드명 | 타입 | 필수 | 범위/형식 | 설명 | 예시 |
|--------|------|------|---------|------|------|
| `id` | string | O | `char_[name]_[index]` | 고유 캐릭터 ID | `char_nox_001` |
| `name` | string | O | 1-20자 | 캐릭터 이름 | `녹스` (Nox) |
| `characterClass` | string | O | `dreamer`\|`collector`\|`weaver` | 캐릭터 클래스 | `dreamer` |
| `description` | string | X | 0-200자 | 캐릭터 설명 | `꿈을 잃은 신비한 존재...` |
| `level` | number | O | 1-100 | 현재 레벨 | `20` |
| `tier` | string | O | `common`\|`uncommon`\|`rare`\|`epic`\|`legendary` | 캐릭터 등급 | `rare` |
| `rarity_color` | string | X | 16진 색상 또는 색상명 | 티어 색상 (UI 참고) | `#3B82F6` |
| `profileImage` | string | X | 이모지 또는 이미지 경로 | 프로필 이미지 | `🧑‍🎨` 또는 `./assets/char_nox.png` |
| `createdAt` | string | X | ISO 8601 형식 | 생성 날짜 | `2026-01-15T10:30:00Z` |
| `lastUpdatedAt` | string | X | ISO 8601 형식 | 최종 수정 날짜 | `2026-03-05T20:00:00Z` |

---

## 캐릭터 기본 스탯

### Base Stat 필드 (착용 장비 제외한 순수 기본값)

| 필드명 | 타입 | 기본값 | 설명 | 영향 받는 요소 | 예시 |
|--------|------|--------|------|-------------|------|
| `baseStat.maxHp` | number | 500 | 최대 체력 (기본값) | 장비로 강화 가능 | `500` |
| `baseStat.atk` | number | 100 | 공격력 (기본값) | 무기 + 반지로 강화 | `100` |
| `baseStat.def` | number | 50 | 방어력 (기본값) | 방어구 + 반지로 강화 | `50` |
| `baseStat.mana` | number | 60 | 최대 마나 (기본값) | 반지로 강화 가능 | `60` |
| `baseStat.critRate` | number | 0 | 회심율 기본 (%) | 무기로 강화 | `0` |
| `baseStat.evasionRate` | number | 0 | 회피율 기본 (%) | 반지/목걸이로 강화 | `0` |
| `baseStat.parryRate` | number | 10 | 패링 확률 기본 (%) | 방어구/목걸이로 강화 | `10` |
| `baseStat.dreamCollect` | number | 0 | 꿈 수집 보너스 기본 (%) | 목걸이로 강화 | `0` |
| `baseStat.statusResist` | number | 0 | 상태 이상 저항 기본 (%) | 반지로 강화 | `0` |

### 실제 스탯 계산 (장비 포함)

```
최종 스탯 = 기본값 + 착용 장비 보너스

예:
- 기본 ATK: 100
- 무기 +40
- 반지 +20
- 반지 옵션(무기 스킬 +20%) ← 무기 스킬에만 적용

최종 ATK = 100 + 40 + 20 = 160
무기 스킬 데미지 = 기본 데미지 × 1.2 (반지 옵션 적용)
```

### 캐릭터 클래스별 기본 스탯 가이드

| 클래스 | maxHp | atk | def | mana | 설명 |
|--------|-------|-----|-----|------|------|
| `dreamer` | 600 | 90 | 45 | 80 | HP와 마나가 많음 (마법사형) |
| `collector` | 500 | 100 | 50 | 60 | 균형잡힌 스탯 (균형형) |
| `weaver` | 450 | 110 | 55 | 70 | 공격력이 높음 (전사형) |

---

## 캐릭터 특성 (Trait)

### 개념

**특성(Trait)**은 캐릭터가 **고정적으로 가지고 있는** 고유한 성질입니다. 게임 시작 시 정해지며, 변경 불가능합니다.

### Trait 필드

| 필드명 | 타입 | 필수 | 설명 | 예시 |
|--------|------|------|------|------|
| `traits[].id` | string | O | 특성 고유 ID | `trait_dream_affinity_001` |
| `traits[].name` | string | O | 특성 이름 | `꿈의 친화력` |
| `traits[].description` | string | O | 특성 설명 | `꿈과 관련된 모든 효과 +20%` |
| `traits[].type` | string | O | `passive`\|`active` | `passive` |
| `traits[].effect` | object | O | 특성 효과 | `{type: "stat_bonus", stat: "dream_collect", value: 20}` |
| `traits[].rarity` | string | X | `common`\|`rare`\|`epic` | `rare` |

### 특성 예시

```json
{
  "traits": [
    {
      "id": "trait_dream_affinity",
      "name": "꿈의 친화력",
      "description": "꿈 수집 +20%. 꿈 관련 카드 능력 +15%",
      "type": "passive",
      "effect": {
        "type": "stat_bonus",
        "stat": "dream_collect",
        "value": 20,
        "unit": "percent"
      },
      "rarity": "rare"
    },
    {
      "id": "trait_memory_void",
      "name": "기억의 공백",
      "description": "모든 피해 -10% 받음. 받는 회복 +10% 증가",
      "type": "passive",
      "effect": {
        "type": "damage_reduction",
        "value": 10,
        "unit": "percent"
      },
      "rarity": "epic"
    }
  ]
}
```

### 특성 타입 분류

| 특성 타입 | 설명 | 활성화 조건 |
|---------|------|----------|
| `passive` | 항상 활성화되는 특성 | 특성 보유 시 자동 |
| `active` | 조건부로 활성화되는 특성 | 특정 상황 (전투 중, 특정 카드 사용 시 등) |

---

## 캐릭터 능력 (Ability)

### 개념

**능력(Ability)**은 캐릭터가 **배울 수 있는** 전투 기술입니다. 레벨 업과 함께 해제되거나, 특정 조건으로 배웁니다.

### Ability 필드

| 필드명 | 타입 | 필수 | 설명 | 예시 |
|--------|------|------|------|------|
| `abilities[].id` | string | O | 능력 고유 ID | `ability_memory_recall_001` |
| `abilities[].name` | string | O | 능력 이름 | `기억 회상` |
| `abilities[].description` | string | O | 능력 설명 | `지난 5턴의 카드 중 1개 재선택` |
| `abilities[].type` | string | O | `combat`\|`utility`\|`passive` | `combat` |
| `abilities[].manaCost` | number | O | 마나 소비량 | `30` |
| `abilities[].cooldown` | number | O | 재사용 대기 (턴) | `2` |
| `abilities[].unlockedAtLevel` | number | X | 해제 레벨 | `15` |
| `abilities[].unlockedBy` | string | X | 해제 조건 (ID) | `quest_shadow_memory` |
| `abilities[].effect` | object | O | 능력 효과 | `{type: "card_reshuffle", cardCount: 1}` |
| `abilities[].isUnlocked` | boolean | O | 해제 여부 | `true` |

### 능력 예시

```json
{
  "abilities": [
    {
      "id": "ability_memory_recall",
      "name": "기억 회상",
      "description": "지난 5턴의 카드 중 원하는 카드 1개를 재선택합니다.",
      "type": "combat",
      "manaCost": 30,
      "cooldown": 2,
      "unlockedAtLevel": 15,
      "unlockedBy": null,
      "effect": {
        "type": "card_reshuffle",
        "cardCount": 1,
        "source": "last_5_turns"
      },
      "isUnlocked": true
    },
    {
      "id": "ability_dream_shield",
      "name": "꿈의 보호막",
      "description": "꿈 에너지로 보호막을 생성해 다음 공격 피해 50% 감소",
      "type": "combat",
      "manaCost": 25,
      "cooldown": 3,
      "unlockedAtLevel": 25,
      "unlockedBy": null,
      "effect": {
        "type": "barrier",
        "damageReduction": 50,
        "duration": 1
      },
      "isUnlocked": false
    }
  ]
}
```

### 능력 타입 분류

| 능력 타입 | 설명 | 사용 시점 |
|---------|------|---------|
| `combat` | 전투 중 사용 가능 | 턴 기반 전투 |
| `utility` | 전투 외 사용 | 메뉴 화면, 탐험 등 |
| `passive` | 항상 활성화 | 특정 조건에서 자동 발동 |

---

## 착용 장비 (Equipped Items)

### Equipped Items 필드

| 필드명 | 타입 | 필수 | 설명 | 예시 |
|--------|------|------|------|------|
| `equippedItems.weapon` | string | X | 착용 무기 ID | `weapon_flame_spear_rare_lv5` |
| `equippedItems.armor` | string | X | 착용 방어구 ID | `armor_dragon_rare_lv5` |
| `equippedItems.ring_1` | string | X | 착용 반지 1 ID | `ring_strength_rare_lv5` |
| `equippedItems.ring_2` | string | X | 착용 반지 2 ID | `null` (미착용) |
| `equippedItems.necklace_1` | string | X | 착용 목걸이 1 ID | `necklace_attack_rare_lv5` |
| `equippedItems.necklace_2` | string | X | 착용 목걸이 2 ID | `null` (미착용) |

### 장비 착용 규칙

```
필수 슬롯 (최소 1개 필수):
├─ weapon: 1개
├─ armor: 1개

선택 슬롯 (0개 이상):
├─ ring_1, ring_2: 최대 2개
└─ necklace_1, necklace_2: 최대 2개

예시:
├─ 최소 구성: 무기 1 + 방어구 1 (2개 슬롯)
├─ 권장 구성: 무기 1 + 방어구 1 + 반지 2 + 목걸이 2 (6개 슬롯)
```

### 착용 장비 예시

```json
{
  "equippedItems": {
    "weapon": "weapon_flame_spear_rare_lv5",
    "armor": "armor_dragon_rare_lv5",
    "ring_1": "ring_strength_rare_lv5",
    "ring_2": null,
    "necklace_1": "necklace_attack_rare_lv5",
    "necklace_2": null
  }
}
```

---

## 경험치 & 레벨 시스템

### Experience 필드

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `experience.currentExp` | number | 현재 레벨에서의 경험치 | `3500` |
| `experience.expToNextLevel` | number | 다음 레벨까지 필요 경험치 | `5000` |
| `experience.totalExp` | number | 게임 시작부터 누적 경험치 | `125000` |
| `experience.levelProgression` | number | 현재 레벨 진행도 (%) | `70` |

### 레벨 진행 가이드

```
레벨 1: 0 EXP (시작)
레벨 2: 1,000 EXP 필요 (누적 1,000)
레벨 3: 1,200 EXP 필요 (누적 2,200)
...
레벨 20: 4,500 EXP 필요 (누적 125,000)
...
레벨 100: 20,000 EXP 필요 (최고 레벨)

EXP 공식: 다음 레벨 필요 EXP = 1000 + (현재 레벨 - 1) × 200
```

### Experience 예시

```json
{
  "experience": {
    "currentExp": 3500,
    "expToNextLevel": 5000,
    "totalExp": 125000,
    "levelProgression": 70
  }
}
```

---

## 캐릭터 상태 (Status)

### 전투 중 실시간 상태

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `status.currentHp` | number | 현재 체력 | `906` |
| `status.currentMana` | number | 현재 마나 | `45` |
| `status.isAlive` | boolean | 생존 여부 | `true` |
| `status.isBattling` | boolean | 전투 중 여부 | `true` |
| `status.statusAilments[]` | array | 상태 이상 목록 | `["poison", "stun"]` |
| `status.buffs[]` | object | 버프 효과 목록 | `[{id: "buff_atk_20", value: 20, duration: 2}]` |
| `status.debuffs[]` | object | 디버프 효과 목록 | `[{id: "debuff_def_30", value: -30, duration: 3}]` |

### 상태 이상 (Status Ailment) 목록

| 상태 이상 | 코드 | 설명 | 지속 시간 |
|---------|------|------|---------|
| 독 | `poison` | 턴마다 데미지 | 3턴 |
| 기절 | `stun` | 다음 턴 행동 불가 | 1턴 |
| 약화 | `weakness` | 공격력 -30% | 2턴 |
| 방어 감소 | `armor_break` | 방어력 -50% | 3턴 |
| 혼란 | `confusion` | 행동 예측 불가 | 2턴 |

### 상태 예시

```json
{
  "status": {
    "currentHp": 906,
    "currentMana": 45,
    "isAlive": true,
    "isBattling": true,
    "statusAilments": ["poison"],
    "buffs": [
      {
        "id": "buff_atk_20",
        "name": "공격력 증가",
        "value": 20,
        "unit": "percent",
        "duration": 2
      }
    ],
    "debuffs": [
      {
        "id": "debuff_poison",
        "name": "독",
        "damagePerTurn": 50,
        "duration": 3
      }
    ]
  }
}
```

---

## JSON 예시

### 완전한 캐릭터 데이터 예시

```json
{
  "id": "char_nox_001",
  "name": "녹스",
  "characterClass": "dreamer",
  "description": "꿈을 잃은 신비한 존재. 자신의 기억을 찾기 위해 꿈들을 수집한다.",
  "level": 20,
  "tier": "rare",
  "rarity_color": "#3B82F6",
  "profileImage": "🧑‍🎨",
  "createdAt": "2026-01-15T10:30:00Z",
  "lastUpdatedAt": "2026-03-05T20:00:00Z",

  "baseStat": {
    "maxHp": 600,
    "atk": 90,
    "def": 45,
    "mana": 80,
    "critRate": 0,
    "evasionRate": 0,
    "parryRate": 10,
    "dreamCollect": 0,
    "statusResist": 0
  },

  "traits": [
    {
      "id": "trait_dream_affinity",
      "name": "꿈의 친화력",
      "description": "꿈 수집 +20%. 꿈 관련 카드 능력 +15%",
      "type": "passive",
      "effect": {
        "type": "stat_bonus",
        "stat": "dream_collect",
        "value": 20,
        "unit": "percent"
      },
      "rarity": "rare"
    },
    {
      "id": "trait_memory_void",
      "name": "기억의 공백",
      "description": "모든 피해 -10% 받음. 받는 회복 +10% 증가",
      "type": "passive",
      "effect": {
        "type": "damage_reduction",
        "value": 10,
        "unit": "percent"
      },
      "rarity": "epic"
    }
  ],

  "abilities": [
    {
      "id": "ability_memory_recall",
      "name": "기억 회상",
      "description": "지난 5턴의 카드 중 원하는 카드 1개를 재선택합니다.",
      "type": "combat",
      "manaCost": 30,
      "cooldown": 2,
      "unlockedAtLevel": 15,
      "unlockedBy": null,
      "effect": {
        "type": "card_reshuffle",
        "cardCount": 1,
        "source": "last_5_turns"
      },
      "isUnlocked": true
    },
    {
      "id": "ability_dream_shield",
      "name": "꿈의 보호막",
      "description": "꿈 에너지로 보호막을 생성해 다음 공격 피해 50% 감소",
      "type": "combat",
      "manaCost": 25,
      "cooldown": 3,
      "unlockedAtLevel": 25,
      "unlockedBy": null,
      "effect": {
        "type": "barrier",
        "damageReduction": 50,
        "duration": 1
      },
      "isUnlocked": false
    }
  ],

  "equippedItems": {
    "weapon": "weapon_flame_spear_rare_lv5",
    "armor": "armor_dragon_rare_lv5",
    "ring_1": "ring_strength_rare_lv5",
    "ring_2": null,
    "necklace_1": "necklace_attack_rare_lv5",
    "necklace_2": null
  },

  "experience": {
    "currentExp": 3500,
    "expToNextLevel": 5000,
    "totalExp": 125000,
    "levelProgression": 70
  },

  "status": {
    "currentHp": 906,
    "currentMana": 45,
    "isAlive": true,
    "isBattling": false,
    "statusAilments": [],
    "buffs": [],
    "debuffs": []
  }
}
```

---

## CSV 형식 가이드

### 기본 캐릭터 정보 (characters_basic.csv)

```csv
id,name,characterClass,level,tier,profileImage,description
char_nox_001,녹스,dreamer,20,rare,🧑‍🎨,꿈을 잃은 신비한 존재...
char_collector_001,수집가,collector,18,uncommon,👤,꿈을 모으는 신비한 존재...
char_weaver_001,직조사,weaver,22,rare,🎭,꿈을 짜는 신비한 존재...
```

### 기본 스탯 정보 (characters_stats.csv)

```csv
char_id,maxHp,atk,def,mana,critRate,evasionRate,parryRate,dreamCollect,statusResist
char_nox_001,600,90,45,80,0,0,10,0,0
char_collector_001,500,100,50,60,0,0,10,0,0
char_weaver_001,450,110,55,70,5,0,10,0,0
```

### 착용 장비 정보 (characters_equipment.csv)

```csv
char_id,weapon,armor,ring_1,ring_2,necklace_1,necklace_2
char_nox_001,weapon_flame_spear_rare_lv5,armor_dragon_rare_lv5,ring_strength_rare_lv5,,necklace_attack_rare_lv5,
char_collector_001,weapon_ice_sword_rare_lv4,armor_leather_uncommon_lv3,ring_wisdom_uncommon_lv4,,necklace_dream_rare_lv5,
char_weaver_001,weapon_fire_axe_rare_lv6,armor_steel_rare_lv5,ring_strength_rare_lv5,ring_wisdom_rare_lv4,necklace_attack_rare_lv5,necklace_defense_rare_lv4
```

### 특성 정보 (characters_traits.csv)

```csv
char_id,trait_id,trait_name,trait_description,trait_type,trait_rarity
char_nox_001,trait_dream_affinity,꿈의 친화력,꿈 수집 +20%...,passive,rare
char_nox_001,trait_memory_void,기억의 공백,모든 피해 -10%...,passive,epic
char_collector_001,trait_hoard_instinct,수집 본능,아이템 획득 +25%...,passive,rare
```

### 능력 정보 (characters_abilities.csv)

```csv
char_id,ability_id,ability_name,ability_desc,ability_type,mana_cost,cooldown,unlocked_at_level,is_unlocked
char_nox_001,ability_memory_recall,기억 회상,지난 5턴 카드 재선택,combat,30,2,15,true
char_nox_001,ability_dream_shield,꿈의 보호막,피해 50% 감소,combat,25,3,25,false
char_collector_001,ability_collect_essence,정수 수집,꿈 20% 추가 획득,utility,20,1,10,true
```

---

## 데이터 검증 규칙

### 필수 검증 사항

1. **ID 고유성**
   - 모든 `id` 필드는 게임 전체에서 고유해야 함

2. **클래스 검증**
   - `characterClass`: dreamer, collector, weaver만 허용

3. **레벨 범위**
   - `level`: 1-100 범위

4. **스탯 검증**
   - 모든 기본 스탯은 0 이상
   - 현재 HP는 최대 HP 이하

5. **장비 연결성**
   - `equippedItems`의 모든 ID는 `ITEM_DATA_SCHEMA`에 존재해야 함

6. **경험치 검증**
   - `currentExp` < `expToNextLevel`
   - `totalExp` >= 0

---

## 다음 단계

1. ✅ 이 스키마에 따라 **캐릭터 데이터 생성** (JSON)
2. ⏳ ITEM_DATA_SCHEMA에 따라 **전체 아이템 데이터 생성** (JSON)
3. ⏳ 두 스키마를 통합하여 **게임 데이터 통합 JSON** 생성

---

**파일 위치:** `/Users/stevemacbook/Projects/geekbrox/teams/game/workspace/data/CHARACTER_DATA_SCHEMA.md`
