# scripts/combat/shared/Card.gd
# 카드 기본 클래스 — DEV_SPEC_SHARED.md 기반
class_name Card
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var cost: int = 1
@export var type: String = ""       # "ATK" | "DEF" | "SKILL" | "POWER" | "CURSE"
@export var tags: Array[String] = []  # ["PARRY", "DODGE", "GUARD", "MAJOR_ARCANA"]
@export var rarity: String = "COMMON"  # COMMON | RARE | SPECIAL | LEGENDARY
@export var description: String = ""
@export var short_desc: String = ""   # 모바일용 짧은 설명 (아이콘+숫자)

# 효과 데이터
@export var damage: int = 0
@export var block: int = 0
@export var draw: int = 0
@export var energy_cost_reduction: int = 0
@export var status_effects: Array[Dictionary] = []

# 태그 체크
func has_tag(tag: String) -> bool:
	return tags.has(tag)

func is_major_arcana() -> bool:
	return tags.has("MAJOR_ARCANA")

func get_mobile_description() -> String:
	if short_desc != "":
		return short_desc
	# 자동 생성
	var parts = []
	if damage > 0: parts.append("⚔️%d" % damage)
	if block > 0:  parts.append("🛡️%d" % block)
	if draw > 0:   parts.append("✨드로우%d" % draw)
	return " ".join(parts)

func dmg_per_energy() -> float:
	if cost == 0: return float(damage)
	return float(damage) / float(cost)

# 카드 복사본 생성
func duplicate_card() -> Card:
	var c = Card.new()
	c.id = id
	c.name = name
	c.cost = cost
	c.type = type
	c.tags = tags.duplicate()
	c.rarity = rarity
	c.description = description
	c.short_desc = short_desc
	c.damage = damage
	c.block = block
	c.draw = draw
	c.energy_cost_reduction = energy_cost_reduction
	c.status_effects = status_effects.duplicate(true)
	return c
