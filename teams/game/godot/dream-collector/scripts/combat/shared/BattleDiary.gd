# scripts/combat/shared/BattleDiary.gd
# 전투 일지 — DEV_SPEC_SHARED.md 기반
class_name BattleDiary
extends Node

var stats: Dictionary = {
	"start_time": 0,
	"parry_attempts": 0,
	"parry_successes": 0,
	"dodge_successes": 0,
	"combos_triggered": 0,
	"best_combo_name": "",
	"total_damage_dealt": 0,
	"total_damage_taken": 0,
	"cards_played": 0,
	"turns_played": 0,
	"shards_gained": 0,
	"tarot_used": 0,
}

var log_entries: Array[String] = []

func start():
	stats = {
		"start_time": Time.get_ticks_msec(),
		"parry_attempts": 0,
		"parry_successes": 0,
		"dodge_successes": 0,
		"combos_triggered": 0,
		"best_combo_name": "",
		"total_damage_dealt": 0,
		"total_damage_taken": 0,
		"cards_played": 0,
		"turns_played": 0,
		"shards_gained": 0,
		"tarot_used": 0,
	}
	log_entries.clear()

func record_parry(success: bool):
	stats["parry_attempts"] += 1
	if success:
		stats["parry_successes"] += 1

func record_dodge():
	stats["dodge_successes"] += 1

func record_combo(combo_name: String):
	stats["combos_triggered"] += 1
	stats["best_combo_name"] = combo_name

func record_damage_dealt(amount: int):
	stats["total_damage_dealt"] += amount

func record_damage_taken(amount: int):
	stats["total_damage_taken"] += amount

func record_card_played():
	stats["cards_played"] += 1

func record_turn():
	stats["turns_played"] += 1

func record_shard_gained():
	stats["shards_gained"] += 1

func record_tarot_used():
	stats["tarot_used"] += 1

func log(message: String):
	log_entries.append("[%s] %s" % [_get_timestamp(), message])
	print("[BattleDiary] %s" % message)

func _get_timestamp() -> String:
	var elapsed = (Time.get_ticks_msec() - stats["start_time"]) / 1000.0
	return "%.1fs" % elapsed

func compile_report() -> Dictionary:
	var duration = (Time.get_ticks_msec() - stats["start_time"]) / 1000.0
	var parry_rate = 0.0
	if stats["parry_attempts"] > 0:
		parry_rate = float(stats["parry_successes"]) / stats["parry_attempts"]
	return {
		"duration": duration,
		"parry_rate": parry_rate,
		"parry_attempts": stats["parry_attempts"],
		"parry_successes": stats["parry_successes"],
		"dodge_successes": stats["dodge_successes"],
		"combos": stats["combos_triggered"],
		"best_combo": stats["best_combo_name"],
		"cards_played": stats["cards_played"],
		"turns_played": stats["turns_played"],
		"damage_dealt": stats["total_damage_dealt"],
		"damage_taken": stats["total_damage_taken"],
		"shards_gained": stats["shards_gained"],
		"tarot_used": stats["tarot_used"],
		"tip": _generate_tip(parry_rate),
	}

func _generate_tip(parry_rate: float) -> String:
	if parry_rate < 0.4:
		return "패링 카드를 더 활용해보세요! 성공 시 에너지가 즉시 +2 충전돼요."
	if stats["combos_triggered"] == 0:
		return "공격 카드 3장을 연속으로 쓰면 콤보가 발동해요! 데미지 +75%!"
	return "완벽한 전투였어요! 🌟"

func get_log() -> Array[String]:
	return log_entries
