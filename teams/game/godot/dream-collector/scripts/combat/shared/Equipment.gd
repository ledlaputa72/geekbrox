# scripts/combat/shared/Equipment.gd
# 장비 클래스 — CURSOR_COMPLETE_DEV_GUIDE
# 슬롯: WEAPON / ARMOR / ACCESSORY / OFF_HAND
# 강화: +10까지, 100% 성공, 스탯 10% per level
class_name Equipment
extends Resource

@export var id: int = 0
@export var name: String = ""
@export var name_ko: String = ""
@export var slot: String = ""  # WEAPON | ARMOR | ACCESSORY | OFF_HAND
@export var rarity: String = "COMMON"  # COMMON | RARE | SPECIAL | LEGENDARY
@export var base_atk: float = 0.0
@export var base_def: float = 0.0
@export var base_hp: float = 0.0
@export var base_spd: float = 0.0
@export var base_cri: float = 0.0  # 치명타율 % (0~25)
@export var enhancement_level: int = 0  # 0~10

func get_total_atk() -> float:
	return base_atk * (1.0 + enhancement_level * 0.1)

func get_total_def() -> float:
	return base_def * (1.0 + enhancement_level * 0.1)

func get_total_hp() -> float:
	return base_hp * (1.0 + enhancement_level * 0.1)

func get_total_spd() -> float:
	return base_spd * (1.0 + enhancement_level * 0.1)

func get_total_cri() -> float:
	return base_cri + enhancement_level * 0.5  # 강화 레벨당 0.5% 추가

func enhance() -> bool:
	"""장비 강화 (100% 성공). 비용: 같은 장비 2개 + 골드는 호출측에서 처리."""
	if enhancement_level < 10:
		enhancement_level += 1
		return true
	return false

func duplicate_equipment() -> Equipment:
	var e = Equipment.new()
	e.id = id
	e.name = name
	e.name_ko = name_ko
	e.slot = slot
	e.rarity = rarity
	e.base_atk = base_atk
	e.base_def = base_def
	e.base_hp = base_hp
	e.base_spd = base_spd
	e.base_cri = base_cri
	e.enhancement_level = enhancement_level
	return e
