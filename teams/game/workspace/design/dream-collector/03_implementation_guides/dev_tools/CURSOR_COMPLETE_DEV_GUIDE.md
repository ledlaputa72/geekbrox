# 🚀 Dream Collector — Cursor 완전 개발 가이드

**대상:** Cursor IDE (Game팀 구현용)  
**작성:** Atlas (PM)  
**날짜:** 2026-03-04  
**상태:** 🟢 즉시 구현 가능

---

## 📌 이 문서에 대해

**목적:**
- 커서가 이 문서만 읽으면 전체 개발 가능
- 카드 200종 데이터 기반의 실제 구현 가이드
- 시스템 간 연계까지 포함

**사용 방법:**
1. 이 문서를 읽기 (30분)
2. Cursor Chat에 프롬프트 복사해서 붙여넣기
3. 코드 생성받아 수정/확장
4. 단계별 진행

**최종 구현 시간:** 약 2주 (15-21시간)

---

## 🎮 프로젝트 개요

```
게임명: Dream Collector (꿈수집가)
장르: 로그라이크 + 방치형 게임
엔진: Godot 4.x
설계: 100% 완료
구현 준비도: 95%
```

---

## 📊 4가지 핵심 시스템

### 1. 카드 시스템 (200종)
- **데이터 파일:** `teams/game/workspace/design/dream-collector/data/cards_200_v2.json`
- **분류:** ATTACK (42) / SKILL (60) / POWER (50) / CURSE (48)
- **희귀도:** COMMON (40%) → RARE (35%) → SPECIAL (15%) → LEGENDARY (10%)
- **강화:** 같은 카드 2개 (또는 + 골드) → +1 강화 (100% 성공, +10까지)

### 2. 장비 강화 시스템 (66종)
- **슬롯:** WEAPON (무기) / ARMOR (방어구) / ACCESSORY (악세서리) / OFF_HAND (보조무기)
- **강화:** 같은 장비 2개 + 골드 → +1 강화 (100% 성공, +10까지)
- **영향:** ATK/DEF/HP (강화도당 +10%)

### 3. 성장 시스템 (무한 Lv)
- **레벨:** Lv 1 ~ 1000+ (무한)
- **경험치:** 100 × (Lv^1.2)
- **자동 배분:** ATK +1.5, DEF +1, HP +5, SPD +0.3 (매 레벨)
- **마일스톤:** Lv 2, 4, 6, 8, 10, 12... (짧은 간격), 재화 + 컨텐츠 오픈

### 4. 가챭 시스템
- **종류:** 장비 가챭 (50D), 카드 가챭 (50D)
- **확률:** 장비 (55% COMMON, 30% RARE, 13% SPECIAL, 2% LEGENDARY)
- **보장:** 50회 RARE, 100회 SPECIAL, 150회 LEGENDARY

---

## 💾 카드 데이터 구조 (cards_200_v2.json)

```json
{
  "id": "ATK-SGL_001",           // 카드 ID (고유)
  "name": "Ace of Blades",       // 영문명
  "nameKo": "검의 에이스",        // 한글명
  "type": "ATTACK",              // ATTACK / SKILL / POWER / CURSE
  "subtype": "SGL",              // SGL (단일), AoE (범위) 등
  "rarity": "COMMON",            // COMMON / RARE / SPECIAL / LEGENDARY
  "cost": 1,                     // 사용 비용
  "costType": "energy",          // 비용 타입
  "description": "단일 적에게 직접 데미지",
  "descriptionKo": "단일 적에게 직접 데미지",
  "stats": {
    "damage": 7,                 // 데미지
    "block": 0,                  // 방어
    "heal": 0                    // 회복
  },
  "effects": [],                 // 특수 효과
  "tags": ["MAJOR_ARCANA"],      // 태그
  "monetization": "free",        // free / premium
  "gameType": ["ATB", "TB"],     // 게임 모드
  "availability": "base"         // 기본 가능 여부
}
```

---

## 🔧 4가지 구현 Phase (우선순위순)

### Phase 1: 카드 시스템 (Week 1, 3월 5-6일)

#### 📖 참조 문서
```
1. CARD_200_DETAILED_DESIGN_GUIDE.md
   위치: teams/game/workspace/design/dream-collector/
   
2. cards_200_v2.json (완전한 카드 데이터)
```

#### 🎯 구현할 것
```
1. Card.gd 클래스
2. CardDatabase.gd (JSON 로드)
3. CardEnhanceSystem.gd (강화, 100% 성공)
4. 카드 UI 기본
```

#### 💻 GDScript 클래스 정의

**Card.gd:**
```gdscript
class_name Card

var id: String                   # "ATK-SGL_001" 형식
var name: String
var name_ko: String
var type: String                # ATTACK / SKILL / POWER / CURSE
var subtype: String             # SGL / AoE 등
var rarity: String              # COMMON / RARE / SPECIAL / LEGENDARY
var cost: int
var cost_type: String           # "energy"
var description: String
var stats: Dictionary           # { "damage": 7, "block": 0, "heal": 0 }
var effects: Array              # 특수 효과
var tags: Array
var enhancement_level: int = 0  # 0-10
var monetization: String        # "free" / "premium"

func get_enhanced_damage() -> float:
    """강화도를 고려한 데미지 계산"""
    if stats.has("damage"):
        return stats["damage"] * (1.0 + enhancement_level * 0.05)
    return 0.0

func enhance() -> bool:
    """카드 강화 (100% 성공)"""
    if enhancement_level < 10:
        enhancement_level += 1
        return true
    return false  # 이미 +10

func get_rarity_value() -> int:
    """희귀도를 숫자로 반환 (강화 재료로 사용)"""
    match rarity:
        "COMMON": return 1
        "RARE": return 3
        "SPECIAL": return 5
        "LEGENDARY": return 10
    return 0
```

**CardDatabase.gd:**
```gdscript
class_name CardDatabase

var cards: Dictionary = {}       # id → Card
var total_cards: int = 0

func _ready():
    load_cards_from_json()

func load_cards_from_json() -> void:
    """cards_200_v2.json 로드"""
    var file = FileAccess.open("res://data/cards_200_v2.json", FileAccess.READ)
    if file:
        var json = JSON.parse_string(file.get_as_text())
        if json is Array:
            for card_data in json:
                var card = _create_card_from_data(card_data)
                cards[card.id] = card
                total_cards += 1

func _create_card_from_data(data: Dictionary) -> Card:
    """JSON 데이터에서 Card 객체 생성"""
    var card = Card.new()
    card.id = data.get("id", "")
    card.name = data.get("name", "")
    card.name_ko = data.get("nameKo", "")
    card.type = data.get("type", "ATTACK")
    card.subtype = data.get("subtype", "")
    card.rarity = data.get("rarity", "COMMON")
    card.cost = data.get("cost", 0)
    card.cost_type = data.get("costType", "energy")
    card.description = data.get("description", "")
    card.stats = data.get("stats", {})
    card.effects = data.get("effects", [])
    card.tags = data.get("tags", [])
    card.monetization = data.get("monetization", "free")
    return card

func get_card(id: String) -> Card:
    """ID로 카드 조회"""
    return cards.get(id, null)

func get_cards_by_type(type: String) -> Array:
    """타입별 카드 조회"""
    var result = []
    for card in cards.values():
        if card.type == type:
            result.append(card)
    return result

func get_cards_by_rarity(rarity: String) -> Array:
    """희귀도별 카드 조회"""
    var result = []
    for card in cards.values():
        if card.rarity == rarity:
            result.append(card)
    return result
```

#### ✅ 체크리스트

```
Phase 1 카드 시스템:
[ ] Card.gd 클래스 생성 및 정의
[ ] CardDatabase.gd 생성 및 JSON 로드 테스트
[ ] cards_200_v2.json 파일 위치 확인
[ ] 200종 카드 모두 로드되는지 테스트
[ ] get_card(), get_cards_by_type() 테스트
[ ] 카드 UI 기본 (카드 정보 표시)
```

---

### Phase 2: 장비 강화 시스템 (Week 1, 3월 7-8일)

#### 📖 참조 문서
```
1. CHARACTER_EQUIPMENT_SYSTEM.md
2. EQUIPMENT_IMPLEMENTATION_DESIGN.md
```

#### 🎯 구현할 것
```
1. Equipment.gd 클래스
2. EquipmentDatabase.gd (66종 정의)
3. EquipmentEnhanceSystem.gd (강화, 100% 성공)
4. 강화 UI
```

#### 💾 장비 데이터 구조

**Equipment.gd:**
```gdscript
class_name Equipment

var id: int                    # 장비 ID
var name: String
var name_ko: String
var slot: String              # WEAPON / ARMOR / ACCESSORY / OFF_HAND
var rarity: String
var base_atk: float = 0
var base_def: float = 0
var base_hp: float = 0
var base_spd: float = 0
var enhancement_level: int = 0  # 0-10

func get_total_atk() -> float:
    return base_atk * (1.0 + enhancement_level * 0.1)

func get_total_def() -> float:
    return base_def * (1.0 + enhancement_level * 0.1)

func get_total_hp() -> float:
    return base_hp * (1.0 + enhancement_level * 0.1)

func enhance(cost: int) -> bool:
    """장비 강화 (100% 성공, 비용: 같은 장비 2개 + 골드)"""
    if enhancement_level < 10:
        enhancement_level += 1
        return true
    return false
```

#### ✅ 체크리스트

```
Phase 2 장비 강화:
[ ] Equipment.gd 클래스 생성
[ ] EquipmentDatabase.gd에 66종 장비 정의
[ ] 4슬롯 구분 (WEAPON/ARMOR/ACCESSORY/OFF_HAND)
[ ] EquipmentEnhanceSystem.gd 구현 (100% 성공)
[ ] 강화 공식 테스트 (10% per level)
[ ] 강화 UI (버튼, 비용 표시, 결과)
```

---

### Phase 3: 성장 시스템 (Week 2, 3월 9-10일)

#### 📖 참조 문서
```
1. PROGRESSION_SYSTEM_REDESIGNED.md
```

#### 🎯 구현할 것
```
1. LevelSystem.gd (무한 Lv, 자동 스탯)
2. MilestoneRewardSystem.gd (재화 + 컨텐츠 오픈)
3. ContentUnlockManager.gd (지역/던전 오픈)
4. UI (레벨, 경험치, 마일스톤)
```

#### 💻 LevelSystem.gd

```gdscript
class_name LevelSystem

var current_level: int = 1
var current_exp: float = 0.0
var total_atk: float = 15.0
var total_def: float = 10.0
var total_hp: float = 100.0
var total_spd: float = 3.0

func get_required_exp() -> float:
    """필요 경험치: 100 × (현재레벨^1.2)"""
    return 100.0 * pow(current_level, 1.2)

func add_exp(amount: float) -> void:
    """경험치 획득"""
    current_exp += amount
    # 레벨업 체크
    while current_exp >= get_required_exp():
        level_up()

func level_up() -> void:
    """레벨업 (자동 스탯 배분)"""
    current_level += 1
    current_exp -= get_required_exp()
    # 자동 스탯 배분
    total_atk += 1.5
    total_def += 1.0
    total_hp += 5.0
    total_spd += 0.3
    # 마일스톤 체크
    check_milestone()

func check_milestone() -> void:
    """마일스톤 도달 체크"""
    MilestoneRewardSystem.trigger_milestone(current_level)
```

#### 📋 마일스톤 정의

```gdscript
# 마일스톤 데이터 (GDScript 딕셔너리)
var milestones = {
  2: {
    "reward_gold": 100,
    "reward_diamond": 5,
    "reward_card": 1,
    "content": "카드 시스템 오픈"
  },
  4: {
    "reward_gold": 200,
    "reward_diamond": 5,
    "reward_equipment": 1,
    "content": "장비 시스템 오픈"
  },
  6: {
    "reward_gold": 500,
    "reward_diamond": 5,
    "content": "강화 시스템 오픈"
  },
  8: {
    "reward_gold": 500,
    "reward_diamond": 5,
    "content": "첫 지역 완료"
  },
  10: {
    "reward_gold": 1000,
    "reward_diamond": 10,
    "reward_card": 3,
    "content": "두 번째 지역 오픈"
  },
  # ... 계속
  50: {
    "reward_gold": 5000,
    "reward_diamond": 50,
    "content": "무한 던전 오픈"
  },
  100: {
    "reward_gold": 10000,
    "reward_diamond": 100,
    "content": "극한 콘텐츠 오픈"
  }
}
```

#### ✅ 체크리스트

```
Phase 3 성장:
[ ] LevelSystem.gd 구현
[ ] 경험치 공식 테스트 (Lv^1.2)
[ ] 자동 스탯 배분 테스트
[ ] MilestoneRewardSystem.gd 구현
[ ] 마일스톤 딕셔너리 완성
[ ] ContentUnlockManager.gd 구현
[ ] UI (레벨, 경험치바, 마일스톤 알림)
```

---

### Phase 4: 가챭 시스템 (Week 2, 3월 11-12일)

#### 📖 참조 문서
```
1. GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md
```

#### 🎯 구현할 것
```
1. DropRateTable.gd (확률 테이블)
2. GachaSystem.gd (뽑기 로직)
3. GachaUI.gd (UI + 애니메이션)
```

#### 💻 GachaSystem.gd

```gdscript
class_name GachaSystem

var equipment_pull_count: int = 0
var card_pull_count: int = 0

# 가챭 확률 테이블
var equipment_rates = {
  "COMMON": 55,
  "RARE": 30,
  "SPECIAL": 13,
  "LEGENDARY": 2
}

var card_rates = {
  "COMMON": 45,
  "RARE": 35,
  "SPECIAL": 15,
  "LEGENDARY": 5
}

func pull_equipment(count: int = 1) -> Array:
    """장비 가챭 뽑기"""
    var results = []
    for i in range(count):
        equipment_pull_count += 1
        var rarity = get_equipment_rarity()
        var equipment = EquipmentDatabase.get_random_by_rarity(rarity)
        results.append(equipment)
        check_guarantee()
    return results

func pull_card(count: int = 1) -> Array:
    """카드 가챭 뽑기"""
    var results = []
    for i in range(count):
        card_pull_count += 1
        var rarity = get_card_rarity()
        var card = CardDatabase.get_random_by_rarity(rarity)
        results.append(card)
        check_guarantee()
    return results

func get_equipment_rarity() -> String:
    """장비 가챭 희귀도 결정"""
    var rand = randf() * 100
    if rand < 55: return "COMMON"
    if rand < 85: return "RARE"
    if rand < 98: return "SPECIAL"
    return "LEGENDARY"

func get_card_rarity() -> String:
    """카드 가챭 희귀도 결정"""
    var rand = randf() * 100
    if rand < 45: return "COMMON"
    if rand < 80: return "RARE"
    if rand < 95: return "SPECIAL"
    return "LEGENDARY"

func check_guarantee() -> void:
    """보장 시스템 체크"""
    if equipment_pull_count == 50:
        print("50회 보장: RARE 획득")
        equipment_pull_count = 0
    if equipment_pull_count == 100:
        print("100회 보장: SPECIAL 획득")
        equipment_pull_count = 0
    if equipment_pull_count == 150:
        print("150회 보장: LEGENDARY 획득")
        equipment_pull_count = 0
```

#### ✅ 체크리스트

```
Phase 4 가챭:
[ ] DropRateTable.gd 구현
[ ] GachaSystem.gd 구현
[ ] 장비 가챭 확률 테스트
[ ] 카드 가챭 확률 테스트
[ ] 보장 시스템 테스트
[ ] GachaUI.gd 구현
[ ] 뽑기 애니메이션
```

---

## 🔗 시스템 간 데이터 연계

### 카드 → 강화
```
카드: Card.gd
  ├─ stats: {"damage": 7, ...}
  └─ enhancement_level: 0-10

카드 강화:
  비용: 같은 카드 2개 + 골드
  결과: enhancement_level + 1
  효과: stats * (1 + enhancement_level * 0.05)
```

### 장비 → 강화
```
장비: Equipment.gd
  ├─ base_atk: 20, base_def: 15
  └─ enhancement_level: 0-10

장비 강화:
  비용: 같은 장비 2개 + 골드
  결과: enhancement_level + 1
  효과: base_stat * (1 + enhancement_level * 0.1)
```

### 성장 → 마일스톤
```
레벨업:
  current_level 증가
  자동 스탯 배분 (ATK+1.5, DEF+1, HP+5, SPD+0.3)
  
마일스톤 트리거:
  Lv 2: 카드 시스템 오픈 + 카드 1장 획득
  Lv 4: 장비 시스템 오픈 + 장비 1개 획득
  Lv 10: 카드 선택 3장 중 1장
  ... 계속
```

### 가챭 → 인벤토리
```
가챭 뽑기:
  pull_equipment(1) → Equipment 객체
  pull_card(1) → Card 객체
  
저장:
  card_inventory: Array[Card]
  equipment_inventory: Array[Equipment]
```

---

## 📁 파일 구조 및 경로

```
~/Projects/geekbrox/
├─ teams/game/workspace/design/dream-collector/
│  ├─ data/
│  │  ├─ cards_200_v2.json (← 카드 데이터, JSON 파싱 필수)
│  │  └─ cards_200_v2.csv
│  ├─ CARD_200_DETAILED_DESIGN_GUIDE.md
│  ├─ CHARACTER_EQUIPMENT_SYSTEM.md
│  ├─ EQUIPMENT_IMPLEMENTATION_DESIGN.md
│  ├─ PROGRESSION_SYSTEM_REDESIGNED.md
│  ├─ GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md
│  └─ IMPLEMENTATION_GUIDE.md
│
├─ teams/game/godot/dream-collector/
│  ├─ src/
│  │  ├─ Card.gd (← 여기에 코드 작성)
│  │  ├─ CardDatabase.gd
│  │  ├─ CardEnhanceSystem.gd
│  │  ├─ Equipment.gd
│  │  ├─ EquipmentDatabase.gd
│  │  ├─ EquipmentEnhanceSystem.gd
│  │  ├─ LevelSystem.gd
│  │  ├─ MilestoneRewardSystem.gd
│  │  ├─ GachaSystem.gd
│  │  └─ ... 등등
│  └─ scenes/
│     └─ UI 장면들

└─ .cursorrules (← Cursor가 자동으로 로드)
```

---

## 🎯 Cursor 프롬프트 예시

### 프롬프트 1: 카드 시스템 시작

```
이 프롬프트를 Cursor Chat에 복사해서 붙여넣기:

---

CURSOR_COMPLETE_DEV_GUIDE.md를 참조해서 다음을 만들어줘:

1. Card.gd 클래스
   - 필드: id, name, name_ko, type, rarity, cost, stats, enhancement_level
   - 함수: get_enhanced_damage(), enhance(), get_rarity_value()

2. CardDatabase.gd 클래스
   - ~/Projects/geekbrox/teams/game/workspace/design/dream-collector/data/cards_200_v2.json을 로드
   - 함수: load_cards_from_json(), get_card(id), get_cards_by_type(), get_cards_by_rarity()
   - 검증: 200종 모두 로드되는지 확인하는 _ready() 함수

주의사항:
- JSON 구조: id, name, nameKo, type, rarity, cost, stats (damage, block, heal), effects, tags
- Card.id는 "ATK-SGL_001" 형식
- 모든 200종 카드가 로드되어야 함

---

이렇게 하면 Cursor가 자동으로:
1. CURSOR_COMPLETE_DEV_GUIDE.md를 참조
2. Card.gd와 CardDatabase.gd 코드 생성
3. JSON 파싱 로직 자동 포함
```

### 프롬프트 2: 장비 강화 시스템

```
CURSOR_COMPLETE_DEV_GUIDE.md의 Phase 2를 참조해서:

1. Equipment.gd 클래스 생성
   - 슬롯: WEAPON, ARMOR, ACCESSORY, OFF_HAND
   - 필드: id, name, slot, rarity, base_atk, base_def, base_hp, enhancement_level (0-10)
   - 함수: get_total_atk(), get_total_def(), get_total_hp(), enhance()

2. EquipmentDatabase.gd 생성
   - 66종 장비를 딕셔너리로 정의
   - 함수: get_equipment(id), get_equipment_by_slot(), get_random_by_rarity()

3. EquipmentEnhanceSystem.gd 생성
   - enhance(equipment, same_equipment, gold) 함수
   - 100% 성공률 (실패 없음)
   - 강화 공식: base_stat * (1 + enhancement_level * 0.1)

---
```

### 프롬프트 3: 성장 시스템

```
CURSOR_COMPLETE_DEV_GUIDE.md의 Phase 3를 참조해서:

1. LevelSystem.gd 구현
   - 필드: current_level, current_exp, total_atk, total_def, total_hp, total_spd
   - 함수: 
     * get_required_exp() → 100 * (현재레벨^1.2)
     * add_exp(amount)
     * level_up() (자동 스탯: ATK+1.5, DEF+1, HP+5, SPD+0.3)
     * check_milestone()

2. MilestoneRewardSystem.gd 구현
   - 마일스톤 데이터 (딕셔너리)
   - trigger_milestone(level) 함수
   - Lv 2: 카드 시스템 오픈 + 카드 1장
   - Lv 4: 장비 시스템 오픈 + 장비 1개
   - ... (전체 목록은 CURSOR_COMPLETE_DEV_GUIDE.md 참조)

3. ContentUnlockManager.gd 구현
   - unlock_by_level(level) 함수
   - 지역, 던전, 이벤트 오픈 로직

---
```

### 프롬프트 4: 가챭 시스템

```
CURSOR_COMPLETE_DEV_GUIDE.md의 Phase 4를 참조해서:

1. GachaSystem.gd 구현
   - 함수:
     * pull_equipment(count) → Array[Equipment]
     * pull_card(count) → Array[Card]
     * get_equipment_rarity() → COMMON(55%), RARE(30%), SPECIAL(13%), LEGENDARY(2%)
     * get_card_rarity() → COMMON(45%), RARE(35%), SPECIAL(15%), LEGENDARY(5%)
     * check_guarantee() (50회, 100회, 150회 보장)

2. GachaUI.gd 구현
   - 가챭 버튼 (1회, 10회)
   - 비용 표시 (50D)
   - 결과 표시 및 애니메이션

---
```

---

## 📊 전체 구현 로드맵

```
Week 1 (3월 5-8일):
  ✓ Day 1-2: Card.gd + CardDatabase.gd (카드 로드)
  ✓ Day 3-4: Equipment.gd + EquipmentDatabase.gd + 강화 (100% 성공)
  ✓ Day 5: 카드/장비 UI 기본

Week 2 (3월 9-13일):
  ✓ Day 1-2: LevelSystem.gd + MilestoneRewardSystem.gd
  ✓ Day 3-4: GachaSystem.gd + GachaUI.gd
  ✓ Day 5: 통합 + 버그 수정

Week 3 (3월 15-18일):
  ✓ 전체 게임 루프 테스트
  ✓ UI/UX 개선
  ✓ 성능 최적화
```

---

## ✅ 최종 체크리스트

```
구현 전:
[ ] CURSOR_COMPLETE_DEV_GUIDE.md 읽기 (30분)
[ ] 카드 데이터 파일 확인 (cards_200_v2.json)
[ ] Godot 프로젝트 준비

Phase 1 (카드):
[ ] Card.gd 완성
[ ] CardDatabase.gd 완성 (200종 로드 확인)
[ ] 카드 UI

Phase 2 (장비):
[ ] Equipment.gd 완성
[ ] EquipmentDatabase.gd 완성 (66종)
[ ] 강화 시스템 (100% 성공)
[ ] 강화 UI

Phase 3 (성장):
[ ] LevelSystem.gd 완성 (무한 Lv)
[ ] MilestoneRewardSystem.gd 완성
[ ] ContentUnlockManager.gd 완성
[ ] 레벨 UI + 마일스톤 알림

Phase 4 (가챭):
[ ] GachaSystem.gd 완성
[ ] GachaUI.gd 완성
[ ] 확률 테스트

통합:
[ ] 전체 시스템 연계
[ ] 게임 루프 테스트
[ ] 버그 수정
[ ] 성능 최적화
```

---

## 💬 자주 사용할 Cursor 명령어

### 문서 참조
```
@file:CURSOR_COMPLETE_DEV_GUIDE.md        (이 파일)
@file:CARD_200_DETAILED_DESIGN_GUIDE.md   (카드 상세)
@file:CHARACTER_EQUIPMENT_SYSTEM.md       (장비 상세)
@file:PROGRESSION_SYSTEM_REDESIGNED.md    (성장 상세)
@file:GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md (가챭 상세)
@file:data/cards_200_v2.json              (카드 데이터)
```

### 섹션 참조
```
@file:CURSOR_COMPLETE_DEV_GUIDE.md:Phase 1
@file:CURSOR_COMPLETE_DEV_GUIDE.md:Phase 2
@file:CURSOR_COMPLETE_DEV_GUIDE.md:마일스톤 정의
@file:CURSOR_COMPLETE_DEV_GUIDE.md:Cursor 프롬프트 예시
```

---

## 🚀 지금 바로 시작하기

```
1. Cursor 열기:
   cd ~/Projects/geekbrox/
   cursor .

2. 첫 번째 프롬프트 실행:
   위의 "프롬프트 1: 카드 시스템" 전체 복사해서
   Cursor Chat에 붙여넣기

3. 코드 생성받기:
   Cursor가 Card.gd와 CardDatabase.gd 생성

4. Phase별 진행:
   프롬프트 2, 3, 4 순서대로 실행
```

---

## 📞 참조 정보

**프로젝트:** Dream Collector  
**설계 완료도:** 100%  
**카드 데이터:** 200종 완성  
**구현 시간:** 약 15-21시간 (2주)

**이 문서만 읽으면 전체 개발 가능!** ✅

---

**준비 완료! Cursor에서 바로 구현을 시작하세요!** 🚀
