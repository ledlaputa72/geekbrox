# 🎮 Dream Collector — Item Data Schema v1.0

**문서 상태:** Schema Definition  
**최종 업데이트:** 2026-03-05  
**작성자:** Atlas PM  
**목적:** 장비 데이터 구조 표준화 (JSON/CSV 호환)

---

## 📋 목차

1. [개요](#개요)
2. [아이템 데이터 필드](#아이템-데이터-필드)
3. [능력치 필드 정의](#능력치-필드-정의)
4. [스킬 필드 정의](#스킬-필드-정의)
5. [옵션 필드 정의](#옵션-필드-정의)
6. [아이템 타입별 필드 가이드](#아이템-타입별-필드-가이드)
7. [JSON 예시](#json-예시)
8. [CSV 형식 가이드](#csv-형식-가이드)

---

## 개요

### 아이템 데이터의 계층 구조

```
Item (장비 1개)
├─ Basic Info (기본 정보)
│  ├─ id
│  ├─ name
│  ├─ type
│  ├─ tier
│  ├─ level
│  └─ icon
├─ Base Stat (기본 능력치)
│  ├─ atk
│  ├─ def
│  ├─ hp
│  ├─ mana
│  ├─ critRate
│  ├─ evasionRate
│  ├─ dreamCollect
│  └─ ...
├─ Skill (고유 스킬)
│  ├─ skillId
│  ├─ skillName
│  ├─ skillDesc
│  ├─ manaCost
│  ├─ cooldown
│  ├─ damagePercent
│  └─ skillEffect
└─ Options (선택 옵션)
   ├─ optionId_1
   ├─ optionName_1
   ├─ optionDesc_1
   ├─ optionEffect_1
   └─ ...
```

---

## 아이템 데이터 필드

### 기본 정보 (Basic Info)

| 필드명 | 타입 | 필수 | 범위/형식 | 설명 | 예시 |
|--------|------|------|---------|------|------|
| `id` | string | O | `[type]_[name]_[tier]` | 고유 ID (게임 내 참조용) | `weapon_flame_spear_rare` |
| `name` | string | O | 1-50자 | 한글 장비명 | `폭염의 창` |
| `name_en` | string | X | 1-50자 | 영문 장비명 (참고용) | `Flame Spear` |
| `type` | string | O | `weapon`\|`armor`\|`ring`\|`necklace` | 장비 타입 | `weapon` |
| `tier` | string | O | `common`\|`uncommon`\|`rare`\|`epic`\|`legendary` | 등급 | `rare` |
| `level` | number | O | 1-10 | 장비 레벨 | `5` |
| `icon` | string | O | 이모지 또는 이미지 경로 | 아이콘 | `⚔️` 또는 `./assets/icon_weapon_001.png` |
| `rarity_color` | string | X | 16진 색상 또는 색상명 | 티어 색상 (UI 참고) | `#3B82F6` (파란색) |
| `description` | string | X | 0-200자 | 아이템 설명 (게임 내 표시) | `열정의 불꽃으로 강화된 창...` |

---

## 능력치 필드 정의

### 아이템이 제공하는 모든 능력치

| 필드명 | 타입 | 기본값 | 설명 | 적용 장비 | 예시 |
|--------|------|--------|------|---------|------|
| `atk` | number | 0 | 공격력 증가 | 무기, 반지 | `40` |
| `def` | number | 0 | 방어력 증가 | 방어구, 반지 | `40` |
| `hp` | number | 0 | 최대 체력 증가 | 방어구, 반지 | `150` |
| `mana` | number | 0 | 최대 마나 증가 | 반지, 무기(옵션) | `50` |
| `mana_regen` | number | 0 | 턴당 마나 회복량 | 반지(옵션) | `5` |
| `crit_rate` | number | 0 | 회심율 증가 (%) | 무기, 반지(옵션) | `8` |
| `crit_damage` | number | 0 | 회심 피해 증가 (%) | 무기(옵션) | `20` |
| `evasion_rate` | number | 0 | 회피율 증가 (%) | 반지, 목걸이(옵션) | `12` |
| `parry_rate` | number | 0 | 패링 확률 증가 (%) | 방어구(옵션), 목걸이 | `20` |
| `dream_collect` | number | 0 | 꿈 수집 보너스 (%) | 목걸이 | `25` |
| `status_resist` | number | 0 | 상태 이상 저항 (%) | 반지(옵션) | `20` |
| `auto_regen` | number | 0 | 턴당 HP 자동 회복 | 방어구 | `3` |
| `card_attack_bonus` | number | 0 | ATTACK 카드 능력 증가 (%) | 목걸이 | `30` |
| `card_skill_bonus` | number | 0 | SKILL 카드 능력 증가 (%) | 목걸이 | `20` |
| `card_power_bonus` | number | 0 | POWER 카드 능력 증가 (%) | 목걸이 | `25` |
| `card_curse_reduction` | number | 0 | CURSE 카드 피해 감소 (%) | 목걸이(옵션) | `40` |

### 능력치 적용 규칙

```json
{
  "baseStat": {
    "atk": 40,
    "def": 15,
    "crit_rate": 8,
    "mana": 0,
    "hp": 0
  }
}
```

**주의:**
- 모든 능력치는 **누적 계산** (여러 장비의 능력치 합산)
- 퍼센트 능력치는 최대 100%까지 누적 가능 (게임 밸런스)
- 고정값 능력치는 무제한 누적

---

## 스킬 필드 정의

### 장비 고유 스킬 정보

| 필드명 | 타입 | 필수 | 설명 | 예시 |
|--------|------|------|------|------|
| `skill.id` | string | O | 스킬 고유 ID | `skill_flame_spear_001` |
| `skill.name` | string | O | 스킬 한글명 | `폭열 돌격` |
| `skill.description` | string | O | 스킬 설명 (게임 내 표시) | `공격력 200% 데미지 + 꿈 수집 +50` |
| `skill.type` | string | O | `offensive`\|`defensive`\|`utility` | `offensive` |
| `skill.manaCost` | number | O | 마나 소비량 | `20` |
| `skill.cooldown` | number | O | 재사용 대기 (턴) | `2` |
| `skill.effect.damagePercent` | number | O | 데미지 (%) | `200` |
| `skill.effect.additionalEffect` | string | X | 추가 효과 | `꿈 수집 +50` |
| `skill.effect.duration` | number | X | 효과 지속 시간 (턴) | `1` |
| `skill.effect.probability` | number | X | 발동 확률 (%) | `100` |

### 스킬 예시

```json
{
  "skill": {
    "id": "skill_flame_spear_lv5",
    "name": "폭열 돌격",
    "description": "공격력 200% 데미지. 추가로 꿈 수집 +50",
    "type": "offensive",
    "manaCost": 20,
    "cooldown": 2,
    "effect": {
      "damagePercent": 200,
      "additionalEffect": "dream_collect_50",
      "duration": 1,
      "probability": 100
    }
  }
}
```

### 스킬 레벨별 진행 (동적 계산)

스킬의 효율은 **아이템 레벨**에 따라 자동 계산됨:

```
효율 = 100% + (아이템 레벨 - 1) × 5%

LV 1: 100%
LV 5: 120%
LV 10: 145%

실제 데미지 = 기본 데미지 × 효율
LV 5: 200% × 120% = 240%
LV 10: 200% × 145% = 290%
```

---

## 옵션 필드 정의

### 플레이어가 선택하는 옵션 (1개 선택)

| 필드명 | 타입 | 필수 | 설명 | 예시 |
|--------|------|------|------|------|
| `options[].id` | string | O | 옵션 고유 ID | `option_flame_spear_001` |
| `options[].name` | string | O | 옵션 한글명 | `공격력 +15%` |
| `options[].description` | string | O | 옵션 설명 | `전투 중 모든 공격 데미지 +15% 증가` |
| `options[].type` | string | O | `offensive`\|`defensive`\|`utility`\|`synergy` | `offensive` |
| `options[].effect` | object | O | 효과 정의 (아래 참고) | `{atk_bonus: 15}` |
| `options[].isSelected` | boolean | X | 선택 여부 (기본: false) | `true` |

### 옵션 효과 (Effect) 정의

```json
{
  "options": [
    {
      "id": "option_001",
      "name": "공격력 +15%",
      "description": "모든 공격의 데미지 +15% 증가",
      "type": "offensive",
      "effect": {
        "type": "stat_bonus",
        "stat": "atk",
        "value": 15,
        "unit": "percent"
      },
      "isSelected": true
    },
    {
      "id": "option_002",
      "name": "방어 관통 +30%",
      "description": "적 방어력 무시 30%",
      "type": "offensive",
      "effect": {
        "type": "armor_penetration",
        "value": 30,
        "unit": "percent"
      },
      "isSelected": false
    },
    {
      "id": "option_003",
      "name": "무기 스킬 +20%",
      "description": "이 장비의 스킬 효율 +20%",
      "type": "synergy",
      "effect": {
        "type": "skill_bonus",
        "skillId": "skill_flame_spear_lv5",
        "value": 20,
        "unit": "percent"
      },
      "isSelected": false
    }
  ]
}
```

### 옵션 효과 타입 (EffectType)

| 타입 | 설명 | 사용 예시 |
|------|------|---------|
| `stat_bonus` | 스탯 증가 | ATK +15%, HP +100 |
| `stat_percent` | 스탯 퍼센트 증가 | ATK +15% |
| `armor_penetration` | 방어력 무시 | 방어 관통 +30% |
| `skill_bonus` | 스킬 효율 증가 | 스킬 데미지 +20% |
| `skill_cooldown_reduce` | 스킬 재사용 대기 감소 | 재사용 -1턴 |
| `card_bonus` | 카드 능력 증가 | ATTACK 카드 +30% |
| `card_evasion` | 카드 회피 | SKILL 카드 회피 +40% |

---

## 아이템 타입별 필드 가이드

### 무기 (Weapon)

**필수 필드:**
- `atk` (필수)
- `crit_rate` (권장)
- `skill` (필수)

**일반적인 옵션:**
- 공격력 +X%
- 방어 관통 +X%
- 회심율 +X%

```json
{
  "id": "weapon_flame_spear_rare",
  "name": "폭염의 창",
  "type": "weapon",
  "tier": "rare",
  "level": 5,
  "icon": "⚔️",
  "baseStat": {
    "atk": 40,
    "crit_rate": 8
  },
  "skill": { /* ... */ },
  "options": [ /* ... */ ]
}
```

### 방어구 (Armor)

**필수 필드:**
- `def` (필수)
- `hp` (권장)
- `auto_regen` (권장)
- `skill` (필수)

**일반적인 옵션:**
- 방어력 +X%
- 최대 HP +X
- 피해 감소 +X%

```json
{
  "id": "armor_dragon_rare",
  "name": "용의 갑옷",
  "type": "armor",
  "tier": "rare",
  "level": 5,
  "icon": "🛡️",
  "baseStat": {
    "def": 40,
    "hp": 150,
    "auto_regen": 3
  },
  "skill": { /* ... */ },
  "options": [ /* ... */ ]
}
```

### 반지 (Ring)

**필수 필드:**
- `atk` 또는 `def` (둘 중 1개 필수)
- `mana` (권장)
- `skill` (필수)

**일반적인 옵션:**
- 무기 스킬 +X%
- 방어구 피해 감소 +X%
- 최대 마나 +X
- 스킬 재사용 -1턴

```json
{
  "id": "ring_strength_rare",
  "name": "힘의 반지",
  "type": "ring",
  "tier": "rare",
  "level": 5,
  "icon": "💍",
  "baseStat": {
    "atk": 20,
    "def": 18,
    "mana": 40
  },
  "skill": { /* ... */ },
  "options": [ /* ... */ ]
}
```

### 목걸이 (Necklace)

**필수 필드:**
- `card_attack_bonus` 또는 `card_skill_bonus` 등 (카드 관련 능력)
- `dream_collect` (권장)
- `skill` (필수)

**일반적인 옵션:**
- ATTACK 카드 +X%
- SKILL 카드 회피 +X%
- POWER 카드 확률 +X%
- CURSE 카드 피해 -X%

```json
{
  "id": "necklace_attack_rare",
  "name": "공격의 목걸이",
  "type": "necklace",
  "tier": "rare",
  "level": 5,
  "icon": "✨",
  "baseStat": {
    "card_attack_bonus": 25,
    "dream_collect": 15
  },
  "skill": { /* ... */ },
  "options": [ /* ... */ ]
}
```

---

## JSON 예시

### 완전한 장비 데이터 예시

```json
{
  "id": "weapon_flame_spear_rare_lv5",
  "name": "폭염의 창",
  "name_en": "Flame Spear",
  "type": "weapon",
  "tier": "rare",
  "level": 5,
  "icon": "⚔️",
  "rarity_color": "#3B82F6",
  "description": "열정의 불꽃으로 강화된 창. 높은 공격력과 회심율을 자랑한다.",
  
  "baseStat": {
    "atk": 40,
    "crit_rate": 8,
    "mana": 0,
    "def": 0,
    "hp": 0,
    "mana_regen": 0,
    "crit_damage": 0,
    "evasion_rate": 0,
    "parry_rate": 0,
    "dream_collect": 0,
    "status_resist": 0,
    "auto_regen": 0
  },

  "skill": {
    "id": "skill_flame_spear_lv5",
    "name": "폭열 돌격",
    "description": "공격력 200% 데미지. 추가로 꿈 수집 +50",
    "type": "offensive",
    "manaCost": 20,
    "cooldown": 2,
    "effect": {
      "damagePercent": 200,
      "additionalEffect": "dream_collect_50",
      "duration": 1,
      "probability": 100
    }
  },

  "options": [
    {
      "id": "option_flame_spear_001",
      "name": "공격력 +15%",
      "description": "전투 중 모든 공격 데미지 +15% 증가",
      "type": "offensive",
      "effect": {
        "type": "stat_bonus",
        "stat": "atk",
        "value": 15,
        "unit": "percent"
      },
      "isSelected": true
    },
    {
      "id": "option_flame_spear_002",
      "name": "방어 관통 +30%",
      "description": "적의 방어력을 30% 무시하고 공격",
      "type": "offensive",
      "effect": {
        "type": "armor_penetration",
        "value": 30,
        "unit": "percent"
      },
      "isSelected": false
    },
    {
      "id": "option_flame_spear_003",
      "name": "전투 시작 공격력 +10%",
      "description": "전투 시작 시 다음 턴까지 공격력 +10%",
      "type": "utility",
      "effect": {
        "type": "stat_bonus",
        "stat": "atk",
        "value": 10,
        "unit": "percent",
        "condition": "battle_start"
      },
      "isSelected": false
    }
  ]
}
```

---

## CSV 형식 가이드

### 기본 장비 정보 (items_basic.csv)

```csv
id,name,name_en,type,tier,level,icon,description
weapon_flame_spear_rare,폭염의 창,Flame Spear,weapon,rare,5,⚔️,열정의 불꽃으로 강화된 창...
armor_dragon_rare,용의 갑옷,Dragon Armor,armor,rare,5,🛡️,용의 가죽으로 만든 갑옷...
ring_strength_rare,힘의 반지,Strength Ring,ring,rare,5,💍,힘을 증폭시키는 신비한 반지...
necklace_attack_rare,공격의 목걸이,Attack Necklace,necklace,rare,5,✨,공격 카드를 강화하는 목걸이...
```

### 능력치 정보 (items_stats.csv)

```csv
item_id,atk,def,hp,mana,crit_rate,crit_damage,evasion_rate,parry_rate,dream_collect,status_resist,auto_regen
weapon_flame_spear_rare,40,0,0,0,8,0,0,0,0,0,0
armor_dragon_rare,0,40,150,0,0,0,0,0,0,0,3
ring_strength_rare,20,18,0,40,0,0,0,0,0,0,0
necklace_attack_rare,0,0,0,0,0,0,0,0,25,0,0
```

### 스킬 정보 (items_skills.csv)

```csv
item_id,skill_id,skill_name,skill_desc,skill_type,mana_cost,cooldown,damage_percent,additional_effect
weapon_flame_spear_rare,skill_flame_spear_lv5,폭열 돌격,공격력 200% + 꿈 수집 +50,offensive,20,2,200,dream_collect_50
armor_dragon_rare,skill_dragon_armor_lv5,용의 방어,패링 성공 → 반격,defensive,18,2,150,parry_counter
ring_strength_rare,skill_strength_ring_lv5,강화의 축복,모든 스탯 +30%,utility,25,1,0,all_stat_buff_30
necklace_attack_rare,skill_attack_necklace_lv5,공격 강화,다음 ATTACK 카드 +100%,utility,20,1,0,card_attack_100
```

### 옵션 정보 (items_options.csv)

```csv
item_id,option_id,option_name,option_desc,option_type,effect_type,effect_stat,effect_value,effect_unit
weapon_flame_spear_rare,option_flame_spear_001,공격력 +15%,공격 데미지 +15%,offensive,stat_bonus,atk,15,percent
weapon_flame_spear_rare,option_flame_spear_002,방어 관통 +30%,방어력 30% 무시,offensive,armor_penetration,,30,percent
weapon_flame_spear_rare,option_flame_spear_003,전투 시작 +10%,시작 시 공격력 +10%,utility,stat_bonus,atk,10,percent
armor_dragon_rare,option_dragon_armor_001,방어력 +15%,받는 피해 15% 감소,defensive,stat_bonus,def,15,percent
```

---

## 데이터 검증 규칙

### 필수 검증 사항

1. **ID 고유성**
   - 모든 `id` 필드는 게임 전체에서 고유해야 함
   - 형식: `[type]_[name]_[tier]_lv[level]`

2. **타입 검증**
   - `type`: weapon, armor, ring, necklace만 허용
   - `tier`: common, uncommon, rare, epic, legendary만 허용
   - `level`: 1-10 범위

3. **능력치 검증**
   - 모든 능력치는 0 이상의 숫자
   - 퍼센트 능력치는 0-200% 범위 (게임 밸런스)

4. **스킬 검증**
   - `manaCost`: 10 이상 (최소 조건)
   - `cooldown`: 0 이상
   - `damagePercent`: 0 이상

5. **옵션 검증**
   - 옵션은 최소 2개 이상 정의 필요
   - `isSelected`는 최대 1개만 true 가능

---

## 다음 단계

1. ✅ 이 스키마에 따라 **아이템 데이터 생성** (JSON)
2. ⏳ 이 스키마에 따라 **아이템 CSV 변환** (스프레드시트 호환)
3. ⏳ **캐릭터 데이터 스키마** 정의 (별도 문서)
4. ⏳ **캐릭터 데이터 생성**

---

**파일 위치:** `/Users/stevemacbook/Projects/geekbrox/teams/game/workspace/data/ITEM_DATA_SCHEMA.md`
