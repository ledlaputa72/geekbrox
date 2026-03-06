# 📊 Item Acquisition Data Schema v1.0

**문서 상태:** Data Schema  
**최종 업데이트:** 2026-03-06  
**목적:** 아이템 획득 시스템의 데이터 구조 정의

---

## 📋 목차

1. [Monster Drop Table](#monster-drop-table)
2. [Quest Reward Table](#quest-reward-table)
3. [Merchant Inventory](#merchant-inventory)
4. [Gacha Config](#gacha-config)
5. [Login Reward](#login-reward)
6. [Event Rewards](#event-rewards)
7. [Milestone Rewards](#milestone-rewards)
8. [Data Format Specifications](#data-format-specifications)

---

## Monster Drop Table

### 스키마 정의

```json
{
  "monsters": [
    {
      "monsterId": "string (unique)",
      "monsterName": "string",
      "monsterNameEn": "string",
      "level": "number (1-50+)",
      "monsterType": "enum (slime/goblin/dragon/etc)",
      
      "baseReward": {
        "gold": "number (기본 골드)",
        "goldVariation": [number, number] (최소, 최대),
        "experience": "number"
      },
      
      "itemDropTable": [
        {
          "itemId": "string",
          "itemName": "string",
          "probability": "number (0-100, %)",
          "tier": "enum (common/uncommon/rare/epic/legendary)",
          "dropLimit": "number (월간 최대 드롭 수, 선택사항)"
        }
      ],
      
      "dropCondition": {
        "minLevel": "number",
        "maxLevel": "number",
        "stageRange": [number, number],
        "requireSpecialCondition": "boolean",
        "specialConditionDesc": "string (예: 'hard mode only')"
      },
      
      "guaranteeSystem": {
        "dropGuaranteeLevel": "number (몇 마리 처치 후 아이템 보증)",
        "guaranteeItem": "string (보증 아이템 ID)",
        "gachaId": "string (뽑기 풀 ID, null면 드롭 전용)"
      }
    }
  ]
}
```

### 예시

```json
{
  "monsterId": "slime_lv1",
  "monsterName": "약한 슬라임",
  "monsterNameEn": "Weak Slime",
  "level": 1,
  "monsterType": "slime",
  
  "baseReward": {
    "gold": 10,
    "goldVariation": [5, 20],
    "experience": 5
  },
  
  "itemDropTable": [
    {
      "itemId": "weapon_crystal_sword_common_lv1",
      "itemName": "크리스탈 검",
      "probability": 15,
      "tier": "common",
      "dropLimit": null
    },
    {
      "itemId": "armor_leather_common_lv1",
      "itemName": "가죽 갑옷",
      "probability": 15,
      "tier": "common",
      "dropLimit": null
    }
  ],
  
  "dropCondition": {
    "minLevel": 1,
    "maxLevel": 5,
    "stageRange": [1, 5],
    "requireSpecialCondition": false,
    "specialConditionDesc": null
  },
  
  "guaranteeSystem": {
    "dropGuaranteeLevel": 50,
    "guaranteeItem": "weapon_crystal_sword_common_lv1",
    "gachaId": "gacha_common_weapons"
  }
}
```

---

## Quest Reward Table

### 스키마 정의

```json
{
  "quests": [
    {
      "questId": "string (unique)",
      "questName": "string",
      "questType": "enum (daily/weekly/event/story)",
      
      "requirement": {
        "targetType": "enum (kill_monsters/clear_stages/collect_dreams/etc)",
        "targetCount": "number",
        "targetSpecific": "string (특정 몬스터/스테이지, 선택사항)"
      },
      
      "reward": {
        "gold": "number",
        "experience": "number",
        "items": [
          {
            "itemId": "string",
            "itemName": "string",
            "quantity": "number (보통 1)",
            "tier": "enum"
          }
        ],
        "gems": "number (보석, 0이면 없음)",
        "specialReward": "object (선택사항, 예: treasure_box)"
      },
      
      "resetCycle": "enum (daily/weekly/none)",
      "completionLimit": "number (월간 완료 제한, null이면 무제한)",
      "unlockCondition": {
        "minLevel": "number",
        "requireStageClearing": "number (선택사항)"
      }
    }
  ]
}
```

### 예시

```json
{
  "questId": "daily_kill_10_monsters",
  "questName": "몬스터 10마리 처치",
  "questType": "daily",
  
  "requirement": {
    "targetType": "kill_monsters",
    "targetCount": 10,
    "targetSpecific": null
  },
  
  "reward": {
    "gold": 50,
    "experience": 30,
    "items": [
      {
        "itemId": "armor_leather_common_lv1",
        "itemName": "가죽 갑옷",
        "quantity": 1,
        "tier": "common"
      }
    ],
    "gems": 0,
    "specialReward": null
  },
  
  "resetCycle": "daily",
  "completionLimit": 1,
  "unlockCondition": {
    "minLevel": 1,
    "requireStageClearing": null
  }
}
```

---

## Merchant Inventory

### 스키마 정의

```json
{
  "merchants": [
    {
      "merchantId": "string (unique)",
      "merchantName": "string",
      "merchantType": "enum (normal/rare/black_market/guild)",
      "merchantLocation": "string",
      
      "inventory": [
        {
          "slot": "number (1-10)",
          "itemId": "string",
          "itemName": "string",
          "tier": "enum",
          "quantity": "number (보통 1, 0이면 품절)",
          
          "price": {
            "currency": "enum (gold/gems)",
            "basePrice": "number",
            "actualPrice": "number (할인/상승 적용)"
          },
          
          "restockSchedule": {
            "resetCycle": "enum (daily/weekly/monthly/never)",
            "restockTime": "string (HH:MM UTC)",
            "lastRestockTime": "string (ISO 8601)"
          },
          
          "limitPerPlayer": "number (플레이어당 구매 제한, null이면 무제한)",
          "totalLimitPerSeason": "number (시즌 구매 제한)"
        }
      ],
      
      "accessRequirement": {
        "minLevel": "number",
        "requireStageClear": "number (선택사항)",
        "requireGuildLevel": "number (길드 상인용)"
      }
    }
  ]
}
```

### 예시

```json
{
  "merchantId": "merchant_normal_village",
  "merchantName": "마을 상인",
  "merchantType": "normal",
  "merchantLocation": "Village - 중앙 광장",
  
  "inventory": [
    {
      "slot": 1,
      "itemId": "weapon_crystal_sword_common_lv1",
      "itemName": "크리스탈 검",
      "tier": "common",
      "quantity": 3,
      
      "price": {
        "currency": "gold",
        "basePrice": 1000,
        "actualPrice": 1000
      },
      
      "restockSchedule": {
        "resetCycle": "daily",
        "restockTime": "00:00",
        "lastRestockTime": "2026-03-06T00:00:00Z"
      },
      
      "limitPerPlayer": 3,
      "totalLimitPerSeason": null
    }
  ],
  
  "accessRequirement": {
    "minLevel": 1,
    "requireStageClear": null,
    "requireGuildLevel": null
  }
}
```

---

## Gacha Config

### 스키마 정의

```json
{
  "gachas": [
    {
      "gachaId": "string (unique)",
      "gachaName": "string",
      "gachaType": "enum (gold_gacha/gem_gacha/event_gacha)",
      
      "cost": {
        "currency": "enum (gold/gems)",
        "singlePull": "number",
        "discountPullPacks": [
          {
            "pullCount": "number",
            "totalCost": "number",
            "discountPercent": "number"
          }
        ]
      },
      
      "probability": {
        "common": "number (0-100, %)",
        "uncommon": "number",
        "rare": "number",
        "epic": "number",
        "legendary": "number"
      },
      
      "pitySystem": {
        "guaranteeRarityLevel": "enum (rare/epic/legendary)",
        "guaranteePullCount": "number (보증 뽑기 횟수)",
        "enableGuarantee": "boolean"
      },
      
      "itemPool": [
        {
          "itemId": "string",
          "itemName": "string",
          "tier": "enum",
          "baseWeight": "number (상대 가중치)",
          "pickupBoost": "number (1.0 = 기본, 2.0 = 2배)",
          "isPeriodLimited": "boolean"
        }
      ],
      
      "scheduleAndPickup": {
        "gachaStartDate": "string (ISO 8601)",
        "gachaEndDate": "string (ISO 8601)",
        "pickupItemId": "string (선택사항)",
        "pickupStartDate": "string (ISO 8601, 선택사항)",
        "pickupEndDate": "string (ISO 8601, 선택사항)",
        "isActive": "boolean"
      }
    }
  ]
}
```

### 예시

```json
{
  "gachaId": "gacha_gold_common",
  "gachaName": "골드 뽑기 - 일반",
  "gachaType": "gold_gacha",
  
  "cost": {
    "currency": "gold",
    "singlePull": 500,
    "discountPullPacks": [
      {
        "pullCount": 10,
        "totalCost": 4500,
        "discountPercent": 10
      },
      {
        "pullCount": 50,
        "totalCost": 20000,
        "discountPercent": 20
      }
    ]
  },
  
  "probability": {
    "common": 60,
    "uncommon": 35,
    "rare": 4.5,
    "epic": 0.5,
    "legendary": 0
  },
  
  "pitySystem": {
    "guaranteeRarityLevel": "rare",
    "guaranteePullCount": 50,
    "enableGuarantee": true
  },
  
  "itemPool": [
    {
      "itemId": "weapon_crystal_sword_common_lv1",
      "itemName": "크리스탈 검",
      "tier": "common",
      "baseWeight": 100,
      "pickupBoost": 1.0,
      "isPeriodLimited": false
    }
  ],
  
  "scheduleAndPickup": {
    "gachaStartDate": "2026-01-01T00:00:00Z",
    "gachaEndDate": null,
    "pickupItemId": null,
    "pickupStartDate": null,
    "pickupEndDate": null,
    "isActive": true
  }
}
```

---

## Login Reward

### 스키마 정의

```json
{
  "loginRewards": [
    {
      "day": "number (1-31)",
      "rewardType": "enum (gold/items/gems/all)",
      
      "reward": {
        "gold": "number (0이면 없음)",
        "items": [
          {
            "itemId": "string",
            "itemName": "string",
            "tier": "enum",
            "quantity": "number"
          }
        ],
        "gems": "number (0이면 없음)"
      },
      
      "specialCondition": {
        "isSpecialDay": "boolean",
        "specialDayDesc": "string (예: 'weekend bonus')"
      }
    }
  ],
  
  "resetCycle": "enum (daily/monthly)",
  "accumulativeMilestone": [
    {
      "cumulativeDays": "number",
      "milestoneReward": "object (item/gems/etc)"
    }
  ]
}
```

### 예시

```json
{
  "loginRewards": [
    {
      "day": 1,
      "rewardType": "gold",
      "reward": {
        "gold": 100,
        "items": [],
        "gems": 0
      },
      "specialCondition": {
        "isSpecialDay": false,
        "specialDayDesc": null
      }
    },
    {
      "day": 7,
      "rewardType": "all",
      "reward": {
        "gold": 500,
        "items": [
          {
            "itemId": "armor_leather_common_lv1",
            "itemName": "가죽 갑옷",
            "tier": "uncommon",
            "quantity": 1
          }
        ],
        "gems": 10
      },
      "specialCondition": {
        "isSpecialDay": true,
        "specialDayDesc": "Weekly milestone reward"
      }
    }
  ],
  
  "resetCycle": "monthly",
  "accumulativeMilestone": [
    {
      "cumulativeDays": 30,
      "milestoneReward": {
        "itemId": "ring_stat_rare_lv5",
        "itemName": "희귀 반지",
        "tier": "rare",
        "gems": 100
      }
    }
  ]
}
```

---

## Event Rewards

### 스키마 정의

```json
{
  "events": [
    {
      "eventId": "string (unique)",
      "eventName": "string",
      "eventType": "enum (seasonal/collaboration/celebration/bugfix)",
      
      "duration": {
        "startDate": "string (ISO 8601)",
        "endDate": "string (ISO 8601)",
        "isActive": "boolean"
      },
      
      "rewardTier": [
        {
          "tier": "number (1-5, 진행도)",
          "requirement": "string (예: '1000 points')",
          "reward": {
            "gold": "number",
            "items": [
              {
                "itemId": "string",
                "itemName": "string",
                "rarity": "enum",
                "quantity": "number"
              }
            ],
            "gems": "number"
          }
        }
      ],
      
      "specialRewards": [
        {
          "rewardId": "string",
          "rewardName": "string",
          "description": "string",
          "itemIds": ["string"],
          "requiredParticipation": "number (예: 100% 참여 필요)"
        }
      ]
    }
  ]
}
```

---

## Milestone Rewards

### 스키마 정의

```json
{
  "milestones": [
    {
      "milestoneId": "string (unique)",
      "milestoneName": "string",
      "milestoneType": "enum (level/stage/playtime/season)",
      
      "condition": {
        "conditionType": "enum (reach_level/clear_stage/playtime_hours/season_progress)",
        "targetValue": "number"
      },
      
      "reward": {
        "gold": "number",
        "items": [
          {
            "itemId": "string",
            "itemName": "string",
            "tier": "enum",
            "isSelectable": "boolean (플레이어 선택 가능)",
            "selectCount": "number (선택 가능 개수, isSelectable=true인 경우)"
          }
        ],
        "gems": "number"
      },
      
      "oneTimeReward": "boolean (한 번만 획득 가능)",
      "completionStatus": "boolean (플레이어별로 추적)"
    }
  ]
}
```

---

## Data Format Specifications

### 공통 필드 정의

```
tier (등급):
- "common" (#6B7280)
- "uncommon" (#10B981)
- "rare" (#3B82F6)
- "epic" (#A855F7)
- "legendary" (#FBBF24)

currency (재화):
- "gold" (게임 화폐)
- "gems" (프리미엄 화폐)

itemType (아이템 타입):
- "weapon" (무기)
- "armor" (방어구)
- "ring" (반지)
- "necklace" (목걸이)

dateFormat (날짜):
- ISO 8601: "2026-03-06T12:30:00Z"

probability (확률):
- 0-100 범위의 퍼센트 (%는 표시하지 않음)
- 합계가 100이 되어야 함
```

### JSON 구조 예시 (통합)

```json
{
  "version": "1.0",
  "lastUpdated": "2026-03-06T12:00:00Z",
  "metadata": {
    "totalItems": 90,
    "totalMonsters": 50,
    "totalQuests": 30,
    "totalEvents": 5
  },
  
  "monsters": [...],
  "quests": [...],
  "merchants": [...],
  "gachas": [...],
  "loginRewards": [...],
  "events": [...],
  "milestones": [...]
}
```

---

**다음 단계:** 실제 데이터 파일 생성 (monster_drop_table.json 등)
