# scripts/combat/shared/CardEnhanceSystem.gd
# 카드 강화 시스템 — CURSOR_COMPLETE_DEV_GUIDE
# 같은 카드 2장 + 골드 → +1 강화 (100% 성공, 최대 +10)
class_name CardEnhanceSystem
extends RefCounted

const MAX_ENHANCEMENT_LEVEL: int = 10
# 강화 1회당 골드 비용 (레벨당 증가 가능)
const BASE_GOLD_COST: int = 100

## 강화 가능 여부: 대상 카드가 +10 미만이고, 동일 ID 카드가 2장 이상 있는지
static func can_enhance(target: Card, inventory: Array) -> bool:
	if target == null or target.enhancement_level >= MAX_ENHANCEMENT_LEVEL:
		return false
	var same_id_count: int = 0
	for c in inventory:
		if c is Card and c.id == target.id:
			same_id_count += 1
	return same_id_count >= 2

## 강화 비용: 같은 카드 2장 + 골드 (레벨당 BASE_GOLD_COST)
static func get_gold_cost(current_level: int) -> int:
	return BASE_GOLD_COST * (current_level + 1)

## 강화 실행: inventory에서 같은 ID 카드 2장 제거, target +1 강화. 골드는 호출측에서 차감.
## 반환: 성공 시 true
static func enhance(target: Card, inventory: Array, spend_gold: Callable) -> bool:
	if target == null or target.enhancement_level >= MAX_ENHANCEMENT_LEVEL:
		return false
	var same_cards: Array[Card] = []
	for c in inventory:
		if c is Card and c.id == target.id and c != target:
			same_cards.append(c)
			if same_cards.size() >= 2:
				break
	if same_cards.size() < 2:
		return false
	var gold_cost = get_gold_cost(target.enhancement_level)
	if spend_gold.is_valid() and not spend_gold.call(gold_cost):
		return false
	# 인벤토리에서 재료 2장 제거 (큰 인덱스부터 제거)
	var indices: Array[int] = [inventory.find(same_cards[0]), inventory.find(same_cards[1])]
	indices.sort()
	for i in range(indices.size() - 1, -1, -1):
		if indices[i] >= 0:
			inventory.remove_at(indices[i])
	return target.enhance()
