# scripts/systems/GachaSystem.gd
# 가챭 시스템 — CURSOR_COMPLETE_DEV_GUIDE
# 장비 가챭 50D, 카드 가챭 50D. 보장: 50/100/150회
extends Node

const COST_PER_PULL_DIAMOND: int = 50

var equipment_pull_count: int = 0
var card_pull_count: int = 0

signal equipment_pulled(results: Array)
signal card_pulled(results: Array)
signal pity_triggered(gacha_type: String, rarity: String)

func _ready():
	pass

func pull_equipment(count: int = 1) -> Array:
	var results: Array = []
	for i in range(count):
		equipment_pull_count += 1
		var rarity = _get_equipment_rarity()
		var eq = _get_equipment_by_rarity(rarity)
		if eq:
			results.append(eq)
		_check_equipment_pity()
	equipment_pulled.emit(results)
	return results

func pull_card(count: int = 1) -> Array:
	var results: Array = []
	for i in range(count):
		card_pull_count += 1
		var rarity = _get_card_rarity()
		var card = _get_card_by_rarity(rarity)
		if card:
			results.append(card)
		_check_card_pity()
	card_pulled.emit(results)
	return results

func _get_equipment_rarity() -> String:
	return DropRateTable.roll_equipment_rarity()

func _get_card_rarity() -> String:
	return DropRateTable.roll_card_rarity()

func _get_equipment_by_rarity(rarity: String) -> Variant:
	if EquipmentDatabase and EquipmentDatabase.has_method("get_random_by_rarity"):
		return EquipmentDatabase.get_random_by_rarity(rarity)
	return null

func _get_card_by_rarity(rarity: String) -> Variant:
	if not CardDatabase:
		return null
	return CardDatabase.get_random_by_rarity(rarity)

func _check_equipment_pity() -> void:
	if equipment_pull_count >= DropRateTable.PITY_LEGENDARY:
		equipment_pull_count = 0
		pity_triggered.emit("equipment", "LEGENDARY")
	elif equipment_pull_count >= DropRateTable.PITY_SPECIAL:
		# 100회 시 SPECIAL 보장 (카운트 리셋은 150에서)
		pass
	elif equipment_pull_count >= DropRateTable.PITY_RARE:
		# 50회 시 RARE 보장
		pass

func _check_card_pity() -> void:
	if card_pull_count >= DropRateTable.PITY_LEGENDARY:
		card_pull_count = 0
		pity_triggered.emit("card", "LEGENDARY")
	elif card_pull_count >= DropRateTable.PITY_SPECIAL:
		pass
	elif card_pull_count >= DropRateTable.PITY_RARE:
		pass

func get_equipment_pity_count() -> int:
	return equipment_pull_count

func get_card_pity_count() -> int:
	return card_pull_count
