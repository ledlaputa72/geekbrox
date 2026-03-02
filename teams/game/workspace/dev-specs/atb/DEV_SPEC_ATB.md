# ⚡ ATB 전투 시스템 — 개발 사양서
# Dream Collector | Dev Spec for Cursor / Claude Code

**버전**: v1.0 | **날짜**: 2026-03-01
**작성**: Kim.G (게임팀장) + OPS 플레이테스트 반영
**대상**: Cursor IDE / Claude Code 구현용
**참조 설계서**: COMBAT_ATB_COMPLETE_v1.md
**공통 시스템**: DEV_SPEC_SHARED.md (반드시 먼저 읽을 것)

> ⚠️ 이 문서는 ATB 전투 모드 전용 스크립트를 정의합니다.
> 공통 Card, Monster, StatusEffect, UI 클래스는 DEV_SPEC_SHARED.md를 참조하세요.

---

## 1. 구현 대상 스크립트 목록

```
res://scripts/combat/atb/
├── CombatManagerATB.gd       ← 핵심 전투 루프
├── ATBEnergySystem.gd        ← 에너지 + 오버플로우 관리
├── ATBReactionManager.gd     ← 패링/회피/방어 판정
├── ATBIntentSystem.gd        ← 적 의도 표시
├── ATBComboSystem.gd         ← 드림 콤보 판정
├── ATBAutoAI.gd              ← 오토 플레이 AI
├── ATBFocusMode.gd           ← 집중 모드 (시간 슬로우)
└── ATBCrisisMode.gd          ← 위기 모드 (HP 30% 이하)

res://scenes/combat/
└── CombatSceneATB.tscn       ← ATB 전투 씬
```

---

## 2. CombatManagerATB.gd

ATB 전투의 중앙 관리자. 모든 서브시스템을 조율.

```gdscript
# scripts/combat/atb/CombatManagerATB.gd
class_name CombatManagerATB
extends Node

# ── 핵심 상수 ──────────────────────────────────────────
const ATB_MAX            = 100.0
const ATB_CHARGE_RATE    = 1.0     # 초당 충전 배율 (spd 100 기준 1초에 1 충전)
const SPEED_DEFAULT      = 1.0
const SPEED_MAX          = 2.5
const SPEED_FOCUS        = 0.3     # 집중 모드
const SPEED_CRISIS       = 0.5     # 위기 개입

# ── 참조 노드 ──────────────────────────────────────────
@onready var energy_system   : ATBEnergySystem    = $ATBEnergySystem
@onready var reaction_mgr    : ATBReactionManager = $ATBReactionManager
@onready var intent_system   : ATBIntentSystem    = $ATBIntentSystem
@onready var combo_system    : ATBComboSystem     = $ATBComboSystem
@onready var auto_ai         : ATBAutoAI          = $ATBAutoAI
@onready var focus_mode      : ATBFocusMode       = $ATBFocusMode
@onready var crisis_mode     : ATBCrisisMode      = $ATBCrisisMode
@onready var hand_ui         : HandUI             = $HandUI
@onready var battle_diary    : BattleDiary        = $BattleDiary

# ── 상태 변수 ──────────────────────────────────────────
var all_entities     : Array[Entity] = []
var speed_multiplier : float = SPEED_DEFAULT
var is_paused        : bool  = false
var reaction_open    : bool  = false  # 리액션 윈도우 활성 중

# ── 시그널 ────────────────────────────────────────────
signal combat_started
signal combat_ended(result: String)      # "WIN" | "LOSE" | "ESCAPE"
signal entity_atb_full(entity: Entity)
signal reaction_window_opened(attack: AttackData)
signal combo_triggered(combo_name: String)

# ── 초기화 ────────────────────────────────────────────
func _ready():
    _init_entities()
    emit_signal("combat_started")

func _init_entities():
    # 플레이어와 몬스터를 all_entities에 등록
    all_entities.append(PlayerEntity)
    for enemy in EnemyGroup.get_enemies():
        all_entities.append(enemy)
        intent_system.register_enemy(enemy)

# ── 메인 게임 루프 ────────────────────────────────────
func _process(delta: float):
    if is_paused or reaction_open:
        return
    _update_atb(delta)
    energy_system.update_timer(delta)
    crisis_mode.check(delta)

func _update_atb(delta: float):
    for entity in all_entities:
        if not entity.is_alive():
            continue
        # spd=100이 기준속도. spd 높을수록 ATB 빠르게 충전
        var charge = (entity.spd / 100.0) * ATB_CHARGE_RATE * delta * speed_multiplier * 100.0
        entity.atb = min(ATB_MAX, entity.atb + charge)
        if entity.atb >= ATB_MAX:
            entity.atb = 0.0
            _on_entity_atb_full(entity)
            break  # 이번 프레임은 한 번만 처리 (동시 만료 방지)

func _on_entity_atb_full(entity: Entity):
    emit_signal("entity_atb_full", entity)
    if entity.is_player:
        # 플레이어 ATB 만료 → 카드 드로우 가능 상태 알림 (선택적)
        hand_ui.prompt_action()
    else:
        _enemy_attack_begin(entity)

# ── 적 공격 처리 ──────────────────────────────────────
func _enemy_attack_begin(enemy: Entity):
    var attack = enemy.get_next_action()
    intent_system.announce_attack(attack)

    # 리액션 윈도우 오픈
    reaction_open = true
    reaction_mgr.open_reaction_window(attack)

    # 리액션 결과를 기다린 후 피해 계산
    await reaction_mgr.reaction_resolved
    reaction_open = false

    var result = reaction_mgr.last_result
    _apply_attack_result(enemy, attack, result)
    intent_system.advance_pattern(enemy)
    _check_battle_end()

func _apply_attack_result(enemy: Entity, attack: AttackData, result: ReactionResult):
    match result.type:
        "PARRY":
            # 패링: 피해 0, 에너지 +2, 적 ATB 롤백
            energy_system.on_parry_success()
            enemy.atb *= 0.5
            VFX.play_at(enemy.position, "parry_clash")
            SFX.play("parry_success")
            battle_diary.log("패링 성공! 에너지 +2")
        "DODGE":
            energy_system.on_dodge_success()
            VFX.play_at(PlayerEntity.position, "dodge_blur")
            SFX.play("dodge_whoosh")
        "GUARD":
            var block_val = result.card.block if result.card else 0
            energy_system.on_guard_success(block_val)
            PlayerEntity.add_block(block_val)
        "NONE":
            # 무반응 — 풀 피해
            var dmg = _calculate_damage(enemy, attack, PlayerEntity)
            PlayerEntity.take_damage(dmg)
            VFX.play_at(PlayerEntity.position, "hit_impact")

func _calculate_damage(attacker: Entity, attack: AttackData, target: Entity) -> int:
    var base = attack.damage
    # 상태이상 보정
    if target.has_status("VULNERABLE"):
        base = int(base * 1.5)
    if attacker.has_status("WEAK"):
        base = int(base * 0.75)
    # 블록 상쇄
    var after_block = max(0, base - target.block)
    target.block = max(0, target.block - base)
    return after_block

# ── 플레이어 카드 플레이 ──────────────────────────────
func player_play_card(card: Card):
    if reaction_open:
        reaction_mgr.on_player_tap_card(card)
        return
    if energy_system.current_energy < card.cost:
        hand_ui.shake_card(card)  # 에너지 부족 피드백
        return
    energy_system.spend(card.cost)
    _resolve_card_effect(card)
    combo_system.register_card(card)
    hand_ui.discard_card(card)
    _check_combo()

func _resolve_card_effect(card: Card):
    # 공격 카드
    if card.type == "ATK":
        var dmg = combo_system.apply_combo_bonus(card.damage)
        for enemy in EnemyGroup.get_alive_enemies():
            var actual = _calculate_player_damage(card, enemy, dmg)
            enemy.take_damage(actual)
    # 방어 카드
    if card.block > 0:
        PlayerEntity.add_block(card.block)
    # 상태이상
    for eff in card.status_effects:
        StatusEffectSystem.apply(eff.target, eff.type, eff.value)
    # 드로우
    if card.draw > 0:
        hand_ui.draw_cards(card.draw)

func _calculate_player_damage(card: Card, enemy: Entity, base: int) -> int:
    var dmg = base + PlayerEntity.atk_bonus
    if enemy.has_status("VULNERABLE"):
        dmg = int(dmg * 1.5)
    if PlayerEntity.has_status("WEAK"):
        dmg = int(dmg * 0.75)
    return max(0, dmg - enemy.block)

# ── 전투 종료 체크 ────────────────────────────────────
func _check_battle_end():
    if not PlayerEntity.is_alive():
        emit_signal("combat_ended", "LOSE")
    elif EnemyGroup.all_dead():
        emit_signal("combat_ended", "WIN")

# ── 전투 속도 변경 ────────────────────────────────────
func set_speed(multiplier: float):
    speed_multiplier = clamp(multiplier, 0.1, SPEED_MAX)
```

---

## 3. ATBEnergySystem.gd

에너지 관리 + 오버플로우 (OPS 피드백: 오버플로우 유지시간 3초로 변경).

```gdscript
# scripts/combat/atb/ATBEnergySystem.gd
class_name ATBEnergySystem
extends Node

# ── 상수 ─────────────────────────────────────────────
const ENERGY_MAX          = 3
const ENERGY_OVERFLOW_MAX = 5
const ENERGY_AUTO_INTERVAL = 5.0   # 초 단위 자동 회복 주기
const OVERFLOW_DURATION   = 3.0    # ★ OPS 피드백: 2.0→3.0초로 연장

# ── 상태 변수 ─────────────────────────────────────────
var current_energy : float = 3.0
var energy_timer   : float = 0.0
var overflow_timer : float = 0.0

# ── 참조 UI ──────────────────────────────────────────
@onready var energy_ui : EnergyUI = $"../UI/EnergyUI"

# ── 업데이트 (CombatManagerATB._process에서 호출) ────
func update_timer(delta: float):
    # 자동 에너지 회복
    energy_timer += delta
    if energy_timer >= ENERGY_AUTO_INTERVAL:
        energy_timer = 0.0
        _add_energy(1.0)

    # 오버플로우 감소
    if overflow_timer > 0:
        overflow_timer -= delta
        if overflow_timer <= 0:
            current_energy = min(current_energy, float(ENERGY_MAX))
            energy_ui.update(current_energy, ENERGY_MAX)
            energy_ui.stop_overflow_glow()

# ── 방어 성공 콜백 ─────────────────────────────────
func on_parry_success():
    # ★ 에너지 +2 즉시 (최대 5 오버플로우)
    _add_energy(2.0)
    if current_energy > ENERGY_MAX:
        overflow_timer = OVERFLOW_DURATION
        energy_ui.show_overflow_glow(Color(1.0, 0.84, 0.0))  # 금색

func on_dodge_success():
    # 에너지 +1 즉시
    _add_energy(1.0)

func on_guard_success(block_val: int):
    # 에너지 +0.5
    # ★ OPS 피드백: 0.5 시각화 — 절반 채워진 오브 애니메이션
    _add_energy(0.5)
    energy_ui.play_half_fill_animation()

# ── 내부 에너지 가산 ───────────────────────────────
func _add_energy(amount: float):
    var prev = current_energy
    current_energy = min(float(ENERGY_OVERFLOW_MAX), current_energy + amount)
    energy_ui.update(current_energy, ENERGY_MAX)
    if current_energy != prev:
        energy_ui.play_gain_animation(amount)

# ── 에너지 소비 (카드 플레이 시) ─────────────────────
func spend(amount: int) -> bool:
    if current_energy < amount:
        return false
    current_energy -= amount
    energy_ui.update(current_energy, ENERGY_MAX)
    energy_ui.play_spend_animation(amount)
    return true

func can_afford(cost: int) -> bool:
    return current_energy >= cost
```

---

## 4. ATBReactionManager.gd

리액션 윈도우 판정 + 결과 시그널.

```gdscript
# scripts/combat/atb/ATBReactionManager.gd
class_name ATBReactionManager
extends Node

# ── 상수 ─────────────────────────────────────────────
# Story 모드 (기본값): 더 넓은 윈도우
# Hard 모드: 타이트한 윈도우
const PARRY_WINDOW_STORY  = 0.8    # ★ OPS 피드백: Story 모드를 기본으로
const PARRY_WINDOW_HARD   = 0.5
const DODGE_WINDOW_STORY  = 1.8
const DODGE_WINDOW_HARD   = 1.2
const COUNTER_WINDOW      = 2.0    # ★ OPS 피드백: 반격 창 2.0초

# ── 상태 변수 ─────────────────────────────────────────
var reaction_state : String = "IDLE"  # "IDLE" | "OPEN" | "RESOLVED"
var parry_timer    : float  = 0.0
var dodge_timer    : float  = 0.0
var counter_timer  : float  = 0.0
var last_result    : ReactionResult = null
var current_attack : AttackData = null
var story_mode     : bool = true   # SettingsManager에서 읽어옴

# ── 시그널 ────────────────────────────────────────────
signal reaction_resolved
signal parry_success(card: Card)
signal dodge_success(card: Card)
signal guard_success(card: Card)
signal reaction_failed

# ── 윈도우 오픈 ──────────────────────────────────────
func open_reaction_window(attack: AttackData):
    current_attack = attack
    story_mode = SettingsManager.story_mode

    var pw = PARRY_WINDOW_STORY if story_mode else PARRY_WINDOW_HARD
    var dw = DODGE_WINDOW_STORY if story_mode else DODGE_WINDOW_HARD

    parry_timer = pw
    dodge_timer = dw
    reaction_state = "OPEN"

    # 손패에서 대응 가능 카드 강조
    HandUI.highlight_reaction_cards(attack.type)

    # 관통 공격은 패링 불가 알림
    if attack.type == AttackType.UNBLOCKABLE:
        UI.show_notice("방어 불가! 회피하세요!", Color.RED)

    _start_window_countdown()

func _start_window_countdown():
    # 패링 윈도우 경과 후 시각 피드백 변경
    await get_tree().create_timer(parry_timer).timeout
    if reaction_state == "OPEN":
        HandUI.switch_to_dodge_highlight()  # 패링 시간 종료, 회피만 가능

    await get_tree().create_timer(dodge_timer - parry_timer).timeout
    if reaction_state == "OPEN":
        _auto_resolve_none()  # 시간 초과 → 무반응

# ── 카드 탭 판정 ──────────────────────────────────────
func on_player_tap_card(card: Card):
    if reaction_state != "OPEN":
        return

    # 관통 공격 처리
    if current_attack.type == AttackType.UNBLOCKABLE:
        if card.has_tag("PARRY"):
            _show_unblockable_fail()
            return

    if card.has_tag("PARRY") and parry_timer > 0:
        _resolve_parry(card)
    elif card.has_tag("DODGE") and dodge_timer > 0:
        _resolve_dodge(card)
    elif card.has_tag("GUARD"):
        _resolve_guard(card)

func _resolve_parry(card: Card):
    reaction_state = "RESOLVED"
    last_result = ReactionResult.new("PARRY", card)
    counter_timer = COUNTER_WINDOW
    emit_signal("parry_success", card)
    emit_signal("reaction_resolved")

func _resolve_dodge(card: Card):
    reaction_state = "RESOLVED"
    last_result = ReactionResult.new("DODGE", card)
    emit_signal("dodge_success", card)
    emit_signal("reaction_resolved")

func _resolve_guard(card: Card):
    reaction_state = "RESOLVED"
    last_result = ReactionResult.new("GUARD", card)
    emit_signal("guard_success", card)
    emit_signal("reaction_resolved")

func _auto_resolve_none():
    if reaction_state != "OPEN":
        return
    reaction_state = "RESOLVED"
    last_result = ReactionResult.new("NONE", null)
    emit_signal("reaction_failed")
    emit_signal("reaction_resolved")

func _show_unblockable_fail():
    VFX.play("blocked_fail_flash")
    UI.show_notice("패링 불가!", Color.RED, 0.5)

# ── _process에서 타이머 감소 ──────────────────────────
func _process(delta: float):
    if reaction_state != "OPEN":
        return
    parry_timer -= delta
    dodge_timer  -= delta


# ── ReactionResult 내부 클래스 ────────────────────────
class ReactionResult:
    var type : String  # "PARRY" | "DODGE" | "GUARD" | "NONE"
    var card : Card
    func _init(t: String, c: Card):
        type = t
        card = c
```

---

## 5. ATBIntentSystem.gd

적 행동 예고 시스템. ATB 충전률에 따라 시각 강도 변화.

```gdscript
# scripts/combat/atb/ATBIntentSystem.gd
class_name ATBIntentSystem
extends Node

# ── 의도 아이콘 매핑 ──────────────────────────────────
const INTENT_ICONS = {
    AttackType.NORMAL:      "⚔️",
    AttackType.HEAVY:       "⚔️⚠️",
    AttackType.AOE:         "🌀",
    AttackType.UNBLOCKABLE: "🔱",
    AttackType.BUFF:        "✨",
    AttackType.DEFEND:      "🛡️",
}

# ── ATB 연동 예고 강도 단계 ───────────────────────────
# ATB 0~60%:  일반 표시
# ATB 60~80%: 강조 (아이콘 크기 업)
# ATB 80~95%: 경고 (주황 테두리)
# ATB 95%+:   위험 (빨간 + 진동 + "⚡위험!" 텍스트)

func update_intent_display(enemy: Entity):
    var atb_pct = enemy.atb / 100.0
    var action  = enemy.get_next_action()

    var icon  = INTENT_ICONS.get(action.type, "❓")
    var value = action.damage

    if atb_pct < 0.6:
        IntentUI.show_normal(enemy, icon, value)
    elif atb_pct < 0.8:
        IntentUI.show_emphasis(enemy, icon, value)
    elif atb_pct < 0.95:
        IntentUI.show_warning(enemy, icon, value, Color.ORANGE)
    else:
        IntentUI.show_danger(enemy, icon, value, Color.RED)
        UI.flash_text("⚡ 위험!", Color.RED, 0.3)
        Haptics.vibrate_light()

func announce_attack(attack: AttackData):
    # 공격 실행 직전 마지막 알림
    IntentUI.flash_all()
    if attack.type == AttackType.HEAVY:
        SFX.play("intent_heavy_warning")
    elif attack.type == AttackType.UNBLOCKABLE:
        SFX.play("intent_unblockable_warning")
        UI.show_notice("방어 불가! 회피하세요!", Color.RED)

func register_enemy(enemy: Entity):
    # 의도 UI 슬롯 생성
    IntentUI.create_slot(enemy)

func advance_pattern(enemy: Entity):
    enemy.advance_action_index()
    update_intent_display(enemy)
```

---

## 6. ATBComboSystem.gd

드림 콤보 판정. 최근 3~4장의 카드 시퀀스를 추적.

```gdscript
# scripts/combat/atb/ATBComboSystem.gd
class_name ATBComboSystem
extends Node

# ── 콤보 시퀀스 버퍼 ─────────────────────────────────
var card_history : Array[Card] = []  # 최근 5장 기록
const HISTORY_MAX = 5

# ── 콤보 정의 ─────────────────────────────────────────
const COMBOS = [
    {
        "name": "연타",
        "condition": func(h): return _last_n_type(h, 3, "ATK"),
        "bonus_fn": func(dmg, card): return int(dmg * 1.75),  # +75%
        "vfx": "combo_triple",
        "sfx": "combo_hit3"
    },
    {
        "name": "완벽한 방어",
        "condition": func(h): return _last_n_type(h, 2, "DEF"),
        "bonus_fn": func(dmg, card): return dmg,  # 데미지 없음, 블록+10은 별도 처리
        "vfx": "combo_perfect_guard",
        "sfx": "combo_guard"
    },
    {
        "name": "패링 반격",
        "condition": func(h): return _last_parry_then_atk(h),
        "bonus_fn": func(dmg, card): return int(dmg * 1.30),  # +30%
        "vfx": "combo_counter",
        "sfx": "combo_counter_hit"
    },
    {
        "name": "약점 폭로",
        "condition": func(h): return _last_vulnerable_then_atk(h),
        "bonus_fn": func(dmg, card): return int(dmg * 1.5),
        "vfx": "combo_expose",
        "sfx": "combo_expose_hit"
    },
]

# ── 카드 등록 ─────────────────────────────────────────
func register_card(card: Card):
    card_history.append(card)
    if card_history.size() > HISTORY_MAX:
        card_history.pop_front()

# ── 콤보 보너스 적용 ─────────────────────────────────
func apply_combo_bonus(base_damage: int) -> int:
    for combo in COMBOS:
        if combo["condition"].call(card_history):
            var bonused = combo["bonus_fn"].call(base_damage, null)
            _trigger_combo_vfx(combo)
            return bonused
    return base_damage

func _trigger_combo_vfx(combo: Dictionary):
    VFX.play(combo["vfx"])
    SFX.play(combo["sfx"])
    UI.show_combo_banner(combo["name"])
    # ★ OPS 피드백: 콤보 힌트 UI — 다음 콤보 가능 조건 미리보기
    _update_combo_hint()

func _update_combo_hint():
    # 현재 시퀀스 기반으로 "다음 카드로 콤보 가능" 힌트 계산
    var hint = _get_next_combo_hint()
    if hint != "":
        ComboHintUI.show(hint)

# ── 조건 헬퍼 ────────────────────────────────────────
func _last_n_type(history: Array, n: int, type: String) -> bool:
    if history.size() < n: return false
    for i in range(n):
        if history[history.size() - 1 - i].type != type:
            return false
    return true

func _last_parry_then_atk(history: Array) -> bool:
    if history.size() < 2: return false
    return history[-1].type == "ATK" and history[-2].has_tag("PARRY")

func _last_vulnerable_then_atk(history: Array) -> bool:
    if history.size() < 2: return false
    var has_vuln = false
    for eff in history[-2].status_effects:
        if eff.type == "VULNERABLE": has_vuln = true
    return has_vuln and history[-1].type == "ATK"

func _get_next_combo_hint() -> String:
    # 현재 히스토리로 어떤 콤보를 1장 더 하면 완성할 수 있는지 판단
    if _last_n_type(card_history, 2, "ATK"):
        return "공격 1장 더 → 연타 콤보!"
    if card_history.size() >= 1 and card_history[-1].has_tag("PARRY"):
        return "공격 카드 → 패링 반격 콤보!"
    return ""
```

---

## 7. ATBAutoAI.gd

오토 플레이 AI. 3단계로 개입 수준 조절.

```gdscript
# scripts/combat/atb/ATBAutoAI.gd
class_name ATBAutoAI
extends Node

# ── 오토 모드 ────────────────────────────────────────
enum AutoMode {
    MANUAL,      # 수동 — AI 없음
    SEMI,        # 세미 — AI 추천 + 플레이어 확인 탭
    FULL         # 풀오토 — AI가 자동 실행
}

var mode : AutoMode = AutoMode.SEMI

# ── 메인 결정 로직 ────────────────────────────────────
func decide_action(hand: Array[Card], enemy: Entity, energy: int) -> Card:
    var intent = enemy.get_next_action()

    # 1순위: 적 ATB 80%+ → 방어 준비
    if enemy.atb >= 80.0:
        var best_defense = _pick_best_defense(hand, intent, energy)
        if best_defense:
            return best_defense

    # 2순위: 적 HP 30% 이하 → 전력 공격
    if enemy.hp_ratio() <= 0.3:
        var atk = _pick_strongest_attack(hand, energy)
        if atk: return atk

    # 3순위: 상태이상 기회
    if not enemy.has_status("VULNERABLE"):
        var debuff = _pick_debuff(hand, energy)
        if debuff: return debuff

    # 4순위: 콤보 완성
    var combo_card = _pick_combo_finisher(hand, energy)
    if combo_card: return combo_card

    # 기본: 코스트 대비 최고 효율 공격
    return _pick_efficient_attack(hand, energy)

# ── 방어 선택 ─────────────────────────────────────────
func _pick_best_defense(hand: Array[Card], intent: AttackData, energy: int) -> Card:
    # 관통 공격 → 회피 카드 우선
    if intent.type == AttackType.UNBLOCKABLE:
        for card in hand:
            if card.has_tag("DODGE") and card.cost <= energy:
                return card
    # 일반/강한 공격 → 패링 카드 우선
    for card in hand:
        if card.has_tag("PARRY") and card.cost <= energy:
            return card
    # 패링 없으면 회피
    for card in hand:
        if card.has_tag("DODGE") and card.cost <= energy:
            return card
    # 방어 카드
    for card in hand:
        if card.has_tag("GUARD") and card.cost <= energy:
            return card
    return null

func _pick_strongest_attack(hand: Array[Card], energy: int) -> Card:
    var best: Card = null
    for card in hand:
        if card.type == "ATK" and card.cost <= energy:
            if best == null or card.damage > best.damage:
                best = card
    return best

func _pick_debuff(hand: Array[Card], energy: int) -> Card:
    for card in hand:
        if card.cost <= energy:
            for eff in card.status_effects:
                if eff.type in ["VULNERABLE", "WEAK", "POISON"]:
                    return card
    return null

func _pick_combo_finisher(hand: Array[Card], energy: int) -> Card:
    var hint = ComboSystem.get_next_combo_hint()
    if hint == "":
        return null
    # 힌트에 맞는 카드 선택 (타입 기반)
    if "공격" in hint:
        return _pick_efficient_attack(hand, energy)
    return null

func _pick_efficient_attack(hand: Array[Card], energy: int) -> Card:
    var best: Card = null
    var best_ratio = 0.0
    for card in hand:
        if card.type == "ATK" and card.cost <= energy and card.cost > 0:
            var ratio = float(card.damage) / card.cost
            if ratio > best_ratio:
                best_ratio = ratio
                best = card
    return best

# ── 세미 오토: 추천 카드 표시 ─────────────────────────
func suggest_card(hand: Array[Card], enemy: Entity, energy: int):
    var suggested = decide_action(hand, enemy, energy)
    if suggested:
        HandUI.highlight_suggested(suggested)

# ── 풀 오토 루프 ─────────────────────────────────────
func auto_play_turn(hand: Array[Card], enemy: Entity, energy: int):
    while energy > 0 and hand.size() > 0:
        var card = decide_action(hand, enemy, energy)
        if card == null:
            break
        await get_tree().create_timer(0.4).timeout  # 자연스러운 플레이 간격
        CombatManager.player_play_card(card)
        hand.erase(card)
        energy -= card.cost
```

---

## 8. ATBFocusMode.gd

집중 모드: 에너지 소모로 시간 슬로우.

```gdscript
# scripts/combat/atb/ATBFocusMode.gd
class_name ATBFocusMode
extends Node

const FOCUS_SPEED       = 0.3    # 슬로우 배율
const FOCUS_COST        = 1      # 에너지 소모
const FOCUS_DURATION    = 3.0    # 지속 시간 (초)
const FOCUS_DRAIN_RATE  = 0.1    # ★ OPS 피드백: 20%→10%로 감소 (집중 모드 더 관대하게)

var is_active       : bool  = false
var focus_remaining : float = 0.0

signal focus_started
signal focus_ended

func activate():
    if is_active: return
    if not EnergySystem.can_afford(FOCUS_COST):
        UI.show_notice("에너지 부족!", Color.ORANGE)
        return

    EnergySystem.spend(FOCUS_COST)
    is_active = true
    focus_remaining = FOCUS_DURATION
    CombatManager.set_speed(FOCUS_SPEED)
    VFX.play("focus_mode_enter")
    SFX.play("focus_activate")
    FocusUI.show_bar(focus_remaining / FOCUS_DURATION)
    emit_signal("focus_started")

func _process(delta: float):
    if not is_active: return
    focus_remaining -= delta * (1.0 / FOCUS_SPEED)  # 실제 시간 기준으로 소모
    FocusUI.update_bar(focus_remaining / FOCUS_DURATION)

    if focus_remaining <= 0:
        _deactivate()

func deactivate_by_player():
    if is_active:
        _deactivate()

func _deactivate():
    is_active = false
    CombatManager.set_speed(1.0)
    VFX.play("focus_mode_exit")
    FocusUI.hide_bar()
    emit_signal("focus_ended")
```

---

## 9. ATBCrisisMode.gd

위기 모드: HP 30% 이하 시 자동 개입.

```gdscript
# scripts/combat/atb/ATBCrisisMode.gd
class_name ATBCrisisMode
extends Node

const CRISIS_HP_THRESHOLD = 0.30    # HP 30% 이하
const CRISIS_SPEED        = 0.5     # 위기 개입 속도
const CRISIS_DURATION     = 10.0    # ★ OPS 피드백: 8→10초로 연장

var is_active        : bool  = false
var crisis_timer     : float = 0.0
var triggered_once   : bool  = false  # 한 전투에 1회만 발동 (선택)

func check(delta: float):
    if is_active:
        crisis_timer -= delta
        if crisis_timer <= 0:
            _end_crisis()
        return

    # 위기 진입 체크
    if PlayerEntity.hp_ratio() <= CRISIS_HP_THRESHOLD and not triggered_once:
        _enter_crisis()

func _enter_crisis():
    is_active = true
    crisis_timer = CRISIS_DURATION
    triggered_once = true
    CombatManager.set_speed(CRISIS_SPEED)
    VFX.play("crisis_vignette")
    SFX.play("crisis_heartbeat")
    CrisisUI.show(crisis_timer)
    UI.show_notice("위기! 방어하세요!", Color.RED)

func _end_crisis():
    is_active = false
    CombatManager.set_speed(1.0)
    VFX.stop("crisis_vignette")
    SFX.stop("crisis_heartbeat")
    CrisisUI.hide()
```

---

## 10. 씬 구성 (CombatSceneATB.tscn)

```
CombatSceneATB (Node)
├── CombatManagerATB
│   ├── ATBEnergySystem
│   ├── ATBReactionManager
│   ├── ATBIntentSystem
│   ├── ATBComboSystem
│   ├── ATBAutoAI
│   ├── ATBFocusMode
│   └── ATBCrisisMode
├── EnemyGroup (Node)
│   ├── Enemy_1
│   └── Enemy_2 (멀티 적 지원)
├── PlayerEntity
├── BattleDiary
├── StatusEffectSystem
└── UI (CanvasLayer)
    ├── EnergyUI        ← 에너지 오브 + 오버플로우 글로우
    ├── HandUI          ← 카드 손패 + 패링/회피 강조
    ├── IntentUI        ← 적 의도 아이콘
    ├── ComboHintUI     ← ★ OPS 추가: 콤보 힌트 미리보기
    ├── FocusUI         ← 집중 모드 게이지
    ├── CrisisUI        ← 위기 모드 타이머
    └── ATBBarUI        ← ATB 게이지 (플레이어 + 적)
```

---

## 11. OPS 플레이테스트 반영 수치 요약

| 항목 | 변경 전 | 변경 후 (최종) | 근거 |
|------|---------|-------------|------|
| Story 모드 기본값 | 하드 모드 기본 | ✅ Story 모드 기본 | 모바일 접근성 |
| 오버플로우 유지 | 2.0초 | ✅ 3.0초 | 보상감 부족 피드백 |
| 집중 모드 드레인 | 20%/초 | ✅ 10%/초 | 너무 짧음 피드백 |
| 위기 모드 지속 | 8초 | ✅ 10초 | 회복 시간 부족 |
| 반격 창 | 미정 | ✅ 2.0초 | 패링 후 반격 흐름 |
| 콤보 힌트 UI | 없음 | ✅ 추가 | 콤보 인지율 향상 |
| 패링 반격 콤보 보너스 | +50% | ✅ +75% | 수동 플레이 보상 강화 |

---

## 12. 구현 순서 권장

1. `Card.gd` (DEV_SPEC_SHARED) → `ATBEnergySystem.gd` → 에너지 UI 기본 테스트
2. `ATBReactionManager.gd` → 패링/회피 판정 단위 테스트
3. `CombatManagerATB.gd` → 전체 전투 루프 통합
4. `ATBIntentSystem.gd` → 의도 표시 연동
5. `ATBComboSystem.gd` → 콤보 판정
6. `ATBAutoAI.gd` → 오토 플레이 모드
7. `ATBFocusMode.gd` + `ATBCrisisMode.gd` → 특수 모드
8. UI 연동 + VFX + SFX

---

**참조 설계서**: COMBAT_ATB_COMPLETE_v1.md
**공통 시스템**: DEV_SPEC_SHARED.md
**OPS 플레이테스트**: teams/ops/workspace/research/combat-analysis/05_PLAYTEST_ATB_REPORT.md
