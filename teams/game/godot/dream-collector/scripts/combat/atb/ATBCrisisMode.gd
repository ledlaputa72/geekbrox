# scripts/combat/atb/ATBCrisisMode.gd
# 위기 모드: HP 30% 이하 시 자동 개입 — DEV_SPEC_ATB.md 기반
class_name ATBCrisisMode
extends Node

const CRISIS_HP_THRESHOLD = 0.30    # HP 30% 이하
const CRISIS_SPEED        = 0.5     # 위기 개입 속도
const CRISIS_DURATION     = 10.0    # ★ OPS 피드백: 8→10초로 연장

var is_active        : bool  = false
var crisis_timer     : float = 0.0
var triggered_once   : bool  = false  # 한 전투에 1회만 발동

signal crisis_entered
signal crisis_ended
signal crisis_tick(remaining: float)

var combat_manager = null
var player_entity  = null

func setup(cm, player):
	combat_manager = cm
	player_entity = player

func check(delta: float):
	if has_node("/root/SettingsManager"):
		if not SettingsManager.crisis_slow_enabled:
			return

	if is_active:
		crisis_timer -= delta
		emit_signal("crisis_tick", crisis_timer)
		if crisis_timer <= 0:
			_end_crisis()
		return

	if player_entity == null:
		return
	var hp_ratio = 0.0
	if player_entity is Dictionary:
		var hp = float(player_entity.get("hp", 0))
		var max_hp = float(player_entity.get("max_hp", 1))
		if max_hp > 0:
			hp_ratio = hp / max_hp
	elif player_entity.has_method("hp_ratio"):
		hp_ratio = player_entity.hp_ratio()

	if hp_ratio > 0.0 and hp_ratio <= CRISIS_HP_THRESHOLD and not triggered_once:
		_enter_crisis()

func _enter_crisis():
	is_active = true
	crisis_timer = CRISIS_DURATION
	triggered_once = true
	if combat_manager and combat_manager.has_method("set_speed"):
		combat_manager.set_speed(CRISIS_SPEED)
	print("[ATBCrisis] 위기 모드! HP 30%% 이하 — 시간 슬로우 %.1f초" % CRISIS_DURATION)
	emit_signal("crisis_entered")

func _end_crisis():
	is_active = false
	if combat_manager:
		# Focus가 활성 중이면 Focus 속도로 복원, 아니면 1.0
		var focus = combat_manager.get_node_or_null("ATBFocusMode")
		var restore_speed = 1.0
		if focus and focus.is_active:
			restore_speed = ATBFocusMode.FOCUS_SPEED
		if combat_manager.has_method("set_speed"):
			combat_manager.set_speed(restore_speed)
	print("[ATBCrisis] 위기 모드 종료")
	emit_signal("crisis_ended")

func reset():
	if is_active:
		_end_crisis()
	triggered_once = false
	crisis_timer = 0.0
