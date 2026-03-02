# scripts/combat/turnbased/TurnBasedIntentSystem.gd
# 적의 다음 2~3 행동을 미리 공개 — DEV_SPEC_TURNBASED.md 기반
class_name TurnBasedIntentSystem
extends Node

# ── 아이콘 매핑 ──────────────────────────────────────
const ICONS = {
	"NORMAL":      {"icon": "⚔️",    "color": Color.WHITE},
	"HEAVY":       {"icon": "⚔️⚠️",  "color": Color.ORANGE},
	"AOE":         {"icon": "🌀",    "color": Color.YELLOW},
	"UNBLOCKABLE": {"icon": "🔱",    "color": Color.RED},
	"BUFF":        {"icon": "✨",    "color": Color.CYAN},
	"DEFEND":      {"icon": "🛡️",   "color": Color(0.5, 0.8, 1.0)},
	"REST":        {"icon": "💤",    "color": Color.GRAY},
}

signal intent_displayed(enemy, actions: Array)
signal current_action_highlighted(enemy)

# ── 모든 적 의도 표시 ─────────────────────────────────
func display_all_enemies():
	for enemy in _get_alive_enemies():
		display_intent(enemy)

func _get_alive_enemies() -> Array:
	# CombatManagerTB에서 적 목록을 받아야 하므로, 부모 노드에서 참조
	var parent = get_parent()
	if parent and "enemies" in parent:
		return parent.enemies.filter(func(e): return e.is_alive())
	return []

func display_intent(enemy):
	# 다음 2~3행동 예고
	var upcoming: Array = []
	if enemy.has_method("get_action_queue"):
		upcoming = enemy.get_action_queue(3)
	elif "action_queue" in enemy:
		upcoming = enemy.action_queue

	var action_data = []
	for i in range(min(3, upcoming.size())):
		var action = upcoming[i]
		var attack_type = action.get("type", "NORMAL")
		var info = ICONS.get(attack_type, {"icon": "❓", "color": Color.WHITE})
		var base_atk = enemy.atk if "atk" in enemy else 10
		var bonus = enemy.atk_bonus if "atk_bonus" in enemy else 0
		var dmg = int((base_atk + bonus) * action.get("damage_mult", 1.0))
		action_data.append({
			"icon": info["icon"],
			"color": info["color"],
			"damage": dmg,
			"type": attack_type,
			"is_current": (i == 0),
		})

	emit_signal("intent_displayed", enemy, action_data)

func highlight_current(enemy):
	emit_signal("current_action_highlighted", enemy)
	print("[TBIntent] 적 행동 시작: %s" % (enemy.display_name if "display_name" in enemy else "적"))

func advance(enemy):
	if enemy.has_method("advance_action"):
		enemy.advance_action()
	display_intent(enemy)
	# ★ OPS 피드백: 의도 전환 시 슬라이드 애니메이션 (UI에서 처리)
	print("[TBIntent] 의도 갱신")
