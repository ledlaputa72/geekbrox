# scripts/combat/shared/EquipmentEnhanceSystem.gd
# 장비 강화 시스템 — CURSOR_COMPLETE_DEV_GUIDE
# 같은 장비 2개 + 골드 → +1 강화 (100% 성공, 최대 +10)
class_name EquipmentEnhanceSystem
extends RefCounted

const MAX_ENHANCEMENT_LEVEL: int = 10
const BASE_GOLD_COST: int = 150  # 강화 1회당 기본 골드 (레벨당 증가)

static func can_enhance(target: Equipment, inventory: Array) -> bool:
	if target == null or target.enhancement_level >= MAX_ENHANCEMENT_LEVEL:
		return false
	var same_count: int = 0
	for item in inventory:
		if item is Equipment and item.id == target.id:
			same_count += 1
	return same_count >= 2

static func get_gold_cost(current_level: int) -> int:
	return BASE_GOLD_COST * (current_level + 1)

## 강화 실행. inventory에서 같은 id 장비 2개 제거, target +1 강화. 골드는 spend_gold(gold_cost)로 차감.
static func enhance(target: Equipment, inventory: Array, spend_gold: Callable) -> bool:
	if target == null or target.enhancement_level >= MAX_ENHANCEMENT_LEVEL:
		return false
	var same: Array[Equipment] = []
	for item in inventory:
		if item is Equipment and item.id == target.id and item != target:
			same.append(item)
			if same.size() >= 2:
				break
	if same.size() < 2:
		return false
	var gold_cost = get_gold_cost(target.enhancement_level)
	if spend_gold.is_valid() and not spend_gold.call(gold_cost):
		return false
	var indices: Array[int] = [inventory.find(same[0]), inventory.find(same[1])]
	indices.sort()
	for i in range(indices.size() - 1, -1, -1):
		if indices[i] >= 0:
			inventory.remove_at(indices[i])
	return target.enhance()
