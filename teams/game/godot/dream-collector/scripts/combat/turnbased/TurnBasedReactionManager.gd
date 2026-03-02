# scripts/combat/turnbased/TurnBasedReactionManager.gd
# 적 턴 리액션 윈도우 판정 — DEV_SPEC_TURNBASED.md 기반
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
var current_attack       : Dictionary = {}
var last_result          : ReactionResult = null
var pending_draw_bonus   : int = 0   # 패링 성공 시 다음 턴 드로우 +1
var story_mode           : bool = true

# 에너지 시스템 참조
var energy_system : TurnBasedEnergySystem = null

# ── 시그널 ────────────────────────────────────────────
signal reaction_resolved
signal parry_success
signal dodge_success

func setup(es: TurnBasedEnergySystem):
	energy_system = es

# ── 윈도우 오픈 ──────────────────────────────────────
func open_window(attack: Dictionary):
	current_attack = attack
	if has_node("/root/SettingsManager"):
		story_mode = SettingsManager.story_mode
	else:
		story_mode = true
	time_elapsed = 0.0
	reaction_state = "OPEN"
	last_result = null

	# 관통 공격 안내
	if attack.get("type", "") == "UNBLOCKABLE":
		print("[TBReaction] 방어 불가! 회피만 가능!")

func _process(delta: float):
	if reaction_state != "OPEN":
		return
	time_elapsed += delta
	var dw = DODGE_WINDOW_STORY if story_mode else DODGE_WINDOW_HARD
	if time_elapsed >= dw:
		_auto_resolve_none()

# ── 카드 탭 처리 ──────────────────────────────────────
func on_player_card_tapped(card: Card):
	if reaction_state != "OPEN":
		return

	var pw = PARRY_WINDOW_STORY if story_mode else PARRY_WINDOW_HARD
	var dw = DODGE_WINDOW_STORY if story_mode else DODGE_WINDOW_HARD

	# 관통 공격 + 패링 시도 → 실패
	if current_attack.get("type", "") == "UNBLOCKABLE" and card.has_tag("PARRY"):
		print("[TBReaction] 패링 불가!")
		return

	if card.has_tag("PARRY") and time_elapsed <= pw:
		_resolve_parry(card)
	elif card.has_tag("DODGE") and time_elapsed <= dw:
		_resolve_dodge(card)
	elif card.has_tag("GUARD"):
		_resolve_guard(card)

func _resolve_parry(card: Card):
	reaction_state = "RESOLVED"
	if energy_system:
		energy_system.on_parry_success()
	pending_draw_bonus += 1        # 다음 턴 드로우 +1
	last_result = ReactionResult.new("PARRY", card, 0)
	emit_signal("parry_success")
	emit_signal("reaction_resolved")
	print("[TBReaction] 패링 성공! 다음 턴 드로우 +1")

func _resolve_dodge(card: Card):
	reaction_state = "RESOLVED"
	if energy_system:
		energy_system.on_dodge_success()
	last_result = ReactionResult.new("DODGE", card, 0)
	emit_signal("dodge_success")
	emit_signal("reaction_resolved")
	print("[TBReaction] 회피 성공!")

func _resolve_guard(card: Card):
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("GUARD", card, card.block)
	emit_signal("reaction_resolved")
	print("[TBReaction] 가드!")

func _auto_resolve_none():
	reaction_state = "RESOLVED"
	last_result = ReactionResult.new("NONE", null, 0)
	emit_signal("reaction_resolved")

func reset():
	reaction_state = "IDLE"
	time_elapsed = 0.0
	current_attack = {}
	last_result = null
	pending_draw_bonus = 0


# ── ReactionResult 내부 클래스 ────────────────────────
class ReactionResult:
	var type        : String  # "PARRY" | "DODGE" | "GUARD" | "NONE"
	var card        : Card
	var block_value : int
	func _init(t: String, c, b: int):
		type = t
		card = c
		block_value = b
