# scripts/combat/shared/Card.gd
# 카드 기본 클래스 — DEV_SPEC_SHARED.md 기반
class_name Card
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var cost: int = 1
@export var type: String = ""       # "ATK" | "SKILL" | "POWER" | "CURSE" (메인 카테고리)
@export var sub_category: String = ""  # 서브 카테고리: SKILL→ GUARD/PARRY/DODGE/ARMOR/HP, ATK→ SINGLE/AOE/DEBUFF 등
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

# 오토 플레이 시 회피 카드 성공 확률 (0.0~1.0, DODGE 태그 카드만 사용)
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
	c.sub_category = sub_category
	c.tags = tags.duplicate()
	c.rarity = rarity
	c.description = description
	c.short_desc = short_desc
	c.damage = damage
	c.block = block
	c.draw = draw
	c.energy_cost_reduction = energy_cost_reduction
	c.status_effects = status_effects.duplicate(true)
	c.auto_dodge_success_rate = auto_dodge_success_rate
	return c
