# Dream Collector - 게임 밸런스 시스템 설계 프레임워크

**작성일:** 2026-02-24  
**담당:** 게임 개발팀 디자인 파트  
**목적:** 85개 카드 데이터 제작 전 전체 밸런스 시스템 설계

---

## 🎯 프로젝트 목표

### 설계 범위
1. **카드 밸런스 시스템** (85장)
2. **몬스터 밸런스 시스템** (34종)
3. **경제 시스템** (재화 가치, 확률, 비용)
4. **진행 곡선** (난이도, 보상, 성장)
5. **업데이트 관리** (버프/너프, 버전 관리)

### 핵심 요구사항
- ✅ 밸런스 조정 가능성 (패치 대응)
- ✅ 데이터 기반 조정 (로그 추적)
- ✅ 버전 관리 시스템
- ✅ 재화 가치 일관성
- ✅ 진행 난이도 곡선

---

## 📊 1. 카드 밸런스 시스템

### 1.1 카드 기본 구조

```json
{
  "id": "atk_001",
  "name": "Quick Strike",
  "type": "attack",
  "rarity": "common",
  "cost": 1,
  "effects": [
    {"type": "damage", "value": 6, "target": "enemy"}
  ],
  "balance_version": "1.0.0",
  "power_rating": 6.0
}
```

### 1.2 파워 레이팅 공식

**기본 공식:**
```
Power Rating = (Total Damage + Total Block + Utility Value) / Cost
```

**타입별 기준치:**
- **Attack:** 5~7 damage per cost
- **Defense:** 4~6 block per cost
- **Skill:** 3~5 utility per cost (카드 드로우 = 2 utility)
- **Power:** Long-term value (다양한 효과)

**레어리티 보너스:**
- Common: 기준치 ×1.0
- Rare: 기준치 ×1.15
- Epic: 기준치 ×1.30
- Legendary: 기준치 ×1.50 + 고유 효과

### 1.3 밸런스 목표 (85장)

| 타입 | 수량 | Common | Rare | Epic | Legendary |
|------|------|--------|------|------|-----------|
| Attack | 20 | 10 | 6 | 3 | 1 |
| Defense | 20 | 10 | 6 | 3 | 1 |
| Skill | 25 | 13 | 8 | 3 | 1 |
| Power | 20 | 10 | 6 | 3 | 1 |
| **합계** | **85** | **43** | **26** | **12** | **4** |

**비율:** Common 50.6%, Rare 30.6%, Epic 14.1%, Legendary 4.7%

---

## 🐉 2. 몬스터 밸런스 시스템

### 2.1 몬스터 기본 구조

```json
{
  "id": "mob_001",
  "name": "Shadow Lurker",
  "type": "normal",
  "difficulty": 1,
  "hp": 30,
  "actions": [
    {"type": "attack", "damage": 6, "pattern": "every_turn"},
    {"type": "block", "amount": 5, "pattern": "every_2_turns"}
  ],
  "rewards": {
    "gold": 15,
    "card_chance": 0.3
  },
  "balance_version": "1.0.0",
  "threat_rating": 5.0
}
```

### 2.2 위협도 레이팅 공식

```
Threat Rating = (Avg Damage per Turn × 0.8) + (HP / 10) + (Special Ability Factor)
```

### 2.3 몬스터 분포 (34종)

| 타입 | 수량 | 난이도 1-3 | 난이도 4-6 | 난이도 7-10 |
|------|------|-----------|-----------|------------|
| Normal | 24 | 12 | 8 | 4 |
| Elite | 7 | 2 | 3 | 2 |
| Boss | 3 | 0 | 1 | 2 |
| **합계** | **34** | **14** | **12** | **8** |

---

## 💰 3. 경제 시스템 (재화 가치)

### 3.1 재화 종류 및 가치

| 재화 | 1차 획득 | 2차 획득 | 가치 비율 |
|------|---------|---------|----------|
| Gold 🪙 | 오프라인 수집, 런 완료 | 이벤트 | 기준(1.0) |
| Gems 💎 | IAP, 일일 보상 | 업적 | 100:1 (골드 대비) |
| Energy ⚡ | 시간 회복, 보석 구매 | - | 20:1 (골드 대비) |

**환산표:**
- 1 Gem = 100 Gold
- 1 Energy = 20 Gold
- 1 Card (Common) = 1,000 Gold
- 1 Card (Rare) = 5,000 Gold
- 1 Card (Epic) = 20,000 Gold
- 1 Card (Legendary) = 100,000 Gold

### 3.2 뽑기 확률 및 비용

#### 일반 뽑기 (골드 🪙)
- **비용:** 1회 1,000 / 10회 9,000 (10% 할인)
- **확률:**
  - Common: 70%
  - Rare: 25%
  - Epic: 4%
  - Legendary: 1%
- **기댓값:** 1,400 Gold (40% 손실) → Idle 수집으로 보상

#### 프리미엄 뽑기 (보석 💎)
- **비용:** 1회 100 / 10회 900 (= 10,000 Gold)
- **확률:**
  - Common: 0%
  - Rare: 60%
  - Epic: 35%
  - Legendary: 5%
- **기댓값:** 14,500 Gold (45% 프리미엄)

### 3.3 업그레이드 비용

| 레벨 | 비용 (Gold) | 효과 증가 | 누적 비용 |
|------|------------|----------|----------|
| 1→2 | 500 | +20% | 500 |
| 2→3 | 1,000 | +20% | 1,500 |
| 3→4 | 2,000 | +20% | 3,500 |
| 4→5 | 4,000 | +20% | 7,500 |
| 5→MAX | 8,000 | +20% | 15,500 |

**업그레이드 제한:** 카드당 최대 레벨 5

---

## 📈 4. 진행 곡선 (Progression Curve)

### 4.1 난이도 증가율

**런 난이도 공식:**
```
Monster HP = Base HP × (1 + 0.15 × Floor)
Monster Damage = Base Damage × (1 + 0.10 × Floor)
```

**플레이어 성장률:**
```
Deck Power = Sum(Card Power Rating) × (1 + Upgrade Bonus) × (1 + Prestige Multiplier)
```

**목표 밸런스:**
- Floor 1-3: Win Rate 80% (튜토리얼)
- Floor 4-7: Win Rate 60% (메인 게임)
- Floor 8-10: Win Rate 40% (도전 모드)
- Boss: Win Rate 50%

### 4.2 보상 곡선

**런 완료 보상:**
```
Gold Reward = 100 × Floor × (1 + Boss Bonus)
Card Reward Chance = 0.3 × (1 + 0.05 × Floor)
```

**프레스티지 보상:**
```
Dream Shards = Floor(Total Reveries / 10,000)
Collection Rate Multiplier = 1.25 per Prestige
```

---

## 🔧 5. 밸런스 조정 시스템

### 5.1 버전 관리

**버전 네이밍:**
```
v{Major}.{Minor}.{Patch}
```

- **Major:** 대규모 시스템 변경 (1.0 → 2.0)
- **Minor:** 카드/몬스터 밸런스 패치 (1.0 → 1.1)
- **Patch:** 버그 수정 (1.0.0 → 1.0.1)

**밸런스 패치 기록:**
```json
{
  "card_id": "atk_001",
  "changes": [
    {
      "version": "1.1.0",
      "date": "2026-03-15",
      "type": "nerf",
      "field": "damage",
      "old_value": 8,
      "new_value": 6,
      "reason": "Win rate too high (65%)"
    }
  ]
}
```

### 5.2 데이터 기반 조정 프로세스

#### 수집할 지표
1. **카드별 지표:**
   - 선택률 (Pick Rate)
   - 승률 기여도 (Win Rate Contribution)
   - 평균 사용 횟수
   - 덱 구성 비율

2. **몬스터별 지표:**
   - 승률 (Player Win Rate)
   - 평균 턴 수
   - 평균 데미지 딜량
   - 평균 데미지 받은량

3. **경제 지표:**
   - 골드 획득률 (per hour)
   - 뽑기 빈도
   - IAP 전환율
   - 재화 보유량 분포

#### 조정 기준

**버프 대상 (Usage Rate < 5%):**
- 파워 레이팅 +10~20%
- 코스트 감소
- 효과 추가

**너프 대상 (Usage Rate > 60%):**
- 파워 레이팅 -10~20%
- 코스트 증가
- 효과 감소

**조정 주기:**
- 마이너 패치: 2주마다
- 메이저 패치: 2개월마다

### 5.3 밸런스 테스트 프로세스

1. **이론 검증 (Spreadsheet)**
   - 파워 레이팅 계산
   - DPS/Block 시뮬레이션
   - 경제 시뮬레이션

2. **시뮬레이션 테스트 (Code)**
   - 1,000회 자동 전투
   - 승률 측정
   - 평균 턴 수 측정

3. **내부 플레이테스트 (10명)**
   - 실제 플레이 20시간
   - 설문 조사 (재미, 난이도)
   - 버그 리포트

4. **데이터 분석 & 조정**
   - 지표 수집
   - 이상치 발견
   - 패치 적용

5. **알파/베타 테스트**
   - 100+ 유저
   - 1주일 테스트
   - 최종 조정

---

## 📂 6. 데이터 구조 및 파일 관리

### 6.1 파일 구조

```
teams/game/data/
├── cards/
│   ├── cards_v1.0.0.json          # 카드 데이터 (버전별)
│   ├── cards_balance_log.json     # 밸런스 패치 로그
│   └── cards_metadata.json        # 메타데이터 (태그, 시너지)
│
├── monsters/
│   ├── monsters_v1.0.0.json
│   ├── monsters_balance_log.json
│   └── monster_patterns.json      # AI 패턴
│
├── economy/
│   ├── currency_rates.json        # 재화 환율
│   ├── gacha_rates.json           # 뽑기 확률
│   └── upgrade_costs.json         # 업그레이드 비용표
│
└── balance/
    ├── power_rating_table.json    # 파워 레이팅 기준표
    ├── progression_curve.json     # 진행 곡선 파라미터
    └── balance_test_results/      # 테스트 결과 아카이브
```

### 6.2 카드 데이터 템플릿

```json
{
  "version": "1.0.0",
  "last_updated": "2026-02-24",
  "cards": [
    {
      "id": "atk_001",
      "name": "Quick Strike",
      "name_kr": "빠른 일격",
      "type": "attack",
      "rarity": "common",
      "cost": 1,
      "effects": [
        {
          "type": "damage",
          "value": 6,
          "target": "enemy",
          "scaling": "none"
        }
      ],
      "description": "Deal 6 damage.",
      "description_kr": "6 데미지를 입힙니다.",
      "tags": ["simple", "starter"],
      "power_rating": 6.0,
      "balance_version": "1.0.0",
      "balance_notes": "Baseline card for power rating",
      "art_asset": "atk_001.png",
      "unlock_condition": "default"
    }
  ]
}
```

### 6.3 몬스터 데이터 템플릿

```json
{
  "version": "1.0.0",
  "monsters": [
    {
      "id": "mob_001",
      "name": "Shadow Lurker",
      "name_kr": "그림자 잠복자",
      "type": "normal",
      "difficulty": 1,
      "hp": 30,
      "actions": [
        {
          "type": "attack",
          "damage": 6,
          "pattern": "repeat",
          "interval": 1,
          "telegraph": "준비 중..."
        },
        {
          "type": "block",
          "amount": 5,
          "pattern": "conditional",
          "condition": "hp_below_50",
          "telegraph": "방어 태세"
        }
      ],
      "ai_pattern": "aggressive",
      "rewards": {
        "gold_min": 10,
        "gold_max": 20,
        "card_chance": 0.3,
        "card_pool": ["common", "rare"]
      },
      "threat_rating": 5.0,
      "balance_version": "1.0.0",
      "balance_notes": "Early game baseline enemy"
    }
  ]
}
```

---

## 🎮 7. 전투 시스템 연계

### 7.1 전투 파라미터

**플레이어 기본 스탯:**
- HP: 80
- Starting Hand: 5
- Max Hand: 7
- Energy per Turn: 3
- Draw per Turn: 5

**상태 효과:**
- Strength: 공격 데미지 +X
- Dexterity: 방어 +X
- Vulnerable: 받는 데미지 +50%
- Weak: 주는 데미지 -25%
- Poison: 턴 종료 시 X 데미지

### 7.2 카드 시너지 시스템

**태그 기반 시너지:**
```json
{
  "synergies": [
    {
      "name": "Poison Synergy",
      "tags": ["poison"],
      "threshold": 3,
      "effect": "poison_damage_x2"
    },
    {
      "name": "Block Synergy",
      "tags": ["block", "defense"],
      "threshold": 5,
      "effect": "block_gain_5"
    }
  ]
}
```

### 7.3 캐릭터 특성 (추후 확장)

**현재:** 기본 캐릭터 1종  
**확장 계획:** 3~5종 캐릭터 (각기 다른 특성)

```json
{
  "character_id": "dreamer_001",
  "name": "Dream Collector",
  "starting_hp": 80,
  "starting_deck": ["atk_001", "atk_001", "def_001", "def_001", "skill_001"],
  "passive_ability": {
    "name": "Dream Power",
    "effect": "Start each combat with 1 extra energy"
  }
}
```

---

## 📊 8. 밸런스 스프레드시트

### 8.1 Google Sheets 템플릿

**시트 구조:**
1. **Cards Master:** 전체 카드 데이터 (85행)
2. **Monsters Master:** 전체 몬스터 데이터 (34행)
3. **Power Rating Calc:** 파워 레이팅 자동 계산
4. **Economy Sim:** 경제 시뮬레이션
5. **Balance Test Results:** 테스트 결과 기록
6. **Patch History:** 패치 이력

**자동 계산 컬럼:**
- Power Rating = SUM(Effect Values) / Cost
- DPS = Damage / Cost
- Value per Gold = Power Rating / Acquisition Cost

---

## ✅ 9. 작업 계획 및 체크리스트

### Phase 1: 시스템 설계 (1주)
- [ ] 파워 레이팅 공식 확정
- [ ] 재화 가치 환산표 작성
- [ ] 진행 곡선 파라미터 설정
- [ ] 데이터 파일 구조 생성

### Phase 2: 데이터 제작 (2주)
- [ ] 카드 85장 데이터 작성
  - [ ] Attack 20장
  - [ ] Defense 20장
  - [ ] Skill 25장
  - [ ] Power 20장
- [ ] 몬스터 34종 데이터 작성
  - [ ] Normal 24종
  - [ ] Elite 7종
  - [ ] Boss 3종

### Phase 3: 밸런스 검증 (1주)
- [ ] 스프레드시트 시뮬레이션
- [ ] 코드 자동 전투 테스트
- [ ] 내부 플레이테스트
- [ ] 조정 및 반영

### Phase 4: Godot 통합 (1주)
- [ ] JSON 파일 → Godot 로드
- [ ] CardDatabase.gd 구현
- [ ] MonsterDatabase.gd 구현
- [ ] 전투 시스템 통합

---

## 🚨 중요 유의사항

### 반드시 지켜야 할 원칙
1. **파워 크리프 방지:** 신규 카드가 기존 카드를 완전히 대체하지 않도록
2. **재화 인플레이션 방지:** 골드 획득률과 소비율 균형
3. **페이 투 윈 방지:** IAP가 승률에 과도한 영향 없도록 (편의성만)
4. **선택의 다양성:** 메타 덱이 1~2개로 고정되지 않도록
5. **학습 곡선:** 초보자가 점진적으로 배울 수 있도록

### 조정 시 고려사항
- 플레이어 감정 (너프 → 보상 제공)
- 메타 다양성 (강제 로테이션 금지)
- 데이터 근거 (감이 아닌 지표 기반)

---

## 📞 담당자 및 연락처

**디자인 리드:** 게임 팀 리더 (Sub-agent)  
**데이터 검증:** OPS 팀 리더 (Sub-agent)  
**최종 승인:** Steve PM

---

**작성일:** 2026-02-24  
**버전:** 1.0.0  
**다음 리뷰:** 2026-03-03
