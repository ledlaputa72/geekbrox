# scripts/combat/shared/Card.gd
# 카드 기본 클래스 — CURSOR_COMPLETE_DEV_GUIDE + cards_200_v2.json 기반
class_name Card
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var name_ko: String = ""       # 한글명 (nameKo from JSON)
@export var cost: int = 1
@export var type: String = ""         # ATTACK | SKILL | POWER | CURSE
@export var subtype: String = ""      # SGL, AoE 등 (JSON subtype)
@export var sub_category: String = "" # 레거시: GUARD/PARRY/DODGE, SINGLE/AOE 등
@export var cost_type: String = "energy"
@export var tags: Array[String] = []
@export var rarity: String = "COMMON"
@export var description: String = ""
@export var short_desc: String = ""
@export var stats: Dictionary = {}    # { "damage": 7, "block": 0, "heal": 0 }
@export var effects: Array = []      # 특수 효과
@export var enhancement_level: int = 0 # 0~10, 강화도
@export var monetization: String = "free" # free | premium

# 효과 데이터 (레거시 호환: stats 또는 직접 값)
@export var damage: int = 0
@export var block: int = 0
@export var draw: int = 0
@export var energy_cost_reduction: int = 0
@export var status_effects: Array[Dictionary] = []

@export var auto_dodge_success_rate: float = 0.5

# 태그 체크
func has_tag(tag: String) -> bool:
	return tags.has(tag)

func is_major_arcana() -> bool:
	return tags.has("MAJOR_ARCANA")

# 메인/서브 카테고리 표시명 (UI·필터용)
const SUB_CATEGORY_DISPLAY = {
	"GUARD": "\uAC00\uB4DC", "PARRY": "\uD328\uB9C1", "DODGE": "\uD68C\uD53C",
	"ARMOR": "\uC544\uBA38", "HP": "\uCCB4\uB825",
	"SINGLE": "\uB2E8\uD0C4", "AOE": "\uAD11\uC5ED", "DEBUFF": "\uB514\uBC84\uD504", "BUFF": "\uBC84\uD504", "UTILITY": "\uC720\uD2B9",
	"DRAW": "\uB4DC\uB85C\uC6B0",
}
func get_sub_category_display_name() -> String:
	return SUB_CATEGORY_DISPLAY.get(sub_category, sub_category) if sub_category else ""

func get_effective_damage() -> int:
	"""stats 또는 레거시 damage 반환"""
	if stats.has("damage"):
		return int(stats["damage"])
	return damage

func get_effective_block() -> int:
	if stats.has("block"):
		return int(stats["block"])
	return block

func get_enhanced_damage() -> float:
	"""강화도를 고려한 데미지: base * (1 + enhancement_level * 0.05)"""
	var base_val = float(get_effective_damage())
	return base_val * (1.0 + enhancement_level * 0.05)

func get_enhanced_block() -> float:
	var base_val = float(get_effective_block())
	return base_val * (1.0 + enhancement_level * 0.05)

func enhance() -> bool:
	"""카드 강화 (100% 성공, +10까지)"""
	if enhancement_level < 10:
		enhancement_level += 1
		return true
	return false

func get_rarity_value() -> int:
	"""희귀도 수치 (강화 재료/가챭 등)"""
	match rarity:
		"COMMON": return 1
		"RARE": return 3
		"SPECIAL": return 5
		"LEGENDARY": return 10
	return 0

func get_mobile_description() -> String:
	if short_desc != "":
		return short_desc
	var d = get_effective_damage()
	var b = get_effective_block()
	var parts = []
	if d > 0: parts.append("⚔️%d" % d)
	if b > 0: parts.append("🛡️%d" % b)
	if draw > 0: parts.append("✨드로우%d" % draw)
	return " ".join(parts) if parts.size() > 0 else description

func dmg_per_energy() -> float:
	var d = get_effective_damage()
	if cost == 0: return float(d)
	return float(d) / float(cost)

# CardHandItem 등 UI용 딕셔너리 (type은 Attack/Skill/Power/Curse 형태)
func to_dict() -> Dictionary:
	var display_type = type
	if display_type == "ATTACK": display_type = "Attack"
	elif display_type == "SKILL": display_type = "Skill"
	elif display_type == "POWER": display_type = "Power"
	elif display_type == "CURSE": display_type = "Curse"
	return {
		"id": id,
		"name": name_ko if name_ko != "" else name,
		"cost": cost,
		"type": display_type,
		"description": description,
		"short_desc": get_mobile_description(),
		"tags": tags.duplicate(),
		"auto_dodge_success_rate": auto_dodge_success_rate,
		"damage": get_effective_damage(),
		"block": get_effective_block(),
		"draw": draw,
		"enhancement_level": enhancement_level,
		"rarity": rarity,
	}

# 카드 복사본 생성
func duplicate_card() -> Card:
	var c = Card.new()
	c.id = id
	c.name = name
	c.name_ko = name_ko
	c.cost = cost
	c.type = type
	c.subtype = subtype
	c.sub_category = sub_category
	c.cost_type = cost_type
	c.tags = tags.duplicate()
	c.rarity = rarity
	c.description = description
	c.short_desc = short_desc
	c.stats = stats.duplicate(true)
	c.effects = effects.duplicate()
	c.enhancement_level = enhancement_level
	c.monetization = monetization
	c.damage = damage
	c.block = block
	c.draw = draw
	c.energy_cost_reduction = energy_cost_reduction
	c.status_effects = status_effects.duplicate(true)
	c.auto_dodge_success_rate = auto_dodge_success_rate
	return c
