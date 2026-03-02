# scripts/combat/atb/ATBFocusMode.gd
# 집중 모드: 에너지 소모로 시간 슬로우 — DEV_SPEC_ATB.md 기반
class_name ATBFocusMode
extends Node

const FOCUS_SPEED       = 0.3    # 슬로우 배율
const FOCUS_COST        = 1      # 에너지 소모
const FOCUS_DURATION    = 3.0    # 지속 시간 (초)
const FOCUS_DRAIN_RATE  = 0.1    # ★ OPS 피드백: 20%→10%로 감소

var is_active       : bool  = false
var focus_remaining : float = 0.0

signal focus_started
signal focus_ended
signal focus_progress(ratio: float)

# 부모 전투 관리자 참조
var combat_manager = null
var energy_system : ATBEnergySystem = null

func _ready():
	pass

func setup(cm, es: ATBEnergySystem):
	combat_manager = cm
	energy_system = es

func activate():
	if is_active: return
	if energy_system == null or not energy_system.can_afford(FOCUS_COST):
		print("[ATBFocus] 에너지 부족!")
		return

	energy_system.spend(FOCUS_COST)
	is_active = true
	focus_remaining = FOCUS_DURATION
	if combat_manager and combat_manager.has_method("set_speed"):
		combat_manager.set_speed(FOCUS_SPEED)
	print("[ATBFocus] 집중 모드 활성화!")
	emit_signal("focus_started")

func _process(delta: float):
	if not is_active: return
	focus_remaining -= delta
	var ratio = clamp(focus_remaining / FOCUS_DURATION, 0.0, 1.0)
	emit_signal("focus_progress", ratio)

	if focus_remaining <= 0:
		_deactivate()

func deactivate_by_player():
	if is_active:
		_deactivate()

func _deactivate():
	is_active = false
	if combat_manager:
		# Crisis가 활성 중이면 Crisis 속도로 복원, 아니면 1.0
		var crisis = combat_manager.get_node_or_null("ATBCrisisMode")
		var restore_speed = 1.0
		if crisis and crisis.is_active:
			restore_speed = ATBCrisisMode.CRISIS_SPEED
		if combat_manager.has_method("set_speed"):
			combat_manager.set_speed(restore_speed)
	print("[ATBFocus] 집중 모드 종료")
	emit_signal("focus_ended")

func reset():
	if is_active:
		_deactivate()
	focus_remaining = 0.0
