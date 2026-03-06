# 🎮 Dream Collector — Card Data Schema v1.0

**문서 상태:** Schema Definition  
**최종 업데이트:** 2026-03-05  
**작성자:** Atlas PM  
**목적:** 카드 데이터 구조 표준화 (JSON/CSV 호환)

---

## 📋 목차

1. [개요](#개요)
2. [카드 기본 정보](#카드-기본-정보)
3. [4가지 카드 종류](#4가지-카드-종류)
4. [카드 레벨 & 강화](#카드-레벨--강화)
5. [카드 효과 (Effect)](#카드-효과-effect)
6. [카드 조합 (Combo)](#카드-조합-combo)
7. [카드와 장비의 연동](#카드와-장비의-연동)
8. [JSON 예시](#json-예시)
9. [CSV 형식 가이드](#csv-형식-가이드)

---

## 개요

### 카드 시스템의 역할

Dream Collector의 **카드 시스템**은 게임의 핵심 메커니즘입니다:

```
전투 흐름:
1. 카드 선택 (매 턴 1~2개 카드 선택)
   ↓
2. 카드 효과 발동 (선택한 카드에 따라 다름)
   ├─ ATTACK: 적에게 데미지
   ├─ SKILL: 특수 효과
   ├─ POWER: 강력한 효과 (높은 리스크)
   └─ CURSE: 악화 효과 (자신 또는 적)
   ↓
3. 결과 반영 (스탯 변화, 상태 이상 등)
```

### 카드 데이터의 계층 구조

```
Card (카드 1개)
├─ Basic Info (기본 정보)
│  ├─ id
│  ├─ name
│  ├─ cardType
│  ├─ rarity
│  ├─ icon
│  └─ level
├─ Base Effect (기본 효과)
│  ├─ effectType
│  ├─ targetType
│  ├─ baseValue
│  └─ description
├─ Stats (카드의 스탯 영향)
│  ├─ damageValue
│  ├─ healValue
│  ├─ buffEffect
│  └─ debuffEffect
├─ Equipment Integration (장비 연동)
│  ├─ bonusFromNecklace
│  ├─ affectedByRing
│  └─ affectedByWeapon
├─ Upgrade (강화 정보)
│  ├─ upgradeLevel
│  ├─ upgradeProgress
│  └─ requiredMaterial
└─ Acquisition (획득 정보)
   ├─ obtainedFrom
   ├─ acquisitionDate
   └─ quantity
```

---

## 카드 기본 정보

### Basic Info 필드

| 필드명 | 타입 | 필수 | 범위/형식 | 설명 | 예시 |
|--------|------|------|---------|------|------|
| `id` | string | O | `card_[name]_[type]_[index]` | 고유 카드 ID | `card_flame_strike_attack_001` |
| `name` | string | O | 1-30자 | 카드 한글명 | `불꽃 공격` |
| `name_en` | string | X | 1-30자 | 카드 영문명 (참고용) | `Flame Strike` |
| `cardType` | string | O | `ATTACK`\|`SKILL`\|`POWER`\|`CURSE` | 카드 종류 | `ATTACK` |
| `rarity` | string | O | `common`\|`uncommon`\|`rare`\|`epic`\|`legendary` | 등급 | `rare` |
| `rarity_color` | string | X | 16진 색상 또는 색상명 | 티어 색상 (UI 참고) | `#3B82F6` |
| `icon` | string | O | 이모지 또는 이미지 경로 | 카드 아이콘 | `🔥` 또는 `./assets/card_flame.png` |
| `level` | number | O | 1-10 | 카드 레벨 | `5` |
| `description` | string | O | 0-200자 | 카드 설명 (게임 내 표시) | `불꽃으로 적을 공격한다. 데미지 180%` |
| `flavor_text` | string | X | 0-300자 | 카드의 배경 스토리 | `오래된 꿈에서 나온 불꽃...` |

---

## 4가지 카드 종류

### 1️⃣ ATTACK 카드

**역할:** 적에게 데미지를 입히는 기본 카드

**특징:**
- 가장 기본적이고 자주 사용됨
- 데미지 계산: (캐릭터 ATK + 무기 스탯) × 카드 데미지% × 목걸이 보너스
- 저위험, 안정적

**필드:**

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `baseEffect.damagePercent` | number | 기본 데미지 (%) | `180` |
| `baseEffect.targetType` | string | 대상 (single/all) | `single` |
| `baseEffect.accuracy` | number | 명중률 (%) | `100` |
| `baseEffect.critChance` | number | 회심 확률 (%) | `15` |

**예시:**

```json
{
  "id": "card_flame_strike_attack_001",
  "name": "불꽃 공격",
  "cardType": "ATTACK",
  "rarity": "rare",
  "level": 5,
  "icon": "🔥",
  "description": "적을 불꽃으로 공격한다. 데미지 180%",
  "baseEffect": {
    "effectType": "damage",
    "damagePercent": 180,
    "targetType": "single",
    "accuracy": 100,
    "critChance": 15
  }
}
```

### 2️⃣ SKILL 카드

**역할:** 특수 효과를 제공하는 카드 (버프, 회복, 패링 등)

**특징:**
- 다양한 효과 제공
- 회피 가능 (목걸이로 회피율 증가)
- 중위험, 높은 전략성

**필드:**

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `baseEffect.skillType` | string | 스킬 타입 (buff/heal/parry/etc) | `heal` |
| `baseEffect.value` | number | 효과 수치 | `150` |
| `baseEffect.duration` | number | 효과 지속 (턴) | `2` |
| `baseEffect.evasionRate` | number | 회피율 (%) | `40` |

**예시:**

```json
{
  "id": "card_healing_light_skill_001",
  "name": "치유의 빛",
  "cardType": "SKILL",
  "rarity": "uncommon",
  "level": 3,
  "icon": "✨",
  "description": "자신을 치유한다. HP 150 회복",
  "baseEffect": {
    "effectType": "heal",
    "skillType": "heal",
    "value": 150,
    "duration": 1,
    "evasionRate": 0
  }
}
```

### 3️⃣ POWER 카드

**역할:** 강력한 효과를 제공하지만, 높은 리스크가 있는 카드

**특징:**
- 매우 강한 효과 (회피 불가, 필수 맞음)
- 높은 대미지 또는 강력한 버프
- 높은 위험, 높은 보상

**필드:**

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `baseEffect.powerValue` | number | 강력 효과 수치 | `300` |
| `baseEffect.unavoidable` | boolean | 회피 불가 여부 | `true` |
| `baseEffect.riskLevel` | string | 위험도 (high/very_high) | `high` |
| `baseEffect.cooldown` | number | 재사용 대기 (턴) | `3` |

**예시:**

```json
{
  "id": "card_meteor_strike_power_001",
  "name": "유성 낙하",
  "cardType": "POWER",
  "rarity": "rare",
  "level": 5,
  "icon": "☄️",
  "description": "엄청난 운석 공격. 데미지 300%. 회피 불가. 3턴 대기",
  "baseEffect": {
    "effectType": "damage",
    "powerValue": 300,
    "unavoidable": true,
    "riskLevel": "high",
    "cooldown": 3,
    "targetType": "single"
  }
}
```

### 4️⃣ CURSE 카드

**역할:** 악화 효과를 주는 카드 (자신에게 또는 적에게)

**특징:**
- 자신을 약화시키는 경우도 있음
- 적을 약화시키는 경우도 있음
- 전략적 사용 필요 (목걸이로 영향 감소 가능)

**필드:**

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `baseEffect.curseType` | string | 저주 타입 (self/enemy) | `enemy` |
| `baseEffect.debuffType` | string | 약화 종류 (poison/stun/etc) | `poison` |
| `baseEffect.debuffValue` | number | 약화 수치 | `50` |
| `baseEffect.debuffDuration` | number | 약화 지속 (턴) | `3` |
| `baseEffect.damageReduction` | number | 목걸이로 감소 가능한 피해 (%) | `40` |

**예시:**

```json
{
  "id": "card_poison_cloud_curse_001",
  "name": "독 구름",
  "cardType": "CURSE",
  "rarity": "uncommon",
  "level": 3,
  "icon": "☠️",
  "description": "적을 독으로 중독시킨다. 3턴간 매턴 50 데미지",
  "baseEffect": {
    "effectType": "debuff",
    "curseType": "enemy",
    "debuffType": "poison",
    "debuffValue": 50,
    "debuffDuration": 3,
    "damageReduction": 40
  }
}
```

---

## 카드 레벨 & 강화

### 카드 레벨 진행

카드는 **LV 1 ~ LV 10**까지 강화 가능합니다.

```
LV 1: 기본 상태
LV 3: 효과 +15%
LV 5: 효과 +30% (현재 레벨)
LV 10: 효과 +50%

효율 계산: 100% + (레벨 - 1) × 5%
```

### 강화 필드

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `upgrade.currentLevel` | number | 현재 레벨 | `5` |
| `upgrade.upgradeExp` | number | 현재 레벨 강화 경험치 | `3500` |
| `upgrade.expToNextLevel` | number | 다음 레벨까지 필요 경험치 | `5000` |
| `upgrade.requiredMaterial` | string | 강화 재료 | `dream_essence` |
| `upgrade.requiredMaterialCount` | number | 필요 재료 개수 | `20` |
| `upgrade.goldCost` | number | 강화 골드 비용 | `10000` |

**강화 예시:**

```json
{
  "upgrade": {
    "currentLevel": 5,
    "upgradeExp": 3500,
    "expToNextLevel": 5000,
    "requiredMaterial": "dream_essence",
    "requiredMaterialCount": 20,
    "goldCost": 10000
  }
}
```

---

## 카드 효과 (Effect)

### 효과 타입 (EffectType)

| 효과 타입 | 설명 | 사용 카드 | 예시 |
|---------|------|---------|------|
| `damage` | 데미지 | ATTACK, POWER | 데미지 180% |
| `heal` | 회복 | SKILL | HP 150 회복 |
| `buff` | 버프 | SKILL | ATK +30% (2턴) |
| `debuff` | 약화 | CURSE | 독 피해 50/턴 |
| `parry` | 패링 | SKILL | 다음 공격 패링 → 반격 |
| `status_change` | 상태 변화 | CURSE | 기절 1턴 |

### 효과 계산 규칙

```
최종 효과 = 기본 효과 × 카드 레벨 효율 × 장비 보너스

예 (ATTACK 카드):
기본: 180%
레벨 5: 180% × 1.2 = 216%
목걸이 보너스 (+25%): 216% × 1.25 = 270%
최종 데미지: 캐릭터 ATK × 270%
```

---

## 카드 조합 (Combo)

### 개념

특정 카드들을 **특정 순서**로 연속 사용하면 **추가 보너스**가 발동됩니다.

### Combo 필드

| 필드명 | 타입 | 설명 | 예시 |
|--------|------|------|------|
| `combos[].id` | string | 조합 고유 ID | `combo_flame_explosion_001` |
| `combos[].name` | string | 조합 이름 | `화염 폭발` |
| `combos[].requiredCards` | array | 필요 카드 순서 | `["card_flame_strike_attack_001", "card_fireball_attack_002"]` |
| `combos[].cardCount` | number | 연속 카드 개수 | `2` |
| `combos[].bonusEffect` | object | 추가 보너스 | `{type: "damage_bonus", value: 50}` |
| `combos[].bonusDescription` | string | 보너스 설명 | `추가 데미지 50%` |

### 조합 예시

```json
{
  "combos": [
    {
      "id": "combo_flame_explosion",
      "name": "화염 폭발",
      "requiredCards": [
        "card_flame_strike_attack_001",
        "card_fireball_attack_002"
      ],
      "cardCount": 2,
      "bonusEffect": {
        "type": "damage_bonus",
        "value": 50
      },
      "bonusDescription": "2개 카드 연속 사용 시 추가 데미지 +50%"
    },
    {
      "id": "combo_shield_defense",
      "name": "완벽한 방어",
      "requiredCards": [
        "card_defense_skill_001",
        "card_healing_light_skill_001"
      ],
      "cardCount": 2,
      "bonusEffect": {
        "type": "damage_reduction",
        "value": 30
      },
      "bonusDescription": "방어+회복 조합 시 다음 3턴 피해 30% 감소"
    }
  ]
}
```

---

## 카드와 장비의 연동

### 목걸이의 카드 강화 방식

```
카드 능력 = 기본 효과 × (1 + 목걸이 보너스%)

예:
- ATTACK 카드 기본: 180% 데미지
- 목걸이 "공격의 목걸이" ATTACK +25%
- 최종: 180% × 1.25 = 225%
```

### Equipment Integration 필드

| 필드명 | 타입 | 설명 | 영향 받는 장비 | 예시 |
|--------|------|------|-------------|------|
| `equipmentIntegration.affectedByNecklace` | boolean | 목걸이 영향 여부 | 목걸이 | `true` |
| `equipmentIntegration.necklaceBonus` | string | 목걸이 보너스 종류 | 목걸이 | `card_attack_bonus` |
| `equipmentIntegration.affectedByRing` | boolean | 반지 영향 여부 | 반지(옵션) | `true` |
| `equipmentIntegration.ringBonus` | string | 반지 보너스 종류 | 반지(옵션) | `skill_duration_increase` |
| `equipmentIntegration.affectedByWeapon` | boolean | 무기 영향 여부 | 무기 | `false` |

### 카드-장비 연동 예시

```json
{
  "equipmentIntegration": {
    "affectedByNecklace": true,
    "necklaceBonus": "card_attack_bonus",
    "affectedByRing": true,
    "ringBonus": "skill_cooldown_reduce",
    "affectedByWeapon": false
  }
}
```

---

## JSON 예시

### 완전한 카드 데이터 예시

```json
{
  "id": "card_flame_strike_attack_001",
  "name": "불꽃 공격",
  "name_en": "Flame Strike",
  "cardType": "ATTACK",
  "rarity": "rare",
  "rarity_color": "#3B82F6",
  "icon": "🔥",
  "level": 5,
  "description": "불꽃으로 적을 공격한다. 데미지 180%",
  "flavor_text": "꿈에서 나온 뜨거운 불꽃이 적을 집어삼킨다.",

  "baseEffect": {
    "effectType": "damage",
    "damagePercent": 180,
    "targetType": "single",
    "accuracy": 100,
    "critChance": 15
  },

  "upgrade": {
    "currentLevel": 5,
    "upgradeExp": 3500,
    "expToNextLevel": 5000,
    "requiredMaterial": "dream_essence",
    "requiredMaterialCount": 20,
    "goldCost": 10000
  },

  "equipmentIntegration": {
    "affectedByNecklace": true,
    "necklaceBonus": "card_attack_bonus",
    "affectedByRing": false,
    "ringBonus": null,
    "affectedByWeapon": false
  },

  "acquisition": {
    "obtainedFrom": "dungeon_stage_5",
    "acquisitionDate": "2026-02-15",
    "quantity": 1
  }
}
```

---

## CSV 형식 가이드

### 카드 기본 정보 (cards_basic.csv)

```csv
id,name,name_en,cardType,rarity,icon,level,description
card_flame_strike_attack_001,불꽃 공격,Flame Strike,ATTACK,rare,🔥,5,불꽃으로 적을 공격한다. 데미지 180%
card_healing_light_skill_001,치유의 빛,Healing Light,SKILL,uncommon,✨,3,자신을 치유한다. HP 150 회복
card_meteor_strike_power_001,유성 낙하,Meteor Strike,POWER,rare,☄️,5,엄청난 운석 공격. 데미지 300%
card_poison_cloud_curse_001,독 구름,Poison Cloud,CURSE,uncommon,☠️,3,적을 독으로 중독시킨다. 3턴간 50 데미지
```

### 카드 효과 정보 (cards_effects.csv)

```csv
card_id,effect_type,base_value,target_type,duration,accuracy,crit_chance
card_flame_strike_attack_001,damage,180,single,1,100,15
card_healing_light_skill_001,heal,150,self,1,100,0
card_meteor_strike_power_001,damage,300,single,1,100,0
card_poison_cloud_curse_001,debuff,50,enemy,3,100,0
```

### 카드 강화 정보 (cards_upgrade.csv)

```csv
card_id,current_level,upgrade_exp,exp_to_next,required_material,material_count,gold_cost
card_flame_strike_attack_001,5,3500,5000,dream_essence,20,10000
card_healing_light_skill_001,3,2000,3000,dream_essence,15,7500
card_meteor_strike_power_001,5,4000,6000,dream_essence,25,12500
card_poison_cloud_curse_001,3,1500,2500,dream_essence,12,6000
```

### 카드-장비 연동 정보 (cards_equipment_integration.csv)

```csv
card_id,affected_by_necklace,necklace_bonus,affected_by_ring,ring_bonus,affected_by_weapon
card_flame_strike_attack_001,true,card_attack_bonus,false,,false
card_healing_light_skill_001,true,card_skill_bonus,true,skill_cooldown_reduce,false
card_meteor_strike_power_001,true,card_power_bonus,false,,false
card_poison_cloud_curse_001,true,card_curse_reduction,false,,false
```

---

## 데이터 검증 규칙

### 필수 검증 사항

1. **ID 고유성**
   - 모든 `id` 필드는 게임 전체에서 고유해야 함
   - 형식: `card_[name]_[type]_[index]`

2. **카드 타입 검증**
   - `cardType`: ATTACK, SKILL, POWER, CURSE만 허용

3. **레벨 범위**
   - `level`: 1-10 범위

4. **등급 검증**
   - `rarity`: common, uncommon, rare, epic, legendary만 허용

5. **효과 값 검증**
   - ATTACK 데미지: 50~400% 범위
   - 회복 값: 50~500 범위
   - 버프/약화: -100~100% 범위

6. **장비 연동 검증**
   - `equipmentIntegration`의 보너스 타입이 해당 장비에서 제공 가능한 타입인지 확인

---

## 카드 종류별 데이터 샘플

### ATTACK 카드 (공격)
```
카드명: 불꽃 공격
효과: 데미지 180%
등급: 레어
목걸이 보너스: O (ATTACK 카드 +25%)
특징: 가장 기본적인 공격 카드
```

### SKILL 카드 (스킬)
```
카드명: 치유의 빛
효과: HP 150 회복
등급: 고급
목걸이 보너스: O (SKILL 카드 회피 +40%)
특징: 회피 가능, 전략적 사용
```

### POWER 카드 (강력함)
```
카드명: 유성 낙하
효과: 데미지 300%, 회피 불가
등급: 레어
목걸이 보너스: O (POWER 카드 +25%)
특징: 강력하지만 3턴 재사용 대기
```

### CURSE 카드 (저주)
```
카드명: 독 구름
효과: 적 독 상태 (3턴)
등급: 고급
목걸이 보너스: O (CURSE 피해 -40%)
특징: 전략적 약화, 목걸이로 영향 감소 가능
```

---

## 다음 단계

1. ✅ ITEM_DATA_SCHEMA.md — 완료
2. ✅ CHARACTER_DATA_SCHEMA.md — 완료
3. ✅ CARD_DATA_SCHEMA.md — 완료
4. ⏳ **cards_data.json** — 전체 카드 데이터 생성 (200종)
5. ⏳ **items_data.json** — 전체 아이템 데이터 생성
6. ⏳ **characters_data.json** — 캐릭터 데이터 생성

---

**파일 위치:** `/Users/stevemacbook/Projects/geekbrox/teams/game/workspace/data/CARD_DATA_SCHEMA.md`
