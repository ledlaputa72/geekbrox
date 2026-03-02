# scripts/combat/turnbased/TarotEnergySystem.gd
# 타로 에너지 — 메이저 아르카나 카드 사용 시 충전 — DEV_SPEC_TURNBASED.md 기반
class_name TarotEnergySystem
extends Node

const TAROT_MAX = 3

var tarot_energy : int = 0

signal tarot_energy_changed(current: int, max_e: int)
signal tarot_spent(cost: int)

func _ready():
	tarot_energy = 0

func on_card_played(card: Card):
	if card.is_major_arcana():
		tarot_energy = min(TAROT_MAX, tarot_energy + 1)
		emit_signal("tarot_energy_changed", tarot_energy, TAROT_MAX)
		print("[TarotEnergy] 타로 에너지 충전! 현재: %d/%d" % [tarot_energy, TAROT_MAX])

# ── 타로 카드 스킬 소비 ────────────────────────────────
# "달의 환영"   — 비용: 타로×2  — 드로우3 + 다음 턴 에너지 +1
# "태양의 폭발" — 비용: 타로×3  — 전체 적 30 데미지 + 디버프 제거
# "심판의 날"   — 비용: 타로×2  — 가장 HP 낮은 적에 HP 40% 피해

func spend_tarot(cost: int) -> bool:
	if tarot_energy < cost:
		print("[TarotEnergy] 타로 에너지 부족! (%d/%d)" % [tarot_energy, cost])
		return false
	tarot_energy -= cost
	emit_signal("tarot_energy_changed", tarot_energy, TAROT_MAX)
	emit_signal("tarot_spent", cost)
	return true

func can_afford_tarot(cost: int) -> bool:
	return tarot_energy >= cost

func add_tarot(amount: int = 1):
	tarot_energy = min(TAROT_MAX, tarot_energy + amount)
	emit_signal("tarot_energy_changed", tarot_energy, TAROT_MAX)

func reset():
	tarot_energy = 0
	emit_signal("tarot_energy_changed", tarot_energy, TAROT_MAX)

func get_current() -> int:
	return tarot_energy
