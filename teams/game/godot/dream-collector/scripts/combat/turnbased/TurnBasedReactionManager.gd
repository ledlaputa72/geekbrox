# scripts/combat/turnbased/TurnBasedReactionManager.gd
# 적 턴 리액션 윈도우 판정 — DEV_SPEC_TURNBASED.md 기반
class_name TurnBasedReactionManager
extends Node

# ── 윈도우 상수 (녹→노→빨, 빨간=가장 짧음) ─────────────
# 회피=노랑+빨강 | 방어=전체 | 패링=빨강만
# Story: 총 2.4초 | Green 0~1.0 | Yellow 1.0~2.0 | Red 2.0~2.4 (가장 짧음)
const GREEN_DURATION_STORY  = 1.0
const DODGE_START_STORY     = 1.0
const PARRY_START_STORY     = 2.0
const WINDOW_END_STORY      = 2.4
const GREEN_DURATION_HARD   = 0.65
const DODGE_START_HARD      = 0.65
const PARRY_START_HARD      = 1.35
const WINDOW_END_HARD       = 1.6

# ── 상태 변수 ─────────────────────────────────────────
var reaction_state       : String = "IDLE"
var time_elapsed         : float  = 0.0
var _last_phase          : String = ""
var current_attack       : Dictionary = {}
var last_result          : ReactionResult = null
var pending_draw_bonus   : int = 0   # 패링 성공 시 다음 턴 드로우 +1
var story_mode           : bool = true
var last_failed_attempt_type : String = ""  # "PARRY" | "DODGE" | "" (실패 페널티 판정용)

# 에너지 시스템 참조
var energy_system : TurnBasedEnergySystem = null

# ── 시그널 ────────────────────────────────────────────
signal reaction_resolved
signal parry_success
signal dodge_success
signal reaction_window_opened(attack: Dictionary)
signal reaction_window_closed(result_type: String)
signal reaction_phase_changed(phase: String, is_unblockable: bool)
signal reaction_attempt_failed(attempted_type: String)  # 패링/회피 타이밍 실패 → UI에서 다음 옵션 활성화

func setup(es: TurnBasedEnergySystem):
	energy_system = es

func _is_unblockable() -> bool:
	return str(current_attack.get("type", "")) == "UNBLOCKABLE"

func _get_phase() -> String:
	var g = GREEN_DURATION_STORY if story_mode else GREEN_DURATION_HARD
	var p = PARRY_START_STORY if story_mode else PARRY_START_HARD
	var e = WINDOW_END_STORY if story_mode else WINDOW_END_HARD
	if time_elapsed < g:
		return "green"
	if time_elapsed < p:
		return "yellow"
	if time_elapsed < e:
		return "red"
	return "closed"

# ── 윈도우 오픈 ──────────────────────────────────────
func open_window(attack: Dictionary):
	current_attack = attack
	if has_node("/root/SettingsManager"):
		story_mode = SettingsManager.story_mode
	else:
		story_mode = true
	time_elapsed = 0.0
	_last_phase = "green"
	reaction_state = "OPEN"
	last_result = null
	last_failed_attempt_type = ""
	emit_signal("reaction_window_opened", attack)
	emit_signal("reaction_phase_changed", "green", _is_unblockable())

	if attack.get("type", "") == "UNBLOCKABLE":
		print("[TBReaction] 방어 불가! 회피만 가능!")

func _process(delta: float):
	if reaction_state != "OPEN":
		return
	time_elapsed += delta
	var e = WINDOW_END_STORY if story_mode else WINDOW_END_HARD
	if time_elapsed >= e:
		_auto_resolve_none()
		return

	var phase = _get_phase()
	if phase != _last_phase:
		_last_phase = phase
		emit_signal("reaction_phase_changed", phase, _is_unblockable())

# ── 카드 탭 처리 ──────────────────────────────────────
func on_player_card_tapped(card: Card):
	if reaction_state != "OPEN":
		return

	if current_attack.get("type", "") == "UNBLOCKABLE" and card.has_tag("PARRY"):
		print("[TBReaction] 패링 불가!")
		emit_signal("reaction_attempt_failed", "PARRY")
		return

	var phase = _get_phase()
	if card.has_tag("PARRY") and phase == "red":
		_resolve_parry(card)
	elif card.has_tag("DODGE") and phase in ["yellow", "red"]:
		_resolve_dodge(card)
	elif card.has_tag("GUARD") and phase in ["green", "yellow", "red"]:
		_resolve_guard(card)
	else:
		if card.has_tag("PARRY") and phase != "red":
			last_failed_attempt_type = "PARRY"
			emit_signal("reaction_attempt_failed", "PARRY")
		elif card.has_tag("DODGE") and not (phase in ["yellow", "red"]):
			last_failed_attempt_type = "DODGE"
			emit_signal("reaction_attempt_failed", "DODGE")

func _resolve_parry(card: Card):
	reaction_state = "RESOLVED"
	if energy_system:
		energy_system.on_parry_success()
	pending_draw_bonus += 1        # 다음 턴 드로우 +1
	last_result = ReactionResult.new("PARRY", card, 0)
	emit_signal("parry_success")
	emit_signal("reaction_window_closed", "PARRY")
	emit_signal("reaction_resolved")
	print("[TBReaction] 패링 성공! 다음 턴 드로우 +1")

func _resolve_dodge(card: Card):
	reaction_state = "RESOLVED"
	if energy_system:
		energy_system.on_dodge_success()
	last_result = ReactionResult.new("DODGE", card, 0)
	emit_signal("dodge_success")
	emit_signal("reaction_window_closed", "DODGE")
	emit_signal("reaction_resolved")
	print("[TBReaction] 회피 성공!")

func _resolve_guard(card: Card):
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("GUARD", card, card.block)
	emit_signal("reaction_window_closed", "GUARD")
	emit_signal("reaction_resolved")
	print("[TBReaction] 가드!")

func _auto_resolve_none():
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("NONE", null, 0)
	emit_signal("reaction_window_closed", "NONE")
	emit_signal("reaction_resolved")

func reset():
	if reaction_state == "OPEN":
		emit_signal("reaction_window_closed", "RESET")
	reaction_state = "IDLE"
	time_elapsed = 0.0
	_last_phase = ""
	current_attack = {}
	last_result = null
	pending_draw_bonus = 0
	last_failed_attempt_type = ""


# ── ReactionResult 내부 클래스 ────────────────────────
class ReactionResult:
	var type        : String  # "PARRY" | "DODGE" | "GUARD" | "NONE"
	var card        : Card
	var block_value : int
	func _init(t: String, c, b: int):
		type = t
		card = c
		block_value = b
