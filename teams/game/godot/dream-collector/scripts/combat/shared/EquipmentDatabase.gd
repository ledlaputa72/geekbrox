# scripts/combat/shared/EquipmentDatabase.gd
# 장비 66종 — CURSOR_COMPLETE_DEV_GUIDE + CHARACTER_EQUIPMENT_SYSTEM
extends Node

var _by_id: Dictionary = {}   # id (int) → Equipment
var _by_slot: Dictionary = {}  # slot → Array[Equipment]
var _by_rarity: Dictionary = {} # rarity → Array[Equipment]

func _ready():
	_build_all()

func _build_all() -> void:
	_by_id.clear()
	_by_slot = { "WEAPON": [], "ARMOR": [], "ACCESSORY": [], "OFF_HAND": [] }
	_by_rarity = { "COMMON": [], "RARE": [], "SPECIAL": [], "LEGENDARY": [] }
	var id_num = 1
	# WEAPON 18: 검6, 도끼6, 지팡이6
	# 형식: [atk, def, hp, spd, name_ko, name_en, rarity, cri(%)]
	var weapons = [
		[10, 0, 0,   0, "검의 파편",   "Fragment Blade",   "COMMON",    0.0],
		[15, 0, 0,   0, "철 검",       "Iron Sword",       "COMMON",    2.0],
		[20, 0, 0,   5, "강철 검",     "Steel Sword",      "RARE",      5.0],
		[25, 0, 0,   5, "은색 검",     "Silver Sword",     "RARE",      8.0],
		[22, 0, 0,  10, "마검사의 검", "Mage Slayer",      "SPECIAL",  10.0],
		[30, 0, 0,  15, "빛의 검",     "Blade of Light",   "LEGENDARY",15.0],
		[12, 0, 0, -10, "도끼의 파편", "Fragment Axe",     "COMMON",    5.0],
		[18, 0, 0, -10, "철 도끼",     "Iron Axe",         "COMMON",    8.0],
		[25, 0, 0,  -5, "전투 도끼",   "Battle Axe",       "RARE",     12.0],
		[32, 0, 0, -15, "거대 도끼",   "Great Axe",        "RARE",     15.0],
		[35, 0, 0, -10, "용의 도끼",   "Dragon Axe",       "SPECIAL",  20.0],
		[40, 0, 0, -20, "저주의 도끼", "Cursed Axe",       "LEGENDARY",25.0],
		[ 8, 0, 0,  15, "마법의 지팡이","Magic Staff",     "COMMON",    5.0],
		[12, 0, 0,  15, "나무 지팡이", "Wooden Staff",     "COMMON",    8.0],
		[15, 0, 0,  20, "신성한 지팡이","Holy Staff",      "RARE",     10.0],
		[18, 0, 0,  25, "마력 지팡이", "Mana Staff",       "RARE",     12.0],
		[22, 0, 0,  30, "별의 지팡이", "Star Staff",       "SPECIAL",  15.0],
		[25, 0, 0,  35, "차원 지팡이", "Dimensional Staff","LEGENDARY",20.0],
	]
	for w in weapons:
		var cri_val: float = w[7] if w.size() > 7 else 0.0
		var e = _make_equip(id_num, w[5], w[4], "WEAPON", w[6], w[0], w[1], w[2], w[3], cri_val)
		_register(e)
		id_num += 1
	# ARMOR 18: 갑옷6, 로브6, 경갑6
	var armors = [
		[0, 2, 30, 0, "천 옷", "Cloth Armor", "COMMON"],
		[0, 5, 50, 0, "가죽 옷", "Leather Armor", "COMMON"],
		[0, 10, 80, 0, "청동 가슴판", "Bronze Plate", "RARE"],
		[0, 15, 150, 0, "강철 갑옷", "Steel Plate", "RARE"],
		[0, 20, 200, 0, "용의 비늘", "Dragon Scale", "SPECIAL"],
		[0, 25, 250, 0, "신성한 갑옷", "Holy Plate", "LEGENDARY"],
		[0, 3, 40, 0, "일반 로브", "Common Robe", "COMMON"],
		[0, 5, 60, 0, "수련자 로브", "Apprentice Robe", "COMMON"],
		[0, 8, 100, 0, "마법사 로브", "Mage Robe", "RARE"],
		[0, 12, 150, 0, "신비로운 로브", "Mystical Robe", "RARE"],
		[0, 15, 180, 0, "차원 로브", "Dimensional Robe", "SPECIAL"],
		[0, 18, 200, 0, "별의 로브", "Star Robe", "LEGENDARY"],
		[0, 4, 60, 0, "경갑", "Light Armor", "COMMON"],
		[0, 6, 80, 0, "추격자 갑옷", "Pursuer Suit", "COMMON"],
		[0, 9, 120, 0, "사냥꾼 옷", "Hunter Suit", "RARE"],
		[0, 12, 140, 0, "그림자 옷", "Shadow Suit", "RARE"],
		[0, 14, 160, 0, "도적 옷", "Rogue Suit", "SPECIAL"],
		[0, 16, 180, 0, "환상의 옷", "Phantom Suit", "LEGENDARY"],
	]
	for a in armors:
		var e = _make_equip(id_num, a[5], a[4], "ARMOR", a[6], a[0], a[1], a[2], a[3])
		_register(e)
		id_num += 1
	# ACCESSORY 15: 반지5, 팔찌5, 신발5
	var accessories = [
		[3, 0, 0, 0, "철 반지", "Iron Ring", "COMMON"],
		[5, 0, 0, 0, "흡혈 반지", "Vampire Ring", "RARE"],
		[0, 5, 0, 0, "방어의 반지", "Defense Ring", "RARE"],
		[0, 0, 0, 20, "속도의 반지", "Speed Ring", "SPECIAL"],
		[10, 3, 0, 10, "왕의 반지", "Royal Ring", "LEGENDARY"],
		[0, 2, 0, 0, "가죽 팔찌", "Leather Bracelet", "COMMON"],
		[2, 0, 0, 0, "공격 팔찌", "Attack Bracelet", "COMMON"],
		[0, 8, 0, 0, "방어의 팔찌", "Defense Bracelet", "RARE"],
		[0, 0, 50, 0, "생명 팔찌", "Life Bracelet", "RARE"],
		[5, 5, 0, 15, "균형 팔찌", "Balance Bracelet", "SPECIAL"],
		[0, 0, 0, 10, "민첩 신발", "Agility Boots", "COMMON"],
		[0, 3, 0, 5, "방어 신발", "Defense Boots", "COMMON"],
		[0, 0, 0, 25, "속도의 신발", "Speed Boots", "RARE"],
		[0, 0, 30, 15, "전투 신발", "Battle Boots", "RARE"],
		[5, 5, 50, 20, "영웅 신발", "Hero Boots", "LEGENDARY"],
	]
	for acc in accessories:
		var e = _make_equip(id_num, acc[5], acc[4], "ACCESSORY", acc[6], acc[0], acc[1], acc[2], acc[3])
		_register(e)
		id_num += 1
	# OFF_HAND 15: 단검/방패 등 15종
	var offhands = [
		[5, 0, 0, 0, "단검", "Dagger", "COMMON"],
		[8, 0, 0, 0, "독 칠한 단검", "Poison Dagger", "RARE"],
		[0, 5, 0, 0, "방패", "Shield", "COMMON"],
		[0, 10, 50, 0, "강철 방패", "Steel Shield", "RARE"],
		[10, 0, 0, 5, "암습 단검", "Ambush Dagger", "RARE"],
		[12, 0, 0, 0, "화염 단검", "Flame Dagger", "SPECIAL"],
		[0, 8, 80, 0, "탑 방패", "Tower Shield", "SPECIAL"],
		[15, 0, 0, 10, "그림자 단검", "Shadow Dagger", "SPECIAL"],
		[0, 12, 100, 0, "신성한 방패", "Holy Shield", "LEGENDARY"],
		[18, 0, 0, 15, "악마의 손길", "Demon Grasp", "LEGENDARY"],
		[7, 3, 0, 0, "쌍검", "Twin Blades", "COMMON"],
		[0, 6, 40, 0, "원형 방패", "Round Shield", "COMMON"],
		[9, 0, 0, 0, "냉기 단검", "Frost Dagger", "RARE"],
		[0, 7, 60, 0, "마법 방패", "Magic Shield", "RARE"],
		[14, 4, 40, 8, "용맹의 보조검", "Valor Offhand", "SPECIAL"],
	]
	for o in offhands:
		var e = _make_equip(id_num, o[5], o[4], "OFF_HAND", o[6], o[0], o[1], o[2], o[3])
		_register(e)
		id_num += 1
	print("[EquipmentDatabase] Loaded %d equipment." % _by_id.size())

func _make_equip(eid: int, name_en: String, name_ko: String, slot: String, rarity: String, atk: float, def: float, hp: float, spd: float, cri: float = 0.0) -> Equipment:
	var e = Equipment.new()
	e.id = eid
	e.name = name_en
	e.name_ko = name_ko
	e.slot = slot
	e.rarity = rarity
	e.base_atk = atk
	e.base_def = def
	e.base_hp = hp
	e.base_spd = spd
	e.base_cri = cri
	return e

func _register(e: Equipment) -> void:
	_by_id[e.id] = e
	_by_slot[e.slot].append(e)
	_by_rarity[e.rarity].append(e)

func get_equipment(id: int) -> Equipment:
	var e = _by_id.get(id, null)
	if e is Equipment:
		return e.duplicate_equipment()
	return null

func get_equipment_by_slot(slot: String) -> Array:
	var arr = _by_slot.get(slot, [])
	var out: Array[Equipment] = []
	for e in arr:
		out.append(e.duplicate_equipment())
	return out

func get_random_by_rarity(rarity: String) -> Equipment:
	var arr = _by_rarity.get(rarity, [])
	if arr.is_empty():
		return null
	var e = arr[randi() % arr.size()]
	return e.duplicate_equipment()

func get_all() -> Array:
	var out: Array[Equipment] = []
	for e in _by_id.values():
		out.append(e.duplicate_equipment())
	return out
