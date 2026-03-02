# scripts/combat/turnbased/TurnBasedEnergySystem.gd
# 턴베이스 에너지 — 전투 시작 3에너지, 매 턴마다 새로 3 (시간 충전 없음)
class_name TurnBasedEnergySystem
extends Node

# ── 상수 ─────────────────────────────────────────────
const BASE_ENERGY   = 3     # 전투 시작 + 매 턴 시작 시 기본 3 (ATB/턴베이스 공통)
const PARRY_BONUS   = 2     # 패링 성공 → 다음 턴 +2
const DODGE_BONUS   = 1     # 회피 성공 → 다음 턴 +1
const OVERFLOW_MAX  = 5     # 보너스 합산 최대

# ── 상태 변수 ─────────────────────────────────────────
var current_energy       : int = 3
var pending_energy_bonus : int = 0  # 적 턴 방어로 적립된 다음 턴 보너스

signal energy_changed(current: int, base: int)
signal bonus_preview_updated(bonus: int, color: Color)

func _ready():
	current_energy = BASE_ENERGY

# ── 플레이어 턴 시작 시 호출 ─────────────────────────
func start_player_turn():
	var total = min(OVERFLOW_MAX, BASE_ENERGY + pending_energy_bonus)
	current_energy = total
	pending_energy_bonus = 0
	emit_signal("energy_changed", current_energy, BASE_ENERGY)

	# ★ OPS 피드백: 획득한 에너지가 기본보다 많으면 강조 표시
	if current_energy > BASE_ENERGY:
		print("[TBEnergy] 보너스 에너지 획득! 현재: %d" % current_energy)

# ── 방어 성공 콜백 (적 턴 중 호출) ──────────────────
func on_parry_success():
	pending_energy_bonus += PARRY_BONUS
	# ★ OPS 피드백: 다음 턴 에너지 미리보기 표시 (즉시)
	emit_signal("bonus_preview_updated", pending_energy_bonus, Color(1.0, 0.84, 0.0))  # 금색
	print("[TBEnergy] 패링! 다음 턴 에너지 +%d 예약" % pending_energy_bonus)

func on_dodge_success():
	pending_energy_bonus += DODGE_BONUS
	emit_signal("bonus_preview_updated", pending_energy_bonus, Color(0.4, 0.8, 1.0))  # 하늘색
	print("[TBEnergy] 회피! 다음 턴 에너지 +%d 예약" % pending_energy_bonus)

# ── 에너지 사용 ──────────────────────────────────────
func spend(amount: int) -> bool:
	if amount < 0:
		# 음수 = 에너지 추가 (DreamShardSystem용)
		current_energy = min(OVERFLOW_MAX, current_energy - amount)
		emit_signal("energy_changed", current_energy, BASE_ENERGY)
		return true
	if current_energy < amount:
		return false
	current_energy -= amount
	emit_signal("energy_changed", current_energy, BASE_ENERGY)
	return true

func can_afford(amount: int) -> bool:
	if amount < 0:
		return true
	return current_energy >= amount

func get_current() -> int:
	return current_energy

func get_pending_bonus() -> int:
	return pending_energy_bonus

func reset():
	current_energy = BASE_ENERGY
	pending_energy_bonus = 0
	emit_signal("energy_changed", current_energy, BASE_ENERGY)
