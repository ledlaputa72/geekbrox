# scripts/combat/shared/Monster.gd
# 몬스터 데이터 구조 — DEV_SPEC_SHARED.md 기반
class_name Monster
extends Node

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 50
@export var atk: int = 10
@export var base_atk: int = 10
@export var spd: float = 50.0      # ATB 속도 (높을수록 빠름)
@export var is_boss: bool = false
@export var sprite_path: String = ""
@export var action_patterns: Array[Dictionary] = []
# 패턴 예시:
# [{"type": "NORMAL", "damage_mult": 1.0},
#  {"type": "HEAVY",  "damage_mult": 2.0},
#  {"type": "DEFEND", "block": 8},
#  {"type": "BUFF",   "stat": "atk", "value": 3}]

# 런타임 상태
var current_hp: int = 0
var action_index: int = 0
var atb: float = 0.0
var block: int = 0
var status_effects: Dictionary = {}   # StatusType → stack_count
var atk_bonus: int = 0

func _ready():
	current_hp = max_hp

func is_alive() -> bool:
	return current_hp > 0

func hp_ratio() -> float:
	if max_hp <= 0: return 0.0
	return float(current_hp) / float(max_hp)

func take_damage(dmg: int):
	var actual = max(0, dmg - block)
	block = max(0, block - dmg)
	current_hp = max(0, current_hp - actual)

func add_block(amount: int):
	block += amount

func reset_block():
	block = 0

func heal(amount: int):
	current_hp = min(max_hp, current_hp + amount)

func get_next_action() -> Dictionary:
	if action_patterns.is_empty():
		return {"type": "NORMAL", "damage_mult": 1.0}
	return action_patterns[action_index % action_patterns.size()]

func advance_action():
	action_index += 1

# 행동 큐 (턴베이스 의도 표시용)
func get_action_queue(count: int = 3) -> Array[Dictionary]:
	var queue: Array[Dictionary] = []
	if action_patterns.is_empty():
		for i in range(count):
			queue.append({"type": "NORMAL", "damage_mult": 1.0})
		return queue
	for i in range(count):
		var idx = (action_index + i) % action_patterns.size()
		queue.append(action_patterns[idx])
	return queue

var action_queue: Array:
	get:
		return get_action_queue(3)

func get_next_damage() -> int:
	var action = get_next_action()
	if action.get("type") in ["NORMAL", "HEAVY", "UNBLOCKABLE"]:
		return int((atk + atk_bonus) * action.get("damage_mult", 1.0))
	return 0

func has_status(status_name: String) -> bool:
	return status_effects.has(status_name) and status_effects[status_name] > 0

# 몬스터 AttackData 생성 헬퍼
func make_attack_data() -> Dictionary:
	var action = get_next_action()
	var damage_mult = action.get("damage_mult", 1.0)
	return {
		"type": action.get("type", "NORMAL"),
		"damage": int((atk + atk_bonus) * damage_mult),
		"attacker": self,
		"block": action.get("block", 0),
	}
