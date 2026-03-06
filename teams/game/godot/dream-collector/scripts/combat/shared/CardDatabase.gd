# scripts/combat/shared/CardDatabase.gd
# 카드 데이터베이스 — CURSOR_COMPLETE_DEV_GUIDE + cards_200_v2.json
# JSON 우선 로드, 실패 시 레거시 30종 폴백
extends Node

# id → Card (템플릿, 복사해서 사용)
var _cards: Dictionary = {}
# 순서 유지용 배열 (get_all, get_cards_by_type 등)
var _all_cards: Array[Card] = []
var _loaded_from_json: bool = false

# 200종 스타터 덱용 ID (cards_200_v2.json 기준: ATTACK + SKILL)
const STARTER_DECK_IDS_200: Array[String] = [
	"ATK-SGL_001", "ATK-SGL_001", "ATK-SGL_002", "ATK-SGL_003",
	"ATK-SGL_004", "ATK-SGL_005",
	"SKL-GRD_001", "SKL-GRD_002", "SKL-GRD_003", "SKL-GRD_004",
]

func _ready():
	load_cards_from_json()
	if _all_cards.is_empty():
		_build_all_cards()
		print("[CardDatabase] Legacy 30 cards loaded.")
	else:
		print("[CardDatabase] Loaded %d cards (JSON)." % _all_cards.size())

func load_cards_from_json() -> void:
	_cards.clear()
	_all_cards.clear()
	_loaded_from_json = false
	var path = "res://data/cards_200_v2.json"
	if not FileAccess.file_exists(path):
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	file = null
	var data = JSON.parse_string(text)
	if data == null:
		push_error("[CardDatabase] JSON parse failed")
		return
	if not (data is Array):
		push_error("[CardDatabase] JSON root is not Array")
		return
	for card_data in data:
		if not (card_data is Dictionary):
			continue
		var card = _create_card_from_data(card_data)
		if card and card.id != "":
			_cards[card.id] = card
			_all_cards.append(card)
	_loaded_from_json = _all_cards.size() > 0

func _create_card_from_data(data: Dictionary) -> Card:
	var card = Card.new()
	card.id = data.get("id", "")
	card.name = data.get("name", "")
	card.name_ko = data.get("nameKo", "")
	card.type = data.get("type", "ATTACK")
	card.subtype = data.get("subtype", "")
	card.sub_category = card.subtype  # 레거시 호환
	card.rarity = data.get("rarity", "COMMON")
	card.cost = int(data.get("cost", 0))
	card.cost_type = data.get("costType", "energy")
	card.description = data.get("description", "")
	if card.description == "":
		card.description = data.get("descriptionKo", "")
	card.stats = data.get("stats", {})
	card.effects = data.get("effects", [])
	var tag_list: Array[String] = []
	for t in data.get("tags", []):
		tag_list.append(str(t))
	card.tags = tag_list
	card.monetization = data.get("monetization", "free")
	# 레거시 호환: damage, block, draw
	card.damage = int(card.stats.get("damage", 0))
	card.block = int(card.stats.get("block", 0))
	card.draw = 0
	for e in card.effects:
		if e is Dictionary and e.get("type", "") == "draw":
			card.draw = int(e.get("value", 0))
			break
	var status_list: Array[Dictionary] = []
	card.status_effects = status_list
	card.auto_dodge_success_rate = 0.5
	return card

# ── 조회 (가이드 API) ─────────────────────────────────────
func get_card(id: String) -> Card:
	return _cards.get(id, null)

func get_cards_by_type(type: String) -> Array:
	var result: Array[Card] = []
	for c in _all_cards:
		if c.type == type:
			result.append(c)
	return result

func get_cards_by_rarity(rarity: String) -> Array:
	var result: Array[Card] = []
	for c in _all_cards:
		if c.rarity == rarity:
			result.append(c)
	return result

func get_random_by_rarity(rarity: String) -> Card:
	var pool = get_cards_by_rarity(rarity)
	if pool.is_empty():
		return null
	var idx = randi() % pool.size()
	return pool[idx]

# ── 레거시 호환 ───────────────────────────────────────────
func get_all() -> Array[Card]:
	return _all_cards.duplicate()

func get_by_id(id: String) -> Card:
	return get_card(id)

func get_by_type(type: String) -> Array[Card]:
	var arr = get_cards_by_type(type)
	var out: Array[Card] = []
	for c in arr:
		out.append(c)
	return out

func get_by_sub_category(sub: String) -> Array[Card]:
	var result: Array[Card] = []
	for c in _all_cards:
		if c.sub_category == sub or c.subtype == sub:
			result.append(c)
	return result

func get_sub_categories_for_type(main_type: String) -> Array[String]:
	var subs: Array[String] = []
	var seen: Dictionary = {}
	for c in _all_cards:
		if c.type == main_type:
			var s = c.sub_category if c.sub_category != "" else c.subtype
			if s != "" and not seen.get(s, false):
				seen[s] = true
				subs.append(s)
	return subs

func get_starter_deck() -> Array[Card]:
	if _loaded_from_json and _all_cards.size() > 0:
		var deck: Array[Card] = []
		for id in STARTER_DECK_IDS_200:
			var card = get_card(id)
			if card:
				deck.append(card.duplicate_card())
		if deck.size() > 0:
			return deck
	# 폴백: 타입별로 앞에서부터 채우기
	var result: Array[Card] = []
	var by_type = { "ATTACK": get_cards_by_type("ATTACK"), "SKILL": get_cards_by_type("SKILL"), "POWER": get_cards_by_type("POWER") }
	var need = [["ATTACK", 3], ["SKILL", 4], ["POWER", 2]]
	for pair in need:
		var typ = pair[0]
		var n = pair[1]
		var pool = by_type.get(typ, [])
		for i in range(min(n, pool.size())):
			result.append(pool[i].duplicate_card())
	return result

const RUN_DECK_SIZE: int = 45
const RUN_DECK_ATTACK_RATIO: float = 0.5  # 50% attack cards

## 런용 덱 45장: 전체 200종 중 45장, 공격 카드 50%
func get_run_deck_45() -> Array[Card]:
	var result: Array[Card] = []
	var attack_pool = get_cards_by_type("ATTACK")
	var other_pool: Array[Card] = []
	for c in _all_cards:
		if c.type != "ATTACK":
			other_pool.append(c)
	var n_attack = int(RUN_DECK_SIZE * RUN_DECK_ATTACK_RATIO)  # 22 or 23
	var n_other = RUN_DECK_SIZE - n_attack
	attack_pool.shuffle()
	other_pool.shuffle()
	for i in range(mini(n_attack, attack_pool.size())):
		result.append(attack_pool[i].duplicate_card())
	for i in range(mini(n_other, other_pool.size())):
		result.append(other_pool[i].duplicate_card())
	result.shuffle()
	return result

func get_full_deck_30() -> Array[Card]:
	var result: Array[Card] = []
	if _all_cards.size() >= RUN_DECK_SIZE:
		return get_run_deck_45()
	if _all_cards.size() >= 30:
		var pool = _all_cards.duplicate()
		pool.shuffle()
		for i in range(30):
			result.append(pool[i].duplicate_card())
		return result
	# 레거시 30종용 ID (폴백 시)
	var ids: Array[String] = [
		"ATK_001", "ATK_002", "ATK_003", "ATK_004", "ATK_005",
		"ATK_006", "ATK_007", "ATK_008", "ATK_009", "ATK_010",
		"DEF_001", "DEF_002", "DEF_003", "DEF_004", "DEF_005",
		"DEF_006", "DEF_007", "DEF_008",
		"PAR_001", "PAR_002", "PAR_003", "PAR_004", "PAR_005",
		"DOD_001", "DOD_002", "DOD_003", "DOD_004", "DOD_005",
		"SKL_001", "SKL_002",
	]
	for id in ids:
		var card = get_card(id)
		if card:
			result.append(card.duplicate_card())
	result.shuffle()
	return result

func get_random_reward_cards(count: int = 3) -> Array[Card]:
	var pool = _all_cards.duplicate()
	pool.shuffle()
	var result: Array[Card] = []
	for i in range(mini(count, pool.size())):
		result.append(pool[i].duplicate_card())
	return result

# ── 레거시 30종 (JSON 없을 때 폴백) ─────────────────────────
func _build_all_cards() -> void:
	_cards.clear()
	_all_cards.clear()
	# ATK
	for t in [
		["ATK_001", "검의 에이스", 1, "ATTACK", 6, 0, 0, [], ["MAJOR_ARCANA"], "COMMON", "단순하지만 확실한 일격.", "⚔️6"],
		["ATK_002", "이중 베기", 2, "ATTACK", 9, 0, 0, [], [], "COMMON", "2회 연속 공격.", "⚔️4.5×2"],
		["ATK_003", "마법사", 2, "ATTACK", 4, 0, 0, [], ["MAJOR_ARCANA"], "RARE", "모든 적에게 4 피해.", "⚔️4 전체"],
		["ATK_004", "탑", 2, "ATTACK", 15, 0, 0, [{"target": "self", "type": "POISON", "value": 3}], ["MAJOR_ARCANA"], "RARE", "강타 + 자해.", "⚔️15"],
		["ATK_005", "세계", 4, "ATTACK", 20, 10, 0, [], ["MAJOR_ARCANA"], "LEGENDARY", "20 피해 + 블록 10.", "⚔️20 🛡️10"],
		["ATK_006", "번개", 1, "ATTACK", 8, 0, 0, [], [], "COMMON", "번개 공격.", "⚔️8"],
		["ATK_007", "악마", 2, "ATTACK", 5, 0, 0, [{"target": "enemy", "type": "POISON", "value": 3}], ["MAJOR_ARCANA"], "RARE", "광역 + 중독.", "⚔️5 🤢"],
		["ATK_008", "태양", 3, "ATTACK", 18, 0, 0, [], ["MAJOR_ARCANA"], "RARE", "강타.", "⚔️18"],
		["ATK_009", "별", 2, "ATTACK", 7, 0, 1, [], ["MAJOR_ARCANA"], "COMMON", "7 피해 + 드로우 1.", "⚔️7 ✨1"],
		["ATK_010", "황제", 3, "ATTACK", 12, 0, 0, [{"target": "self", "type": "STRENGTH", "value": 2}], ["MAJOR_ARCANA"], "SPECIAL", "12 피해 + 힘+2.", "⚔️12 💪+2"],
	]:
		var c = _make(t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11])
		c.sub_category = "SINGLE"
		if t[0] in ["ATK_003", "ATK_007"]: c.sub_category = "AOE"
		elif t[0] == "ATK_004": c.sub_category = "DEBUFF"
		elif t[0] == "ATK_009": c.sub_category = "UTILITY"
		elif t[0] == "ATK_010": c.sub_category = "BUFF"
		_cards[c.id] = c
		_all_cards.append(c)
	# DEF (SKILL)
	for t in [
		["DEF_001", "방패의 왕", 2, "SKILL", 0, 12, 0, [], ["GUARD"], "COMMON", "블록 12.", "🛡️12"],
		["DEF_002", "철벽", 1, "SKILL", 0, 5, 0, [], ["GUARD"], "COMMON", "블록 5.", "🛡️5"],
		["DEF_003", "여황제", 3, "SKILL", 0, 18, 0, [], ["GUARD", "MAJOR_ARCANA"], "RARE", "블록 18.", "🛡️18"],
		["DEF_004", "교황", 2, "SKILL", 0, 8, 1, [], ["GUARD", "MAJOR_ARCANA"], "COMMON", "블록 8 + 드로우 1.", "🛡️8 ✨1"],
		["DEF_005", "달", 2, "SKILL", 0, 10, 0, [{"target": "self", "type": "DEXTERITY", "value": 1}], ["GUARD", "MAJOR_ARCANA"], "RARE", "블록 10 + 민첩+1.", "🛡️10"],
		["DEF_006", "정의", 1, "SKILL", 0, 7, 0, [], ["GUARD", "MAJOR_ARCANA"], "COMMON", "블록 7.", "🛡️7"],
		["DEF_007", "은둔자", 2, "SKILL", 0, 15, 0, [], ["GUARD", "MAJOR_ARCANA"], "RARE", "블록 15.", "🛡️15"],
		["DEF_008", "절제", 1, "SKILL", 0, 4, 0, [], ["GUARD", "MAJOR_ARCANA"], "COMMON", "블록 4 + 회복 2.", "🛡️4 ❤️2"],
	]:
		var c = _make(t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11])
		c.sub_category = "GUARD"
		if t[0] == "DEF_008": c.status_effects.append({"target": "self", "type": "HEAL", "value": 2})
		_cards[c.id] = c
		_all_cards.append(c)
	# PARRY
	for t in [
		["PAR_001", "꿈의 쳐내기", 0, "SKILL", 0, 0, 1, [], ["PARRY"], "COMMON", "패링 + 에너지+2 + 드로우 1.", "🥋 ⚡+2"],
		["PAR_002", "반사의 순간", 0, "SKILL", 0, 0, 0, [], ["PARRY"], "RARE", "패링 + 반격 30%.", "🥋 반격"],
		["PAR_003", "각성의 쳐내기", 0, "SKILL", 0, 0, 0, [], ["PARRY"], "SPECIAL", "패링 (0.3초) ⚡+3.", "🥋 ⚡+3"],
		["PAR_004", "달빛 반격", 1, "SKILL", 8, 0, 0, [], ["PARRY"], "RARE", "패링 + 반격 8.", "🥋 ⚔️8"],
		["PAR_005", "완벽한 방어", 0, "SKILL", 0, 0, 0, [], ["PARRY", "DODGE"], "SPECIAL", "패링+회피 ⚡+1.", "🥋🌀"],
	]:
		var c = _make(t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11])
		c.sub_category = "PARRY"
		if t[0] == "PAR_005": c.auto_dodge_success_rate = 0.5
		_cards[c.id] = c
		_all_cards.append(c)
	# DODGE
	for t in [
		["DOD_001", "꿈의 스텝", 0, "SKILL", 0, 0, 0, [], ["DODGE"], "COMMON", "회피 ⚡+1.", "🌀 ⚡+1"],
		["DOD_002", "잔상", 0, "SKILL", 0, 0, 0, [], ["DODGE"], "RARE", "회피 + 버프이전.", "🌀"],
		["DOD_003", "황혼의 도약", 0, "SKILL", 0, 0, 0, [{"target": "self", "type": "STRENGTH", "value": 3}], ["DODGE"], "RARE", "회피 + 다음 공격+3.", "🌀 ⚔️+3"],
		["DOD_004", "연막", 1, "SKILL", 0, 0, 0, [{"target": "enemy", "type": "WEAK", "value": 2}], ["DODGE"], "RARE", "회피 + 약화 2.", "🌀 👁️-3"],
		["DOD_005", "반보 앞으로", 0, "SKILL", 0, 0, 0, [], ["DODGE", "PARRY"], "COMMON", "반회피 ⚡+1.", "🌀🥋"],
	]:
		var c = _make(t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11])
		c.sub_category = "DODGE"
		c.auto_dodge_success_rate = 0.5
		_cards[c.id] = c
		_all_cards.append(c)
	# POWER
	for t in [
		["SKL_001", "바보", 0, "POWER", 0, 0, 1, [], ["MAJOR_ARCANA"], "COMMON", "드로우 1 + ⚡+1.", "✨1 ⚡+1"],
		["SKL_002", "달의 환영", 2, "POWER", 0, 0, 3, [], ["MAJOR_ARCANA"], "RARE", "드로우 3.", "✨3"],
	]:
		var c = _make(t[0], t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11])
		c.sub_category = "DRAW"
		_cards[c.id] = c
		_all_cards.append(c)

func _make(p_id: String, p_name: String, p_cost: int, p_type: String, p_damage: int, p_block: int, p_draw: int,
		p_status_effects: Array, p_tags: Array, p_rarity: String, p_desc: String, p_short_desc: String) -> Card:
	var c = Card.new()
	c.id = p_id
	c.name = p_name
	c.name_ko = p_name
	c.cost = p_cost
	c.type = p_type
	c.damage = p_damage
	c.block = p_block
	c.draw = p_draw
	var typed_se: Array[Dictionary] = []
	typed_se.assign(p_status_effects)
	c.status_effects = typed_se
	var typed_tags: Array[String] = []
	typed_tags.assign(p_tags)
	c.tags = typed_tags
	c.rarity = p_rarity
	c.description = p_desc
	c.short_desc = p_short_desc
	c.stats = {"damage": p_damage, "block": p_block, "heal": 0}
	return c
