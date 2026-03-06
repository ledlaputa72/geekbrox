# scripts/systems/DropRateTable.gd
# 가챭 확률 테이블 — CURSOR_COMPLETE_DEV_GUIDE, GACHA_ENHANCEMENT_FINAL_SIMPLIFIED
class_name DropRateTable
extends RefCounted

# 장비 가챭: 55% COMMON, 30% RARE, 13% SPECIAL, 2% LEGENDARY
const EQUIPMENT_RATES: Dictionary = {
	"COMMON": 55,
	"RARE": 30,
	"SPECIAL": 13,
	"LEGENDARY": 2,
}

# 카드 가챭: 45% COMMON, 35% RARE, 15% SPECIAL, 5% LEGENDARY
const CARD_RATES: Dictionary = {
	"COMMON": 45,
	"RARE": 35,
	"SPECIAL": 15,
	"LEGENDARY": 5,
}

# 보장: 50회 RARE, 100회 SPECIAL, 150회 LEGENDARY
const PITY_RARE: int = 50
const PITY_SPECIAL: int = 100
const PITY_LEGENDARY: int = 150

static func roll_equipment_rarity() -> String:
	var r = randf() * 100.0
	if r < 55: return "COMMON"
	if r < 85: return "RARE"
	if r < 98: return "SPECIAL"
	return "LEGENDARY"

static func roll_card_rarity() -> String:
	var r = randf() * 100.0
	if r < 45: return "COMMON"
	if r < 80: return "RARE"
	if r < 95: return "SPECIAL"
	return "LEGENDARY"
