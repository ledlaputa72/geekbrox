# scripts/systems/LevelSystem.gd
# 성장 시스템 — CURSOR_COMPLETE_DEV_GUIDE, PROGRESSION_SYSTEM_REDESIGNED
# 무한 Lv (1~1000+), 필요 EXP = 100 × (Lv^1.2), 자동 스탯 배분
class_name LevelSystem
extends RefCounted

var current_level: int = 1
var current_exp: float = 0.0
var total_atk: float = 15.0
var total_def: float = 10.0
var total_hp: float = 100.0
var total_spd: float = 3.0

signal level_changed(new_level: int)

func get_required_exp() -> float:
	"""필요 경험치: 100 × (현재 레벨^1.2)"""
	return 100.0 * pow(current_level, 1.2)

func add_exp(amount: float) -> void:
	current_exp += amount
	while current_exp >= get_required_exp():
		level_up()

func level_up() -> void:
	var required = get_required_exp()
	current_level += 1
	current_exp -= required
	total_atk += 1.5
	total_def += 1.0
	total_hp += 5.0
	total_spd += 0.3
	level_changed.emit(current_level)
	# 마일스톤은 LevelSystem.level_changed에 연결된 MilestoneRewardSystem.trigger_milestone에서 처리
