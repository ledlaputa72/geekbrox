# Cursor Dual Combat System Guide - Dream Collector

**작성일**: 2026-02-26  
**작성자**: Atlas  
**용도**: Cursor로 ATB + 턴제 두 시스템 개발 & 비교 테스트  
**목표**: 두 전투 시스템 동시 관리, 쉬운 전환, 효율적 개발

---

## 📋 목차

1. [프로젝트 구조 설계](#1-프로젝트-구조-설계)
2. [공통 인터페이스 설계](#2-공통-인터페이스-설계)
3. [시스템 전환 메커니즘](#3-시스템-전환-메커니즘)
4. [Cursor 워크플로우](#4-cursor-워크플로우)
5. [Cursor 프롬프트 모음](#5-cursor-프롬프트-모음)
6. [비교 테스트 가이드](#6-비교-테스트-가이드)
7. [트러블슈팅](#7-트러블슈팅)

---

## 1. 프로젝트 구조 설계

### 1.1 파일 분리 전략

#### 목표 구조
```
autoload/
├── CombatManagerBase.gd         # 추상 인터페이스 (공통)
├── CombatManagerATB.gd          # ATB 구현체
├── CombatManagerTurnBased.gd   # 턴제 구현체
└── AutoBattleAI.gd              # ATB 전용 AI

ui/
├── combat/
│   ├── ATBGaugeBar.tscn/gd     # ATB 전용 (게이지)
│   ├── CardHandUI.tscn/gd      # 턴제 전용 (손패)
│   ├── CardItem.tscn/gd        # 턴제 전용 (드래그 가능 카드)
│   ├── IntentBubble.tscn/gd    # 턴제 전용 (의도)
│   └── PlayArea.tscn/gd        # 턴제 전용 (드롭 존)
│
└── bottom_uis/
    ├── CombatBottomUI_ATB.tscn/gd       # ATB 전용 UI
    └── CombatBottomUI_TurnBased.tscn/gd # 턴제 전용 UI

scenes/
└── InRun_v4.tscn                # 공통 씬 (시스템 감지)
```

#### 파일 명명 규칙

**시스템별 구분**:
- `_ATB` 접미사: ATB 전용
- `_TurnBased` 접미사: 턴제 전용
- 접미사 없음: 공통 (Base, 공유)

**예시**:
```gdscript
# 좋은 예
CombatManagerATB.gd
CombatManagerTurnBased.gd
CombatBottomUI_ATB.tscn

# 나쁜 예
CombatManager.gd  # 애매함, 어느 시스템?
CombatUI.tscn     # 공통인지 특정 시스템인지 불명확
```

---

### 1.2 UI 분리 전략

#### 전략 A: 완전 분리 (추천)

**장점**:
- ✅ 명확한 구분
- ✅ 충돌 없음
- ✅ 독립 개발 가능

**단점**:
- ❌ 중복 코드 (일부)
- ❌ 파일 수 증가

**구조**:
```
ui/bottom_uis/
├── CombatBottomUI_ATB.tscn      # ATB 전용 (속도, 자동전투)
└── CombatBottomUI_TurnBased.tscn # 턴제 전용 (End Turn, 손패)
```

**InRun_v4.gd에서 로드**:
```gdscript
const COMBAT_UI_PATHS = {
    "ATB": "res://ui/bottom_uis/CombatBottomUI_ATB.tscn",
    "TurnBased": "res://ui/bottom_uis/CombatBottomUI_TurnBased.tscn"
}

func _load_combat_ui():
    var combat_mode = _detect_combat_mode()  # "ATB" or "TurnBased"
    var ui_scene = load(COMBAT_UI_PATHS[combat_mode])
    var ui = ui_scene.instantiate()
    bottom_area.add_child(ui)
```

---

#### 전략 B: 조건부 UI (비추천)

**장점**:
- ✅ 파일 수 적음
- ✅ 일부 코드 공유

**단점**:
- ❌ 복잡한 조건문
- ❌ 디버깅 어려움
- ❌ Cursor가 헷갈림

**구조** (피하세요):
```gdscript
# CombatBottomUI.gd (하나의 파일)
func _ready():
    if CombatManager.is_atb_mode:
        _setup_atb_ui()
    else:
        _setup_turn_based_ui()
```

**왜 나쁜가?**:
- Cursor가 조건문 깊이 이해 못함
- 수정 시 양쪽 다 영향
- 테스트 복잡

---

### 1.3 씬 분리 전략

#### 옵션 A: 단일 InRun_v4 (추천)

**구조**:
```
InRun_v4.tscn  # 하나의 씬
  ↓ (런타임에 CombatManager 타입 감지)
  ├─ ATB 모드 → CombatBottomUI_ATB 로드
  └─ 턴제 모드 → CombatBottomUI_TurnBased 로드
```

**장점**:
- ✅ 씬 하나만 관리
- ✅ 전환 쉬움 (autoload만 바꾸면 됨)
- ✅ 공통 로직 공유 (TopArea, BottomNav 등)

**단점**:
- ❌ 런타임 감지 필요

**구현**:
```gdscript
# InRun_v4.gd
func _detect_combat_mode() -> String:
    """현재 CombatManager 타입 감지"""
    if CombatManager.has_method("toggle_auto_battle"):
        return "ATB"
    elif CombatManager.has_method("end_player_turn"):
        return "TurnBased"
    else:
        push_error("Unknown combat mode!")
        return "ATB"  # fallback
```

---

#### 옵션 B: 별도 씬 (비추천)

**구조**:
```
InRun_ATB.tscn       # ATB 전용
InRun_TurnBased.tscn # 턴제 전용
```

**장점**:
- ✅ 완전 독립

**단점**:
- ❌ 씬 2개 관리
- ❌ 공통 로직 중복
- ❌ DreamCardSelection → 어느 씬으로?

**결론**: 옵션 A (단일 씬) 추천

---

## 2. 공통 인터페이스 설계

### 2.1 CombatManagerBase (추상 클래스)

**역할**: 두 시스템의 공통 API 정의

#### 필수 공통 시그널
```gdscript
# autoload/CombatManagerBase.gd
extends Node
class_name CombatManagerBase

# ─── Common Signals (양쪽 모두 emit 필수) ───────────

signal combat_log_updated(message: String)
signal entity_updated(entity_type: String, index: int)
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal combat_ended(victory: bool)
signal energy_changed(current: int, max: int)
```

**규칙**: 
- ✅ 두 시스템 모두 이 시그널 사용
- ✅ InRun_v4는 이 시그널만 연결
- ❌ 시스템별 고유 시그널은 별도 (선택적 연결)

---

#### 시스템별 고유 시그널

**ATB 전용**:
```gdscript
# CombatManagerATB.gd
signal atb_gauge_updated(entity_type: String, index: int, atb: float, max_atb: float)
signal energy_timer_updated(progress: float)
```

**턴제 전용**:
```gdscript
# CombatManagerTurnBased.gd
signal turn_phase_changed(phase: String, turn_count: int, is_player: bool)
signal intent_updated(entity_type: String, index: int, action: Dictionary)
signal player_turn_ended()
signal enemy_turn_ended()
```

**InRun_v4 연결 방법**:
```gdscript
func switch_to_combat():
    # 공통 시그널 (항상 연결)
    CombatManager.combat_log_updated.connect(_on_combat_log_updated)
    CombatManager.entity_updated.connect(_on_entity_updated)
    CombatManager.damage_dealt.connect(_on_damage_dealt)
    CombatManager.combat_ended.connect(_on_combat_ended)
    CombatManager.energy_changed.connect(_on_energy_changed)
    
    # 시스템별 시그널 (조건부 연결)
    if CombatManager.has_signal("atb_gauge_updated"):
        # ATB 모드
        CombatManager.atb_gauge_updated.connect(_on_atb_gauge_updated)
    
    if CombatManager.has_signal("turn_phase_changed"):
        # 턴제 모드
        CombatManager.turn_phase_changed.connect(_on_turn_phase_changed)
        CombatManager.intent_updated.connect(_on_intent_updated)
```

---

### 2.2 공통 메서드 (Base에 구현)

**Base 클래스에 실제 구현** (중복 방지):

```gdscript
# CombatManagerBase.gd

# ─── Shared State ─────────────────────────────────────

var in_combat: bool = false
var hero: Dictionary = {}
var monsters: Array = []
var combat_log: Array = []

# ─── Common Methods (실제 구현) ───────────────────────

func add_log(message: String):
    """로그 추가 (공유 로직)"""
    combat_log.append(message)
    combat_log_updated.emit(message)
    print("[Combat] " + message)

func _apply_damage(entity: Dictionary, damage: int):
    """데미지 적용 (블록 먼저, 그 다음 HP)"""
    if entity.block > 0:
        var blocked = min(entity.block, damage)
        entity.block -= blocked
        damage -= blocked
        if damage <= 0:
            return
    
    entity.hp -= damage
    entity.hp = max(0, entity.hp)

func _calculate_damage(atk: int, def: int, eva: int) -> int:
    """데미지 계산 (회피, 방어, 분산)"""
    # 회피 체크
    if randf() * 100 < eva:
        return 0
    
    # 기본 데미지
    var base_damage = atk - def
    base_damage = max(1, base_damage)
    
    # 분산 (90%-110%)
    var variance = randf_range(0.9, 1.1)
    var final_damage = int(base_damage * variance)
    
    return max(1, final_damage)

func _check_combat_end():
    """전투 종료 체크 (승리/패배)"""
    # 패배 (Hero 죽음)
    if hero.hp <= 0:
        add_log("Hero has been defeated!")
        in_combat = false
        combat_ended.emit(false)
        return
    
    # 승리 (모든 Monster 죽음)
    var all_dead = true
    for monster in monsters:
        if monster.hp > 0:
            all_dead = false
            break
    
    if all_dead:
        add_log("All monsters defeated!")
        in_combat = false
        combat_ended.emit(true)
        return

func _get_first_alive_monster() -> int:
    """첫 번째 살아있는 Monster 인덱스"""
    for i in range(monsters.size()):
        if monsters[i].hp > 0:
            return i
    return -1

# ─── Abstract Methods (자식 클래스가 구현) ────────────

func start_combat(monster_data: Array):
    push_error("start_combat() must be overridden")

func end_combat():
    push_error("end_combat() must be overridden")

func play_card(card_index: int, target_index: int = -1) -> bool:
    push_error("play_card() must be overridden")
    return false

func get_combat_state() -> Dictionary:
    """전투 상태 반환 (UI 동기화용)"""
    return {
        "hero": hero,
        "monsters": monsters,
        "in_combat": in_combat,
        "combat_log": combat_log
    }
```

**자식 클래스 (ATB/TurnBased)**:
- ✅ `add_log()` 직접 호출 (중복 없음)
- ✅ `_apply_damage()` 직접 호출
- ✅ `_calculate_damage()` 직접 호출
- ✅ `_check_combat_end()` 직접 호출
- ❌ 재정의 불필요

---

### 2.3 카드 효과 적용 (공통 vs 개별)

#### 방법 A: Base에 공통 구현 (추천)

```gdscript
# CombatManagerBase.gd
func _apply_card_effects(card: Dictionary, target_index: int):
    """카드 효과 적용 (공통 로직)"""
    # Damage
    if card.has("damage"):
        if target_index >= 0 and target_index < monsters.size():
            var target = monsters[target_index]
            var damage = card.damage
            _apply_damage(target, damage)
            add_log("→ %s dealt %d damage to %s" % [card.name, damage, target.name])
            damage_dealt.emit("monster", target_index, damage, false)
            entity_updated.emit("monster", target_index)
            _check_combat_end()
    
    # Block
    if card.has("block"):
        hero.block += card.block
        add_log("→ Gained %d Block 🛡" % card.block)
        entity_updated.emit("hero", 0)
    
    # Buff
    if card.has("buff"):
        var buff = card.buff
        if buff.stat == "atk":
            hero.atk += buff.value
            add_log("→ ATK +%d (now %d)" % [buff.value, hero.atk])
            entity_updated.emit("hero", 0)
    
    # Draw
    if card.has("draw"):
        DeckManager.draw_cards(card.draw)
        add_log("→ Drew %d cards" % card.draw)
```

**자식 클래스**:
```gdscript
# CombatManagerATB.gd
func play_card(card_index: int, target_index: int = -1) -> bool:
    # ... (에너지 체크, 타겟 체크) ...
    
    # 카드 효과 적용 (Base 메서드 호출)
    _apply_card_effects(card, target_index)
    
    return true
```

**장점**: 중복 최소화, 일관성

---

#### 방법 B: 각 시스템 개별 구현 (비추천)

**단점**:
- 코드 중복
- 동기화 문제 (한쪽 수정 시 다른 쪽도 수정 필요)

**결론**: 방법 A (Base 공통 구현) 추천

---

## 3. 시스템 전환 메커니즘

### 3.1 Autoload 전환 (project.godot)

#### 현재 활성 시스템 확인

**project.godot**:
```toml
[autoload]

CombatManagerBase="*res://autoload/CombatManagerBase.gd"

# === ACTIVE COMBAT SYSTEM === #
# Switch by commenting/uncommenting

# ATB Mode (현재 활성)
CombatManager="*res://autoload/CombatManagerATB.gd"

# Turn-Based Mode
# CombatManager="*res://autoload/CombatManagerTurnBased.gd"

# === END === #

DeckManager="*res://autoload/DeckManager.gd"
GameManager="*res://autoload/GameManager.gd"
UITheme="*res://autoload/UITheme.gd"
AutoBattleAI="*res://autoload/AutoBattleAI.gd"
```

---

#### 전환 방법 (Manual)

**Step 1**: Godot 종료

**Step 2**: `project.godot` 수정

ATB → 턴제:
```diff
# ATB Mode
- CombatManager="*res://autoload/CombatManagerATB.gd"
+ # CombatManager="*res://autoload/CombatManagerATB.gd"

# Turn-Based Mode
- # CombatManager="*res://autoload/CombatManagerTurnBased.gd"
+ CombatManager="*res://autoload/CombatManagerTurnBased.gd"
```

**Step 3**: Godot 재실행

**Step 4**: 전투 시작 → 새 시스템 작동 확인

---

### 3.2 런타임 전환 (실험적, 비추천)

#### GameSettings를 통한 전환

```gdscript
# autoload/GameSettings.gd
enum CombatMode { ATB, TURN_BASED }
var combat_mode: CombatMode = CombatMode.ATB

func set_combat_mode(mode: CombatMode):
    combat_mode = mode
    save_settings()  # 저장
```

**문제**:
- ❌ Autoload는 런타임 교체 불가
- ❌ 씬 재로드 필요 (복잡)
- ❌ 상태 유지 어려움

**결론**: 수동 전환 (project.godot) 권장

---

### 3.3 테스트 모드 (빠른 전환)

#### 개발 중 빠른 테스트를 위한 방법

**개발 스크립트 추가**:
```bash
# tools/switch_combat.sh
#!/bin/bash

MODE=$1  # "atb" or "turn"

if [ "$MODE" == "atb" ]; then
    sed -i '' 's|^CombatManager=.*TurnBased|# CombatManager="*res://autoload/CombatManagerTurnBased.gd"|' project.godot
    sed -i '' 's|^# CombatManager=.*ATB|CombatManager="*res://autoload/CombatManagerATB.gd"|' project.godot
    echo "✅ Switched to ATB mode"
elif [ "$MODE" == "turn" ]; then
    sed -i '' 's|^CombatManager=.*ATB|# CombatManager="*res://autoload/CombatManagerATB.gd"|' project.godot
    sed -i '' 's|^# CombatManager=.*TurnBased|CombatManager="*res://autoload/CombatManagerTurnBased.gd"|' project.godot
    echo "✅ Switched to Turn-Based mode"
else
    echo "Usage: ./switch_combat.sh [atb|turn]"
fi
```

**사용법**:
```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector

# ATB로 전환
./tools/switch_combat.sh atb

# 턴제로 전환
./tools/switch_combat.sh turn
```

**Godot 재실행** 필요!

---

## 4. Cursor 워크플로우

### 4.1 개발 순서 (권장)

#### Phase 1: 공통 기반 (1주)
1. CombatManagerBase.gd 생성
2. 공통 메서드 구현
3. 시그널 체계 정리
4. InRun_v4 공통 로직

#### Phase 2: ATB 완성 (1주)
1. CombatManagerATB.gd 완성
2. ATB 전용 UI (속도, 자동전투)
3. ATB 게이지 바
4. AutoBattleAI 고도화
5. 테스트 & 밸런싱

#### Phase 3: 턴제 개발 (3주)
1. CombatManagerTurnBased.gd 골격
2. 턴 시스템 구현
3. 손패 UI (드래그 앤 드롭)
4. 의도 시스템
5. 턴제 전용 UI
6. 테스트 & 밸런싱

#### Phase 4: 통합 & 비교 (1주)
1. 전환 메커니즘 확립
2. 양쪽 테스트
3. 비교 데이터 수집
4. 최종 결정

**총 소요**: 6주 (part-time) 또는 3주 (full-time)

---

### 4.2 병렬 개발 vs 순차 개발

#### 전략 A: 순차 개발 (추천)

```
Week 1: Base + ATB 완성
  ↓ (ATB 플레이 가능)
Week 2-4: 턴제 개발
  ↓ (턴제 플레이 가능)
Week 5: 비교 테스트
  ↓
Week 6: 최종 결정
```

**장점**:
- ✅ ATB 먼저 완성 → 빠른 피드백
- ✅ 턴제 실패 시 ATB로 출시 가능
- ✅ 학습 곡선 완만

**단점**:
- ❌ 총 개발 기간 길어짐

---

#### 전략 B: 병렬 개발 (비추천)

```
Week 1-4: ATB + 턴제 동시 개발
  ↓ (혼란, 충돌 가능)
Week 5-6: 통합 & 테스트
```

**단점**:
- ❌ 머릿속 전환 비용
- ❌ 파일 충돌 가능
- ❌ Cursor 혼란 (어느 시스템?)

**결론**: 순차 개발 권장

---

### 4.3 Cursor 사용 팁

#### Tip 1: 시스템 명시

**나쁜 프롬프트**:
```
CombatManager.gd에 턴 종료 기능 추가해줘
```
→ 문제: 어느 CombatManager? ATB? 턴제?

**좋은 프롬프트**:
```
@autoload/CombatManagerTurnBased.gd

end_player_turn() 함수를 추가해줘.
플레이어가 턴 종료 버튼을 누르면:
1. 플레이어 턴 종료 효과 처리
2. enemy_turn_started 시그널 emit
3. _start_enemy_turn() 호출
```

---

#### Tip 2: 파일 참조 명확히

**나쁜 프롬프트**:
```
전투 UI 수정해줘
```
→ 문제: ATB UI? 턴제 UI?

**좋은 프롬프트**:
```
@ui/bottom_uis/CombatBottomUI_TurnBased.gd

End Turn 버튼을 추가해줘:
- 크기: 200×60
- 텍스트: "End Turn (Space)"
- 플레이어 턴에만 활성화
- 클릭 시 CombatManager.end_player_turn() 호출
```

---

#### Tip 3: 공통 로직은 Base 참조

**좋은 프롬프트**:
```
@autoload/CombatManagerBase.gd

_apply_card_effects() 함수를 추가해줘.
이 함수는 ATB와 턴제 양쪽에서 사용할 거야.

카드 효과:
- damage → 적에게 데미지
- block → Hero 방어
- buff → 스탯 증가
- draw → 카드 드로우

damage_dealt 시그널 emit 포함.
```

---

#### Tip 4: 한 번에 하나만

**나쁜 프롬프트**:
```
ATB 게이지랑 턴제 손패 UI 둘 다 만들어줘
```
→ 문제: Cursor 혼란, 품질 저하

**좋은 프롬프트**:
```
먼저 ATB 게이지만 만들자:
@ui/combat/ATBGaugeBar.tscn/gd

(ATB 완성 후)

이제 턴제 손패 UI 만들자:
@ui/combat/CardHandUI.tscn/gd
```

---

## 5. Cursor 프롬프트 모음

### 5.1 Base 구축 프롬프트 (3개)

#### 프롬프트 1: CombatManagerBase 생성

```
새 파일을 만들어줘: autoload/CombatManagerBase.gd

이 파일은 ATB와 턴제 전투 시스템의 공통 추상 클래스야.

다음을 포함해야 해:

1. 공통 시그널 5개:
   - combat_log_updated(message: String)
   - entity_updated(entity_type: String, index: int)
   - damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
   - combat_ended(victory: bool)
   - energy_changed(current: int, max: int)

2. 공통 변수:
   - in_combat: bool = false
   - hero: Dictionary = {}
   - monsters: Array = []
   - combat_log: Array = []

3. 공통 메서드 (실제 구현):
   - add_log(message: String)
   - _apply_damage(entity: Dictionary, damage: int)
   - _calculate_damage(atk: int, def: int, eva: int) -> int
   - _check_combat_end()
   - _get_first_alive_monster() -> int
   - _apply_card_effects(card: Dictionary, target_index: int)

4. 추상 메서드 (자식이 구현):
   - start_combat(monster_data: Array)
   - end_combat()
   - play_card(card_index: int, target_index: int = -1) -> bool

각 함수에 docstring 포함하고, 섹션별로 주석 구분.

참고:
@autoload/CombatManager.gd (현재 구현)
```

---

#### 프롬프트 2: CombatManager → CombatManagerATB 리네임

```
@autoload/CombatManager.gd

이 파일을 다음과 같이 수정해줘:

1. 파일명 변경: CombatManager.gd → CombatManagerATB.gd

2. 첫 줄 수정:
   extends Node
   ↓
   extends CombatManagerBase

3. 파일 상단에 주석:
   """
   CombatManagerATB - ATB Combat System
   Mode: Real-time with auto-battle support
   """

4. 중복 코드 제거:
   CombatManagerBase에 있는 메서드 삭제:
   - add_log()
   - _apply_damage()
   - _calculate_damage()
   - _check_combat_end()
   - _get_first_alive_monster()
   - _apply_card_effects()
   
   대신 super 클래스 메서드 직접 호출.

5. ATB 전용 시그널 추가:
   signal atb_gauge_updated(entity_type: String, index: int, atb: float, max_atb: float)

아직 project.godot은 수정하지 마.
```

---

#### 프롬프트 3: project.godot 업데이트

```
@project.godot

autoload 섹션을 수정해줘:

현재:
[autoload]
CombatManager="*res://autoload/CombatManager.gd"

목표:
[autoload]
CombatManagerBase="*res://autoload/CombatManagerBase.gd"

# === ACTIVE COMBAT SYSTEM === #
# ATB Mode (현재 활성)
CombatManager="*res://autoload/CombatManagerATB.gd"

# Turn-Based Mode (미래)
# CombatManager="*res://autoload/CombatManagerTurnBased.gd"
# === END === #

주석으로 전환 가능하게 구조화.
```

---

### 5.2 ATB 완성 프롬프트 (5개)

#### 프롬프트 4: ATB 게이지 컴포넌트

```
새 컴포넌트: ui/combat/ATBGaugeBar.tscn + ATBGaugeBar.gd

구조:
- Root: Control (80×20)
  - Background: Panel (어두운 회색)
  - Bar: ProgressBar (파랑→초록→금색 그라데이션)
  - Label: Label ("75/100", 우측 정렬)

GDScript:
```gdscript
extends Control

@onready var bar = $Bar
@onready var label = $Label

var current: float = 0.0
var maximum: float = 100.0

func set_atb(value: float, max_value: float = 100.0):
    current = value
    maximum = max_value
    _update_ui()

func _update_ui():
    var ratio = current / maximum
    bar.value = ratio * 100
    label.text = "%d/%d" % [int(current), int(maximum)]
    
    # Color based on fill
    if ratio >= 1.0:
        bar.modulate = Color(1, 0.9, 0.3)  # Gold
    elif ratio >= 0.75:
        bar.modulate = Color(0.3, 1, 0.3)  # Green
    else:
        bar.modulate = Color(0.5, 0.5, 1)  # Blue
```

UITheme 스타일 적용.
```

---

#### 프롬프트 5-8: (ATB Implementation Guide 참조)

ATB 완성은 **ATB_Implementation_Guide.md**의 프롬프트 사용.

---

### 5.3 턴제 개발 프롬프트 (10개)

#### 프롬프트 9-23: (TurnBased Implementation Guide 참조)

턴제 개발은 **TurnBased_Implementation_Guide.md**의 프롬프트 사용.

---

### 5.4 통합 프롬프트 (5개)

#### 프롬프트 24: InRun_v4 시스템 감지

```
@ui/screens/InRun_v4.gd

전투 시스템 자동 감지 함수 추가:

```gdscript
func _detect_combat_mode() -> String:
    """현재 CombatManager 타입 감지"""
    # ATB 메서드 체크
    if CombatManager.has_method("toggle_auto_battle"):
        return "ATB"
    
    # 턴제 메서드 체크
    if CombatManager.has_method("end_player_turn"):
        return "TurnBased"
    
    # Fallback
    push_warning("[InRun_v4] Unknown combat mode, defaulting to ATB")
    return "ATB"

const COMBAT_UI_PATHS = {
    "ATB": "res://ui/bottom_uis/CombatBottomUI_ATB.tscn",
    "TurnBased": "res://ui/bottom_uis/CombatBottomUI_TurnBased.tscn"
}

func _load_combat_ui():
    """전투 UI 동적 로드 (시스템에 따라)"""
    var mode = _detect_combat_mode()
    var ui_path = COMBAT_UI_PATHS[mode]
    var ui_scene = load(ui_path)
    
    if not ui_scene:
        push_error("[InRun_v4] Failed to load combat UI: %s" % ui_path)
        return
    
    var ui = ui_scene.instantiate()
    bottom_area.add_child(ui)
    current_bottom_ui = ui
    
    print("[InRun_v4] Loaded combat UI: %s" % mode)
```

switch_to_combat()에서 _load_combat_ui() 호출.
```

---

#### 프롬프트 25: 조건부 시그널 연결

```
@ui/screens/InRun_v4.gd

switch_to_combat()에서 조건부 시그널 연결:

```gdscript
func switch_to_combat():
    # ... (기존 코드) ...
    
    # === 공통 시그널 (항상 연결) === #
    CombatManager.combat_log_updated.connect(_on_combat_log_updated)
    CombatManager.entity_updated.connect(_on_entity_updated)
    CombatManager.damage_dealt.connect(_on_damage_dealt)
    CombatManager.combat_ended.connect(_on_combat_ended)
    CombatManager.energy_changed.connect(_on_energy_changed)
    
    # === ATB 전용 시그널 (조건부) === #
    if CombatManager.has_signal("atb_gauge_updated"):
        CombatManager.atb_gauge_updated.connect(_on_atb_gauge_updated)
        print("[InRun_v4] Connected ATB signals")
        
        # ATB 게이지 표시
        if hero_node:
            hero_node.set_atb_visible(true)
        for node in character_nodes:
            if node.visible:
                node.set_atb_visible(true)
    
    # === 턴제 전용 시그널 (조건부) === #
    if CombatManager.has_signal("turn_phase_changed"):
        CombatManager.turn_phase_changed.connect(_on_turn_phase_changed)
        CombatManager.intent_updated.connect(_on_intent_updated)
        print("[InRun_v4] Connected Turn-Based signals")
```

switch_to_exploration()에서 모든 시그널 연결 해제:

```gdscript
func switch_to_exploration():
    # 공통 시그널 연결 해제
    if CombatManager.combat_log_updated.is_connected(_on_combat_log_updated):
        CombatManager.combat_log_updated.disconnect(_on_combat_log_updated)
    
    # ATB 시그널 (있으면 해제)
    if CombatManager.has_signal("atb_gauge_updated"):
        if CombatManager.atb_gauge_updated.is_connected(_on_atb_gauge_updated):
            CombatManager.atb_gauge_updated.disconnect(_on_atb_gauge_updated)
    
    # 턴제 시그널 (있으면 해제)
    if CombatManager.has_signal("turn_phase_changed"):
        if CombatManager.turn_phase_changed.is_connected(_on_turn_phase_changed):
            CombatManager.turn_phase_changed.disconnect(_on_turn_phase_changed)
    
    # ... (나머지 로직) ...
```
```

---

#### 프롬프트 26-28: (디버그, 테스트 관련)

나머지 프롬프트는 다음 섹션 참조.

---

## 6. 비교 테스트 가이드

### 6.1 테스트 시나리오

#### 시나리오 1: 동일 덱 비교

**목적**: 순수 전투 시스템 차이 측정

**방법**:
1. 고정 덱 사용 (예: Strike 4장, Defend 4장, Skill 4장)
2. 동일 Monster (Slime 2마리, HP 20)
3. ATB 모드 10회 플레이
4. 턴제 모드 10회 플레이
5. 데이터 수집

**측정 지표**:
| 지표 | ATB | 턴제 | 비교 |
|------|-----|------|------|
| 평균 전투 시간 | ? | ? | 턴제가 X배 느림 |
| 승률 | ? | ? | 난이도 차이 |
| 카드 사용량 | ? | ? | 효율성 |
| HP 손실 | ? | ? | 안전성 |

---

#### 시나리오 2: 플레이어 경험

**목적**: 주관적 재미 비교

**방법**:
1. 각 시스템 1시간씩 플레이
2. 설문지 작성:
   - 전략적 깊이: 1-10
   - 몰입감: 1-10
   - 접근성: 1-10
   - 재미: 1-10
   - 다시 하고 싶은 정도: 1-10

**분석**:
- 평균 점수 비교
- 정성적 피드백

---

#### 시나리오 3: 극한 상황

**목적**: 시스템 안정성 테스트

**테스트 케이스**:
1. **Monster 10마리**: 성능 테스트
2. **손패 0장**: 덱 소진 테스트
3. **에너지 0**: 교착 상태 테스트
4. **HP 1 vs Monster HP 1**: 긴박한 상황

**ATB vs 턴제 안정성** 비교.

---

### 6.2 데이터 수집 방법

#### 자동 로깅

**CombatManagerBase에 추가**:
```gdscript
# autoload/CombatManagerBase.gd

var combat_stats: Dictionary = {
    "start_time": 0.0,
    "end_time": 0.0,
    "turns_taken": 0,
    "cards_played": 0,
    "damage_dealt_total": 0,
    "damage_taken_total": 0,
    "victory": false
}

func start_combat(monster_data: Array):
    # ... (기존 코드) ...
    
    # 통계 초기화
    combat_stats.start_time = Time.get_unix_time_from_system()
    combat_stats.turns_taken = 0
    combat_stats.cards_played = 0
    combat_stats.damage_dealt_total = 0
    combat_stats.damage_taken_total = 0

func play_card(card_index: int, target_index: int = -1) -> bool:
    # ... (기존 코드) ...
    
    if success:
        combat_stats.cards_played += 1
    
    return success

func _check_combat_end():
    # ... (기존 코드) ...
    
    if not in_combat:
        combat_stats.end_time = Time.get_unix_time_from_system()
        combat_stats.victory = (hero.hp > 0)
        _save_combat_stats()

func _save_combat_stats():
    """전투 통계 저장 (CSV)"""
    var file = FileAccess.open("user://combat_stats.csv", FileAccess.WRITE_READ)
    
    if not file:
        file = FileAccess.open("user://combat_stats.csv", FileAccess.WRITE)
        # Header
        file.store_line("mode,duration,turns,cards,dmg_dealt,dmg_taken,victory")
    
    # Data row
    var mode = "ATB" if has_method("toggle_auto_battle") else "TurnBased"
    var duration = combat_stats.end_time - combat_stats.start_time
    var row = "%s,%.2f,%d,%d,%d,%d,%s" % [
        mode,
        duration,
        combat_stats.turns_taken,
        combat_stats.cards_played,
        combat_stats.damage_dealt_total,
        combat_stats.damage_taken_total,
        "true" if combat_stats.victory else "false"
    ]
    
    file.store_line(row)
    file.close()
    
    print("[Combat Stats] Saved: %s" % row)
```

**결과 파일**: `user://combat_stats.csv`

---

#### 데이터 분석 (Python)

```python
import pandas as pd
import matplotlib.pyplot as plt

# CSV 로드
df = pd.read_csv("combat_stats.csv")

# ATB vs 턴제 비교
atb = df[df['mode'] == 'ATB']
turn = df[df['mode'] == 'TurnBased']

print("=== ATB Stats ===")
print(atb.describe())

print("\n=== Turn-Based Stats ===")
print(turn.describe())

# 시각화
fig, axes = plt.subplots(2, 2, figsize=(12, 10))

# 전투 시간
axes[0, 0].hist([atb['duration'], turn['duration']], label=['ATB', 'Turn-Based'])
axes[0, 0].set_title("Combat Duration")
axes[0, 0].legend()

# 카드 사용량
axes[0, 1].boxplot([atb['cards'], turn['cards']], labels=['ATB', 'Turn-Based'])
axes[0, 1].set_title("Cards Played")

# 승률
axes[1, 0].bar(['ATB', 'Turn-Based'], [atb['victory'].mean(), turn['victory'].mean()])
axes[1, 0].set_title("Win Rate")

# 데미지
axes[1, 1].scatter(atb['dmg_dealt'], atb['dmg_taken'], label='ATB', alpha=0.5)
axes[1, 1].scatter(turn['dmg_dealt'], turn['dmg_taken'], label='Turn-Based', alpha=0.5)
axes[1, 1].set_xlabel("Damage Dealt")
axes[1, 1].set_ylabel("Damage Taken")
axes[1, 1].legend()

plt.tight_layout()
plt.savefig("combat_comparison.png")
plt.show()
```

---

### 6.3 비교 체크리스트

**전투 전**:
- [ ] 동일 덱 준비
- [ ] 동일 Monster 설정
- [ ] 통계 파일 초기화

**ATB 테스트**:
- [ ] project.godot → ATB 활성화
- [ ] Godot 재실행
- [ ] 10회 전투
- [ ] 통계 수집

**턴제 테스트**:
- [ ] project.godot → 턴제 활성화
- [ ] Godot 재실행
- [ ] 10회 전투
- [ ] 통계 수집

**분석**:
- [ ] CSV 데이터 Python 분석
- [ ] 그래프 생성
- [ ] 정성적 피드백 작성
- [ ] 최종 결론

---

## 7. 트러블슈팅

### 7.1 자주 발생하는 에러

#### 에러 1: "CombatManager not found"

**증상**:
```
E 0:00:01:0123   get_node: Node not found: "/root/CombatManager" 
```

**원인**: project.godot에 CombatManager autoload 없음

**해결**:
```toml
# project.godot 확인
[autoload]
CombatManager="*res://autoload/CombatManagerATB.gd"  # 또는 TurnBased
```

Godot 재실행 필요!

---

#### 에러 2: "Invalid get index 'atb'"

**증상**:
```
Invalid get index 'atb' (on base: 'Dictionary')
```

**원인**: 턴제 모드에서 ATB 게이지 접근

**해결**:
```gdscript
# InRun_v4.gd
func _on_atb_gauge_updated(entity_type, index, atb, max_atb):
    # ATB 모드 체크
    if not CombatManager.has_method("toggle_auto_battle"):
        return  # 턴제 모드는 무시
    
    # ATB 게이지 업데이트
    # ...
```

---

#### 에러 3: "play_card() not implemented"

**증상**:
```
play_card() must be overridden
```

**원인**: CombatManagerBase의 추상 메서드를 자식이 구현 안 함

**해결**:
```gdscript
# CombatManagerTurnBased.gd
func play_card(card_index: int, target_index: int = -1) -> bool:
    # 구현 추가!
    # ...
    return true
```

---

#### 에러 4: 시그널 연결 중복

**증상**:
```
E 0:00:05:0789   connect: Signal 'combat_log_updated' is already connected 
```

**원인**: switch_to_combat() 여러 번 호출

**해결**:
```gdscript
func switch_to_combat():
    # 중복 연결 방지
    if not CombatManager.combat_log_updated.is_connected(_on_combat_log_updated):
        CombatManager.combat_log_updated.connect(_on_combat_log_updated)
```

---

### 7.2 Cursor 한계 & 우회

#### 한계 1: 조건부 로직 이해 못함

**문제**:
```gdscript
if CombatManager.has_method("toggle_auto_battle"):
    # ATB 로직
else:
    # 턴제 로직
```

Cursor가 양쪽 브랜치 모두 작성하려 함 → 혼란

**우회**:
```
두 개의 별도 프롬프트 사용:

프롬프트 1: ATB 로직만
프롬프트 2: 턴제 로직만

그 다음 수동으로 if/else 결합.
```

---

#### 한계 2: 파일 참조 헷갈림

**문제**: `@CombatManager.gd` 입력 시 ATB인지 턴제인지 모름

**우회**:
```
항상 전체 경로 사용:
@autoload/CombatManagerATB.gd
@autoload/CombatManagerTurnBased.gd
```

---

#### 한계 3: 대규모 리팩토링 실패

**문제**: "전체 CombatManager를 턴제로 바꿔줘" → 엉망

**우회**:
```
작은 단위로 분리:
1. 턴 시스템 변수 추가
2. _start_player_turn() 함수만 작성
3. end_player_turn() 함수만 작성
4. ...

한 번에 하나씩!
```

---

### 7.3 디버깅 팁

#### Tip 1: 시스템 감지 로그

**시작 시 어느 시스템인지 출력**:
```gdscript
# InRun_v4.gd
func _ready():
    var mode = _detect_combat_mode()
    print("=".repeat(60))
    print("🎮 COMBAT MODE: %s" % mode)
    print("=".repeat(60))
```

---

#### Tip 2: 시그널 추적

**모든 시그널에 print 추가**:
```gdscript
func _on_entity_updated(entity_type, index):
    print("[Signal] entity_updated: %s[%d]" % [entity_type, index])
    # ...

func _on_turn_phase_changed(phase, turn_count, is_player):
    print("[Signal] turn_phase_changed: %s (Turn %d, Player: %s)" % [phase, turn_count, is_player])
    # ...
```

---

#### Tip 3: 통계 출력

**전투 종료 시 요약 출력**:
```gdscript
func _check_combat_end():
    # ... (기존 코드) ...
    
    if not in_combat:
        print("\n=== Combat Summary ===")
        print("Duration: %.1fs" % (combat_stats.end_time - combat_stats.start_time))
        print("Cards Played: %d" % combat_stats.cards_played)
        print("Damage Dealt: %d" % combat_stats.damage_dealt_total)
        print("Victory: %s" % combat_stats.victory)
        print("=".repeat(30))
```

---

## 8. 최종 체크리스트

### 파일 구조
- [ ] CombatManagerBase.gd 생성
- [ ] CombatManagerATB.gd (리네임 완료)
- [ ] CombatManagerTurnBased.gd 생성
- [ ] UI 파일 분리 (ATB/TurnBased 접미사)
- [ ] project.godot 전환 시스템

### 공통 인터페이스
- [ ] 공통 시그널 정의
- [ ] 공통 메서드 구현 (Base)
- [ ] 추상 메서드 정의
- [ ] _apply_card_effects() 공통화

### ATB 시스템
- [ ] CombatManagerATB 완성
- [ ] ATB 게이지 UI
- [ ] 자동전투 AI
- [ ] 속도 제어

### 턴제 시스템
- [ ] CombatManagerTurnBased 완성
- [ ] 턴 시스템 구현
- [ ] 손패 UI (드래그 앤 드롭)
- [ ] 의도 시스템

### 통합
- [ ] InRun_v4 시스템 감지
- [ ] 조건부 시그널 연결
- [ ] UI 동적 로드
- [ ] 전환 스크립트

### 테스트
- [ ] ATB 10회 플레이
- [ ] 턴제 10회 플레이
- [ ] 통계 수집
- [ ] 비교 분석

### 문서
- [ ] CHANGELOG 업데이트
- [ ] 주석 완비
- [ ] 비교 리포트 작성

---

## 9. 결론 및 권장사항

### 개발 전략 요약

**옵션 A: ATB 먼저 완성 (추천) 🌟**
1. Week 1: Base + ATB 완성
2. Week 2: 플레이테스트 & 밸런싱
3. Week 3: v1.0 출시
4. 이후: 피드백 수집
5. v2.0: 턴제 추가 (선택적)

**장점**:
- ✅ 빠른 출시 (3주)
- ✅ 낮은 리스크
- ✅ 점진적 개선

---

**옵션 B: 동시 개발**
1. Week 1: Base + ATB 골격
2. Week 2-3: ATB 완성
3. Week 4-6: 턴제 개발
4. Week 7: 통합 & 테스트
5. Week 8: v1.0 출시 (두 모드)

**장점**:
- ✅ 플레이어 선택권
- ✅ 시장 검증

**단점**:
- ❌ 개발 시간 2배
- ❌ 밸런싱 2배
- ❌ 리스크 높음

---

### 최종 권고

**첫 프로젝트라면**: 옵션 A (ATB 먼저)  
**경험 있다면**: 옵션 B (두 모드)  
**불확실하다면**: ATB 완성 → 피드백 → 결정

---

**문서 종료**

**작성 시간**: 2026-02-26  
**버전**: 1.0  
**관련 문서**:
- ATB_Implementation_Guide.md
- TurnBased_Implementation_Guide.md
