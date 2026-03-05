# 🚀 Dream Collector — Implementation Guide for Cursor

**작성:** Atlas (PM)  
**대상:** Game팀 (Cursor IDE)  
**날짜:** 2026-03-04  
**상태:** 구현 시작 가능

---

## 📌 개요

이 문서는 **Cursor에서 실제 구현할 때** 참조해야 할 모든 정보를 체계적으로 정리했습니다.

**사용 방법:**
1. 현재 구현할 시스템을 찾기
2. 해당 섹션의 "참조 문서" 읽기
3. "구현 체크리스트" 따라 진행
4. "예시 코드" 참고하여 구현

---

## 🎯 4가지 핵심 시스템 (구현 우선순위순)

### Priority 1️⃣: 카드 시스템 (Card System)

**진행 기간:** Week 1 (3월 5-6일)  
**담당:** Game팀

#### 📖 참조 문서
```
1. CARD_200_DETAILED_DESIGN_GUIDE.md (필수)
   - 200종 카드 완전 정의
   - 4가지 분류 (ATTACK/SKILL/POWER/CURSE)
   - 효과 정의

2. data/cards_200_v2.json (필수)
   - 모든 카드 데이터
   - JSON 구조 확인

3. GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md (참고)
   - 가챭에서의 카드 드롭
```

#### 🎮 구현할 GDScript 클래스

```gdscript
# Card.gd
class_name Card

var id: int                    # 카드 ID (1-200)
var name: String              # 카드 이름
var type: String              # ATTACK / SKILL / POWER / CURSE
var rarity: String            # COMMON / RARE / SPECIAL / LEGENDARY
var cost: int                 # 사용 비용
var description: String       # 설명
var enhancement_level: int = 0  # 강화도 (0-10)

# 함수
func get_enhanced_power() -> float:
    # 강화도에 따른 전력 계산
    return base_power * (1.0 + enhancement_level * 0.05)
```

#### ✅ 구현 체크리스트

```
[ ] Card.gd 클래스 생성
    - id, name, type, rarity, cost, description
    - enhancement_level (0-10)
    - get_enhanced_power() 함수
    
[ ] CardDatabase.gd 생성
    - cards_200_v2.json 로드
    - 200종 모두 로드 확인
    - get_card(id) 함수
    
[ ] 데이터 구조 검증
    - JSON 파싱 테스트
    - 모든 필드 확인
    
[ ] UI 표시 (기본)
    - 카드 정보 표시
    - 강화도 표시
```

#### 💾 데이터 구조

```json
{
  "id": 1,
  "name": "강력한 공격",
  "type": "ATTACK",
  "rarity": "COMMON",
  "cost": 2,
  "description": "기본 공격",
  "base_power": 10
}
```

---

### Priority 2️⃣: 장비 강화 시스템 (Equipment Enhancement)

**진행 기간:** Week 1 (3월 7-8일)  
**담당:** Game팀

#### 📖 참조 문서
```
1. CHARACTER_EQUIPMENT_SYSTEM.md (필수)
   - 4슬롯 장비 구조 (무기/방어구/악세서리/보조무기)
   - 66종 장비

2. EQUIPMENT_IMPLEMENTATION_DESIGN.md (필수)
   - GDScript 구현 세부사항

3. CHARACTER_TRAITS_ENHANCED.md (참고, 특성은 제외)
```

#### 🎮 구현할 GDScript 클래스

```gdscript
# Equipment.gd
class_name Equipment

var id: int                      # 장비 ID
var name: String                # 장비 이름
var slot: String                # WEAPON / ARMOR / ACCESSORY / OFF_HAND
var rarity: String              # 희귀도
var base_atk: float = 0         # 기본 공격력
var base_def: float = 0         # 기본 방어력
var base_hp: float = 0          # 기본 생명력
var enhancement_level: int = 0  # 강화도 (0-10)

# 함수
func get_total_atk() -> float:
    return base_atk * (1.0 + enhancement_level * 0.1)

func get_total_def() -> float:
    return base_def * (1.0 + enhancement_level * 0.1)
```

#### ✅ 구현 체크리스트

```
[ ] Equipment.gd 클래스 생성
    - 4가지 슬롯 구분
    - base_atk, base_def, base_hp
    - enhancement_level (0-10)
    - get_total_atk(), get_total_def() 함수
    
[ ] EquipmentDatabase.gd 생성
    - 66종 장비 정의
    - get_equipment(id) 함수
    - slot별 필터링
    
[ ] EquipmentEnhanceSystem.gd 생성
    - enhance(equipment, material) 함수
    - 100% 성공률 (실패 없음)
    - 비용 계산 (같은 장비 2개 + 골드)
    
[ ] UI
    - 장비 정보 표시
    - 강화도 표시
    - 강화 버튼
```

#### 💾 데이터 구조

```gdscript
# Equipment 정의 예시
var weapon_iron_sword = {
  "id": 1,
  "name": "강철 검",
  "slot": "WEAPON",
  "rarity": "COMMON",
  "base_atk": 20,
  "base_def": 0,
  "base_hp": 0
}
```

---

### Priority 3️⃣: 성장 시스템 (Level & Progression)

**진행 기간:** Week 1-2 (3월 9-10일)  
**담당:** Game팀

#### 📖 참조 문서
```
1. PROGRESSION_SYSTEM_REDESIGNED.md (필수)
   - 무한 레벨 (Lv 1-1000+)
   - 자동 스탯 배분
   - 마일스톤 보상

2. data/cards_200_v2.json (참고)
   - 마일스톤 보상 카드
```

#### 🎮 구현할 GDScript 클래스

```gdscript
# LevelSystem.gd
class_name LevelSystem

var current_level: int = 1
var current_exp: float = 0.0
var total_atk: float = 15.0      # 초기값
var total_def: float = 10.0
var total_hp: float = 100.0
var total_spd: float = 3.0

# 함수
func get_required_exp() -> float:
    # 필요 경험치: 100 × (현재레벨^1.2)
    return 100.0 * pow(current_level, 1.2)

func add_exp(amount: float) -> void:
    current_exp += amount
    # 레벨업 체크
    while current_exp >= get_required_exp():
        level_up()

func level_up() -> void:
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
    match current_level:
        2: unlock_card_system()
        4: unlock_equipment_system()
        6: unlock_enhancement_system()
        # ... 계속
```

#### ✅ 구현 체크리스트

```
[ ] LevelSystem.gd 생성
    - level, exp, atk, def, hp, spd
    - get_required_exp() (Lv^1.2 공식)
    - add_exp() 함수
    - level_up() 함수 (자동 스탯 +1.5/+1/+5/+0.3)
    
[ ] MilestoneRewardSystem.gd 생성
    - 마일스톤 트리거 (Lv 2, 4, 6, 8, 10, ...)
    - 재화 보상 (골드, 다이아, 카드, 장비)
    - 컨텐츠 언락 로직
    
[ ] ContentUnlockManager.gd 생성
    - 레벨별 지역 오픈
    - 레벨별 던전 오픈
    - 레벨별 이벤트 오픈
    
[ ] UI
    - 레벨 표시
    - 경험치 진행도
    - 다음 마일스톤까지 남은 경험치
    - 마일스톤 도달 시 특별 연출
```

#### 📊 마일스톤 정의

```gdscript
var milestones = {
  2: { "reward": { "card": 1 }, "unlock": "card_system" },
  4: { "reward": { "equipment": 1 }, "unlock": "equipment_system" },
  6: { "reward": { "gold": 500 }, "unlock": "enhancement_system" },
  # ... 계속 (문서 참조)
}
```

---

### Priority 4️⃣: 가챭 시스템 (Gacha System)

**진행 기간:** Week 2 (3월 11-12일)  
**담당:** Game팀

#### 📖 참조 문서
```
1. GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md (필수)
   - 장비/카드 분리 가챭
   - 희귀도별 확률
   - 보장 시스템

2. CARD_200_DETAILED_DESIGN_GUIDE.md (참고)
   - 카드 가챭 확률

3. CHARACTER_EQUIPMENT_SYSTEM.md (참고)
   - 장비 가챭 확률
```

#### 🎮 구현할 GDScript 클래스

```gdscript
# GachaSystem.gd
class_name GachaSystem

var diamond_balance: int = 0  # 다이아 잔액
var equipment_pull_count: int = 0  # 연속 뽑기 카운트

# 함수
func pull_equipment(count: int = 1) -> Array:
    var results = []
    for i in range(count):
        equipment_pull_count += 1
        var rarity = get_equipment_rarity()  # 확률 기반
        var equipment = get_random_equipment_by_rarity(rarity)
        results.append(equipment)
    check_guarantee()
    return results

func get_equipment_rarity() -> String:
    # 확률: 55% COMMON, 30% RARE, 13% SPECIAL, 2% LEGENDARY
    var rand = randf() * 100
    if rand < 55: return "COMMON"
    if rand < 85: return "RARE"
    if rand < 98: return "SPECIAL"
    return "LEGENDARY"

func check_guarantee() -> void:
    # 보장: 50회 RARE, 100회 SPECIAL, 150회 LEGENDARY
    match equipment_pull_count:
        50: guarantee_rarity("RARE")
        100: guarantee_rarity("SPECIAL")
        150: guarantee_rarity("LEGENDARY")
```

#### ✅ 구현 체크리스트

```
[ ] DropRateTable.gd 생성
    - 장비: 55% COMMON, 30% RARE, 13% SPECIAL, 2% LEGENDARY
    - 카드: 45% COMMON, 35% RARE, 15% SPECIAL, 5% LEGENDARY
    
[ ] GachaSystem.gd 생성
    - pull_equipment(count) 함수
    - pull_card(count) 함수
    - 확률 계산 (get_rarity())
    - 보장 시스템 (50/100/150회)
    
[ ] GachaUI.gd 생성
    - 가챭 버튼
    - 1회 / 10회 선택
    - 결과 표시
    - 애니메이션
    
[ ] 경제 통합
    - 다이아 차감
    - 획득 아이템 저장 (card_inventory, equipment_inventory)
```

#### 💾 확률 테이블

```gdscript
var gacha_rates = {
  "equipment": {
    "COMMON": 55,
    "RARE": 30,
    "SPECIAL": 13,
    "LEGENDARY": 2
  },
  "card": {
    "COMMON": 45,
    "RARE": 35,
    "SPECIAL": 15,
    "LEGENDARY": 5
  }
}
```

---

## 📋 전체 구현 로드맵

### Week 1 (3월 5-8일)

```
Day 1-2 (3월 5-6일): 카드 시스템
  [ ] Card.gd
  [ ] CardDatabase.gd
  [ ] 카드 로드 테스트

Day 3-4 (3월 7-8일): 장비 시스템
  [ ] Equipment.gd
  [ ] EquipmentDatabase.gd
  [ ] EquipmentEnhanceSystem.gd
  [ ] 강화 로직 테스트
```

### Week 2 (3월 9-13일)

```
Day 1-2 (3월 9-10일): 성장 시스템
  [ ] LevelSystem.gd
  [ ] MilestoneRewardSystem.gd
  [ ] ContentUnlockManager.gd
  [ ] 마일스톤 트리거 테스트

Day 3-4 (3월 11-12일): 가챭 시스템
  [ ] DropRateTable.gd
  [ ] GachaSystem.gd
  [ ] GachaUI.gd
  [ ] 가챭 뽑기 테스트

Day 5 (3월 13일): 통합 & 버그 수정
  [ ] 전체 시스템 통합
  [ ] 크로스 시스템 연계 테스트
  [ ] 버그 수정
```

### Week 3 (3월 15-18일)

```
통합 테스트 & UI 폴리시
  [ ] 전체 게임 흐름 테스트
  [ ] UI/UX 개선
  [ ] 성능 최적화
```

---

## 🔧 구현 팁 (Cursor 활용)

### 1. 카드 로드 예시 요청
```
Cursor Chat에 입력:
"CARD_200_DETAILED_DESIGN_GUIDE.md를 참조해서
cards_200_v2.json을 로드하는 CardDatabase.gd를 만들어줘"

→ Cursor가 파일을 참조하여 코드 생성
```

### 2. 강화 공식 요청
```
"CHARACTER_EQUIPMENT_SYSTEM.md의 강화 공식을 사용해서
Equipment.gd에 강화 함수를 추가해줘"

→ 정확한 공식으로 구현
```

### 3. 마일스톤 정의 요청
```
"PROGRESSION_SYSTEM_REDESIGNED.md의 마일스톤을 
GDScript 딕셔너리로 변환해줘"

→ 마일스톤 데이터 자동 생성
```

---

## ✅ 최종 체크리스트 (구현 완료 후)

```
[ ] 모든 클래스 생성 완료
[ ] 데이터 로드 테스트 (JSON 파싱)
[ ] 강화 로직 테스트 (100% 성공)
[ ] 레벨업 로직 테스트 (자동 스탯 배분)
[ ] 마일스톤 트리거 테스트
[ ] 가챭 확률 테스트
[ ] UI 기본 구현
[ ] 전체 게임 루프 연결
[ ] 버그 수정
[ ] 성능 최적화
```

---

## 📞 참조 명령어 (Cursor)

### 파일별 참조
```
@file:CARD_200_DETAILED_DESIGN_GUIDE.md
@file:CHARACTER_EQUIPMENT_SYSTEM.md
@file:PROGRESSION_SYSTEM_REDESIGNED.md
@file:GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md
```

### 섹션별 참조
```
@file:PROGRESSION_SYSTEM_REDESIGNED.md:마일스톤 보상
@file:CHARACTER_EQUIPMENT_SYSTEM.md:4슬롯 구조
```

### 데이터 파일
```
@file:data/cards_200_v2.json
```

---

## 🎯 시작하기

**지금 바로:**
1. Cursor에서 ~/Projects/geekbrox/ 열기
2. CARD_200_DETAILED_DESIGN_GUIDE.md 읽기
3. "Card.gd 만들어줘" → Cursor에 요청
4. 구현 시작!

**시간 예상:**
- 설계 이해: 2시간
- 코딩: 10-14시간 (Phase 1-4)
- 테스트: 3-5시간
- **총 15-21시간 (약 2주)**

---

**모든 준비가 완료되었습니다!**  
**Cursor에서 바로 구현을 시작하세요!** 🚀
