# scripts/combat/atb/ATBEnergySystem.gd
# ATB 에너지 관리 — 전투 시작 3에너지, 시간당 자동 충전 (5초마다 +1)
class_name ATBEnergySystem
extends Node

# ── 상수 ─────────────────────────────────────────────
const ENERGY_MAX          = 3      # 전투 시작 + 최대 (ATB/턴베이스 공통)
const ENERGY_OVERFLOW_MAX = 5
const ENERGY_AUTO_INTERVAL = 5.0   # ATB 전용: 시간에 따른 충전 (5초마다 +1)
const OVERFLOW_DURATION   = 3.0    # ★ OPS 피드백: 2.0→3.0초로 연장

# ── 상태 변수 ─────────────────────────────────────────
var current_energy : float = 3.0
var energy_timer   : float = 0.0
var overflow_timer : float = 0.0

signal energy_changed(current: float, max_energy: int)
signal energy_timer_progress(progress: float)  # 0.0~1.0 쿨타임 진행률

func _ready():
	current_energy = ENERGY_MAX

# ── 업데이트 (CombatManagerATB._process에서 호출) ────
func update_timer(delta: float):
	# 자동 에너지 회복
	energy_timer += delta
	emit_signal("energy_timer_progress", clamp(energy_timer / ENERGY_AUTO_INTERVAL, 0.0, 1.0))
	if energy_timer >= ENERGY_AUTO_INTERVAL:
		energy_timer = 0.0
		_add_energy(1.0)

	# 오버플로우 감소
	if overflow_timer > 0:
		overflow_timer -= delta
		if overflow_timer <= 0:
			current_energy = min(current_energy, float(ENERGY_MAX))
			emit_signal("energy_changed", current_energy, ENERGY_MAX)

# ── 방어 성공 콜백 ─────────────────────────────────
func on_parry_success():
	# ★ 에너지 +2 즉시 (최대 5 오버플로우)
	_add_energy(2.0)
	if current_energy > ENERGY_MAX:
		overflow_timer = OVERFLOW_DURATION

func on_dodge_success():
	# 에너지 +1 즉시
	_add_energy(1.0)

func on_guard_success(_block_val: int):
	# 에너지 +0.5
	_add_energy(0.5)

# ── 내부 에너지 가산 ───────────────────────────────
func _add_energy(amount: float):
	var prev = current_energy
	current_energy = min(float(ENERGY_OVERFLOW_MAX), current_energy + amount)
	if current_energy != prev:
		emit_signal("energy_changed", current_energy, ENERGY_MAX)

# ── 에너지 소비 (카드 플레이 시) ─────────────────────
func spend(amount: int) -> bool:
	if current_energy < amount:
		return false
	current_energy -= amount
	emit_signal("energy_changed", current_energy, ENERGY_MAX)
	return true

func can_afford(cost: int) -> bool:
	return current_energy >= cost

func get_current() -> int:
	return int(current_energy)

func reset():
	current_energy = ENERGY_MAX
	energy_timer = 0.0
	overflow_timer = 0.0
	emit_signal("energy_changed", current_energy, ENERGY_MAX)
