# scripts/systems/MilestoneRewardSystem.gd
# 마일스톤 보상 — CURSOR_COMPLETE_DEV_GUIDE, PROGRESSION_SYSTEM_REDESIGNED
# 레벨 도달 시 재화 + 컨텐츠 오픈. LevelSystem.level_changed에 연결하여 사용.
extends Node

signal reward_gold(amount: int)
signal reward_diamond(amount: int)
signal reward_card(count: int, rarity: String)
signal reward_equipment(count: int, rarity: String)
signal content_unlocked(content_id: String, description: String)

var _claimed: Dictionary = {}  # level -> true (이미 수령한 마일스톤)

# 마일스톤 데이터: 레벨 -> 보상 + 컨텐츠
var milestones: Dictionary = {}

static func _get_milestone_dict() -> Dictionary:
	return {
	2: { "reward_gold": 100, "reward_diamond": 5, "reward_card": 1, "content": "카드 시스템 오픈" },
	4: { "reward_gold": 200, "reward_diamond": 5, "reward_equipment": 1, "content": "장비 시스템 오픈" },
	6: { "reward_gold": 1000, "reward_diamond": 0, "content": "강화 시스템 오픈" },
	8: { "reward_gold": 500, "reward_diamond": 5, "content": "첫 지역 완료" },
	10: { "reward_gold": 1000, "reward_diamond": 10, "reward_card": 3, "content": "두 번째 지역 오픈" },
	12: { "reward_gold": 0, "reward_diamond": 10, "content": "가챭 시스템 오픈" },
	14: { "reward_gold": 1000, "reward_diamond": 0, "reward_equipment": 1, "content": "일일 던전 오픈" },
	16: { "reward_gold": 1000, "reward_diamond": 15, "content": "세 번째 지역 오픈" },
	18: { "reward_gold": 0, "reward_diamond": 0, "reward_card": 1, "content": "플레이 스타일 선택" },
	20: { "reward_gold": 5000, "reward_diamond": 20, "reward_equipment": 2, "content": "보스 챌린지 오픈" },
	25: { "reward_gold": 2000, "reward_diamond": 0, "reward_card": 1, "reward_equipment": 1, "content": "네 번째 지역 오픈" },
	30: { "reward_gold": 3000, "reward_diamond": 25, "reward_card": 2, "content": "월간 이벤트 오픈" },
	35: { "reward_gold": 0, "reward_diamond": 50, "reward_equipment": 1, "content": "무한 던전 미리보기" },
	40: { "reward_gold": 5000, "reward_diamond": 30, "reward_equipment": 2, "content": "다섯 번째 지역 오픈" },
	45: { "reward_gold": 5000, "reward_diamond": 20, "reward_card": 3, "content": "시즌 이벤트 미리보기" },
	50: { "reward_gold": 10000, "reward_diamond": 50, "reward_card": 1, "reward_equipment": 1, "content": "무한 던전 오픈" },
	75: { "reward_gold": 15000, "reward_diamond": 75, "reward_card": 2, "content": "고급 챌린지 오픈" },
	100: { "reward_gold": 20000, "reward_diamond": 100, "reward_card": 5, "reward_equipment": 2, "content": "극한 콘텐츠 미리보기" },
	150: { "reward_gold": 30000, "reward_diamond": 150, "reward_card": 1, "reward_equipment": 3, "content": "극한 던전 오픈" },
	200: { "reward_gold": 50000, "reward_diamond": 200, "reward_card": 3, "reward_equipment": 1, "content": "무한 챌린지 오픈" },
	500: { "reward_gold": 100000, "reward_diamond": 500, "reward_card": 10, "reward_equipment": 5, "content": "시즌 2 시작" },
	1000: { "reward_gold": 100000, "reward_diamond": 1000, "content": "극한 콘텐츠 오픈" },
	}

static func get_milestone_data(level: int) -> Dictionary:
	var data = _get_milestone_dict()
	return data.get(level, {})

func _ready():
	milestones = _get_milestone_dict()

func trigger_milestone(level: int) -> void:
	if _claimed.get(level, false):
		return
	var data = milestones.get(level, {})
	if data.is_empty():
		return
	_claimed[level] = true
	if data.get("reward_gold", 0) > 0:
		reward_gold.emit(int(data["reward_gold"]))
	if data.get("reward_diamond", 0) > 0:
		reward_diamond.emit(int(data["reward_diamond"]))
	if data.get("reward_card", 0) > 0:
		reward_card.emit(int(data["reward_card"]), data.get("card_rarity", "COMMON"))
	if data.get("reward_equipment", 0) > 0:
		reward_equipment.emit(int(data["reward_equipment"]), data.get("equipment_rarity", "COMMON"))
	if data.get("content", "") != "":
		content_unlocked.emit("milestone_%d" % level, str(data["content"]))
