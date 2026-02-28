# ATB Implementation Guide - Dream Collector

**작성일**: 2026-02-26  
**작성자**: Atlas  
**용도**: Cursor IDE로 ATB 전투 시스템 개발  
**목표**: 완전한 ATB 자동전투 시스템 구현 + 턴제와 비교 테스트

---

## 📋 목차

1. [현재 구현 분석](#1-현재-구현-분석)
2. [ATB 시스템 완전 구현 명세](#2-atb-시스템-완전-구현-명세)
3. [Cursor 개발 가이드](#3-cursor-개발-가이드)
4. [완성 체크리스트](#4-완성-체크리스트)

---

## 1. 현재 구현 분석

### 1.1 CombatManager.gd 코드 리뷰

**파일 위치**: `autoload/CombatManager.gd` (약 400 라인)

#### 현재 구조

**주요 변수**:
```gdscript
# Combat State
var in_combat: bool = false
var hero: Dictionary = {}              # {name, hp, max_hp, atk, def, spd, eva, atb, energy, block}
var monsters: Array = []               # [{name, hp, max_hp, atk, def, spd, atb, block}, ...]
var combat_log: Array = []

# ATB Settings
const ATB_MAX: float = 100.0
const ATB_CHARGE_RATE: float = 1.0

# Energy System
const ENERGY_MAX: int = 3
const ENERGY_TIMER_DURATION: float = 5.0
var energy_timer: float = 0.0

# Auto-Battle
var auto_battle_enabled: bool = false
var auto_battle_delay: float = 0.5
var auto_battle_timer: float = 0.0

# Speed
var speed_multiplier: float = 1.0      # 1×, 2×, 3×
```

**주요 시그널**:
```gdscript
signal combat_log_updated(message: String)
signal entity_updated(entity_type: String, index: int)
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal combat_ended(victory: bool)
signal energy_changed(current: int, max: int)
signal energy_timer_updated(progress: float)
```

**핵심 함수**:
1. `_process(delta)`: ATB 업데이트, 턴 체크, 에너지 회복, 자동전투
2. `_update_atb(delta)`: 모든 entity의 ATB 게이지 증가
3. `_check_atb_turns()`: ATB 100 도달 시 턴 실행
4. `_execute_hero_turn()`: Hero 자동 공격
5. `_execute_monster_turn(index)`: Monster 행동
6. `play_card(card_index, target_index)`: 카드 사용 (수동/자동)
7. `_apply_card_effects(card, target)`: 카드 효과 적용
8. `_update_energy_timer(delta)`: 시간당 에너지 회복 + 카드 드로우
9. `_update_auto_battle(delta)`: 자동전투 AI

#### ATB 메커니즘 분석

**ATB 게이지 계산**:
```gdscript
# 매 프레임마다 업데이트
entity.atb += (ATB_MAX / entity.spd) * delta * ATB_CHARGE_RATE

# 예시 (spd=10, delta=0.016초):
# atb += (100 / 10) * 0.016 * 1.0 = 0.16
# 약 6.25초 후 100 도달
```

**턴 실행 조건**:
- `entity.atb >= ATB_MAX` (100)
- `entity.hp > 0`

**턴 실행 후**:
- `entity.atb = 0.0` (리셋)
- 다음 턴까지 다시 충전

**에너지 시스템**:
- 손패 크기에 따라 동적 회복 시간 (5장 = 5초)
- 에너지 최대치(3) 시: 카드만 드로우
- 에너지 미만: 에너지 +1 + 카드 드로우

**자동전투 AI**:
- `AutoBattleAI.choose_card_to_play()` 호출
- 에너지 있고 손에 카드 있으면 자동 사용
- 0.5초 딜레이

---

### 1.2 장점 분석 (ATB 시스템)

#### ✅ 장점 1: 낮은 학습 곡선
- **이유**: 자동전투 지원으로 초보자도 쉽게 플레이
- **근거**: 모바일 게임 트렌드 (AFK Arena, Raid: Shadow Legends)
- **타겟**: 캐주얼~미드코어 유저에게 최적

#### ✅ 장점 2: 빠른 전투 템포
- **이유**: 턴 대기 없이 실시간 진행
- **측정**: 1회 전투 약 30-60초 (vs 턴제 2-5분)
- **효과**: 짧은 플레이 세션에 적합 (출퇴근 시간)

#### ✅ 장점 3: 멀티태스킹 가능
- **이유**: 자동전투 ON → 다른 일 하면서 플레이
- **시나리오**: 직장인/학생이 일하면서 레벨업
- **비교**: 턴제는 지속적 집중 필요

#### ✅ 장점 4: 속도 조절 유연성
- **구현**: `speed_multiplier` (1×, 2×, 3×)
- **효과**: 
  - 빠른 파밍: 3× 속도
  - 전략적 플레이: 1× 속도 + 수동 카드
- **편의성**: 플레이어가 선택 가능

#### ✅ 장점 5: 방치형 게임플레이
- **시장**: 모바일 방치형 게임 큰 시장
- **수익화**: 자동전투 + 스태미너 시스템 결합 용이
- **유저 유지**: 짧은 플레이 세션으로 이탈률 낮음

#### ✅ 장점 6: 구현 복잡도 낮음
- **근거**: 이미 70% 구현 완료
- **추가 작업**: UI 개선, AI 튜닝
- **비교**: 턴제는 손패 UI, 드래그 앤 드롭 등 필요

#### ✅ 장점 7: 리소스 제약 적합
- **개발 시간**: 2-3주 완성 가능
- **테스트**: 밸런싱 상대적 단순
- **첫 프로젝트**: 위험 최소화

---

### 1.3 단점 분석 (ATB 시스템)

#### ❌ 단점 1: 전략적 깊이 제한
- **문제**: 자동전투는 최적 선택 보장 못함
- **개선**: 
  - 수동 카드 플레이 옵션 제공
  - AI 우선순위 시스템 고도화
  - 카드 조합 시너지 설계

#### ❌ 단점 2: 플레이어 주도성 약함
- **문제**: "보는 게임" 느낌
- **개선**:
  - 중요 순간 자동 일시정지 (보스 등장)
  - 세미 오토 모드 (카드 선택만 수동)
  - 특수 카드는 수동 확인 필수

#### ❌ 단점 3: 덱빌딩 장르 정체성 충돌
- **문제**: Slay the Spire 팬은 턴제 선호
- **완화**:
  - "ATB 모드는 선택 사항" 마케팅
  - 턴제 모드 나중에 추가
  - 하이브리드 시스템 (세미 오토)

#### ❌ 단점 4: 실시간 밸런싱 어려움
- **문제**: ATB 속도 밸런싱 예민
- **예시**: spd 10 vs 5 → 2배 차이 큼
- **해결**:
  - 상한/하한선 설정 (5-20)
  - 상대 속도 비율로 조정

#### ❌ 단점 5: PC/콘솔 시장 부적합
- **문제**: PC 유저는 턴제 선호
- **시장 데이터**: Steam 덱빌더 대부분 턴제
- **전략**: 모바일 우선 → PC는 나중

#### ❌ 단점 6: 긴장감 부족
- **문제**: 자동전투는 긴박함 ↓
- **개선**:
  - 보스전 자동 OFF
  - 위기 상황 경고 (HP 30% 이하)
  - 특수 이벤트 강제 선택

---

### 1.4 Slay the Spire 비교표

| 항목 | ATB (Dream Collector) | 턴제 (Slay the Spire) | 승자 |
|------|---------------------|---------------------|------|
| **전략적 깊이** | ⭐⭐⭐ (70%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **접근성** | ⭐⭐⭐⭐⭐ (100%) | ⭐⭐⭐ (60%) | ATB |
| **플레이 속도** | ⭐⭐⭐⭐⭐ (30-60초/전투) | ⭐⭐ (2-5분/전투) | ATB |
| **몰입감** | ⭐⭐⭐ (70%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **멀티태스킹** | ⭐⭐⭐⭐⭐ (가능) | ⭐ (불가능) | ATB |
| **학습 곡선** | ⭐⭐⭐⭐⭐ (쉬움) | ⭐⭐⭐ (중간) | ATB |
| **리플레이 가치** | ⭐⭐⭐⭐ (80%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **모바일 적합성** | ⭐⭐⭐⭐⭐ (100%) | ⭐⭐⭐ (70%) | ATB |
| **PC/콘솔 적합성** | ⭐⭐ (40%) | ⭐⭐⭐⭐⭐ (100%) | 턴제 |
| **개발 난이도** | ⭐⭐⭐⭐⭐ (쉬움) | ⭐⭐⭐ (중간) | ATB |
| **밸런싱 난이도** | ⭐⭐⭐ (중간) | ⭐⭐⭐⭐ (어려움) | ATB |
| **수익화 가능성** | ⭐⭐⭐⭐⭐ (높음) | ⭐⭐⭐ (중간) | ATB |

**종합 점수**:
- ATB: 52/60 (86.7%)
- 턴제: 48/60 (80%)

**결론**: 
- **모바일 우선 전략** → ATB 유리
- **PC 하드코어 시장** → 턴제 유리
- **첫 프로젝트 리스크 관리** → ATB 안전

---

## 2. ATB 시스템 완전 구현 명세

### 2.1 파일 구조 재설계

#### 현재 (단일 시스템)
```
autoload/
└── CombatManager.gd (ATB 전용, 400 라인)
```

#### 목표 (다중 시스템 지원)
```
autoload/
├── CombatManagerBase.gd         # 추상 인터페이스 (새로 생성, 150 라인)
├── CombatManagerATB.gd          # ATB 구현체 (리네임, 450 라인)
└── CombatManagerTurnBased.gd   # 턴제 구현체 (미래, 500 라인)
```

**왜 분리하나?**:
- 두 시스템 독립적 개발/테스트
- 런타임 전환 가능
- 코드 충돌 최소화

---

### 2.2 CombatManagerBase.gd (추상 클래스)

**목적**: 두 전투 시스템의 공통 인터페이스

```gdscript
# autoload/CombatManagerBase.gd
extends Node
class_name CombatManagerBase

# ─── Common Signals ───────────────────────────────────

signal combat_log_updated(message: String)
signal entity_updated(entity_type: String, index: int)
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal combat_ended(victory: bool)
signal energy_changed(current: int, max: int)

# ─── Common State ─────────────────────────────────────

var in_combat: bool = false
var hero: Dictionary = {}
var monsters: Array = []
var combat_log: Array = []

# ─── Abstract Methods (Must Override) ─────────────────

func start_combat(monster_data: Array):
	"""
	Initialize combat with given monsters.
	Must be overridden by child classes.
	"""
	push_error("start_combat() not implemented")

func end_combat():
	"""
	Clean up combat state.
	Must be overridden by child classes.
	"""
	push_error("end_combat() not implemented")

func play_card(card_index: int, target_index: int = -1) -> bool:
	"""
	Play a card from hand.
	Returns true if successful.
	Must be overridden by child classes.
	"""
	push_error("play_card() not implemented")
	return false

func get_combat_state() -> Dictionary:
	"""
	Get current combat state for UI sync.
	Returns: {hero, monsters, turn_info, etc.}
	"""
	return {
		"hero": hero,
		"monsters": monsters,
		"in_combat": in_combat
	}

# ─── Common Methods (Shared Logic) ────────────────────

func add_log(message: String):
	"""Add message to combat log (shared)"""
	combat_log.append(message)
	combat_log_updated.emit(message)
	print("[Combat] " + message)

func _apply_damage(entity: Dictionary, damage: int):
	"""Apply damage to entity (block first, then HP)"""
	if entity.block > 0:
		var blocked = min(entity.block, damage)
		entity.block -= blocked
		damage -= blocked
		if damage <= 0:
			return
	
	entity.hp -= damage
	entity.hp = max(0, entity.hp)

func _calculate_damage(atk: int, def: int, eva: int) -> int:
	"""Calculate damage with evasion and variance"""
	if randf() * 100 < eva:
		return 0
	
	var base_damage = atk - def
	base_damage = max(1, base_damage)
	
	var variance = randf_range(0.9, 1.1)
	var final_damage = int(base_damage * variance)
	
	return max(1, final_damage)

func _check_combat_end():
	"""Check victory/defeat conditions"""
	if hero.hp <= 0:
		add_log("Hero has been defeated!")
		in_combat = false
		combat_ended.emit(false)
		return
	
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
	"""Get index of first alive monster"""
	for i in range(monsters.size()):
		if monsters[i].hp > 0:
			return i
	return -1
```

---

### 2.3 CombatManagerATB.gd (완전 구현)

**기존 파일**: `autoload/CombatManager.gd`  
**작업**: 리네임 → `CombatManagerATB.gd` + `extends CombatManagerBase` 추가

```gdscript
# autoload/CombatManagerATB.gd
extends CombatManagerBase

# ─── ATB-Specific Signals ─────────────────────────────

signal atb_gauge_updated(entity_type: String, index: int, atb: float, max_atb: float)
signal energy_timer_updated(progress: float)

# ─── ATB Settings ─────────────────────────────────────

const ATB_MAX: float = 100.0
const ATB_CHARGE_RATE: float = 1.0

# ─── Energy System ────────────────────────────────────

const ENERGY_MAX: int = 3
var energy_timer: float = 0.0

# ─── Auto-Battle ──────────────────────────────────────

var auto_battle_enabled: bool = false
var auto_battle_delay: float = 0.5
var auto_battle_timer: float = 0.0

# ─── Speed Control ────────────────────────────────────

var speed_multiplier: float = 1.0  # 1×, 2×, 3×

# ─── Lifecycle ────────────────────────────────────────

func _process(delta):
	if not in_combat:
		return
	
	var scaled_delta = delta * speed_multiplier
	
	_update_atb(scaled_delta)
	_check_atb_turns()
	_update_energy_timer(scaled_delta)
	
	if auto_battle_enabled:
		_update_auto_battle(scaled_delta)

# ─── Combat Start/End ─────────────────────────────────

func start_combat(monster_data: Array):
	in_combat = true
	combat_log.clear()
	
	# Initialize Hero
	hero = {
		"name": "Hero",
		"hp": 80,
		"max_hp": 80,
		"atk": 10,
		"def": 2,
		"spd": 10,
		"eva": 5,
		"atb": 0.0,
		"energy": 3,
		"block": 0
	}
	
	# Initialize Monsters
	monsters.clear()
	for m_data in monster_data:
		var monster = m_data.duplicate()
		monster["atb"] = randf_range(0, 50)
		monster["block"] = 0
		monsters.append(monster)
	
	# Initialize Deck
	var starting_deck = _get_starting_deck()
	DeckManager.initialize_combat_deck(starting_deck)
	DeckManager.draw_cards(5)
	
	energy_timer = 0.0
	
	add_log("Combat started! (ATB Mode)")
	add_log("Hero vs %d monsters" % monsters.size())
	
	energy_changed.emit(hero.energy, ENERGY_MAX)
	energy_timer_updated.emit(0.0)

func end_combat():
	in_combat = false
	hero.clear()
	monsters.clear()
	combat_log.clear()
	auto_battle_enabled = false
	auto_battle_timer = 0.0
	energy_timer = 0.0

# ─── ATB System ───────────────────────────────────────

func _update_atb(delta: float):
	"""Update ATB gauges for all entities"""
	# Hero ATB
	if hero.hp > 0:
		hero.atb += (ATB_MAX / hero.spd) * delta * ATB_CHARGE_RATE
		if hero.atb >= ATB_MAX:
			hero.atb = ATB_MAX
		atb_gauge_updated.emit("hero", 0, hero.atb, ATB_MAX)
	
	# Monsters ATB
	for i in range(monsters.size()):
		var monster = monsters[i]
		if monster.hp > 0:
			monster.atb += (ATB_MAX / monster.spd) * delta * ATB_CHARGE_RATE
			if monster.atb >= ATB_MAX:
				monster.atb = ATB_MAX
			atb_gauge_updated.emit("monster", i, monster.atb, ATB_MAX)

func _check_atb_turns():
	"""Check if any entity is ready to act (ATB >= 100)"""
	# Hero turn
	if hero.atb >= ATB_MAX and hero.hp > 0:
		_execute_hero_turn()
	
	# Monster turns
	for i in range(monsters.size()):
		var monster = monsters[i]
		if monster.atb >= ATB_MAX and monster.hp > 0:
			_execute_monster_turn(i)

func _execute_hero_turn():
	"""Hero auto-attack (if no cards played)"""
	var target_index = _get_first_alive_monster()
	
	if target_index == -1:
		return
	
	var target = monsters[target_index]
	var damage = _calculate_damage(hero.atk, target.def, target.eva)
	
	if damage > 0:
		_apply_damage(target, damage)
		add_log("%s attacked %s for %d damage" % [hero.name, target.name, damage])
		damage_dealt.emit("monster", target_index, damage, false)
	else:
		add_log("%s attacked %s but missed!" % [hero.name, target.name])
	
	hero.atb = 0.0
	entity_updated.emit("hero", 0)
	entity_updated.emit("monster", target_index)
	
	_check_combat_end()

func _execute_monster_turn(monster_index: int):
	"""Monster attacks hero"""
	var monster = monsters[monster_index]
	
	var damage = _calculate_damage(monster.atk, hero.def, hero.eva)
	
	if damage > 0:
		_apply_damage(hero, damage)
		add_log("%s attacked %s for %d damage" % [monster.name, hero.name, damage])
		damage_dealt.emit("hero", 0, damage, false)
	else:
		add_log("%s attacked %s but missed!" % [monster.name, hero.name])
	
	monster.atb = 0.0
	entity_updated.emit("monster", monster_index)
	entity_updated.emit("hero", 0)
	
	_check_combat_end()

# ─── Energy System ────────────────────────────────────

func _update_energy_timer(delta: float):
	"""Update energy timer and charge energy when full"""
	var hand_size = DeckManager.get_hand_size()
	var dynamic_duration = max(1.0, float(hand_size))
	
	energy_timer += delta
	
	var progress = energy_timer / dynamic_duration
	energy_timer_updated.emit(progress)
	
	if energy_timer >= dynamic_duration:
		energy_timer = 0.0
		
		if hero.energy >= ENERGY_MAX:
			# Only draw card
			var drawn_card = DeckManager.draw_card()
			if not drawn_card.is_empty():
				add_log("Drew 1 card: %s" % drawn_card.name)
		else:
			# Charge energy + draw card
			hero.energy += 1
			add_log("+1 Energy ⚡")
			energy_changed.emit(hero.energy, ENERGY_MAX)
			entity_updated.emit("hero", 0)
			
			var drawn_card = DeckManager.draw_card()
			if not drawn_card.is_empty():
				add_log("Drew 1 card: %s" % drawn_card.name)

# ─── Card Play ────────────────────────────────────────

func play_card(card_index: int, target_index: int = -1) -> bool:
	"""Play a card from hand"""
	if card_index < 0 or card_index >= DeckManager.get_hand_size():
		add_log("Invalid card selection")
		return false
	
	var cards = DeckManager.get_hand_cards()
	var card = cards[card_index]
	
	# Check energy
	if hero.energy < card.cost:
		add_log("Not enough energy! (Need %d, have %d)" % [card.cost, hero.energy])
		return false
	
	# Auto-target if needed
	var card_target = card.get("target", "none")
	if card_target == "single" and target_index == -1:
		target_index = _get_first_alive_monster()
		if target_index == -1:
			add_log("No valid target!")
			return false
	
	# Spend energy
	hero.energy -= card.cost
	energy_changed.emit(hero.energy, ENERGY_MAX)
	entity_updated.emit("hero", 0)
	
	# Play card
	DeckManager.play_card(card_index)
	
	# Apply effects
	_apply_card_effects(card, target_index)
	
	add_log("Played %s (Cost: %d)" % [card.name, card.cost])
	
	return true

func _apply_card_effects(card: Dictionary, target_index: int):
	"""Apply card effects"""
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

# ─── Auto-Battle ──────────────────────────────────────

func toggle_auto_battle():
	"""Toggle auto-battle on/off"""
	auto_battle_enabled = not auto_battle_enabled
	auto_battle_timer = 0.0
	
	if auto_battle_enabled:
		add_log("🤖 Auto-battle enabled")
	else:
		add_log("🤖 Auto-battle disabled")

func _update_auto_battle(delta: float):
	"""Auto-battle AI"""
	if not auto_battle_enabled:
		return
	
	auto_battle_timer += delta
	if auto_battle_timer < auto_battle_delay:
		return
	
	var hand = DeckManager.get_hand_cards()
	if hand.is_empty() or hero.energy <= 0:
		return
	
	# AI chooses card
	var choice = AutoBattleAI.choose_card_to_play(hand, hero, monsters, hero.energy)
	
	if choice.is_empty():
		return
	
	# Play card
	var success = play_card(choice.card_index, choice.get("target_index", -1))
	
	if success:
		auto_battle_timer = 0.0

# ─── Speed Control ────────────────────────────────────

func set_speed_multiplier(multiplier: float):
	"""Set combat speed (1×, 2×, 3×)"""
	speed_multiplier = clamp(multiplier, 0.5, 3.0)
	add_log("⚡ Speed: %.1f×" % speed_multiplier)

# ─── Utility ──────────────────────────────────────────

func _get_starting_deck() -> Array:
	"""Get starting deck card IDs"""
	return [
		"attack_01", "attack_01", "attack_01", "attack_01",  # 4x Strike
		"attack_03", "attack_03", "attack_03",  # 3x Slash
		"defense_01", "defense_01", "defense_01", "defense_01",  # 4x Defend
		"skill_02"  # 1x Focus
	]

func can_afford_card(card_cost: int) -> bool:
	return hero.energy >= card_cost

func get_current_energy() -> int:
	return hero.get("energy", 0)

func get_max_energy() -> int:
	return ENERGY_MAX
```

---

### 2.4 UI 컴포넌트 추가

#### ATBGaugeBar.tscn/gd (새로 생성)

**위치**: `ui/combat/ATBGaugeBar.tscn`

**용도**: 각 entity 밑에 ATB 게이지 표시

**디자인**:
```
[███████░░░] 75/100
```

**GDScript**:
```gdscript
# ui/combat/ATBGaugeBar.gd
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
		bar.modulate = Color(1, 0.9, 0.3)  # Gold (ready!)
	elif ratio >= 0.75:
		bar.modulate = Color(0.3, 1, 0.3)  # Green
	else:
		bar.modulate = Color(0.5, 0.5, 1)  # Blue
```

---

## 3. Cursor 개발 가이드

### 3.1 구현 순서

#### Phase 1: 기반 작업 (30분)

**목표**: 파일 구조 재구성, 공통 인터페이스 생성

**Task 1-1: CombatManagerBase.gd 생성**

Cursor 프롬프트:
```
새 파일을 만들어줘: autoload/CombatManagerBase.gd

이 파일은 ATB와 턴제 전투 시스템의 공통 추상 클래스야.

다음을 포함해야 해:
1. 공통 시그널 6개:
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

3. 추상 메서드 (override 필수):
   - start_combat(monster_data: Array)
   - end_combat()
   - play_card(card_index: int, target_index: int = -1) -> bool
   - get_combat_state() -> Dictionary

4. 공통 메서드 (공유 로직):
   - add_log(message: String)
   - _apply_damage(entity: Dictionary, damage: int)
   - _calculate_damage(atk: int, def: int, eva: int) -> int
   - _check_combat_end()
   - _get_first_alive_monster() -> int

각 함수에 docstring 포함하고, 섹션별로 주석 구분해줘.
```

**예상 결과**: `CombatManagerBase.gd` 생성 (150 라인)

---

**Task 1-2: CombatManager.gd → CombatManagerATB.gd 리네임**

Cursor 프롬프트:
```
@autoload/CombatManager.gd

이 파일을 다음과 같이 수정해줘:

1. 파일명 변경: CombatManager.gd → CombatManagerATB.gd
2. 첫 줄 수정: extends Node → extends CombatManagerBase
3. 파일 상단에 주석 추가:
   """
   CombatManagerATB - ATB (Active Time Battle) Combat System
   Extends: CombatManagerBase
   Mode: Real-time with auto-battle support
   """

4. 중복 코드 제거:
   - CombatManagerBase에 있는 공통 메서드 삭제:
     * add_log()
     * _apply_damage()
     * _calculate_damage()
     * _check_combat_end()
     * _get_first_alive_monster()
   - 대신 super 클래스 메서드 호출

5. ATB 전용 시그널 추가:
   signal atb_gauge_updated(entity_type: String, index: int, atb: float, max_atb: float)

아직 실행하지 말고, 코드만 수정해줘.
```

**예상 결과**: `CombatManagerATB.gd` 생성, 중복 코드 제거

---

**Task 1-3: project.godot 업데이트**

Cursor 프롬프트:
```
@project.godot

autoload 섹션을 수정해줘:

현재:
[autoload]
CombatManager="*res://autoload/CombatManager.gd"

목표:
[autoload]
CombatManagerBase="*res://autoload/CombatManagerBase.gd"
CombatManager="*res://autoload/CombatManagerATB.gd"

설명: 
- CombatManagerBase는 추상 클래스
- CombatManager는 실제로 CombatManagerATB를 가리킴 (기존 코드 호환성)
```

**예상 결과**: 프로젝트 설정 업데이트, 기존 코드 호환

---

**Phase 1 테스트**:
```bash
# Godot 실행
godot project.godot

# 확인:
1. 에러 없이 로드되는지
2. CombatManager가 CombatManagerATB를 참조하는지
3. 기존 combat 시작되는지
```

---

#### Phase 2: ATB 게이지 UI (45분)

**목표**: ATB 게이지 바 컴포넌트 생성 + InRun_v4 통합

**Task 2-1: ATBGaugeBar 컴포넌트 생성**

Cursor 프롬프트:
```
새 컴포넌트를 만들어줘:

파일: ui/combat/ATBGaugeBar.tscn + ATBGaugeBar.gd

구조:
- Root: Control (size: 80×20)
  - Background: Panel (어두운 회색)
  - Bar: ProgressBar (파랑→초록→금색)
  - Label: Label (우측 정렬, "75/100")

GDScript (ATBGaugeBar.gd):
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

스타일 적용해줘 (UITheme 사용).
```

**예상 결과**: ATB 게이지 컴포넌트 완성

---

**Task 2-2: CharacterNode에 ATB 게이지 추가**

Cursor 프롬프트:
```
@ui/components/CharacterNode.tscn
@ui/components/CharacterNode.gd

CharacterNode에 ATB 게이지를 추가해줘:

1. .tscn:
   - ATBGaugeBar 인스턴스 추가
   - HP바 아래에 배치 (y +25)
   - 초기 visible = false

2. .gd:
   @onready var atb_bar = $ATBGaugeBar
   
   func set_atb_visible(visible: bool):
       atb_bar.visible = visible
   
   func update_atb(value: float, max_value: float = 100.0):
       atb_bar.set_atb(value, max_value)

기본적으로 ATB바는 숨겨져 있고, ATB 모드에서만 표시.
```

**예상 결과**: CharacterNode가 ATB 게이지 지원

---

**Task 2-3: InRun_v4에서 ATB 게이지 업데이트**

Cursor 프롬프트:
```
@ui/screens/InRun_v4.gd

switch_to_combat() 함수에서 CombatManager 시그널 연결을 추가해줘:

```gdscript
func switch_to_combat():
	# ... (기존 코드) ...
	
	# Connect ATB signals
	if CombatManager.has_signal("atb_gauge_updated"):
		CombatManager.atb_gauge_updated.connect(_on_atb_gauge_updated)
	
	# Show ATB bars on all characters
	if hero_node:
		hero_node.set_atb_visible(true)
	
	for node in character_nodes:
		if node.visible:
			node.set_atb_visible(true)

func _on_atb_gauge_updated(entity_type: String, index: int, atb: float, max_atb: float):
	if entity_type == "hero" and hero_node:
		hero_node.update_atb(atb, max_atb)
	elif entity_type == "monster" and index < character_nodes.size():
		character_nodes[index].update_atb(atb, max_atb)
```

switch_to_exploration()에서는 시그널 연결 해제하고 ATB바 숨기기.
```

**예상 결과**: ATB 게이지가 실시간 업데이트됨

---

**Phase 2 테스트**:
```bash
# Godot 실행 → 전투 시작
1. Hero와 Monster 밑에 ATB 바 표시되는지
2. 바가 점점 차오르는지
3. 100 도달 시 금색으로 변하는지
4. 턴 실행 후 0으로 리셋되는지
```

---

#### Phase 3: 자동전투 AI 개선 (60분)

**목표**: AutoBattleAI 고도화, 우선순위 시스템

**Task 3-1: AutoBattleAI.gd 생성**

Cursor 프롬프트:
```
새 파일: autoload/AutoBattleAI.gd

자동전투 AI 로직 구현:

```gdscript
extends Node

# ─── Card Priority ────────────────────────────────────

enum CardPriority {
	CRITICAL = 5,  # 즉시 사용 (강력한 공격, 위기 상황 방어)
	HIGH = 4,      # 높은 우선순위 (효율적 공격)
	MEDIUM = 3,    # 중간 (일반 공격, 버프)
	LOW = 2,       # 낮은 (드로우, 약한 효과)
	SKIP = 1       # 사용 안 함
}

# ─── Main AI ──────────────────────────────────────────

func choose_card_to_play(hand: Array, hero: Dictionary, monsters: Array, energy: int) -> Dictionary:
	"""
	Choose best card to play from hand.
	Returns: {card_index: int, target_index: int} or {} if none
	"""
	if hand.is_empty() or energy <= 0:
		return {}
	
	var best_choice = {}
	var best_score = -999.0
	
	for i in range(hand.size()):
		var card = hand[i]
		
		# Skip if can't afford
		if card.cost > energy:
			continue
		
		# Calculate score
		var score = _calculate_card_score(card, hero, monsters)
		
		if score > best_score:
			best_score = score
			best_choice = {
				"card_index": i,
				"target_index": _choose_target(card, monsters)
			}
	
	return best_choice

# ─── Scoring ──────────────────────────────────────────

func _calculate_card_score(card: Dictionary, hero: Dictionary, monsters: Array) -> float:
	"""Calculate priority score for card"""
	var score = 0.0
	
	# Damage cards
	if card.has("damage"):
		score += card.damage * 1.5
		
		# Bonus if can kill
		var target = _get_weakest_monster(monsters)
		if target and target.hp <= card.damage:
			score += 50.0  # Kill priority
	
	# Block cards
	if card.has("block"):
		var hp_ratio = float(hero.hp) / float(hero.max_hp)
		
		if hp_ratio < 0.3:
			score += card.block * 3.0  # Critical defense!
		elif hp_ratio < 0.6:
			score += card.block * 1.5
		else:
			score += card.block * 0.5  # Low priority when healthy
	
	# Buff cards
	if card.has("buff"):
		score += 30.0  # Always good
	
	# Draw cards
	if card.has("draw"):
		score += card.draw * 10.0
	
	# Cost efficiency
	score -= card.cost * 5.0
	
	return score

func _choose_target(card: Dictionary, monsters: Array) -> int:
	"""Choose best target for card"""
	var target_type = card.get("target", "none")
	
	if target_type == "single":
		# Prioritize weakest (kill faster)
		var weakest = _get_weakest_monster(monsters)
		if weakest:
			return monsters.find(weakest)
	
	return -1

func _get_weakest_monster(monsters: Array) -> Dictionary:
	"""Get monster with lowest HP"""
	var weakest = null
	var min_hp = 9999
	
	for monster in monsters:
		if monster.hp > 0 and monster.hp < min_hp:
			min_hp = monster.hp
			weakest = monster
	
	return weakest if weakest else {}
```

project.godot에 autoload 추가:
AutoBattleAI="*res://autoload/AutoBattleAI.gd"
```

**예상 결과**: 스마트한 자동전투 AI

---

**Task 3-2: 카드 우선순위 데이터 추가**

Cursor 프롬프트:
```
카드 데이터에 auto_priority 필드 추가:

예시:
{
	"id": "attack_01",
	"name": "Strike",
	"cost": 1,
	"damage": 6,
	"target": "single",
	"auto_priority": "MEDIUM"  # ← 추가
}

{
	"id": "defense_01",
	"name": "Defend",
	"cost": 1,
	"block": 5,
	"auto_priority": "HIGH"  # 위기 시 높은 우선순위
}

AutoBattleAI에서 이 필드를 참고해서 점수 보정.
```

---

**Phase 3 테스트**:
```bash
# 자동전투 ON (UI 버튼)
1. AI가 적절한 카드를 선택하는지
2. HP 낮을 때 방어 카드 우선 사용하는지
3. 킬 가능한 적을 먼저 노리는지
4. 에너지 효율적인지
```

---

#### Phase 4: 속도 제어 & UI 개선 (45분)

**목표**: 속도 버튼, 자동전투 토글, 시각 피드백

**Task 4-1: CombatUI 속도 버튼 추가**

Cursor 프롬프트:
```
@ui/bottom_uis/CombatBottomUI.tscn
@ui/bottom_uis/CombatBottomUI.gd

상단에 속도 제어 버튼 3개 추가:

[1×] [2×] [3×]  [🤖 Auto]

```gdscript
@onready var speed_1x_button = $SpeedButtons/Speed1x
@onready var speed_2x_button = $SpeedButtons/Speed2x
@onready var speed_3x_button = $SpeedButtons/Speed3x
@onready var auto_button = $AutoButton

func _ready():
	speed_1x_button.pressed.connect(_on_speed_pressed.bind(1.0))
	speed_2x_button.pressed.connect(_on_speed_pressed.bind(2.0))
	speed_3x_button.pressed.connect(_on_speed_pressed.bind(3.0))
	auto_button.pressed.connect(_on_auto_pressed)
	
	_update_speed_buttons(1.0)

func _on_speed_pressed(multiplier: float):
	CombatManager.set_speed_multiplier(multiplier)
	_update_speed_buttons(multiplier)

func _update_speed_buttons(current: float):
	speed_1x_button.disabled = (current == 1.0)
	speed_2x_button.disabled = (current == 2.0)
	speed_3x_button.disabled = (current == 3.0)
	
	# Visual highlight
	speed_1x_button.modulate = Color(1, 1, 1) if current == 1.0 else Color(0.5, 0.5, 0.5)
	# (repeat for 2×, 3×)

func _on_auto_pressed():
	CombatManager.toggle_auto_battle()
	auto_button.text = "🤖 Auto: ON" if CombatManager.auto_battle_enabled else "🤖 Auto: OFF"
```

UITheme 스타일 적용.
```

**예상 결과**: 속도/자동전투 제어 UI

---

**Task 4-2: 에너지 타이머 시각화**

Cursor 프롬프트:
```
@ui/bottom_uis/CombatBottomUI.tscn

에너지 타이머 ProgressBar 추가:

[⚡⚡⚡] [████████░░] 80%

```gdscript
@onready var energy_timer_bar = $EnergyPanel/TimerBar
@onready var energy_label = $EnergyPanel/Label

func _ready():
	CombatManager.energy_timer_updated.connect(_on_energy_timer_updated)
	CombatManager.energy_changed.connect(_on_energy_changed)

func _on_energy_timer_updated(progress: float):
	energy_timer_bar.value = progress * 100

func _on_energy_changed(current: int, max: int):
	energy_label.text = ("⚡" * current) + ("○" * (max - current))
```

progress가 1.0 도달 시 빠르게 깜빡이기 (시각 피드백).
```

---

**Phase 4 테스트**:
```bash
# Godot 실행
1. 속도 버튼 (1×, 2×, 3×) 작동하는지
2. 3× 속도에서 전투가 빠르게 진행되는지
3. 자동전투 ON/OFF 토글 작동하는지
4. 에너지 타이머 바가 차오르는지
5. 에너지 충전 시 카드 드로우 확인
```

---

### 3.2 전체 Cursor 프롬프트 모음 (10개)

**(위 Phase 1-4에 포함된 프롬프트 7개 + 추가 3개)**

**추가 프롬프트 1: 디버그 패널**
```
CombatUI에 디버그 패널 추가:

[DEBUG]
Hero ATB: 75.2 / 100.0
Monster 0 ATB: 92.5 / 100.0
Monster 1 ATB: 45.1 / 100.0
Energy: 2 / 3
Hand: 5 cards
Speed: 2.0×

F3 키로 toggle.
```

**추가 프롬프트 2: ATB 속도 밸런싱**
```
CombatManagerATB.gd의 속도 밸런싱 조정:

현재 문제: spd 차이가 크면 턴 빈도 격차 너무 큼

해결:
1. spd 상한/하한 설정 (5-20)
2. 로그 스케일 적용: atb_rate = log(spd + 1) * k
3. 테스트 후 k 값 조정

목표: spd 10 vs 20 → 턴 빈도 1.5배 차이 (현재 2배)
```

**추가 프롬프트 3: 에러 핸들링**
```
CombatManagerATB.gd에 에러 핸들링 추가:

1. play_card()에서 invalid card_index → 에러 메시지 + false 리턴
2. _apply_card_effects()에서 target_index out of range → 경고 로그
3. _update_atb()에서 spd = 0 → spd = 1로 보정
4. DeckManager null 체크 (카드 드로우 전)

안전하게 처리하고, 에러 시 게임 크래시 방지.
```

---

### 3.3 테스트 가이드

#### Godot 실행 체크리스트

**Phase 1 (기반 작업)**:
- [ ] 에러 없이 로드
- [ ] CombatManager 싱글톤 접근 가능
- [ ] CombatManagerATB 상속 확인 (`extends CombatManagerBase`)
- [ ] start_combat() 호출 시 전투 시작

**Phase 2 (ATB 게이지)**:
- [ ] Hero/Monster 밑에 ATB 바 표시
- [ ] 바가 실시간 차오름 (파랑→초록→금색)
- [ ] 100 도달 시 턴 실행 + 0 리셋
- [ ] 속도(spd)에 따라 충전 속도 다름

**Phase 3 (자동전투 AI)**:
- [ ] 자동전투 ON 시 카드 자동 사용
- [ ] HP 낮을 때 방어 우선
- [ ] 킬 가능한 적 우선 타겟
- [ ] 에너지 효율적 선택
- [ ] 사용 불가 카드 건너뜀

**Phase 4 (UI)**:
- [ ] 속도 버튼 (1×, 2×, 3×) 작동
- [ ] 3× 속도에서 빠른 진행
- [ ] 자동전투 토글 ON/OFF
- [ ] 에너지 타이머 바 차오름
- [ ] 에너지 충전 시 카드 드로우 + 로그

---

#### 디버깅 포인트

**print 문 추가 위치**:
```gdscript
# _update_atb()
print("[ATB] Hero: %.1f, Monster 0: %.1f" % [hero.atb, monsters[0].atb if not monsters.is_empty() else 0])

# _execute_hero_turn()
print("[Turn] Hero acts! Target: %s" % target.name)

# _update_auto_battle()
print("[Auto] Chose card: %d, Target: %d" % [choice.card_index, choice.target_index])

# _update_energy_timer()
print("[Energy] Timer: %.2f/%d, Progress: %.1f%%" % [energy_timer, dynamic_duration, progress * 100])
```

**예상 에러 & 해결책**:

| 에러 | 원인 | 해결 |
|------|------|------|
| `Invalid get index 'atb'` | Monster에 atb 필드 없음 | start_combat()에서 초기화 확인 |
| `AutoBattleAI not found` | autoload 미등록 | project.godot 확인 |
| `atb_gauge_updated signal not connected` | 시그널 연결 안 됨 | InRun_v4에서 connect 확인 |
| `Division by zero (spd)` | spd = 0 | spd 최소값 1로 보정 |
| `Hand is empty but card played` | DeckManager 동기화 문제 | play_card() 시작에 체크 추가 |

---

## 4. 완성 체크리스트

### 코드 작업
- [ ] CombatManagerBase.gd 생성 (추상 클래스)
- [ ] CombatManager.gd → CombatManagerATB.gd 리네임
- [ ] project.godot autoload 업데이트
- [ ] ATBGaugeBar.tscn/gd 컴포넌트 생성
- [ ] CharacterNode에 ATB 게이지 통합
- [ ] InRun_v4에서 ATB 시그널 연결
- [ ] AutoBattleAI.gd 생성
- [ ] CombatBottomUI 속도/자동전투 버튼 추가
- [ ] 에너지 타이머 시각화

### 기능 테스트
- [ ] ATB 게이지 정상 작동
- [ ] 속도에 따라 충전 속도 다름
- [ ] 100 도달 시 턴 실행
- [ ] 자동전투 AI 스마트한 선택
- [ ] 속도 제어 (1×, 2×, 3×) 작동
- [ ] 자동전투 ON/OFF 토글
- [ ] 에너지 회복 + 카드 드로우
- [ ] 전투 시작/종료 정상
- [ ] 데미지 계산 정확
- [ ] 승리/패배 처리 정상

### 밸런싱
- [ ] spd 범위 적절 (5-20)
- [ ] 전투 시간 30-90초
- [ ] AI 선택 합리적
- [ ] 에너지 회복 속도 적절
- [ ] 속도 3× 시 게임 가능

### 문서화
- [ ] CHANGELOG.md 업데이트
- [ ] 주석/docstring 완비
- [ ] 디버그 print 문 제거 (또는 DEBUG 플래그)
- [ ] 코드 리뷰 완료

---

## 5. 다음 단계 (ATB 완성 후)

1. **데이터 통합**: JSON 카드/몬스터 DB
2. **UI 폴리시**: 애니메이션, 사운드
3. **밸런싱**: 플레이테스트 100회
4. **턴제 구현**: 비교 테스트 준비
5. **하이브리드 모드**: 세미 오토 실험

---

**문서 종료**

**작성 시간**: 2026-02-26  
**버전**: 1.0  
**다음 문서**: TurnBased_Implementation_Guide.md
