# scripts/combat/shared/StatusEffectSystem.gd
# 상태이상 시스템 — DEV_SPEC_SHARED.md 기반
class_name StatusEffectSystem
extends Node

enum StatusType {
	POISON,       # 중독: 매 턴 HP 감소
	VULNERABLE,   # 취약: 받는 피해 +50%
	WEAK,         # 약화: 주는 피해 -25%
	STRENGTH,     # 힘: 공격력 증가 (영구)
	DEXTERITY,    # 민첩: 블록 획득량 증가 (영구)
	BURNING,      # 화상: 중독과 유사, 별도 스택
	ENTANGLED,    # 묶음: 이번 턴 공격 불가
	HEAL          # 치유: 즉발 HP 회복 (스택 = 회복량)
}

const STATUS_MAP = {
	"POISON": StatusType.POISON,
	"VULNERABLE": StatusType.VULNERABLE,
	"WEAK": StatusType.WEAK,
	"STRENGTH": StatusType.STRENGTH,
	"DEXTERITY": StatusType.DEXTERITY,
	"BURNING": StatusType.BURNING,
	"ENTANGLED": StatusType.ENTANGLED,
	"HEAL": StatusType.HEAL,
}

var statuses: Dictionary = {}  # StatusType → stack_count

# 오너 엔티티 참조 (Monster or player Dictionary)
var owner_entity = null

func _ready():
	statuses = {}

func apply(type, stacks: int):
	var status_type = _resolve_type(type)
	statuses[status_type] = statuses.get(status_type, 0) + stacks
	if statuses[status_type] <= 0:
		statuses.erase(status_type)

func remove(type, stacks: int = 999):
	var status_type = _resolve_type(type)
	if statuses.has(status_type):
		statuses[status_type] = max(0, statuses[status_type] - stacks)
		if statuses[status_type] <= 0:
			statuses.erase(status_type)

func has_status(type) -> bool:
	var status_type = _resolve_type(type)
	return statuses.has(status_type) and statuses[status_type] > 0

func get_stacks(type) -> int:
	var status_type = _resolve_type(type)
	return statuses.get(status_type, 0)

func tick_turn():
	# DoT: POISON
	if statuses.has(StatusType.POISON):
		var dmg = statuses[StatusType.POISON]
		if owner_entity and owner_entity.has_method("take_damage"):
			owner_entity.take_damage(dmg)
		statuses[StatusType.POISON] -= 1
		if statuses[StatusType.POISON] <= 0:
			statuses.erase(StatusType.POISON)

	# DoT: BURNING
	if statuses.has(StatusType.BURNING):
		var dmg = statuses[StatusType.BURNING]
		if owner_entity and owner_entity.has_method("take_damage"):
			owner_entity.take_damage(dmg)
		statuses[StatusType.BURNING] -= 1
		if statuses[StatusType.BURNING] <= 0:
			statuses.erase(StatusType.BURNING)

	# 턴 기반 디버프 감소: VULNERABLE, WEAK
	if statuses.has(StatusType.VULNERABLE):
		statuses[StatusType.VULNERABLE] -= 1
		if statuses[StatusType.VULNERABLE] <= 0:
			statuses.erase(StatusType.VULNERABLE)

	if statuses.has(StatusType.WEAK):
		statuses[StatusType.WEAK] -= 1
		if statuses[StatusType.WEAK] <= 0:
			statuses.erase(StatusType.WEAK)

	# ENTANGLED: 1턴 지속
	if statuses.has(StatusType.ENTANGLED):
		statuses.erase(StatusType.ENTANGLED)

func get_damage_multiplier() -> float:
	var mult = 1.0
	if statuses.has(StatusType.VULNERABLE):
		mult *= 1.5
	return mult

func get_outgoing_multiplier() -> float:
	var mult = 1.0
	if statuses.has(StatusType.WEAK):
		mult *= 0.75
	return mult

func get_strength_bonus() -> int:
	return statuses.get(StatusType.STRENGTH, 0)

func get_dexterity_bonus() -> int:
	return statuses.get(StatusType.DEXTERITY, 0)

func clear_all():
	statuses.clear()

func _resolve_type(type) -> StatusType:
	if type is StatusType or type is int:
		return type as StatusType
	if type is String:
		if STATUS_MAP.has(type):
			return STATUS_MAP[type]
		push_warning("[StatusEffectSystem] Unknown status type string: '%s'" % type)
		return StatusType.POISON
	push_warning("[StatusEffectSystem] Invalid status type: %s" % str(type))
	return StatusType.POISON

static func apply_to(target, type, stacks: int):
	if target == null:
		return
	# HEAL은 즉발 효과 — status_effects에 저장하지 않고 바로 처리
	var type_str = type if type is String else StatusType.keys()[type] if type is int and type < StatusType.size() else str(type)
	if type_str == "HEAL":
		if target.has_method("heal"):
			target.heal(stacks)
		elif target is Dictionary and "hp" in target:
			var max_hp = target.get("max_hp", 200)
			target["hp"] = mini(max_hp, target.get("hp", 0) + stacks)
		return
	if target.has_method("apply_status"):
		target.apply_status(type, stacks)
	elif "status_effects" in target:
		var key = type if type is String else StatusType.keys()[type] if type is int and type < StatusType.size() else str(type)
		target.status_effects[key] = target.status_effects.get(key, 0) + stacks
