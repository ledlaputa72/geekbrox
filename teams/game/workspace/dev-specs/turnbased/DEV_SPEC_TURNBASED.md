# 🃏 턴베이스 전투 시스템 — 개발 사양서
# Dream Collector | Dev Spec for Cursor / Claude Code

**버전**: v1.0 | **날짜**: 2026-03-01
**작성**: Kim.G (게임팀장) + OPS 플레이테스트 반영
**대상**: Cursor IDE / Claude Code 구현용
**참조 설계서**: COMBAT_TURNBASED_COMPLETE_v1.md
**공통 시스템**: DEV_SPEC_SHARED.md (반드시 먼저 읽을 것)

> ⚠️ 이 문서는 턴베이스 전투 모드 전용 스크립트를 정의합니다.
> 공통 Card, Monster, StatusEffect, UI 클래스는 DEV_SPEC_SHARED.md를 참조하세요.

---

## 1. 구현 대상 스크립트 목록

```
res://scripts/combat/turnbased/
├── CombatManagerTB.gd          ← 핵심 전투 루프 (턴 관리)
├── TurnBasedEnergySystem.gd    ← 에너지 + 다음 턴 보너스 관리
├── TurnBasedReactionManager.gd ← 패링/회피/방어 판정 (적 턴에)
├── TurnBasedIntentSystem.gd    ← 의도 시스템 (다음 2~3행동 예고)
├── TurnBasedHandSystem.gd      ← 손패 드로우/버림/셔플
├── TarotEnergySystem.gd        ← 타로 에너지 (메이저 아르카나 카드)
├── DreamShardSystem.gd         ← 꿈 조각 즉발 소비
├── DeckPassiveCalculator.gd    ← 덱 구성 기반 패시브
└── TurnBasedAutoAI.gd          ← 오토 플레이 AI (3단계)

res://scenes/combat/
└── CombatSceneTB.tscn          ← 턴베이스 전투 씬
```

---

## 2. CombatManagerTB.gd

턴베이스 전투의 중앙 관리자. 플레이어 턴 → 적 턴 → 리액션 → 반복.

```gdscript
# scripts/combat/turnbased/CombatManagerTB.gd
class_name CombatManagerTB
extends Node

# ── 턴 상태 ──────────────────────────────────────────
enum TurnPhase {
    PLAYER_TURN,        # 플레이어 카드 플레이 단계
    PLAYER_END,         # 턴 종료 처리
    ENEMY_TURN_BEGIN,   # 적 행동 발표
    ENEMY_ATTACKING,    # 적 공격 실행 + 리액션 윈도우
    ENEMY_TURN_END,     # 상태이상 처리
    CHECK_END,          # 전투 종료 체크
}

var current_phase : TurnPhase = TurnPhase.PLAYER_TURN
var turn_count    : int = 0

# ── 참조 노드 ──────────────────────────────────────────
@onready var energy_system   : TurnBasedEnergySystem    = $TurnBasedEnergySystem
@onready var reaction_mgr    : TurnBasedReactionManager = $TurnBasedReactionManager
@onready var intent_system   : TurnBasedIntentSystem    = $TurnBasedIntentSystem
@onready var hand_system     : TurnBasedHandSystem      = $TurnBasedHandSystem
@onready var tarot_system    : TarotEnergySystem        = $TarotEnergySystem
@onready var shard_system    : DreamShardSystem         = $DreamShardSystem
@onready var deck_passive    : DeckPassiveCalculator    = $DeckPassiveCalculator
@onready var auto_ai         : TurnBasedAutoAI          = $TurnBasedAutoAI

# ── 시그널 ────────────────────────────────────────────
signal combat_started
signal combat_ended(result: String)   # "WIN" | "LOSE"
signal player_turn_started(energy: int, hand: Array[Card])
signal enemy_turn_started(enemy: Entity)
signal turn_count_updated(n: int)

# ── 전투 시작 ─────────────────────────────────────────
func _ready():
    _apply_deck_passives()
    _start_player_turn()
    emit_signal("combat_started")

func _apply_deck_passives():
    var passives = deck_passive.calculate(PlayerDeck.all_cards())
    for passive in passives:
        passive.apply(PlayerEntity)
    DeckPassiveUI.show(passives)  # ★ OPS 피드백: 덱 패시브 UI 표시

# ── 플레이어 턴 시작 ──────────────────────────────────
func _start_player_turn():
    current_phase = TurnPhase.PLAYER_TURN
    turn_count += 1
    emit_signal("turn_count_updated", turn_count)

    # 에너지 초기화 (이전 리액션 보너스 포함)
    energy_system.start_player_turn()

    # 드로우 5장 (+ 패링 보너스 드로우)
    hand_system.draw_to_hand(5 + reaction_mgr.pending_draw_bonus)
    reaction_mgr.pending_draw_bonus = 0

    emit_signal("player_turn_started", energy_system.current_energy, hand_system.hand)

    # 의도 확인
    intent_system.display_all_enemies()

    # 오토 AI 처리
    if auto_ai.mode == TurnBasedAutoAI.AutoMode.FULL:
        await auto_ai.auto_play_turn(hand_system.hand, EnemyGroup.get_current_enemy(), energy_system.current_energy)
        player_end_turn()
    elif auto_ai.mode == TurnBasedAutoAI.AutoMode.SEMI:
        auto_ai.suggest_next_card(hand_system.hand, EnemyGroup.get_current_enemy(), energy_system.current_energy)

# ── 카드 플레이 (플레이어 입력) ──────────────────────
func player_play_card(card: Card):
    if current_phase != TurnPhase.PLAYER_TURN:
        return
    if not energy_system.can_afford(card.cost):
        HandUI.shake_card(card)
        return

    energy_system.spend(card.cost)
    _resolve_card_effect(card)
    hand_system.discard_card(card)
    tarot_system.on_card_played(card)
    shard_system.on_card_played(card)   # 꿈 조각 획득 조건 체크
    _check_battle_end()

func _resolve_card_effect(card: Card):
    if card.type == "ATK":
        for enemy in EnemyGroup.get_alive_enemies():
            var dmg = _calc_player_damage(card, enemy)
            enemy.take_damage(dmg)
    if card.block > 0:
        PlayerEntity.add_block(card.block)
    for eff in card.status_effects:
        StatusEffectSystem.apply(eff.target, eff.type, eff.value)
    if card.draw > 0:
        hand_system.draw_cards(card.draw)

func _calc_player_damage(card: Card, enemy: Entity) -> int:
    var dmg = card.damage + PlayerEntity.atk_bonus
    if enemy.has_status("VULNERABLE"):  dmg = int(dmg * 1.5)
    if PlayerEntity.has_status("WEAK"): dmg = int(dmg * 0.75)
    return max(0, dmg - enemy.block)

# ── 턴 종료 (플레이어 버튼 또는 AI 완료) ────────────
func player_end_turn():
    current_phase = TurnPhase.PLAYER_END

    # 미사용 카드 버림 더미
    hand_system.discard_remaining()

    # 블록 소멸 (기본값)
    PlayerEntity.reset_block()

    # 적 턴 시작
    await get_tree().create_timer(0.3).timeout
    _start_enemy_turns()

# ── 적 턴 ─────────────────────────────────────────────
func _start_enemy_turns():
    for enemy in EnemyGroup.get_alive_enemies():
        await _enemy_perform_action(enemy)
        if not PlayerEntity.is_alive():
            _check_battle_end()
            return

    # 상태이상 틱
    StatusEffectSystem.tick_all()

    # 다음 플레이어 턴
    await get_tree().create_timer(0.3).timeout
    _start_player_turn()

func _enemy_perform_action(enemy: Entity):
    current_phase = TurnPhase.ENEMY_ATTACKING
    var action = enemy.get_next_action()

    intent_system.highlight_current(enemy)
    await get_tree().create_timer(0.5).timeout  # 연출 대기

    # 리액션 윈도우 오픈
    reaction_mgr.open_window(action)
    await reaction_mgr.reaction_resolved

    # 결과 적용
    var result = reaction_mgr.last_result
    _apply_action_result(enemy, action, result)
    intent_system.advance(enemy)
    _check_battle_end()

func _apply_action_result(enemy: Entity, action: AttackData, result: ReactionResult):
    match result.type:
        "PARRY":
            SFX.play("parry_success")
            VFX.play("parry_clash")
            battle_log("패링! 에너지 +2 다음 턴")
            shard_system.gain_shard(1)  # 패링 → 꿈 조각 +1
        "DODGE":
            SFX.play("dodge_whoosh")
            VFX.play("dodge_blur")
        "GUARD":
            PlayerEntity.add_block(result.block_value)
            SFX.play("block_thud")
        "NONE":
            var dmg = _calc_enemy_damage(action, PlayerEntity)
            PlayerEntity.take_damage(dmg)
            VFX.play("hit_impact")

func _calc_enemy_damage(action: AttackData, target: Entity) -> int:
    var dmg = action.damage
    if target.has_status("VULNERABLE"):  dmg = int(dmg * 1.5)
    if action.attacker.has_status("WEAK"): dmg = int(dmg * 0.75)
    var after_block = max(0, dmg - target.block)
    target.block = max(0, target.block - dmg)
    return after_block

# ── 전투 종료 ─────────────────────────────────────────
func _check_battle_end():
    if not PlayerEntity.is_alive():
        emit_signal("combat_ended", "LOSE")
    elif EnemyGroup.all_dead():
        emit_signal("combat_ended", "WIN")
```

---

## 3. TurnBasedEnergySystem.gd

매 턴 3 에너지 + 이전 턴 방어 보너스 적립.

```gdscript
# scripts/combat/turnbased/TurnBasedEnergySystem.gd
class_name TurnBasedEnergySystem
extends Node

# ── 상수 ─────────────────────────────────────────────
const BASE_ENERGY   = 3
const PARRY_BONUS   = 2     # 패링 성공 → 다음 턴 +2
const DODGE_BONUS   = 1     # 회피 성공 → 다음 턴 +1
const OVERFLOW_MAX  = 5     # 보너스 합산 최대

# ── 상태 변수 ─────────────────────────────────────────
var current_energy       : int = 3
var pending_energy_bonus : int = 0  # 적 턴 방어로 적립된 다음 턴 보너스

@onready var energy_ui : EnergyUI = $"../UI/EnergyUI"

# ── 플레이어 턴 시작 시 호출 ─────────────────────────
func start_player_turn():
    var total = min(OVERFLOW_MAX, BASE_ENERGY + pending_energy_bonus)
    current_energy = total
    pending_energy_bonus = 0

    energy_ui.update(current_energy, BASE_ENERGY)
    energy_ui.hide_bonus_preview()

    # ★ OPS 피드백: 획득한 에너지가 기본보다 많으면 강조 표시
    if current_energy > BASE_ENERGY:
        energy_ui.play_bonus_gain_animation(current_energy - BASE_ENERGY)

# ── 방어 성공 콜백 (적 턴 중 호출) ──────────────────
func on_parry_success():
    pending_energy_bonus += PARRY_BONUS
    # ★ OPS 피드백: 다음 턴 에너지 미리보기 표시 (즉시)
    energy_ui.show_bonus_preview(pending_energy_bonus, Color(1.0, 0.84, 0.0))  # 금색

func on_dodge_success():
    pending_energy_bonus += DODGE_BONUS
    energy_ui.show_bonus_preview(pending_energy_bonus, Color(0.4, 0.8, 1.0))   # 하늘색

# ── 에너지 사용 ──────────────────────────────────────
func spend(amount: int) -> bool:
    if current_energy < amount:
        return false
    current_energy -= amount
    energy_ui.update(current_energy, BASE_ENERGY)
    return true

func can_afford(amount: int) -> bool:
    return current_energy >= amount
```

---

## 4. TurnBasedReactionManager.gd

적 턴에 열리는 리액션 윈도우 판정.

```gdscript
# scripts/combat/turnbased/TurnBasedReactionManager.gd
class_name TurnBasedReactionManager
extends Node

# ── 윈도우 상수 ──────────────────────────────────────
const PARRY_WINDOW_STORY  = 0.8    # Story 모드 (기본값)
const PARRY_WINDOW_HARD   = 0.5
const DODGE_WINDOW_STORY  = 1.8
const DODGE_WINDOW_HARD   = 1.2

# ── 상태 변수 ─────────────────────────────────────────
var reaction_state       : String = "IDLE"
var time_elapsed         : float  = 0.0
var current_attack       : AttackData = null
var last_result          : ReactionResult = null
var pending_draw_bonus   : int = 0   # 패링 성공 시 다음 턴 드로우 +1
var story_mode           : bool = true

# ── 시그널 ────────────────────────────────────────────
signal reaction_resolved
signal parry_success
signal dodge_success

# ── 윈도우 오픈 ──────────────────────────────────────
func open_window(attack: AttackData):
    current_attack = attack
    story_mode = SettingsManager.story_mode
    time_elapsed = 0.0
    reaction_state = "OPEN"
    last_result = null

    HandUI.highlight_reaction_cards(attack.type)

    # 관통 공격 안내
    if attack.type == AttackType.UNBLOCKABLE:
        UI.show_notice("방어 불가! 회피하세요!", Color.RED)
        HandUI.highlight_dodge_only()

func _process(delta: float):
    if reaction_state != "OPEN":
        return
    time_elapsed += delta
    var dw = DODGE_WINDOW_STORY if story_mode else DODGE_WINDOW_HARD
    if time_elapsed >= dw:
        _auto_resolve_none()

# ── 카드 탭 처리 (플레이어 입력 → CombatManagerTB에서 라우팅) ──
func on_player_card_tapped(card: Card):
    if reaction_state != "OPEN":
        return

    var pw = PARRY_WINDOW_STORY if story_mode else PARRY_WINDOW_HARD
    var dw = DODGE_WINDOW_STORY if story_mode else DODGE_WINDOW_HARD

    # 관통 공격 + 패링 시도 → 실패
    if current_attack.type == AttackType.UNBLOCKABLE and card.has_tag("PARRY"):
        VFX.play("parry_fail_flash")
        UI.show_notice("패링 불가!", Color.RED, 0.5)
        return

    if card.has_tag("PARRY") and time_elapsed <= pw:
        _resolve_parry(card)
    elif card.has_tag("DODGE") and time_elapsed <= dw:
        _resolve_dodge(card)
    elif card.has_tag("GUARD"):
        _resolve_guard(card)

func _resolve_parry(card: Card):
    reaction_state = "RESOLVED"
    EnergySystem.on_parry_success()
    pending_draw_bonus += 1        # 다음 턴 드로우 +1
    last_result = ReactionResult.new("PARRY", card, 0)
    VFX.play("parry_perfect_flash")
    Haptics.vibrate_medium()
    emit_signal("parry_success")
    emit_signal("reaction_resolved")

func _resolve_dodge(card: Card):
    reaction_state = "RESOLVED"
    EnergySystem.on_dodge_success()
    last_result = ReactionResult.new("DODGE", card, 0)
    VFX.play("dodge_step_blur")
    emit_signal("dodge_success")
    emit_signal("reaction_resolved")

func _resolve_guard(card: Card):
    reaction_state = "RESOLVED"
    last_result = ReactionResult.new("GUARD", card, card.block)
    emit_signal("reaction_resolved")

func _auto_resolve_none():
    reaction_state = "RESOLVED"
    last_result = ReactionResult.new("NONE", null, 0)
    HandUI.clear_highlights()
    emit_signal("reaction_resolved")


# ── ReactionResult 내부 클래스 ────────────────────────
class ReactionResult:
    var type        : String  # "PARRY" | "DODGE" | "GUARD" | "NONE"
    var card        : Card
    var block_value : int
    func _init(t: String, c: Card, b: int):
        type = t
        card = c
        block_value = b
```

---

## 5. TurnBasedIntentSystem.gd

적의 다음 2~3 행동을 미리 공개.

```gdscript
# scripts/combat/turnbased/TurnBasedIntentSystem.gd
class_name TurnBasedIntentSystem
extends Node

# ── 아이콘 매핑 ──────────────────────────────────────
const ICONS = {
    AttackType.NORMAL:      {"icon": "⚔️",   "color": Color.WHITE},
    AttackType.HEAVY:       {"icon": "⚔️⚠️", "color": Color.ORANGE},
    AttackType.AOE:         {"icon": "🌀",   "color": Color.YELLOW},
    AttackType.UNBLOCKABLE: {"icon": "🔱",   "color": Color.RED},
    AttackType.BUFF:        {"icon": "✨",   "color": Color.CYAN},
    AttackType.DEFEND:      {"icon": "🛡️",  "color": Color.LIGHT_BLUE},
    AttackType.REST:        {"icon": "💤",   "color": Color.GRAY},
}

# ── 모든 적 의도 표시 ─────────────────────────────────
func display_all_enemies():
    for enemy in EnemyGroup.get_alive_enemies():
        display_intent(enemy)

func display_intent(enemy: Entity):
    # 다음 2~3행동 예고
    var upcoming = enemy.action_queue.slice(0, 3)
    IntentUI.clear_slots(enemy)

    for i in range(upcoming.size()):
        var action = upcoming[i]
        var info   = ICONS.get(action.type, {"icon": "❓", "color": Color.WHITE})
        IntentUI.add_slot(
            enemy    = enemy,
            icon     = info["icon"],
            value    = action.damage if action.damage > 0 else -1,
            color    = info["color"],
            is_current = (i == 0),
            is_heavy   = action.damage > enemy.base_atk * 1.5,
        )

func highlight_current(enemy: Entity):
    IntentUI.flash_slot(enemy, 0)   # 현재 행동(첫 번째) 강조

func advance(enemy: Entity):
    enemy.advance_action_index()
    display_intent(enemy)
    # ★ OPS 피드백: 의도 전환 시 슬라이드 애니메이션
    IntentUI.slide_advance(enemy)
```

---

## 6. TurnBasedHandSystem.gd

덱/손패/버림더미/셔플 관리.

```gdscript
# scripts/combat/turnbased/TurnBasedHandSystem.gd
class_name TurnBasedHandSystem
extends Node

const HAND_MAX = 10

var deck      : Array[Card] = []
var hand      : Array[Card] = []
var discard   : Array[Card] = []

signal hand_updated(hand: Array[Card])
signal deck_empty_reshuffled

func initialize(deck_list: Array[Card]):
    deck = deck_list.duplicate()
    deck.shuffle()
    hand.clear()
    discard.clear()

func draw_to_hand(n: int):
    for _i in range(n):
        if hand.size() >= HAND_MAX:
            break
        if deck.is_empty():
            _reshuffle()
        if deck.is_empty():
            break  # 덱과 버림더미 모두 비어있음
        var card = deck.pop_front()
        hand.append(card)
    emit_signal("hand_updated", hand)
    HandUI.refresh(hand)

func draw_cards(n: int):
    draw_to_hand(n)

func discard_card(card: Card):
    hand.erase(card)
    discard.append(card)
    emit_signal("hand_updated", hand)

func discard_remaining():
    for card in hand:
        discard.append(card)
    hand.clear()
    emit_signal("hand_updated", hand)

func _reshuffle():
    deck = discard.duplicate()
    discard.clear()
    deck.shuffle()
    emit_signal("deck_empty_reshuffled")
    UI.show_notice("덱 셔플!", Color.LIGHT_BLUE, 0.8)
```

---

## 7. TarotEnergySystem.gd

타로 에너지 (메이저 아르카나 카드 사용 시 충전).

```gdscript
# scripts/combat/turnbased/TarotEnergySystem.gd
class_name TarotEnergySystem
extends Node

const TAROT_MAX = 3

var tarot_energy : int = 0

@onready var tarot_ui : TarotUI = $"../UI/TarotUI"

func on_card_played(card: Card):
    if card.is_major_arcana():
        tarot_energy = min(TAROT_MAX, tarot_energy + 1)
        tarot_ui.update(tarot_energy)
        # ★ OPS 피드백: 보라색 UI로 타로 에너지 시각화
        tarot_ui.play_gain_animation(Color(0.6, 0.2, 0.9))

# ── 타로 카드 정의 ────────────────────────────────────
# (카드 데이터는 DEV_SPEC_SHARED.md의 카드 목록 참조)
#
# "달의 환영"   — 비용: 타로×2  — 드로우3 + 다음 턴 에너지 +1
# "태양의 폭발" — 비용: 타로×3  — 전체 적 30 데미지 + 디버프 제거
# "심판의 날"   — 비용: 타로×2  — 가장 HP 낮은 적에 HP 40% 피해

func spend_tarot(cost: int) -> bool:
    if tarot_energy < cost:
        UI.show_notice("타로 에너지 부족!", Color.PURPLE)
        return false
    tarot_energy -= cost
    tarot_ui.update(tarot_energy)
    tarot_ui.play_spend_animation()
    return true
```

---

## 8. DreamShardSystem.gd

꿈 조각: 전투 중 획득해서 즉발 소비하는 보조 자원.

```gdscript
# scripts/combat/turnbased/DreamShardSystem.gd
class_name DreamShardSystem
extends Node

const MAX_SHARDS = 5

var shards : int = 0

@onready var shard_ui : ShardUI = $"../UI/ShardUI"

# ── 획득 조건 (CombatManagerTB에서 카드 플레이 시 호출) ──
func on_card_played(card: Card):
    # 같은 색 카드 2연속 체크는 HandSystem이 전달
    # 한 턴 누적 비용 5+ 체크는 EnergySystem이 전달
    pass

func gain_shard(n: int = 1):
    shards = min(MAX_SHARDS, shards + n)
    shard_ui.update(shards)
    # ★ OPS 피드백: 획득 시 조각 날아오는 VFX
    shard_ui.play_gain_animation(n)

# ── 소비 ─────────────────────────────────────────────
enum ShardAbility { QUICK_DRAW, ENERGY_BURST, DREAM_HEAL, NIGHTMARE }

func spend(ability: ShardAbility) -> bool:
    var cost = _get_cost(ability)
    if shards < cost:
        UI.show_notice("꿈 조각 부족!", Color.AQUA)
        return false
    shards -= cost
    shard_ui.update(shards)
    _apply_effect(ability)
    return true

func _get_cost(ability: ShardAbility) -> int:
    match ability:
        ShardAbility.QUICK_DRAW:   return 1
        ShardAbility.ENERGY_BURST: return 2
        ShardAbility.DREAM_HEAL:   return 3
        ShardAbility.NIGHTMARE:    return 5
    return 99

func _apply_effect(ability: ShardAbility):
    match ability:
        ShardAbility.QUICK_DRAW:
            HandSystem.draw_cards(1)
            VFX.play("shard_draw")
        ShardAbility.ENERGY_BURST:
            EnergySystem.spend(-1)  # 음수 spend = 에너지 추가
            VFX.play("shard_energy")
        ShardAbility.DREAM_HEAL:
            PlayerEntity.heal(8)
            VFX.play("shard_heal")
        ShardAbility.NIGHTMARE:
            for enemy in EnemyGroup.get_alive_enemies():
                StatusEffectSystem.apply(enemy, "VULNERABLE", 2)
            VFX.play("shard_nightmare")
```

---

## 9. DeckPassiveCalculator.gd

덱 구성 분석 → 전투 시작 시 패시브 적용.

```gdscript
# scripts/combat/turnbased/DeckPassiveCalculator.gd
class_name DeckPassiveCalculator
extends Node

func calculate(deck: Array[Card]) -> Array[Dictionary]:
    var passives : Array[Dictionary] = []

    var def_count    = _count_type(deck, "DEF")
    var atk_count    = _count_type(deck, "ATK")
    var arcana_count = _count_where(deck, func(c): return c.is_major_arcana())
    var parry_count  = _count_where(deck, func(c): return c.has_tag("PARRY"))

    if def_count >= 5:
        passives.append({
            "name": "달의 기사",
            "desc": "매 플레이어 턴 시작 시 블록 3 획득",
            "apply": func(): PlayerEntity.add_block(3)
        })
    if atk_count >= 7:
        passives.append({
            "name": "검의 달인",
            "desc": "첫 번째 공격 카드 데미지 +2",
            "apply": func(): PlayerEntity.atk_first_bonus = 2
        })
    if arcana_count >= 3:
        passives.append({
            "name": "타로 학자",
            "desc": "전투 시작 시 타로 에너지 +1",
            "apply": func(): TarotSystem.tarot_energy += 1
        })
    if parry_count >= 4:
        passives.append({
            "name": "달빛 반격사",
            "desc": "패링 성공 시 다음 턴 에너지 보너스 +1 추가",
            "apply": func(): PlayerEntity.parry_energy_bonus_extra = 1
        })

    return passives

func _count_type(deck: Array[Card], type: String) -> int:
    return deck.filter(func(c): return c.type == type).size()

func _count_where(deck: Array[Card], pred: Callable) -> int:
    return deck.filter(pred).size()
```

---

## 10. TurnBasedAutoAI.gd

오토 플레이 AI (3단계: 수동 / 세미 / 풀오토).

```gdscript
# scripts/combat/turnbased/TurnBasedAutoAI.gd
class_name TurnBasedAutoAI
extends Node

enum AutoMode { MANUAL, SEMI, FULL }

var mode : AutoMode = AutoMode.SEMI

# ── 방어 결정 (적 턴 리액션 윈도우) ─────────────────
func decide_defense(hand: Array[Card], attack: AttackData, energy: int) -> Card:
    # 관통 공격 → 회피 전용
    if attack.type == AttackType.UNBLOCKABLE:
        for card in hand:
            if card.has_tag("DODGE") and card.cost <= energy:
                return card
        return null  # 회피 카드 없으면 무반응 (피해 감수)

    # 강한 공격 → 패링 70% 확률로 시도
    if attack.damage > attack.attacker.base_atk * 1.3:
        if randf() < 0.70:
            for card in hand:
                if card.has_tag("PARRY") and card.cost <= energy:
                    return card

    # 패링 카드 우선
    for card in hand:
        if card.has_tag("PARRY") and card.cost <= energy:
            return card if randf() < 0.65 else null

    # 회피 카드
    for card in hand:
        if card.has_tag("DODGE") and card.cost <= energy:
            return card

    # 방어 카드
    for card in hand:
        if card.has_tag("GUARD") and card.cost <= energy:
            return card

    return null  # 대응 불가 → 무반응

# ── 공격 카드 플레이 결정 ─────────────────────────────
func decide_attack_cards(hand: Array[Card], energy: int, enemy: Entity) -> Array[Card]:
    var selected : Array[Card] = []
    var rem = energy

    # HP 40% 이하 → 방어 카드 우선
    if PlayerEntity.hp_ratio() < 0.40:
        for card in hand:
            if card.type == "DEF" and card.cost <= rem:
                selected.append(card)
                rem -= card.cost
                break

    # 공격 효율(dmg/cost) 순으로 선택
    var attacks = hand.filter(func(c): return c.type == "ATK" and c.cost <= rem and c.cost > 0)
    attacks.sort_custom(func(a, b): return float(a.damage)/a.cost > float(b.damage)/b.cost)

    for card in attacks:
        if card.cost <= rem:
            selected.append(card)
            rem -= card.cost

    return selected

# ── 세미 오토: 추천 카드 강조 ─────────────────────────
func suggest_next_card(hand: Array[Card], enemy: Entity, energy: int):
    var cards = decide_attack_cards(hand, energy, enemy)
    if cards.size() > 0:
        HandUI.highlight_suggested(cards[0])

# ── 풀 오토 플레이 ────────────────────────────────────
func auto_play_turn(hand: Array[Card], enemy: Entity, energy: int):
    var to_play = decide_attack_cards(hand, energy, enemy)
    for card in to_play:
        await get_tree().create_timer(0.5).timeout
        CombatManager.player_play_card(card)
    await get_tree().create_timer(0.5).timeout
    CombatManager.player_end_turn()
```

---

## 11. 씬 구성 (CombatSceneTB.tscn)

```
CombatSceneTB (Node)
├── CombatManagerTB
│   ├── TurnBasedEnergySystem
│   ├── TurnBasedReactionManager
│   ├── TurnBasedIntentSystem
│   ├── TurnBasedHandSystem
│   ├── TarotEnergySystem
│   ├── DreamShardSystem
│   ├── DeckPassiveCalculator
│   └── TurnBasedAutoAI
├── EnemyGroup (Node)
│   ├── Enemy_1
│   └── Enemy_2
├── PlayerEntity
├── BattleDiary
├── StatusEffectSystem
└── UI (CanvasLayer)
    ├── EnergyUI          ← 에너지 오브 (3개) + 보너스 미리보기 (금/하늘색)
    ├── HandUI            ← 카드 손패 (최대 10장) + 패링/회피 강조
    ├── IntentUI          ← 적 의도 슬롯 (2~3개)
    ├── TarotUI           ← 타로 에너지 (🌙 × 3) — 보라색
    ├── ShardUI           ← 꿈 조각 (◆ × 5) — 청록색
    ├── DeckPassiveUI     ← 현재 활성 덱 패시브 표시
    ├── TurnEndButton     ← 턴 종료 버튼
    └── AutoModeToggle    ← 수동/세미/풀오토 전환
```

---

## 12. OPS 플레이테스트 반영 수치 요약

| 항목 | 변경 전 | 변경 후 (최종) | 근거 |
|------|---------|-------------|------|
| 다음 턴 에너지 미리보기 | 없음 | ✅ 금색/하늘색 미리보기 | 패링 보상 체감 향상 |
| 타로 에너지 UI | 미정 | ✅ 보라색 테마 🌙 | 시각적 구분 명확화 |
| 꿈 조각 획득 VFX | 없음 | ✅ 날아오는 조각 애니메이션 | 획득 피드백 부재 |
| 덱 패시브 표시 | 없음 | ✅ 전투 시작 시 UI 표시 | 패시브 인지율 향상 |
| Story 모드 기본값 | 하드 기본 | ✅ Story 기본 (0.8초) | 모바일 접근성 |
| 의도 전환 애니메이션 | 즉시 전환 | ✅ 슬라이드 애니메이션 | 전환 명확성 향상 |

---

## 13. 구현 순서 권장

1. `TurnBasedHandSystem.gd` → 드로우/버림 기본 동작 확인
2. `TurnBasedEnergySystem.gd` → 에너지 + 보너스 미리보기 UI
3. `TurnBasedReactionManager.gd` → 패링/회피 타이밍 판정 단위 테스트
4. `CombatManagerTB.gd` → 전체 턴 루프 통합
5. `TurnBasedIntentSystem.gd` → 의도 표시 연동
6. `TarotEnergySystem.gd` + `DreamShardSystem.gd` → 보조 자원 시스템
7. `DeckPassiveCalculator.gd` → 덱 패시브 적용
8. `TurnBasedAutoAI.gd` → 오토 플레이 모드
9. UI 전체 연동 + VFX + SFX

---

**참조 설계서**: COMBAT_TURNBASED_COMPLETE_v1.md
**공통 시스템**: DEV_SPEC_SHARED.md
**OPS 플레이테스트**: teams/ops/workspace/research/combat-analysis/06_PLAYTEST_TURNBASED_REPORT.md
