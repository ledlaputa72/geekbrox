# Dream Collector - Combat System Design

> 모바일 턴제 덱빌딩 전투 시스템 상세 기획

**버전:** 1.0  
**작성일:** 2026-02-24  
**작성자:** Atlas

---

## 📋 목차

1. [전투 화면 UI 구성](#1-전투-화면-ui-구성)
2. [전투 진행 흐름](#2-전투-진행-흐름)
3. [수동/자동 전투 모드](#3-수동자동-전투-모드)
4. [핵심 시스템](#4-핵심-시스템)
5. [모바일 최적화](#5-모바일-최적화)
6. [구현 우선순위](#6-구현-우선순위)

---

## 1. 전투 화면 UI 구성

### 1.1 화면 레이아웃 (390×844px)

```
┌─────────────────────────────────────┐
│  Top Bar (50px)                     │  ← 턴 수, 메뉴, End Turn 버튼
├─────────────────────────────────────┤
│                                     │
│  Enemy Area (180px)                 │  ← 적 카드, HP, 의도 표시
│                                     │
├─────────────────────────────────────┤
│  Combat Log (100px)                 │  ← 전투 로그 (스크롤)
├─────────────────────────────────────┤
│  Player Status (60px)               │  ← HP 바, Energy 바
├─────────────────────────────────────┤
│                                     │
│  Hand Area (150px)                  │  ← 카드 핸드 (가로 스크롤)
│                                     │
├─────────────────────────────────────┤
│  Pile Counters (44px)               │  ← Deck, Discard, Banish
└─────────────────────────────────────┘
   Total: 584px (content area)
```

---

### 1.2 상세 UI 요소

#### 🔝 Top Bar (50px)
```
┌─────┬─────────────────────┬─────────┐
│ ☰   │    Turn: 3          │ End Turn│
└─────┴─────────────────────┴─────────┘
```

**기능:**
- **☰ 메뉴 버튼** (왼쪽)
  - 일시정지
  - 항복 (MainLobby 복귀)
  - 설정

- **Turn 카운터** (중앙)
  - 현재 턴 수 표시
  - 참고용

- **End Turn 버튼** (오른쪽)
  - 플레이어 턴 종료
  - 자동 전투 시 "Auto" 토글로 변경

---

#### 👾 Enemy Area (180px)
```
┌──────────────────────────────────────┐
│ Shadow Fiend                    ⚔️  │  ← 이름, 의도 아이콘
│ ████████████░░░░░░░░ 15/18 HP       │  ← HP 바
│                                      │
│ 🔥                     Intent: 3 ATK │  ← 상태, 의도 설명
└──────────────────────────────────────┘
```

**구성 요소:**
1. **적 이름** (상단 좌측)
2. **의도 아이콘** (상단 우측, 원형 배지)
   - ⚔️ 공격
   - 🛡 방어
   - 🔮 스킬
3. **HP 바** (가로 진행 바)
   - 색상 전환: 초록 → 노랑 → 빨강
4. **상태 효과** (하단 좌측, 원형 아이콘)
   - 🔥 화상
   - 💀 독
   - 💪 강화
5. **의도 설명** (하단 우측)
   - "Intent: 3 ATK"
   - "Intent: Heal 5"

---

#### 📜 Combat Log (100px)
```
┌──────────────────────────────────────┐
│ • You dealt 10 damage               │  ← 최근 3개 로그
│ • Enemy attacks for 3 damage        │
│ • You blocked 8 damage              │
└──────────────────────────────────────┘
```

**기능:**
- 최근 3-5개 액션 표시
- 색상 구분:
  - 초록: 플레이어 공격
  - 빨강: 적 공격
  - 회색: 기타
- 스크롤 가능 (세로)

---

#### ❤️ Player Status (60px)
```
┌──────────────────────────────────────┐
│ HP:  7/10  ████████████░░░░          │  ← HP 바
│ EN:  2/3   ████████░░░░░░░░          │  ← Energy 바
└──────────────────────────────────────┘
```

**구성:**
- HP 바 (상단)
  - 색상 전환: 초록 → 노랑 → 빨강
  - 숫자 표시: "7/10"
- Energy 바 (하단)
  - 파랑색
  - 숫자 표시: "2/3"

---

#### 🃏 Hand Area (150px)
```
┌────┬────┬────┬────┬────┐
│ ⚔️ │ 🛡 │ ⚔️ │ 🛡 │ ⚔️ │  ← 카드 아이콘
│  1 │  1 │  5 │  2 │  4 │  ← 에너지 코스트 (우상단 배지)
└────┴────┴────┴────┴────┘
    Strike  Defend  Oblivion  Guardian  Burst
```

**카드 UI:**
- **크기:** 72×101px (작은 카드)
- **배치:** 가로 스크롤 (최대 7장)
- **색상:** 레어리티별 그라디언트
  - Common: 회색
  - Uncommon: 초록
  - Rare: 파랑
  - Epic: 보라
  - Legendary: 금색
- **코스트 배지:** 우상단 원형 (에너지 코스트)
- **플레이 불가:** 회색 처리 + 흐림 효과
- **선택:** 금색 테두리

---

#### 📚 Pile Counters (44px)
```
┌──────────────────────────────────────┐
│   Deck: 8    Discard: 3    Banish: 1 │
└──────────────────────────────────────┘
```

**기능:**
- **Deck:** 남은 덱 카드 수
- **Discard:** 버린 덱 카드 수 (클릭 시 목록 표시)
- **Banish:** 제거된 카드 수 (클릭 시 목록 표시)

---

## 2. 전투 진행 흐름

### 2.1 전투 초기화

```
Combat Starts
     ↓
Load Enemy Data
  - HP, Attack, Defense
  - AI Pattern
  - Intent Queue
     ↓
Load Player Data
  - Current HP from run
  - Deck from DeckBuilder
     ↓
Shuffle Deck
     ↓
Draw Starting Hand (4 cards)
     ↓
Set Energy to 3
     ↓
Display Enemy Intent (Turn 1)
     ↓
Player Turn Begins
```

---

### 2.2 플레이어 턴

```
┌─────────────────────────────────────┐
│ PLAYER TURN                         │
├─────────────────────────────────────┤
│ 1. Draw Phase                       │
│    - Draw 1 card                    │
│    - If deck empty → Shuffle discard│
│                                     │
│ 2. Action Phase                     │
│    - Play cards (spend Energy)      │
│    - Resolve card effects           │
│    - Update HP/Energy state         │
│    - Check hand limit (7 max)       │
│                                     │
│ 3. Player clicks "End Turn"         │
│    - Unused Energy lost             │
│    - Transition to Enemy Turn       │
└─────────────────────────────────────┘
```

**카드 플레이 흐름:**
```
Player taps card
     ↓
Check Energy >= Card Cost?
  NO → Show feedback "Not enough energy"
  YES → Continue
     ↓
Card requires target?
  NO → Auto-target enemy
  YES → Player selects target
     ↓
Spend Energy
     ↓
Resolve Card Effect
  - Deal damage
  - Gain block
  - Apply status
  - Draw cards
     ↓
Move card to Discard Pile
     ↓
Update Combat Log
     ↓
Check hand limit (7)
  - If > 7 → Force discard
```

---

### 2.3 적 턴

```
┌─────────────────────────────────────┐
│ ENEMY TURN                          │
├─────────────────────────────────────┤
│ 1. Execute Intent                   │
│    - Attack: Deal damage to player  │
│    - Defend: Gain block             │
│    - Skill: Apply status/special    │
│                                     │
│ 2. Apply Status Effects             │
│    - Poison damage                  │
│    - Regeneration heal              │
│    - Buff/Debuff tick               │
│                                     │
│ 3. Queue Next Intent                │
│    - Show icon + description        │
│                                     │
│ 4. Transition to Player Turn        │
└─────────────────────────────────────┘
```

---

### 2.4 승리/패배 조건

```
After Each Turn:
     ↓
Check Enemy HP ≤ 0?
  YES → Victory Screen
  NO → Continue
     ↓
Check Player HP ≤ 0?
  YES → Defeat Screen
  NO → Continue
     ↓
Loop to next turn
```

---

## 3. 수동/자동 전투 모드

### 3.1 수동 전투 (Manual Mode)

**특징:**
- 플레이어가 직접 카드 선택
- 전략적 플레이 가능
- 타겟 선택 가능 (멀티 적 시)

**인터랙션:**
1. 카드 **탭** → 선택
2. 적 **탭** → 타겟 지정 (필요 시)
3. **End Turn** 버튼 → 턴 종료

---

### 3.2 자동 전투 (Auto Mode) ⚠️ 모바일 필수

**UI 변화:**
```
┌─────┬─────────────────────┬─────────┐
│ ☰   │    Turn: 3   [🤖]   │  Speed  │  ← Auto 토글 + 속도 버튼
└─────┴─────────────────────┴─────────┘
```

**기능:**
- **🤖 Auto 버튼** (토글)
  - ON: 자동 전투 활성화
  - OFF: 수동 전투 복귀
  
- **Speed 버튼** (자동 전투 시)
  - 1× (보통)
  - 2× (빠름)
  - 3× (매우 빠름)

---

### 3.3 자동 전투 AI 로직

```python
class AutoPlayAI:
    def play_turn(self, hand, energy, enemy):
        """
        간단한 휴리스틱 기반 AI
        """
        playable_cards = [c for c in hand if c.cost <= energy]
        
        # 우선순위 1: HP 낮으면 방어
        if player.hp < player.max_hp * 0.3:
            defense_cards = [c for c in playable_cards if c.type == "Defense"]
            if defense_cards:
                return defense_cards[0]
        
        # 우선순위 2: 에너지 효율 최대화
        sorted_by_efficiency = sorted(
            playable_cards, 
            key=lambda c: c.damage / c.cost,  # 데미지/코스트 비율
            reverse=True
        )
        
        if sorted_by_efficiency:
            return sorted_by_efficiency[0]
        
        # 우선순위 3: 플레이 가능한 아무 카드
        return playable_cards[0] if playable_cards else None
```

**자동 전투 규칙:**
1. **방어 우선:** HP < 30% → 방어 카드 우선
2. **효율 중심:** 데미지/코스트 비율 높은 카드 선택
3. **에너지 소진:** 가능한 많은 카드 플레이
4. **턴 자동 종료:** 플레이 가능 카드 없으면 자동 종료

**속도 배율:**
- 1×: 액션 간 1초 딜레이
- 2×: 액션 간 0.5초 딜레이
- 3×: 액션 간 0.2초 딜레이

---

## 4. 핵심 시스템

### 4.1 데미지 계산

```gdscript
func calculate_damage(base_damage: int, attacker, defender) -> int:
    var final_damage = base_damage
    
    # 공격자 버프 적용
    if attacker.has_status("strength"):
        final_damage += 3
    
    if attacker.has_status("weak"):
        final_damage -= 3
    
    # 방어자 디버프 적용
    if defender.has_status("vulnerable"):
        final_damage = int(final_damage * 1.5)
    
    # 방어력 적용
    var blocked = min(defender.block, final_damage)
    final_damage -= blocked
    defender.block -= blocked
    
    return max(0, final_damage)
```

---

### 4.2 에너지 시스템

```gdscript
class_name CombatManager

var max_energy: int = 3
var current_energy: int = 3

func start_player_turn():
    current_energy = max_energy
    draw_card(1)
    update_energy_ui()

func play_card(card: Card) -> bool:
    if current_energy < card.cost:
        show_feedback("Not enough energy!")
        return false
    
    current_energy -= card.cost
    resolve_card_effect(card)
    move_to_discard(card)
    update_energy_ui()
    return true

func end_player_turn():
    # 에너지는 리셋 (캐리오버 없음)
    current_energy = 0
    start_enemy_turn()
```

---

### 4.3 카드 효과 해석기

```gdscript
func resolve_card_effect(card: Card, target):
    match card.type:
        "attack":
            var damage = calculate_damage(card.damage, player, target)
            target.take_damage(damage)
            add_combat_log("You dealt %d damage" % damage)
        
        "defense":
            player.block += card.block_value
            add_combat_log("You gained %d block" % card.block_value)
        
        "skill":
            if card.effect == "draw":
                draw_card(card.draw_amount)
            elif card.effect == "energy":
                current_energy += card.energy_gain
            elif card.effect == "status":
                target.apply_status(card.status_type, card.duration)
```

---

### 4.4 적 AI 패턴

```gdscript
class Enemy:
    var intent_queue: Array = []
    var turn_count: int = 0
    
    func generate_intent():
        """
        간단한 패턴 기반 AI
        """
        turn_count += 1
        
        # 예시: 2턴마다 강공격
        if turn_count % 2 == 0:
            intent_queue.append({
                "type": "attack",
                "value": attack_power * 1.5,
                "icon": "⚔️"
            })
        else:
            intent_queue.append({
                "type": "attack",
                "value": attack_power,
                "icon": "⚔️"
            })
    
    func execute_turn(player):
        var intent = intent_queue.pop_front()
        
        match intent.type:
            "attack":
                var damage = calculate_damage(intent.value, self, player)
                player.take_damage(damage)
                add_combat_log("Enemy dealt %d damage" % damage)
            
            "defend":
                self.block += intent.value
                add_combat_log("Enemy gained %d block" % intent.value)
        
        generate_intent()  # 다음 턴 의도 생성
```

---

## 5. 모바일 최적화

### 5.1 터치 인터랙션

**카드 플레이:**
```
Option A: 탭 방식 (권장)
1. 카드 탭 → 선택 (금색 테두리)
2. 적 탭 → 타겟 지정
3. 자동 플레이

Option B: 드래그 방식
1. 카드 드래그 시작
2. 적 위로 드래그
3. 드롭 → 플레이

권장: Option A (더 빠르고 정확)
```

**줌/상세 보기:**
```
카드 롱 프레스 (0.5초)
     ↓
모달 팝업 (카드 상세 정보)
  - 큰 카드 이미지
  - 효과 설명
  - [Cancel] [Play] 버튼
```

---

### 5.2 UI 피드백

**액션 피드백:**
- 카드 플레이: 빛나는 효과 + 사운드
- 데미지: 숫자 튀어오름 (Damage Popup)
- HP 변화: 바 애니메이션 (0.3초)
- 턴 전환: 페이드 효과

**햅틱 피드백:**
- 카드 플레이: 짧은 진동
- 데미지 받음: 중간 진동
- 승리/패배: 긴 진동

---

### 5.3 자동 전투 필수성

**이유:**
- ✅ **모바일 게임 표준:** 방치/아이들 게임 필수 기능
- ✅ **사용자 편의:** 반복 전투 스킵
- ✅ **시간 절약:** 빠른 진행 가능
- ✅ **접근성:** 전략 게임에 익숙하지 않은 유저 지원

**구현 우선순위:**
- Phase 1: 수동 전투만 구현
- Phase 2: 기본 자동 전투 AI
- Phase 3: 속도 조절 + 최적화

---

## 6. 구현 우선순위

### Phase 1: 기본 전투 (3-4일)
**목표:** 플레이 가능한 전투 시스템

- [x] Combat 화면 UI
- [x] CombatManager.gd (턴 관리)
- [x] 카드 플레이 로직
- [x] 데미지 계산
- [x] 간단한 적 AI (공격만)
- [x] 승리/패배 판정
- [x] 수동 전투만

**테스트 데이터:**
- 10개 기본 카드 (Attack/Defend)
- 3종 적 (약/중/강)

---

### Phase 2: 자동 전투 (1-2일)
**목표:** 자동 플레이 AI

- [x] Auto 토글 버튼
- [x] AutoPlayAI 클래스
- [x] 간단한 휴리스틱 AI
- [x] 속도 조절 (1×/2×/3×)

---

### Phase 3: 폴리싱 (1-2일)
**목표:** UX 개선

- [x] 애니메이션 추가
- [x] 사운드 효과
- [x] 햅틱 피드백
- [x] 카드 상세 모달
- [x] Pile 카운터 클릭 기능

---

### Phase 4: 고급 기능 (추후)
**목표:** 콘텐츠 확장

- [ ] 상태 효과 시스템
- [ ] 복잡한 적 AI 패턴
- [ ] 멀티 타겟
- [ ] 카드 시너지
- [ ] 전투 통계

---

## 📊 최종 체크리스트

### 🔴 Phase 1: 기본 전투 (필수)
- [ ] c08-combat.tscn (UI)
- [ ] CombatManager.gd (로직)
- [ ] 카드 플레이 시스템
- [ ] 데미지 계산
- [ ] 간단한 적 AI
- [ ] 승리/패배 화면 연동

### 🟡 Phase 2: 자동 전투 (중요)
- [ ] Auto 모드 토글
- [ ] AutoPlayAI 구현
- [ ] 속도 조절

### 🟢 Phase 3: 폴리싱 (선택)
- [ ] 애니메이션
- [ ] 사운드
- [ ] 상세 모달

---

## 🎯 다음 단계

**지금 시작:** c08-combat 화면 UI 구현  
**예상 시간:** 8시간 (1일)  
**결과물:** 플레이 가능한 기본 전투

---

**작성:** Atlas  
**날짜:** 2026-02-24  
**버전:** 1.0
