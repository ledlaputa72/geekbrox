# scripts/combat/atb/ATBReactionManager.gd
# 리액션 윈도우 판정 + 결과 시그널 — DEV_SPEC_ATB.md 기반
class_name ATBReactionManager
extends Node

# ── 상수 (녹→노→빨, 빨간=가장 짧음) ─────────────────────
# 회피=노랑+빨강 | 방어=전체 | 패링=빨강만
# Story: 총 2.4초 | Green 0~1.0 (가장 김) | Yellow 1.0~2.0 | Red 2.0~2.4 (가장 짧음)
const GREEN_DURATION_STORY  = 1.0
const DODGE_START_STORY     = 1.0
const PARRY_START_STORY     = 2.0
const WINDOW_END_STORY      = 2.4
# Hard: 더 짧게
const GREEN_DURATION_HARD   = 0.65
const DODGE_START_HARD      = 0.65
const PARRY_START_HARD      = 1.35
const WINDOW_END_HARD       = 1.6
const COUNTER_WINDOW        = 2.0

# ── 상태 변수 ─────────────────────────────────────────
var reaction_state : String = "IDLE"  # "IDLE" | "OPEN" | "RESOLVED"
var time_elapsed   : float  = 0.0
var _last_phase    : String = ""
var parry_timer    : float  = 0.0   # 호환용 (미사용)
var dodge_timer    : float  = 0.0   # 호환용 (미사용)
var counter_timer  : float  = 0.0
var last_result    : ReactionResult = null
var current_attack : Dictionary = {}
var story_mode     : bool = true   # SettingsManager에서 읽어옴
var last_failed_attempt_type : String = ""  # "PARRY" | "DODGE" | "" (실패 판정용)

# ── 시그널 ────────────────────────────────────────────
signal reaction_resolved
signal parry_success(card: Card)
signal dodge_success(card: Card)
signal guard_success(card: Card)
signal reaction_failed
signal reaction_window_opened(attack: Dictionary)
signal reaction_window_closed(result_type: String)
signal reaction_phase_changed(phase: String, is_unblockable: bool)
signal reaction_attempt_failed(attempted_type: String)  # 패링/회피 타이밍 실패 → UI에서 다음 옵션 활성화

# ── 윈도우 오픈 ──────────────────────────────────────
func open_reaction_window(attack: Dictionary):
	current_attack = attack
	if has_node("/root/SettingsManager"):
		story_mode = SettingsManager.story_mode
	else:
		story_mode = true

	time_elapsed = 0.0
	_last_phase = "green"
	last_failed_attempt_type = ""
	reaction_state = "OPEN"
	emit_signal("reaction_window_opened", attack)
	emit_signal("reaction_phase_changed", "green", _is_unblockable())

	if attack.get("type", "") == "UNBLOCKABLE":
		print("[ATBReaction] UNBLOCKABLE attack — DODGE only!")

func _is_unblockable() -> bool:
	return str(current_attack.get("type", "")) == "UNBLOCKABLE"

func _get_phase() -> String:
	var g = GREEN_DURATION_STORY if story_mode else GREEN_DURATION_HARD
	var d = DODGE_START_STORY if story_mode else DODGE_START_HARD
	var p = PARRY_START_STORY if story_mode else PARRY_START_HARD
	var e = WINDOW_END_STORY if story_mode else WINDOW_END_HARD
	if time_elapsed < g:
		return "green"
	if time_elapsed < p:
		return "yellow"
	if time_elapsed < e:
		return "red"
	return "closed"

# ── 카드 탭 판정 ──────────────────────────────────────
func on_player_tap_card(card: Card):
	if reaction_state != "OPEN":
		return

	if current_attack.get("type", "") == "UNBLOCKABLE":
		if card.has_tag("PARRY"):
			print("[ATBReaction] PARRY failed on UNBLOCKABLE!")
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
		# 실패 시도 기록 (시간 종료 시 NONE으로 떨어질 때 페널티 적용용) + UI에 다음 옵션 활성화
		if card.has_tag("PARRY") and phase != "red":
			last_failed_attempt_type = "PARRY"
			emit_signal("reaction_attempt_failed", "PARRY")
		elif card.has_tag("DODGE") and not (phase in ["yellow", "red"]):
			last_failed_attempt_type = "DODGE"
			emit_signal("reaction_attempt_failed", "DODGE")

func _resolve_parry(card: Card):
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("PARRY", card)
	counter_timer = COUNTER_WINDOW
	emit_signal("parry_success", card)
	emit_signal("reaction_window_closed", "PARRY")
	emit_signal("reaction_resolved")

func _resolve_dodge(card: Card):
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("DODGE", card)
	emit_signal("dodge_success", card)
	emit_signal("reaction_window_closed", "DODGE")
	emit_signal("reaction_resolved")

func _resolve_guard(card: Card):
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("GUARD", card)
	emit_signal("guard_success", card)
	emit_signal("reaction_window_closed", "GUARD")
	emit_signal("reaction_resolved")

func _auto_resolve_none():
	if reaction_state != "OPEN":
		return
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("NONE", null)
	emit_signal("reaction_failed")
	emit_signal("reaction_window_closed", "NONE")
	emit_signal("reaction_resolved")

func reset():
	if reaction_state == "OPEN":
		emit_signal("reaction_window_closed", "RESET")
	reaction_state = "IDLE"
	time_elapsed = 0.0
	_last_phase = ""
	last_failed_attempt_type = ""
	parry_timer = 0.0
	dodge_timer = 0.0
	counter_timer = 0.0
	last_result = null
	current_attack = {}

# ── _process: time_elapsed 증가 + phase 변경 시 시그널 ─
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


# ── ReactionResult 내부 클래스 ────────────────────────
class ReactionResult:
	var type : String  # "PARRY" | "DODGE" | "GUARD" | "NONE"
	var card : Card
	func _init(t: String, c):
		type = t
		card = c
