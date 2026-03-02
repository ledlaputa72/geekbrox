# scripts/combat/atb/ATBComboSystem.gd
# 드림 콤보 판정 — DEV_SPEC_ATB.md 기반
class_name ATBComboSystem
extends Node

# ── 콤보 시퀀스 버퍼 ─────────────────────────────────
var card_history : Array[Card] = []  # 최근 5장 기록
const HISTORY_MAX = 5

signal combo_triggered(combo_name: String, bonus_percent: int)
signal combo_hint_updated(hint: String)

# ── 콤보 정의 ─────────────────────────────────────────
# (callable 대신 직접 메서드 호출로 Godot 4 호환성 확보)
const COMBO_NAMES = ["연타", "완벽한 방어", "패링 반격", "약점 폭로"]
const COMBO_VFX   = ["combo_triple", "combo_perfect_guard", "combo_counter", "combo_expose"]
const COMBO_SFX   = ["combo_hit3", "combo_guard", "combo_counter_hit", "combo_expose_hit"]
const COMBO_BONUS = [75, 10, 30, 50]  # 데미지 보너스 퍼센트 (완벽한 방어: 블록 +10)

# ── 카드 등록 ─────────────────────────────────────────
func register_card(card: Card):
	card_history.append(card)
	if card_history.size() > HISTORY_MAX:
		card_history.pop_front()
	_update_hint()

# ── 콤보 보너스 적용 ─────────────────────────────────
func apply_combo_bonus(base_damage: int) -> int:
	var combo_idx = _check_combo()
	if combo_idx < 0:
		return base_damage

	var combo_name = COMBO_NAMES[combo_idx]
	var bonus_pct  = COMBO_BONUS[combo_idx]

	print("[ATBCombo] 콤보! %s (+%d%%)" % [combo_name, bonus_pct])
	emit_signal("combo_triggered", combo_name, bonus_pct)

	return int(base_damage * (1.0 + bonus_pct / 100.0))

func _check_combo() -> int:
	# 콤보 판정은 register_card 이후에 호출되므로 card_history에 현재 카드 포함됨
	# 0: 연타 — ATK 3연속
	if _last_n_type(card_history, 3, "ATK"):
		return 0
	# 2: 패링 반격 — PARRY 후 ATK
	if _last_parry_then_atk(card_history):
		return 2
	# 3: 약점 폭로 — VULNERABLE 디버프 후 ATK
	if _last_vulnerable_then_atk(card_history):
		return 3
	# 1: 완벽한 방어 — DEF 2연속 (방어 카드에서도 콤보 발동)
	if _last_n_type(card_history, 2, "DEF"):
		return 1
	return -1

func _update_hint():
	var hint = _get_next_combo_hint()
	emit_signal("combo_hint_updated", hint)

func _get_next_combo_hint() -> String:
	if _last_n_type(card_history, 2, "ATK"):
		return "공격 1장 더 → 연타 콤보! (+75%)"
	if card_history.size() >= 1 and card_history[-1].has_tag("PARRY"):
		return "공격 카드 → 패링 반격 콤보! (+30%)"
	if _last_n_type(card_history, 1, "DEF"):
		return "방어 1장 더 → 완벽한 방어!"
	return ""

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
		if eff.get("type", "") == "VULNERABLE": has_vuln = true
	return has_vuln and history[-1].type == "ATK"

func reset():
	card_history.clear()

func get_next_combo_hint() -> String:
	return _get_next_combo_hint()
