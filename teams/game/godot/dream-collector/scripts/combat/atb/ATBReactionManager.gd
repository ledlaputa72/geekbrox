# scripts/combat/atb/ATBReactionManager.gd
# 리액션 윈도우 판정 + 결과 시그널 — DEV_SPEC_ATB.md 기반
class_name ATBReactionManager
extends Node

# ── 상수 ─────────────────────────────────────────────
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
var current_attack : Dictionary = {}
var story_mode     : bool = true   # SettingsManager에서 읽어옴

# ── 시그널 ────────────────────────────────────────────
signal reaction_resolved
signal parry_success(card: Card)
signal dodge_success(card: Card)
signal guard_success(card: Card)
signal reaction_failed

# ── 윈도우 오픈 ──────────────────────────────────────
func open_reaction_window(attack: Dictionary):
	current_attack = attack
	if has_node("/root/SettingsManager"):
		story_mode = SettingsManager.story_mode
	else:
		story_mode = true

	var pw = PARRY_WINDOW_STORY if story_mode else PARRY_WINDOW_HARD
	var dw = DODGE_WINDOW_STORY if story_mode else DODGE_WINDOW_HARD

	parry_timer = pw
	dodge_timer  = dw
	reaction_state = "OPEN"

	# 관통 공격은 패링 불가 알림
	if attack.get("type", "") == "UNBLOCKABLE":
		print("[ATBReaction] UNBLOCKABLE attack — DODGE only!")

	# 타이머는 _process에서 감소, dodge_timer <= 0 시 자동 none 처리

# ── 카드 탭 판정 ──────────────────────────────────────
func on_player_tap_card(card: Card):
	if reaction_state != "OPEN":
		return

	# 관통 공격 처리
	if current_attack.get("type", "") == "UNBLOCKABLE":
		if card.has_tag("PARRY"):
			print("[ATBReaction] PARRY failed on UNBLOCKABLE!")
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

func reset():
	reaction_state = "IDLE"
	parry_timer = 0.0
	dodge_timer = 0.0
	counter_timer = 0.0
	last_result = null
	current_attack = {}

# ── _process에서 타이머 감소 ──────────────────────────
func _process(delta: float):
	if reaction_state != "OPEN":
		return
	parry_timer -= delta
	dodge_timer -= delta
	if dodge_timer <= 0:
		_auto_resolve_none()


# ── ReactionResult 내부 클래스 ────────────────────────
class ReactionResult:
	var type : String  # "PARRY" | "DODGE" | "GUARD" | "NONE"
	var card : Card
	func _init(t: String, c):
		type = t
		card = c
