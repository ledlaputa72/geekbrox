# Turn-Based Implementation Guide - Dream Collector

**작성일**: 2026-02-26  
**작성자**: Atlas  
**용도**: Cursor IDE로 턴제 전투 시스템 개발  
**목표**: Slay the Spire 스타일 턴제 시스템 구현 + ATB와 비교 테스트

---

## 📋 목차

1. [턴제 시스템 설계](#1-턴제-시스템-설계)
2. [시스템 변경 영향도 분석](#2-시스템-변경-영향도-분석)
3. [게임플레이 비교](#3-게임플레이-비교)
4. [Cursor 개발 가이드](#4-cursor-개발-가이드)
5. [구현 계획](#5-구현-계획)
6. [최종 비교표](#6-최종-비교표)
7. [완성 체크리스트](#7-완성-체크리스트)

---

## 1. 턴제 시스템 설계

### 1.1 전투 흐름 (Turn-Based Structure)

#### 기본 구조
```
전투 시작
  ↓
[플레이어 턴]
  1. 턴 시작 효과 (버프/디버프 처리)
  2. 에너지 충전 (기본 3개)
  3. 카드 드로우 (손패 5장 채우기)
  4. 플레이어 행동:
     - 카드 플레이 (에너지 소비)
     - 여러 카드 순차 사용 가능
     - "턴 종료" 버튼 클릭
  5. 턴 종료 효과 (블록 초기화)
  ↓
[적 턴]
  1. 턴 시작 효과
  2. 각 적이 "의도(Intent)" 실행
     - 공격 → Hero에게 데미지
     - 버프 → 자신 강화
     - 디버프 → Hero 약화
  3. 턴 종료 효과
  ↓
다시 [플레이어 턴]으로

전투 종료 조건:
- Victory: 모든 적 HP 0
- Defeat: Hero HP 0
```

#### Slay the Spire와의 차이점

| 항목 | Slay the Spire | Dream Collector (턴제) |
|------|---------------|----------------------|
| **에너지** | 턴당 3개 (업그레이드 가능) | 턴당 3개 (고정) |
| **손패** | 5장 (최대 10장) | 5장 (최대 8장) |
| **드로우** | 턴 시작 시 5장 채우기 | 동일 |
| **블록** | 턴 종료 시 소멸 | 동일 |
| **적 의도** | 다음 행동 미리 표시 | 동일 (간소화) |
| **복잡도** | 매우 높음 (유물, 포션 등) | 중간 (카드+기본 메카닉만) |

---

### 1.2 에너지 시스템 재정의

#### 현재 (ATB)
```gdscript
# 시간 기반 회복
var energy_timer: float = 0.0
const ENERGY_TIMER_DURATION: float = 5.0  # 5초당 1개

# 최대치 도달 시 카드만 드로우
if hero.energy >= ENERGY_MAX:
    draw_card()
else:
    hero.energy += 1
    draw_card()
```

#### 턴제 (목표)
```gdscript
# 턴 시작 시 에너지 리셋
func _start_player_turn():
    hero.energy = ENERGY_MAX  # 항상 3개로 리셋
    energy_changed.emit(hero.energy, ENERGY_MAX)
    add_log("Turn %d: Energy restored to %d ⚡" % [turn_count, ENERGY_MAX])

# 에너지 소비 (카드 플레이)
func play_card(card_index: int, target_index: int = -1) -> bool:
    if hero.energy < card.cost:
        add_log("Not enough energy!")
        return false
    
    hero.energy -= card.cost
    energy_changed.emit(hero.energy, ENERGY_MAX)
    # ... (카드 효과 적용)
```

**주요 변경점**:
- ❌ 제거: `energy_timer`, `_update_energy_timer()`
- ✅ 추가: 턴당 에너지 리셋
- ✅ 간소화: 시간 관리 없음

**밸런싱**:
- 기본 에너지: 3개
- 턴당 1-2장 카드 플레이 (평균 cost 1.5)
- 에너지 증가 카드: +1 또는 +2
- 에너지 감소 효과: 적 디버프

---

### 1.3 카드 플레이 메카닉

#### 손패 관리 시스템

**손패 상태**:
```gdscript
# DeckManager.gd에 추가
var hand: Array = []           # 현재 손패 (최대 8장)
var hand_size_max: int = 8     # 손패 상한
var hand_size_base: int = 5    # 턴 시작 시 채울 목표

func draw_to_hand_size():
    """턴 시작: 손패를 5장까지 채우기"""
    var to_draw = hand_size_base - hand.size()
    if to_draw > 0:
        draw_cards(to_draw)

func is_hand_full() -> bool:
    return hand.size() >= hand_size_max
```

**드로우 메카닉**:
1. **턴 시작**: 손패 5장 채우기
2. **카드 효과**: 추가 드로우 (예: "Draw 2")
3. **손패 초과**: 8장 넘으면 드로우 불가
4. **덱 소진**: 버린 카드 더미 → 덱으로 셔플

#### 카드 선택 UI

**현재 (ATB)**: 자동 선택 또는 간단한 클릭

**턴제 (목표)**: 드래그 앤 드롭

```
손패 UI (하단):
┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐
│ 1⚡│ │ 2⚡│ │ 1⚡│ │ 0⚡│ │ 3⚡│
│Strike│Defense│Slash│Power│Heavy│
└────┘ └────┘ └────┘ └────┘ └────┘
   ↑ 드래그 가능
   ↓
[적 또는 플레이 영역으로 드롭]
```

**구현 방식**:
- **CardHandUI.tscn**: 손패 카드 5개 배치
- **CardItem.tscn**: 개별 카드 (드래그 가능)
- **드래그**: `_get_drag_data()`, `_can_drop_data()`, `_drop_data()`
- **타겟 선택**: 
  - 단일 타겟 카드 → 적 위로 드롭
  - 자기 버프 → 플레이 영역에 드롭

**카드 사용 타이밍**:
- 순서 무관 (에너지만 충분하면 언제든)
- 한 턴에 여러 카드 가능
- 카드 효과 즉시 적용

---

### 1.4 적 행동 패턴 (Intent System)

#### 의도(Intent) 표시 시스템

**Slay the Spire 방식**:
```
👾 Monster A
HP: 25/30
Intent: [⚔️ 8] (공격 8 예정)

👹 Monster B
HP: 40/40
Intent: [🛡️ 6] (방어 6 예정)
```

**Dream Collector 간소화 버전**:
```gdscript
# Monster 데이터에 actions 추가
{
    "id": "slime_01",
    "name": "Slime",
    "hp": 20,
    "max_hp": 20,
    "actions": [
        {"type": "attack", "damage": 6, "icon": "⚔️"},
        {"type": "attack", "damage": 8, "icon": "⚔️"},
        {"type": "defend", "block": 5, "icon": "🛡️"}
    ]
}

# 턴제 시스템
func _prepare_enemy_turn():
    """적 턴 준비: 의도 선택"""
    for i in range(monsters.size()):
        var monster = monsters[i]
        if monster.hp > 0:
            # 랜덤 또는 패턴 기반으로 행동 선택
            var action = _choose_monster_action(monster)
            monster["next_action"] = action
            
            # UI에 의도 표시
            intent_updated.emit("monster", i, action)

func _execute_enemy_turn():
    """적 턴 실행: 의도 실행"""
    for i in range(monsters.size()):
        var monster = monsters[i]
        if monster.hp > 0:
            var action = monster.get("next_action", {})
            _execute_monster_action(i, action)
```

**의도 UI**:
- 적 캐릭터 위에 말풍선
- 아이콘 + 수치 (⚔️ 8, 🛡️ 5)
- 플레이어 턴 동안 표시 → 적 턴에 실행

**행동 타입**:
1. **공격 (attack)**: Hero에게 데미지
2. **강화 (buff)**: 자신 ATK/DEF 증가
3. **약화 (debuff)**: Hero 약화
4. **방어 (defend)**: 블록 획득
5. **특수 (special)**: 고유 패턴 (보스만)

---

### 1.5 턴 관리 시스템

**새로운 변수**:
```gdscript
# CombatManagerTurnBased.gd
enum TurnPhase {
    PLAYER_TURN_START,    # 에너지 리셋, 드로우
    PLAYER_TURN_MAIN,     # 플레이어 행동 중
    PLAYER_TURN_END,      # 블록 소멸, 효과 처리
    ENEMY_TURN_START,     # 적 턴 시작
    ENEMY_TURN_MAIN,      # 적 행동 실행 (애니메이션)
    ENEMY_TURN_END,       # 효과 처리
}

var current_phase: TurnPhase = TurnPhase.PLAYER_TURN_START
var turn_count: int = 1
var is_player_turn: bool = true
```

**턴 전환 흐름**:
```gdscript
func _start_player_turn():
    """플레이어 턴 시작"""
    current_phase = TurnPhase.PLAYER_TURN_START
    is_player_turn = true
    turn_count += 1
    
    # 1. 턴 시작 효과 (버프/디버프 감소)
    _process_turn_start_effects("hero")
    
    # 2. 에너지 리셋
    hero.energy = ENERGY_MAX
    energy_changed.emit(hero.energy, ENERGY_MAX)
    
    # 3. 블록 초기화 (이전 턴 블록 소멸)
    hero.block = 0
    entity_updated.emit("hero", 0)
    
    # 4. 손패 채우기 (5장까지)
    DeckManager.draw_to_hand_size()
    
    # 5. UI 업데이트
    current_phase = TurnPhase.PLAYER_TURN_MAIN
    add_log("=== Turn %d: Your Turn ===" % turn_count)
    turn_phase_changed.emit("player", turn_count)

func end_player_turn():
    """플레이어가 "턴 종료" 버튼 클릭"""
    current_phase = TurnPhase.PLAYER_TURN_END
    
    # 턴 종료 효과 (카드 효과 등)
    _process_turn_end_effects("hero")
    
    # 손패 남은 카드 → 버린 카드 더미
    # (Slay the Spire는 남김, 선택 사항)
    
    # 적 턴 시작
    await get_tree().create_timer(0.5).timeout
    _start_enemy_turn()

func _start_enemy_turn():
    """적 턴 시작"""
    current_phase = TurnPhase.ENEMY_TURN_START
    is_player_turn = false
    
    add_log("=== Enemy Turn ===")
    
    # 1. 턴 시작 효과
    for i in range(monsters.size()):
        if monsters[i].hp > 0:
            _process_turn_start_effects("monster", i)
    
    # 2. 블록 초기화
    for monster in monsters:
        monster.block = 0
    
    # 3. 행동 실행
    current_phase = TurnPhase.ENEMY_TURN_MAIN
    await _execute_enemy_turn()
    
    # 4. 턴 종료
    current_phase = TurnPhase.ENEMY_TURN_END
    await get_tree().create_timer(0.5).timeout
    
    # 5. 플레이어 턴 시작
    _start_player_turn()

func _execute_enemy_turn():
    """적 행동 실행 (순차적 애니메이션)"""
    for i in range(monsters.size()):
        var monster = monsters[i]
        if monster.hp > 0:
            var action = monster.get("next_action", {})
            _execute_monster_action(i, action)
            
            # 애니메이션 대기
            await get_tree().create_timer(0.8).timeout
    
    # 전투 종료 체크
    _check_combat_end()
```

**턴 종료 버튼**:
- CombatUI에 큰 버튼 추가
- 플레이어 턴에만 활성화
- 클릭 시 `end_player_turn()` 호출
- 단축키: Space 또는 Enter

---

## 2. 시스템 변경 영향도 분석

### 2.1 기존 시스템 변경사항

#### CombatManager.gd → CombatManagerTurnBased.gd

**제거할 코드** (~150 라인):
```gdscript
# ATB 관련 전부 제거
const ATB_MAX: float = 100.0
const ATB_CHARGE_RATE: float = 1.0
var atb_gauges: Dictionary = {}

func _update_atb(delta: float)
func _check_atb_turns()
signal atb_gauge_updated(...)

# 에너지 타이머 제거
var energy_timer: float = 0.0
const ENERGY_TIMER_DURATION: float = 5.0
func _update_energy_timer(delta: float)
signal energy_timer_updated(progress: float)

# 자동전투 제거 (턴제는 수동만)
var auto_battle_enabled: bool = false
var auto_battle_delay: float = 0.5
func toggle_auto_battle()
func _update_auto_battle(delta: float)

# 속도 제어 제거 (턴제는 타이밍 무관)
var speed_multiplier: float = 1.0
func set_speed_multiplier(multiplier: float)
```

**추가할 코드** (~200 라인):
```gdscript
# 턴 관리
enum TurnPhase { PLAYER_TURN_START, PLAYER_TURN_MAIN, ... }
var current_phase: TurnPhase
var turn_count: int = 1
var is_player_turn: bool = true

func _start_player_turn()
func end_player_turn()  # Public! (UI에서 호출)
func _start_enemy_turn()
func _execute_enemy_turn()

# 의도 시스템
func _prepare_enemy_turn()  # 의도 선택
func _choose_monster_action(monster) -> Dictionary
signal intent_updated(entity_type: String, index: int, action: Dictionary)

# 효과 처리
func _process_turn_start_effects(entity_type: String, index: int = 0)
func _process_turn_end_effects(entity_type: String, index: int = 0)

# 손패 관리 통합
# (DeckManager와 긴밀한 연동)
```

**변경할 코드**:
```gdscript
# _process(delta) 거의 빈 함수
func _process(delta):
    # 턴제는 프레임 업데이트 불필요
    # 애니메이션만 처리
    pass

# start_combat() 수정
func start_combat(monster_data: Array):
    # ... (기존 초기화) ...
    
    # ATB 초기화 제거
    # 턴 시스템 초기화
    turn_count = 0
    
    # 적 의도 준비
    _prepare_enemy_turn()
    
    # 첫 턴 시작
    _start_player_turn()
```

**영향도 요약**:
- 삭제: ~150 라인
- 추가: ~200 라인
- 수정: ~50 라인
- **순 증가**: ~100 라인 (500 라인 → 600 라인)

---

#### DeckManager.gd 확장

**현재 기능**:
```gdscript
# 덱 관리
var deck: Array = []
var hand: Array = []
var discard: Array = []
var exile: Array = []

func initialize_combat_deck(card_ids: Array)
func draw_card() -> Dictionary
func draw_cards(count: int)
func play_card(card_index: int)
func shuffle_discard_into_deck()
```

**추가 필요 기능** (~100 라인):
```gdscript
# 손패 크기 관리
const HAND_SIZE_BASE: int = 5
const HAND_SIZE_MAX: int = 8

func draw_to_hand_size():
    """턴 시작: 손패를 5장까지 채우기"""
    var to_draw = HAND_SIZE_BASE - hand.size()
    if to_draw > 0:
        draw_cards(to_draw)

func is_hand_full() -> bool:
    return hand.size() >= HAND_SIZE_MAX

func get_hand_size() -> int:
    return hand.size()

func get_deck_size() -> int:
    return deck.size()

func get_discard_size() -> int:
    return discard.size()

# 카드 검색
func find_card_in_hand(card_id: String) -> int:
    for i in range(hand.size()):
        if hand[i].id == card_id:
            return i
    return -1

# 디버그
func get_combat_state() -> Dictionary:
    return {
        "deck_count": deck.size(),
        "hand_count": hand.size(),
        "discard_count": discard.size(),
        "exile_count": exile.size()
    }
```

**영향도**: DeckManager.gd +100 라인 (200 → 300)

---

#### UI 변경사항

**InRun_v4.gd**:
- ATB 게이지 제거
- 턴 카운터 추가
- 의도 말풍선 추가
- 손패 UI 교체

**CombatBottomUI** (대폭 개편):

현재 (ATB):
```
[Auto] [1×] [2×] [3×]
[⚡⚡⚡] [████████░░] 80%
[Card Hand] (간단)
```

목표 (턴제):
```
Turn 5          Energy: ⚡⚡⚡ (3/3)

┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐
│ 1⚡│ │ 2⚡│ │ 1⚡│ │ 0⚡│ │ 3⚡│
│Strike│Defense│Slash│Power│Heavy│
└────┘ └────┘ └────┘ └────┘ └────┘
(드래그 가능)

[        End Turn (Space)         ]
Deck: 15 | Discard: 8 | Exile: 0
```

**새로 필요한 UI**:
1. **CardHandUI.tscn**: 손패 5장 배치
2. **CardItem.tscn**: 개별 카드 (드래그 가능)
3. **IntentBubble.tscn**: 적 의도 말풍선
4. **TurnCounter.tscn**: 턴 카운터 + 정보

**예상 작업량**: UI 리빌드 8-10 시간

---

### 2.2 새로 필요한 시스템

#### 1. TurnManager (옵션)

**역할**: 턴 흐름 제어를 CombatManager에서 분리

```gdscript
# autoload/TurnManager.gd (선택 사항)
extends Node

signal turn_started(turn_count: int, is_player: bool)
signal turn_ended(turn_count: int, is_player: bool)
signal phase_changed(phase: String)

var turn_count: int = 0
var is_player_turn: bool = true

func start_player_turn():
    turn_count += 1
    is_player_turn = true
    turn_started.emit(turn_count, true)

func end_player_turn():
    is_player_turn = false
    turn_ended.emit(turn_count, true)

func start_enemy_turn():
    is_player_turn = false
    turn_started.emit(turn_count, false)

func end_enemy_turn():
    turn_ended.emit(turn_count, false)
```

**장점**: 관심사 분리, 테스트 용이  
**단점**: 추가 복잡도  
**권장**: ❌ 첫 구현에선 불필요 (CombatManager에 통합)

---

#### 2. HandManager (옵션)

**역할**: 손패 UI 관리 (DeckManager와 별도)

```gdscript
# ui/combat/HandManager.gd
extends Control

@onready var card_container = $CardContainer

var card_items: Array[CardItem] = []

func update_hand(cards: Array):
    """DeckManager의 손패를 UI에 표시"""
    # 기존 카드 정리
    for item in card_items:
        item.queue_free()
    card_items.clear()
    
    # 새 카드 생성
    for i in range(cards.size()):
        var card = cards[i]
        var item = CardItemScene.instantiate()
        item.setup(card, i)
        item.card_played.connect(_on_card_played)
        card_container.add_child(item)
        card_items.append(item)

func _on_card_played(card_index: int, target_index: int):
    CombatManager.play_card(card_index, target_index)
```

**권장**: ✅ 필요 (UI 복잡도 높음)

---

#### 3. IntentDisplay 시스템

**구조**:
```
CharacterNode (Monster)
  ├─ HP Bar
  ├─ Sprite
  └─ IntentBubble (새로 추가)
      ├─ Icon (⚔️, 🛡️, etc.)
      └─ Value (숫자)
```

**IntentBubble.gd**:
```gdscript
extends Control

@onready var icon_label = $Icon
@onready var value_label = $Value

func show_intent(action: Dictionary):
    """의도 표시: {type: "attack", damage: 8, icon: "⚔️"}"""
    icon_label.text = action.get("icon", "❓")
    
    if action.type == "attack":
        value_label.text = str(action.damage)
        modulate = Color(1, 0.5, 0.5)  # 빨강
    elif action.type == "defend":
        value_label.text = str(action.block)
        modulate = Color(0.5, 0.5, 1)  # 파랑
    elif action.type == "buff":
        value_label.text = "↑"
        modulate = Color(0.5, 1, 0.5)  # 초록
    
    visible = true

func hide_intent():
    visible = false
```

**권장**: ✅ 필수 (턴제 핵심 UI)

---

#### 4. 카드 드래그 앤 드롭 UI

**CardItem.gd** (드래그 가능한 카드):
```gdscript
extends Control

var card_data: Dictionary = {}
var card_index: int = -1
var is_dragging: bool = false

signal card_played(card_index: int, target_index: int)

# ─── Drag & Drop ──────────────────────────────────────

func _get_drag_data(at_position):
    """드래그 시작"""
    is_dragging = true
    
    # 드래그 프리뷰 (반투명 복사본)
    var preview = self.duplicate()
    preview.modulate.a = 0.7
    set_drag_preview(preview)
    
    return {"card_index": card_index, "card": card_data}

func _can_drop_data(at_position, data):
    """드롭 가능 여부 (항상 true, 타겟은 드롭 영역이 판단)"""
    return true

func _notification(what):
    if what == NOTIFICATION_DRAG_END:
        is_dragging = false

# ─── Target Selection ─────────────────────────────────

# (드롭은 Monster Node 또는 Play Area에서 처리)
```

**DropZone (Monster 위)**:
```gdscript
# CharacterNode.gd에 추가
func _can_drop_data(at_position, data):
    """이 Monster가 타겟 가능한지"""
    if not data.has("card_index"):
        return false
    
    var card = data.card
    var target_type = card.get("target", "none")
    
    # 단일 타겟 카드만 드롭 가능
    return target_type == "single"

func _drop_data(at_position, data):
    """카드 드롭 → 플레이"""
    var card_index = data.card_index
    var monster_index = get_index()  # 이 Monster의 인덱스
    
    # CombatManager에 카드 플레이 요청
    CombatManager.play_card(card_index, monster_index)
```

**권장**: ✅ 필수 (턴제 핵심 상호작용)

---

## 3. 게임플레이 비교

### 3.1 플레이 타임

| 시나리오 | ATB (현재) | 턴제 (목표) | 비고 |
|---------|-----------|-----------|------|
| **일반 전투** | 30-60초 | 2-4분 | 턴제 4-8배 느림 |
| **보스전** | 1-2분 | 5-10분 | 턴제 5배 느림 |
| **전체 런** | 15-20분 | 30-60분 | 턴제 2-3배 느림 |

**분석**:
- ATB: 빠른 파밍, 짧은 플레이 세션
- 턴제: 깊은 전략, 한 판이 무거움
- 모바일: ATB 유리 (출퇴근 시간)
- PC: 턴제 유리 (집중 플레이)

---

### 3.2 전략적 깊이

#### ATB (자동전투)
- **사전 전략**: 덱 구성이 90%
- **전투 중**: 수동 개입 10%
- **실수 여지**: 낮음 (AI가 처리)
- **학습 곡선**: 완만
- **마스터리**: 덱 빌딩 능력

#### 턴제 (수동 조작)
- **사전 전략**: 덱 구성 50%
- **전투 중**: 카드 순서, 타이밍 50%
- **실수 여지**: 높음 (순서 실수 치명적)
- **학습 곡선**: 가파름
- **마스터리**: 덱 빌딩 + 전투 센스

**심층 분석**:

| 전략 요소 | ATB | 턴제 | 승자 |
|----------|-----|------|------|
| 덱 구성 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 동등 |
| 카드 순서 | ⭐ (AI) | ⭐⭐⭐⭐⭐ | 턴제 |
| 자원 관리 | ⭐⭐ | ⭐⭐⭐⭐⭐ | 턴제 |
| 적 예측 | ⭐⭐ | ⭐⭐⭐⭐⭐ | 턴제 |
| 리스크 관리 | ⭐⭐ | ⭐⭐⭐⭐⭐ | 턴제 |
| 콤보 빌드 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 턴제 |

**결론**: 턴제가 전략적 깊이 2-3배 높음

---

### 3.3 난이도 곡선

**ATB**:
```
난이도
 ↑
 │           ┌─────── 덱 빌딩 숙련
 │         ╱
 │       ╱
 │     ╱  (자동전투 의존)
 │   ╱
 │ ╱
 └─────────────────────────> 플레이 시간
  쉬움  중간  어려움
```

**턴제**:
```
난이도
 ↑
 │                 ┌───── 전투 센스 숙련
 │               ╱
 │             ╱
 │         ┌─╱  (덱 빌딩 + 전투)
 │       ╱
 │   ┌─╱
 │ ╱
 └─────────────────────────> 플레이 시간
  쉬움  중간  어려움  고수
```

**학습 곡선 비교**:
- ATB: 1-2시간 이해 → 5-10시간 마스터
- 턴제: 3-5시간 이해 → 20-50시간 마스터

**밸런싱 난이도**:
- ATB: 상대적 쉬움 (AI 조정만)
- 턴제: 어려움 (카드 조합 무한대)

---

## 4. Cursor 개발 가이드

### 4.1 구현 순서 (5 Phases)

#### Phase 1: 턴 시스템 프레임워크 (60분)

**목표**: CombatManagerTurnBased.gd 기본 골격 생성

**Task 1-1: CombatManagerTurnBased.gd 생성**

Cursor 프롬프트:
```
@autoload/CombatManagerBase.gd

새 파일을 만들어줘: autoload/CombatManagerTurnBased.gd

이 파일은 턴제 전투 시스템 구현체야.

```gdscript
extends CombatManagerBase

# ─── Turn-Based Signals ───────────────────────────────

signal turn_phase_changed(phase: String, turn_count: int, is_player: bool)
signal intent_updated(entity_type: String, index: int, action: Dictionary)
signal player_turn_ended()
signal enemy_turn_ended()

# ─── Turn System ──────────────────────────────────────

enum TurnPhase {
    PLAYER_TURN_START,
    PLAYER_TURN_MAIN,
    PLAYER_TURN_END,
    ENEMY_TURN_START,
    ENEMY_TURN_MAIN,
    ENEMY_TURN_END
}

var current_phase: TurnPhase = TurnPhase.PLAYER_TURN_START
var turn_count: int = 0
var is_player_turn: bool = true

# ─── Energy System (턴제) ─────────────────────────────

const ENERGY_MAX: int = 3

# ─── Lifecycle ────────────────────────────────────────

func _process(delta):
    # 턴제는 프레임 업데이트 불필요
    pass

# ─── Combat Start/End ─────────────────────────────────

func start_combat(monster_data: Array):
    in_combat = true
    combat_log.clear()
    turn_count = 0
    
    # Initialize Hero
    hero = {
        "name": "Hero",
        "hp": 80,
        "max_hp": 80,
        "atk": 10,
        "def": 2,
        "spd": 10,  # 턴제에선 미사용 (호환성)
        "eva": 5,
        "energy": ENERGY_MAX,
        "block": 0
    }
    
    # Initialize Monsters
    monsters.clear()
    for m_data in monster_data:
        var monster = m_data.duplicate()
        monster["block"] = 0
        monster["next_action"] = {}  # 의도 저장
        monsters.append(monster)
    
    # Initialize Deck
    var starting_deck = _get_starting_deck()
    DeckManager.initialize_combat_deck(starting_deck)
    
    add_log("Combat started! (Turn-Based Mode)")
    add_log("Hero vs %d monsters" % monsters.size())
    
    # 적 의도 준비
    _prepare_enemy_turn()
    
    # 첫 턴 시작
    _start_player_turn()

func end_combat():
    in_combat = false
    hero.clear()
    monsters.clear()
    combat_log.clear()
    turn_count = 0

# ─── Turn Flow ────────────────────────────────────────

func _start_player_turn():
    """플레이어 턴 시작"""
    current_phase = TurnPhase.PLAYER_TURN_START
    is_player_turn = true
    turn_count += 1
    
    # 1. 턴 시작 효과
    _process_turn_start_effects("hero")
    
    # 2. 에너지 리셋
    hero.energy = ENERGY_MAX
    energy_changed.emit(hero.energy, ENERGY_MAX)
    
    # 3. 블록 초기화
    hero.block = 0
    entity_updated.emit("hero", 0)
    
    # 4. 손패 채우기
    DeckManager.draw_to_hand_size()
    
    # 5. UI 업데이트
    current_phase = TurnPhase.PLAYER_TURN_MAIN
    add_log("=== Turn %d: Your Turn ===" % turn_count)
    turn_phase_changed.emit("player_turn_start", turn_count, true)

func end_player_turn():
    """플레이어가 턴 종료 (Public API)"""
    current_phase = TurnPhase.PLAYER_TURN_END
    
    add_log("Player turn ended")
    player_turn_ended.emit()
    
    # 턴 종료 효과
    _process_turn_end_effects("hero")
    
    # 적 턴 시작
    await get_tree().create_timer(0.5).timeout
    _start_enemy_turn()

func _start_enemy_turn():
    """적 턴 시작"""
    current_phase = TurnPhase.ENEMY_TURN_START
    is_player_turn = false
    
    add_log("=== Enemy Turn ===")
    turn_phase_changed.emit("enemy_turn_start", turn_count, false)
    
    # 1. 턴 시작 효과
    for i in range(monsters.size()):
        if monsters[i].hp > 0:
            _process_turn_start_effects("monster", i)
    
    # 2. 블록 초기화
    for monster in monsters:
        monster.block = 0
    
    # 3. 행동 실행
    current_phase = TurnPhase.ENEMY_TURN_MAIN
    await _execute_enemy_turn()
    
    # 4. 턴 종료
    current_phase = TurnPhase.ENEMY_TURN_END
    enemy_turn_ended.emit()
    
    # 다음 적 의도 준비
    _prepare_enemy_turn()
    
    # 5. 플레이어 턴 시작
    await get_tree().create_timer(0.5).timeout
    _start_player_turn()

func _execute_enemy_turn():
    """적 행동 실행 (순차적)"""
    for i in range(monsters.size()):
        var monster = monsters[i]
        if monster.hp > 0:
            var action = monster.get("next_action", {})
            await _execute_monster_action(i, action)
            await get_tree().create_timer(0.8).timeout
    
    _check_combat_end()

# ─── Monster AI (Intent) ──────────────────────────────

func _prepare_enemy_turn():
    """적 턴 의도 선택"""
    for i in range(monsters.size()):
        var monster = monsters[i]
        if monster.hp > 0:
            var action = _choose_monster_action(monster)
            monster["next_action"] = action
            intent_updated.emit("monster", i, action)

func _choose_monster_action(monster: Dictionary) -> Dictionary:
    """Monster 행동 선택 (랜덤)"""
    var actions = monster.get("actions", [])
    if actions.is_empty():
        # Fallback: 기본 공격
        return {"type": "attack", "damage": monster.atk, "icon": "⚔️"}
    
    # 랜덤 선택
    return actions.pick_random()

func _execute_monster_action(monster_index: int, action: Dictionary):
    """Monster 행동 실행"""
    var monster = monsters[monster_index]
    
    match action.type:
        "attack":
            var damage = _calculate_damage(action.damage, hero.def, hero.eva)
            if damage > 0:
                _apply_damage(hero, damage)
                add_log("%s attacked Hero for %d damage" % [monster.name, damage])
                damage_dealt.emit("hero", 0, damage, false)
            else:
                add_log("%s attacked but missed!" % monster.name)
        
        "defend":
            monster.block += action.block
            add_log("%s gained %d Block 🛡" % [monster.name, action.block])
        
        "buff":
            monster[action.stat] += action.value
            add_log("%s buffed %s +%d" % [monster.name, action.stat.to_upper(), action.value])
    
    entity_updated.emit("monster", monster_index)
    entity_updated.emit("hero", 0)
    
    _check_combat_end()

# ─── Effects ──────────────────────────────────────────

func _process_turn_start_effects(entity_type: String, index: int = 0):
    """턴 시작 효과 처리 (버프/디버프 등)"""
    # TODO: 버프/디버프 시스템 추가 시 구현
    pass

func _process_turn_end_effects(entity_type: String, index: int = 0):
    """턴 종료 효과 처리"""
    # TODO: 지속 효과 등
    pass

# ─── Card Play (턴제 버전) ────────────────────────────

func play_card(card_index: int, target_index: int = -1) -> bool:
    """카드 플레이 (플레이어 턴에만 가능)"""
    if not is_player_turn:
        add_log("Not your turn!")
        return false
    
    if current_phase != TurnPhase.PLAYER_TURN_MAIN:
        add_log("Cannot play cards now!")
        return false
    
    # (나머지 로직은 ATB와 동일)
    # ... (에너지 체크, 타겟 체크, 효과 적용)
    
    return true

# ─── Utility ──────────────────────────────────────────

func _get_starting_deck() -> Array:
    return [
        "attack_01", "attack_01", "attack_01", "attack_01",
        "attack_03", "attack_03", "attack_03",
        "defense_01", "defense_01", "defense_01", "defense_01",
        "skill_02"
    ]
```

project.godot 업데이트는 아직 하지 마 (Phase 5에서).
```

**예상 결과**: CombatManagerTurnBased.gd 골격 완성 (400 라인)

---

**Task 1-2: play_card() 완전 구현**

Cursor 프롬프트:
```
@autoload/CombatManagerTurnBased.gd

play_card() 함수를 완전히 구현해줘.

ATB 버전 참고:
@autoload/CombatManagerATB.gd

하지만 턴제 버전은:
1. is_player_turn 체크 필수
2. current_phase가 PLAYER_TURN_MAIN일 때만
3. 에너지 체크, 타겟 체크 동일
4. 카드 효과 적용 (_apply_card_effects)
5. DeckManager.play_card() 호출

_apply_card_effects()도 ATB 버전 그대로 복사해줘.
```

---

**Phase 1 테스트**:
```bash
# 아직 Godot 실행 안 함 (Phase 5까지 완성 후)
# 코드 검증만:
1. 문법 에러 없는지 (GDScript 체크)
2. 함수 시그니처 맞는지
3. CombatManagerBase 상속 확인
```

---

#### Phase 2: DeckManager 확장 (45분)

**목표**: 손패 관리 기능 추가

**Task 2-1: 손패 크기 관리**

Cursor 프롬프트:
```
@autoload/DeckManager.gd

손패 관리 기능을 추가해줘:

```gdscript
# 상수
const HAND_SIZE_BASE: int = 5  # 턴 시작 시 목표
const HAND_SIZE_MAX: int = 8   # 최대 손패

# 함수 추가
func draw_to_hand_size():
    """턴 시작: 손패를 5장까지 채우기"""
    var current_size = hand.size()
    var to_draw = HAND_SIZE_BASE - current_size
    
    if to_draw > 0:
        draw_cards(to_draw)
        print("[DeckManager] Drew %d cards to fill hand (now %d)" % [to_draw, hand.size()])

func is_hand_full() -> bool:
    """손패가 꽉 찼는지"""
    return hand.size() >= HAND_SIZE_MAX

func get_hand_size() -> int:
    return hand.size()

func get_deck_size() -> int:
    return deck.size()

func get_discard_size() -> int:
    return discard.size()

func get_exile_size() -> int:
    return exile.size()

func get_combat_state() -> Dictionary:
    """전투 상태 (디버그용)"""
    return {
        "deck_count": deck.size(),
        "hand_count": hand.size(),
        "discard_count": discard.size(),
        "exile_count": exile.size()
    }
```

draw_cards() 함수도 수정해서 손패 상한 체크:

```gdscript
func draw_cards(count: int):
    for i in range(count):
        if is_hand_full():
            print("[DeckManager] Hand is full! Cannot draw more.")
            break
        
        var card = draw_card()
        if not card.is_empty():
            print("[DeckManager] Drew: %s" % card.name)
```
```

---

**Task 2-2: 카드 검색 함수**

Cursor 프롬프트:
```
@autoload/DeckManager.gd

카드 검색 함수 추가:

```gdscript
func find_card_in_hand(card_id: String) -> int:
    """손패에서 카드 찾기 (인덱스 반환)"""
    for i in range(hand.size()):
        if hand[i].id == card_id:
            return i
    return -1

func get_card_from_hand(card_index: int) -> Dictionary:
    """손패에서 카드 가져오기"""
    if card_index >= 0 and card_index < hand.size():
        return hand[card_index]
    return {}

func remove_card_from_hand(card_index: int) -> Dictionary:
    """손패에서 카드 제거 (exile 등)"""
    if card_index >= 0 and card_index < hand.size():
        var card = hand[card_index]
        hand.remove_at(card_index)
        return card
    return {}
```
```

---

**Phase 2 테스트**:
```bash
# DeckManager 테스트 스크립트 (나중에)
1. initialize_combat_deck() 호출
2. draw_to_hand_size() → 5장 확인
3. is_hand_full() → false 확인
4. draw_cards(10) → 8장 상한 확인
5. get_combat_state() → 덱/손패/버린카드 확인
```

---

#### Phase 3: 손패 UI 구현 (90분)

**목표**: 드래그 가능한 카드 UI

**Task 3-1: CardItem 컴포넌트**

Cursor 프롬프트:
```
새 컴포넌트를 만들어줘:

파일: ui/combat/CardItem.tscn + CardItem.gd

구조:
- Root: Control (size: 100×140)
  - Background: Panel (테두리, 그라데이션)
  - VBox
    - CostLabel: Label ("1⚡", 우상단)
    - NameLabel: Label (카드 이름)
    - IconLabel: Label (이모지 아이콘)
    - DescLabel: Label (설명, 작은 글씨)

GDScript (CardItem.gd):

```gdscript
extends Control

var card_data: Dictionary = {}
var card_index: int = -1
var is_dragging: bool = false
var original_position: Vector2

signal card_played(card_index: int, target_index: int)

@onready var background = $Background
@onready var cost_label = $VBox/CostLabel
@onready var name_label = $VBox/NameLabel
@onready var icon_label = $VBox/IconLabel
@onready var desc_label = $VBox/DescLabel

func setup(card: Dictionary, index: int):
    card_data = card
    card_index = index
    _update_ui()

func _update_ui():
    cost_label.text = "%d⚡" % card_data.get("cost", 0)
    name_label.text = card_data.get("name", "Unknown")
    icon_label.text = card_data.get("icon", "🃏")
    
    # 설명 생성
    var desc = ""
    if card_data.has("damage"):
        desc += "Deal %d damage. " % card_data.damage
    if card_data.has("block"):
        desc += "Gain %d Block. " % card_data.block
    if card_data.has("draw"):
        desc += "Draw %d cards. " % card_data.draw
    desc_label.text = desc

    # 에너지 부족 시 어둡게
    if not CombatManager.can_afford_card(card_data.cost):
        modulate = Color(0.5, 0.5, 0.5)
    else:
        modulate = Color(1, 1, 1)

# ─── Drag & Drop ──────────────────────────────────────

func _get_drag_data(at_position):
    """드래그 시작"""
    if not CombatManager.can_afford_card(card_data.cost):
        return null  # 에너지 부족 시 드래그 불가
    
    is_dragging = true
    original_position = global_position
    
    # 드래그 프리뷰
    var preview = self.duplicate()
    preview.modulate.a = 0.8
    preview.scale = Vector2(1.2, 1.2)
    set_drag_preview(preview)
    
    return {
        "card_index": card_index,
        "card": card_data
    }

func _notification(what):
    if what == NOTIFICATION_DRAG_END:
        is_dragging = false

# ─── Hover Effect ─────────────────────────────────────

func _on_mouse_entered():
    if not is_dragging:
        scale = Vector2(1.1, 1.1)
        z_index = 10

func _on_mouse_exited():
    if not is_dragging:
        scale = Vector2(1.0, 1.0)
        z_index = 0
```

UITheme 스타일 적용.
Mouse Enter/Exit 시그널 연결.
```

**예상 결과**: 드래그 가능한 카드 UI 완성

---

**Task 3-2: CardHandUI 컨테이너**

Cursor 프롬프트:
```
새 컴포넌트: ui/combat/CardHandUI.tscn + CardHandUI.gd

구조:
- Root: Control (full width)
  - CardContainer: HBoxContainer (중앙 정렬, 10px 간격)

GDScript:

```gdscript
extends Control

const CardItemScene = preload("res://ui/combat/CardItem.tscn")

@onready var card_container = $CardContainer

var card_items: Array = []

signal card_played(card_index: int, target_index: int)

func update_hand(cards: Array):
    """DeckManager의 손패를 UI에 표시"""
    # 기존 카드 정리
    for item in card_items:
        item.queue_free()
    card_items.clear()
    
    # 새 카드 생성
    for i in range(cards.size()):
        var card = cards[i]
        var item = CardItemScene.instantiate()
        item.setup(card, i)
        card_container.add_child(item)
        card_items.append(item)
    
    print("[CardHandUI] Updated hand: %d cards" % cards.size())

func refresh():
    """손패 갱신 (에너지 변경 시)"""
    var cards = DeckManager.get_hand_cards()
    update_hand(cards)
```

CombatManager 시그널 연결:
- energy_changed → refresh()
- combat_log_updated → (손패 변경 시 refresh)
```

---

**Task 3-3: 드롭 존 (Monster + PlayArea)**

Cursor 프롬프트:
```
@ui/components/CharacterNode.gd

Monster가 카드 드롭 타겟이 되도록 수정:

```gdscript
# ─── Drop Zone ────────────────────────────────────────

func _can_drop_data(at_position, data):
    """이 Monster가 드롭 타겟 가능한지"""
    if not data.has("card_index"):
        return false
    
    var card = data.card
    var target_type = card.get("target", "none")
    
    # 단일 타겟 카드만 드롭 가능
    if target_type != "single":
        return false
    
    # 죽은 Monster는 타겟 불가
    if character_data.hp <= 0:
        return false
    
    return true

func _drop_data(at_position, data):
    """카드 드롭 → CombatManager에 플레이 요청"""
    var card_index = data.card_index
    var monster_index = get_index()  # Parent(CharacterArea) 내 인덱스
    
    print("[CharacterNode] Card %d dropped on Monster %d" % [card_index, monster_index])
    
    # CombatManager에 카드 플레이 요청
    CombatManager.play_card(card_index, monster_index)
```

추가로 PlayArea (자기 버프용) 만들기:

새 파일: ui/combat/PlayArea.tscn + PlayArea.gd

```gdscript
extends Control

# 자기 버프 카드 드롭 존
func _can_drop_data(at_position, data):
    if not data.has("card_index"):
        return false
    
    var card = data.card
    var target_type = card.get("target", "none")
    
    # self 또는 none 타겟
    return target_type in ["self", "none"]

func _drop_data(at_position, data):
    var card_index = data.card_index
    
    print("[PlayArea] Card %d played (self/none target)" % card_index)
    
    # 타겟 없이 플레이
    CombatManager.play_card(card_index, -1)
```

InRun_v4에 PlayArea 추가 (BottomArea 중앙).
```

---

**Phase 3 테스트**:
```bash
# Godot 실행 (Phase 5 이후)
1. 손패에 카드 5장 표시되는지
2. 마우스 호버 시 카드 확대되는지
3. 드래그 시 반투명 프리뷰 표시되는지
4. Monster 위로 드롭 → 카드 플레이 확인
5. PlayArea에 드롭 → 자기 버프 확인
6. 에너지 부족 카드는 드래그 불가 확인
```

---

#### Phase 4: 의도 시스템 (60분)

**목표**: 적 의도 표시

**Task 4-1: IntentBubble 컴포넌트**

Cursor 프롬프트:
```
새 컴포넌트: ui/combat/IntentBubble.tscn + IntentBubble.gd

구조:
- Root: Control (size: 60×40)
  - Background: Panel (말풍선 스타일)
  - HBox
    - IconLabel: Label (⚔️, 🛡️ 등)
    - ValueLabel: Label (숫자)

GDScript:

```gdscript
extends Control

@onready var background = $Background
@onready var icon_label = $HBox/IconLabel
@onready var value_label = $HBox/ValueLabel

func show_intent(action: Dictionary):
    """
    의도 표시
    action: {type: "attack", damage: 8, icon: "⚔️"}
    """
    if action.is_empty():
        hide()
        return
    
    icon_label.text = action.get("icon", "❓")
    
    # 타입별 색상
    match action.type:
        "attack":
            value_label.text = str(action.get("damage", 0))
            background.modulate = Color(1, 0.5, 0.5)  # 빨강
        "defend":
            value_label.text = str(action.get("block", 0))
            background.modulate = Color(0.5, 0.5, 1)  # 파랑
        "buff":
            value_label.text = "↑"
            background.modulate = Color(0.5, 1, 0.5)  # 초록
        "debuff":
            value_label.text = "↓"
            background.modulate = Color(1, 1, 0.5)  # 노랑
        _:
            value_label.text = "?"
            background.modulate = Color(0.7, 0.7, 0.7)  # 회색
    
    visible = true

func hide_intent():
    visible = false
```

UITheme 스타일 적용.
```

**예상 결과**: 의도 말풍선 완성

---

**Task 4-2: CharacterNode에 IntentBubble 추가**

Cursor 프롬프트:
```
@ui/components/CharacterNode.tscn
@ui/components/CharacterNode.gd

CharacterNode에 IntentBubble 추가:

.tscn:
- IntentBubble 인스턴스 추가
- HP바 위에 배치 (y -30)
- 초기 visible = false

.gd:

```gdscript
@onready var intent_bubble = $IntentBubble

func show_intent(action: Dictionary):
    """의도 표시 (Monster만)"""
    if character_data.type != "monster":
        return
    
    intent_bubble.show_intent(action)

func hide_intent():
    intent_bubble.hide_intent()
```

기본적으로 숨겨져 있고, CombatManager가 의도 표시 명령.
```

---

**Task 4-3: InRun_v4에서 의도 연결**

Cursor 프롬프트:
```
@ui/screens/InRun_v4.gd

switch_to_combat()에서 의도 시그널 연결:

```gdscript
func switch_to_combat():
    # ... (기존 코드) ...
    
    # Connect intent signal
    if CombatManager.has_signal("intent_updated"):
        CombatManager.intent_updated.connect(_on_intent_updated)

func _on_intent_updated(entity_type: String, index: int, action: Dictionary):
    """적 의도 업데이트"""
    if entity_type == "monster" and index < character_nodes.size():
        var monster_node = character_nodes[index]
        monster_node.show_intent(action)
```

switch_to_exploration()에서 시그널 연결 해제.
```

---

**Phase 4 테스트**:
```bash
# 전투 시작
1. 각 Monster 위에 의도 말풍선 표시되는지
2. 공격: 빨간 말풍선 + 데미지 숫자
3. 방어: 파란 말풍선 + 블록 숫자
4. 적 턴 실행 → 의도대로 행동하는지
5. 다음 턴 시작 → 새 의도 표시되는지
```

---

#### Phase 5: 통합 & 테스트 (90분)

**목표**: 모든 시스템 통합, 최종 테스트

**Task 5-1: project.godot 전환 스위치**

Cursor 프롬프트:
```
@project.godot

autoload 섹션에 전환 설정 추가:

현재:
[autoload]
CombatManagerBase="*res://autoload/CombatManagerBase.gd"
CombatManager="*res://autoload/CombatManagerATB.gd"

목표 (턴제 테스트):
[autoload]
CombatManagerBase="*res://autoload/CombatManagerBase.gd"
CombatManager="*res://autoload/CombatManagerTurnBased.gd"

주석으로 전환 가능하게:
# ATB Mode
# CombatManager="*res://autoload/CombatManagerATB.gd"

# Turn-Based Mode (active)
CombatManager="*res://autoload/CombatManagerTurnBased.gd"
```

**전환 방법**:
1. Godot 종료
2. project.godot 수정
3. Godot 재실행

---

**Task 5-2: CombatBottomUI 턴제 버전**

Cursor 프롬프트:
```
@ui/bottom_uis/CombatBottomUI.tscn
@ui/bottom_uis/CombatBottomUI.gd

CombatBottomUI를 턴제 버전으로 개편:

.tscn 구조:
- TopPanel
  - TurnLabel: Label ("Turn 5")
  - EnergyLabel: Label ("⚡⚡⚡ 3/3")
  
- MiddlePanel (CardHandUI)
  - CardHandUI 인스턴스
  
- BottomPanel
  - EndTurnButton: Button (200×60, "End Turn (Space)")
  - DeckInfo: Label ("Deck: 15 | Discard: 8")

.gd:

```gdscript
@onready var turn_label = $TopPanel/TurnLabel
@onready var energy_label = $TopPanel/EnergyLabel
@onready var card_hand_ui = $MiddlePanel/CardHandUI
@onready var end_turn_button = $BottomPanel/EndTurnButton
@onready var deck_info_label = $BottomPanel/DeckInfo

func _ready():
    # Connect signals
    CombatManager.turn_phase_changed.connect(_on_turn_phase_changed)
    CombatManager.energy_changed.connect(_on_energy_changed)
    CombatManager.player_turn_ended.connect(_on_player_turn_ended)
    CombatManager.enemy_turn_ended.connect(_on_enemy_turn_ended)
    
    end_turn_button.pressed.connect(_on_end_turn_pressed)
    
    # Shortcut
    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_accept"):  # Space or Enter
        if CombatManager.is_player_turn:
            _on_end_turn_pressed()

func _on_turn_phase_changed(phase: String, turn_count: int, is_player: bool):
    turn_label.text = "Turn %d" % turn_count
    
    if is_player:
        end_turn_button.disabled = false
        end_turn_button.text = "End Turn (Space)"
    else:
        end_turn_button.disabled = true
        end_turn_button.text = "Enemy Turn..."

func _on_energy_changed(current: int, max: int):
    var symbols = ("⚡" * current) + ("○" * (max - current))
    energy_label.text = "%s %d/%d" % [symbols, current, max]

func _on_end_turn_pressed():
    if CombatManager.is_player_turn:
        CombatManager.end_player_turn()

func _on_player_turn_ended():
    end_turn_button.disabled = true
    end_turn_button.text = "Enemy Turn..."

func _on_enemy_turn_ended():
    # (플레이어 턴 시작 시그널에서 처리됨)
    pass

func _process(delta):
    # 덱 정보 업데이트 (매 프레임)
    var state = DeckManager.get_combat_state()
    deck_info_label.text = "Deck: %d | Discard: %d" % [state.deck_count, state.discard_count]
```

UITheme 스타일 적용.
```

---

**Task 5-3: 최종 통합 테스트**

Cursor 프롬프트:
```
전체 시스템 통합 검증:

1. InRun_v4.gd가 CombatManagerTurnBased 시그널 모두 연결하는지 확인
2. DeckManager.gd가 draw_to_hand_size() 호출하는지 확인
3. CardHandUI가 손패 업데이트하는지 확인
4. Monster 의도가 표시되는지 확인
5. 드래그 앤 드롭이 작동하는지 확인

각 파일에 print 문 추가해서 디버깅:

CombatManagerTurnBased.gd:
```gdscript
func _start_player_turn():
    print("[TB Combat] === PLAYER TURN %d ===" % turn_count)
    # ...

func _start_enemy_turn():
    print("[TB Combat] === ENEMY TURN ===")
    # ...

func play_card(card_index: int, target_index: int = -1) -> bool:
    print("[TB Combat] Playing card %d on target %d" % [card_index, target_index])
    # ...
```

CardHandUI.gd:
```gdscript
func update_hand(cards: Array):
    print("[CardHandUI] Updating hand: %d cards" % cards.size())
    # ...
```

DeckManager.gd:
```gdscript
func draw_to_hand_size():
    print("[DeckManager] Drawing to fill hand...")
    # ...
```

모든 시그널 연결 확인 후 최종 플레이테스트.
```

---

**Phase 5 최종 테스트 체크리스트**:

**턴 시스템**:
- [ ] 플레이어 턴 시작 시 에너지 3개 리셋
- [ ] 손패 5장 채워짐
- [ ] "End Turn" 버튼 활성화
- [ ] Space 키로 턴 종료 가능
- [ ] 적 턴 시작
- [ ] 의도대로 적 행동 실행
- [ ] 다시 플레이어 턴

**카드 플레이**:
- [ ] 손패 5장 표시
- [ ] 드래그 시 프리뷰
- [ ] Monster 위로 드롭 → 공격 카드 작동
- [ ] PlayArea에 드롭 → 버프 카드 작동
- [ ] 에너지 소비 확인
- [ ] 손패에서 카드 사라짐
- [ ] 카드 효과 적용 (데미지, 블록 등)

**의도 시스템**:
- [ ] 플레이어 턴에 적 의도 표시
- [ ] 공격: 빨간 말풍선 + 숫자
- [ ] 방어: 파란 말풍선 + 숫자
- [ ] 적 턴 실행 → 의도대로 행동
- [ ] 다음 턴 새 의도 표시

**전투 종료**:
- [ ] 모든 Monster 죽으면 승리
- [ ] Hero 죽으면 패배
- [ ] 보상 모달 표시

---

### 4.2 전체 Cursor 프롬프트 모음 (15개)

**(위 Phase 1-5에 포함된 프롬프트 13개 + 추가 2개)**

**추가 프롬프트 1: 손패 버리기 기능**
```
@autoload/DeckManager.gd

손패 버리기 기능 추가 (턴 종료 시 선택 사항):

```gdscript
func discard_hand():
    """손패 전체를 버린 카드 더미로"""
    while not hand.is_empty():
        var card = hand.pop_front()
        discard.append(card)
    
    print("[DeckManager] Discarded entire hand (%d cards)" % discard.size())

func discard_specific_card(card_index: int) -> bool:
    """특정 카드만 버리기"""
    if card_index >= 0 and card_index < hand.size():
        var card = hand[card_index]
        hand.remove_at(card_index)
        discard.append(card)
        print("[DeckManager] Discarded: %s" % card.name)
        return true
    return false
```

CombatManagerTurnBased.gd의 end_player_turn()에서:
- 옵션 1: 손패 유지 (추천)
- 옵션 2: 손패 버리기 (Slay the Spire 스타일)
```

**추가 프롬프트 2: 디버그 패널 (턴제)**
```
CombatBottomUI에 디버그 패널 추가:

[DEBUG] (F3 toggle)
Turn: 5 (Player)
Phase: PLAYER_TURN_MAIN
Energy: 2 / 3
Hand: 5 cards
Deck: 15 | Discard: 8 | Exile: 0

Monster 0: Intent = Attack (8)
Monster 1: Intent = Defend (6)

Last Action: Played "Strike" on Monster 0
```

---

### 4.3 테스트 시나리오

#### 시나리오 1: 기본 전투 흐름
```
1. 전투 시작
   - Hero HP 80/80, Energy 3/3
   - Monsters 2마리 생성
   - 손패 5장 드로우
   - 적 의도 표시 (⚔️8, 🛡️6)

2. 플레이어 턴 1
   - Strike (1⚡) 드래그 → Monster 0
   - → Monster 0 HP 감소
   - → Energy 2/3
   - → 손패 4장
   - Defend (1⚡) 드래그 → PlayArea
   - → Hero Block +5
   - → Energy 1/3
   - "End Turn" 클릭

3. 적 턴 1
   - Monster 0: 공격 (Hero HP -8, Block 사용)
   - Monster 1: 방어 (Monster 1 Block +6)
   - 새 의도 표시

4. 플레이어 턴 2
   - Energy 3/3 (리셋)
   - Block 0 (리셋)
   - 손패 5장 (채워짐)
   - ...

5. 전투 종료
   - Monster 모두 죽음 → 승리
   - 또는 Hero 죽음 → 패배
```

**예상 소요 시간**: 2-4분

---

#### 시나리오 2: 에지 케이스 테스트
```
1. 에너지 부족
   - 3⚡ 카드 드래그 시도
   - → 드래그 불가 (회색 표시)

2. 손패 초과
   - Draw 카드 플레이
   - → 8장 상한 도달
   - → 더 이상 드로우 안 됨
   - → 로그: "Hand is full!"

3. 덱 소진
   - 덱 0장 상태에서 드로우
   - → 버린 카드 더미 → 덱 셔플
   - → 계속 드로우 가능

4. 타겟 없는 적
   - 모든 Monster 죽은 상태
   - → 카드 드롭 불가
   - → "No valid target!"

5. 플레이어 턴 중 턴 종료 연타
   - Space 키 여러 번
   - → 한 번만 처리됨 (중복 방지)
```

---

#### 시나리오 3: UI 반응성 테스트
```
1. 카드 드래그 프리뷰
   - 드래그 시작 → 반투명 복사본
   - Monster 위로 이동 → 타겟 하이라이트?
   - 드롭 → 카드 사라짐 + 효과

2. 마우스 호버
   - 카드 위로 마우스
   - → 카드 확대 (1.1배)
   - → z-index 상승

3. 의도 변경
   - 적 턴 종료
   - → 새 의도 표시 (부드러운 전환)

4. 애니메이션
   - 적 행동 실행
   - → 0.8초 딜레이 (순차적)
   - → 데미지 숫자 표시
   - → Shake 효과
```

---

## 5. 구현 계획

### 5.1 단계별 마일스톤

**Week 1: Core Framework** (Phase 1-2)
- Day 1-2: CombatManagerTurnBased.gd
- Day 3-4: DeckManager 확장
- Day 5: 테스트 & 디버깅

**Week 2: UI Implementation** (Phase 3-4)
- Day 1-2: CardItem + CardHandUI
- Day 3-4: 드래그 앤 드롭
- Day 5: IntentBubble

**Week 3: Integration** (Phase 5)
- Day 1-2: CombatBottomUI 개편
- Day 3-4: 전체 통합 테스트
- Day 5: 버그 수정

**Total**: 약 3주 (full-time) 또는 6주 (part-time)

---

### 5.2 개발 리소스

**예상 개발 시간**:
- 코딩: 40-50시간
- UI 작업: 20-30시간
- 테스트: 15-20시간
- 버그 수정: 10-15시간
- **Total**: **85-115시간** (약 3주 full-time)

**필요한 추가 에셋**:
- 카드 스프라이트 (현재 이모지 대체)
- 의도 아이콘 (⚔️ 🛡️ 등)
- UI 사운드 (카드 플레이, 턴 종료)
- 애니메이션 (드래그, 드롭 효과)

**기술적 난이도**:
- 중상 (ATB 대비 2배)
- 드래그 앤 드롭 구현 복잡
- 손패 UI 관리 까다로움
- 턴 동기화 버그 가능성

---

### 5.3 리스크 & 완화 방안

#### 리스크 1: 드래그 앤 드롭 버그
- **증상**: 카드가 제대로 드롭 안 됨, 중복 플레이
- **완화**: 철저한 테스트, 상태 플래그 관리
- **대안**: 클릭 방식 fallback (드래그 실패 시)

#### 리스크 2: 턴 동기화 문제
- **증상**: 플레이어/적 턴 꼬임, 무한 루프
- **완화**: Phase enum 엄격 관리, 디버그 로그
- **대안**: Turn Stack 구조 (undo 가능)

#### 리스크 3: 손패 UI 버그
- **증상**: 카드 중복 표시, 인덱스 오류
- **완화**: DeckManager와 UI 동기화 철저히
- **대안**: 손패 상태를 매 프레임 검증

#### 리스크 4: 성능 문제
- **증상**: 카드 10장+ 시 프레임 드롭
- **완화**: 카드 풀링, 불필요한 업데이트 최소화
- **대안**: 손패 상한 8장으로 제한

#### 리스크 5: 밸런싱 어려움
- **증상**: 카드 조합 시너지 예측 불가
- **완화**: 광범위한 플레이테스트 (100+ 판)
- **대안**: 카드 효과 단순화, 숫자 조정

---

## 6. 최종 비교표

| 항목 | ATB (현재) | 턴제 (목표) | 권장 |
|------|-----------|-----------|------|
| **전략적 깊이** | ⭐⭐⭐ (70%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **접근성** | ⭐⭐⭐⭐⭐ (100%) | ⭐⭐⭐ (60%) | ATB |
| **플레이 속도** | ⭐⭐⭐⭐⭐ (30-60초) | ⭐⭐ (2-5분) | ATB |
| **몰입감** | ⭐⭐⭐ (70%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **멀티태스킹** | ⭐⭐⭐⭐⭐ (가능) | ⭐ (불가능) | ATB |
| **학습 곡선** | ⭐⭐⭐⭐⭐ (쉬움) | ⭐⭐⭐ (중간) | ATB |
| **리플레이 가치** | ⭐⭐⭐⭐ (80%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **모바일 적합성** | ⭐⭐⭐⭐⭐ (100%) | ⭐⭐⭐ (70%) | ATB |
| **PC/콘솔 적합성** | ⭐⭐ (40%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **개발 난이도** | ⭐⭐⭐⭐⭐ (쉬움) | ⭐⭐⭐ (중간) | ATB |
| **개발 시간** | ⭐⭐⭐⭐⭐ (2주) | ⭐⭐ (6주) | ATB |
| **밸런싱 난이도** | ⭐⭐⭐ (중간) | ⭐⭐ (어려움) | ATB |
| **수익화 가능성** | ⭐⭐⭐⭐⭐ (높음) | ⭐⭐⭐ (중간) | ATB |
| **장르 정통성** | ⭐⭐ (비정통) | ⭐⭐⭐⭐⭐ (정통) | 턴제 |

**종합 점수**:
- ATB: 58/70 (82.9%) - 모바일 우선 전략
- 턴제: 52/70 (74.3%) - PC 하드코어 시장

---

## 7. 완성 체크리스트

### 코드 작업
- [ ] CombatManagerTurnBased.gd 생성
- [ ] 턴 시스템 (_start_player_turn, end_player_turn, _start_enemy_turn)
- [ ] 의도 시스템 (_prepare_enemy_turn, _execute_monster_action)
- [ ] DeckManager.gd 확장 (draw_to_hand_size, is_hand_full)
- [ ] CardItem.tscn/gd (드래그 가능)
- [ ] CardHandUI.tscn/gd (손패 컨테이너)
- [ ] IntentBubble.tscn/gd (의도 말풍선)
- [ ] PlayArea.tscn/gd (자기 버프 드롭 존)
- [ ] CombatBottomUI 개편 (턴 카운터, End Turn 버튼)
- [ ] CharacterNode에 드롭 존 추가
- [ ] InRun_v4 시그널 연결

### 기능 테스트
- [ ] 턴 시스템 정상 작동
- [ ] 에너지 턴당 3개 리셋
- [ ] 손패 5장 채워짐
- [ ] 카드 드래그 앤 드롭
- [ ] Monster 타겟팅
- [ ] PlayArea 자기 버프
- [ ] 의도 표시 (공격/방어/버프)
- [ ] 적 행동 실행 (의도대로)
- [ ] 전투 시작/종료
- [ ] 승리/패배 처리

### UI/UX
- [ ] 손패 5장 배치
- [ ] 카드 호버 확대
- [ ] 드래그 프리뷰
- [ ] 의도 말풍선 색상
- [ ] End Turn 버튼 (Space 단축키)
- [ ] 턴 카운터 표시
- [ ] 에너지 시각화
- [ ] 덱/버린카드 정보

### 밸런싱
- [ ] 카드 비용 조정
- [ ] 적 행동 패턴 다양화
- [ ] 손패 크기 적절 (5-8장)
- [ ] 전투 시간 2-4분
- [ ] 난이도 곡선 완만

### 문서화
- [ ] CHANGELOG.md 업데이트
- [ ] 주석/docstring 완비
- [ ] 디버그 print 제거
- [ ] 코드 리뷰 완료

---

## 8. 권장사항

### ATB 유지 vs 턴제 전환

**현재 상황**:
- ATB 70% 구현 완료
- 첫 프로젝트 (리소스 제약)
- 모바일 우선 전략

**분석**:

#### 시나리오 A: ATB 유지 (추천)
- ✅ 빠른 출시 (2-3주)
- ✅ 낮은 리스크
- ✅ 모바일 시장 적합
- ✅ 개발 경험 쌓기
- ❌ 장르 정통성 낮음

**추천 이유**:
1. 첫 프로젝트는 완성도가 중요
2. ATB도 충분히 재밌게 만들 수 있음
3. 출시 후 피드백 → v2.0에서 턴제 추가

#### 시나리오 B: 턴제 전환
- ✅ 장르 정통성 높음
- ✅ PC 시장 진출 가능
- ✅ 전략적 깊이
- ❌ 개발 시간 2-3배 (6주+)
- ❌ 리스크 높음 (드래그 앤 드롭 등)
- ❌ 밸런싱 어려움

**권장 시기**: v2.0 업데이트

#### 시나리오 C: 하이브리드 (세미 오토)
- **개념**: 턴제 기반 + 자동 플레이 옵션
- **구현**:
  ```
  플레이어 턴:
  1. 자동 OFF (기본): 카드 직접 플레이
  2. 자동 ON (선택): AI가 카드 선택 → 1초 딜레이 → 자동 플레이
     (플레이어는 개입 가능)
  ```
- **장점**: 
  - 양쪽 유저 모두 만족
  - 전략 깊이 + 편의성
- **단점**: 
  - 개발 복잡도 최고
  - UI 복잡

**권장 시기**: v3.0 (경험 쌓은 후)

---

### 최종 권고

**Steve, 다음 중 선택해주세요**:

**옵션 A: ATB 완성 (추천) 🌟**
- 목표: 2-3주 내 v1.0 완성
- 장점: 빠른 출시, 낮은 리스크
- 이후: 피드백 → v2.0 턴제 추가

**옵션 B: 턴제로 전환**
- 목표: 6-8주 후 v1.0 완성
- 장점: 장르 정통성
- 리스크: 개발 기간 길어짐

**옵션 C: 두 시스템 모두 구현**
- 목표: 플레이어 선택 (설정에서 전환)
- 장점: 최대 유연성
- 단점: 개발 시간 2배, 밸런싱 2배

---

**문서 종료**

**작성 시간**: 2026-02-26  
**버전**: 1.0  
**다음 문서**: Cursor_Dual_Combat_Guide.md
