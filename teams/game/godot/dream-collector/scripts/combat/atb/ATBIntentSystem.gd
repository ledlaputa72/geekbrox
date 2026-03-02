# scripts/combat/atb/ATBIntentSystem.gd
# 적 행동 예고 시스템 — DEV_SPEC_ATB.md 기반
class_name ATBIntentSystem
extends Node

# ── 의도 아이콘 매핑 ──────────────────────────────────
const INTENT_ICONS = {
	"NORMAL":      "⚔️",
	"HEAVY":       "⚔️⚠️",
	"AOE":         "🌀",
	"UNBLOCKABLE": "🔱",
	"BUFF":        "✨",
	"DEFEND":      "🛡️",
	"REST":        "💤",
}

const INTENT_COLORS = {
	"NORMAL":      Color.WHITE,
	"HEAVY":       Color.ORANGE,
	"AOE":         Color.YELLOW,
	"UNBLOCKABLE": Color.RED,
	"BUFF":        Color.CYAN,
	"DEFEND":      Color(0.5, 0.8, 1.0),
	"REST":        Color.GRAY,
}

# 등록된 적 목록
var registered_enemies: Array = []

# UI 참조 (있을 경우)
var intent_ui = null

signal intent_updated(enemy, icon: String, value: int, color: Color)
signal danger_level_changed(enemy, level: int)  # 0=일반, 1=강조, 2=경고, 3=위험

func register_enemy(enemy):
	if not registered_enemies.has(enemy):
		registered_enemies.append(enemy)

func unregister_enemy(enemy):
	registered_enemies.erase(enemy)

# ── ATB 연동 예고 강도 업데이트 ───────────────────────
func update_intent_display(enemy):
	var atb_pct = 0.0
	if "atb" in enemy:
		atb_pct = enemy.atb / 100.0

	var action = {}
	if enemy.has_method("get_next_action"):
		action = enemy.get_next_action()

	var attack_type = action.get("type", "NORMAL")
	var damage = _get_action_damage(enemy, action)
	var icon  = INTENT_ICONS.get(attack_type, "❓")
	var color = INTENT_COLORS.get(attack_type, Color.WHITE)

	var danger_level = 0
	if atb_pct >= 0.95:
		danger_level = 3
	elif atb_pct >= 0.8:
		danger_level = 2
	elif atb_pct >= 0.6:
		danger_level = 1

	emit_signal("intent_updated", enemy, icon, damage, color)
	emit_signal("danger_level_changed", enemy, danger_level)

func announce_attack(attack: Dictionary):
	# 공격 실행 직전 마지막 알림
	var attack_type = attack.get("type", "NORMAL")
	if attack_type == "HEAVY":
		print("[ATBIntent] ⚠️ 강한 공격!")
	elif attack_type == "UNBLOCKABLE":
		print("[ATBIntent] 🔱 방어 불가! 회피하세요!")

func advance_pattern(enemy):
	if enemy.has_method("advance_action"):
		enemy.advance_action()
	update_intent_display(enemy)

func _get_action_damage(enemy, action: Dictionary) -> int:
	var base_atk = enemy.atk if "atk" in enemy else 10
	var bonus = enemy.atk_bonus if "atk_bonus" in enemy else 0
	var mult = action.get("damage_mult", 1.0)
	return int((base_atk + bonus) * mult)

func clear_all():
	registered_enemies.clear()
