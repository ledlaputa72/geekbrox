# scripts/systems/ContentUnlockManager.gd
# 컨텐츠 오픈 — CURSOR_COMPLETE_DEV_GUIDE, PROGRESSION_SYSTEM_REDESIGNED
# 레벨에 따라 지역/던전/이벤트 오픈. MilestoneRewardSystem.content_unlocked와 연동 가능.
extends Node

signal content_unlocked(content_id: String, name_key: String)

# 레벨별 오픈 컨텐츠 ID
var _unlock_by_level: Dictionary = {
	2: "card_system",
	4: "equipment_system",
	6: "enhance_system",
	8: "region_1_complete",
	10: "region_2",
	12: "gacha_system",
	14: "daily_dungeon",
	16: "region_3",
	18: "play_style_ui",
	20: "boss_challenge",
	25: "region_4",
	30: "monthly_event",
	35: "infinite_dungeon_preview",
	40: "region_5",
	45: "season_event_preview",
	50: "infinite_dungeon",
	75: "advanced_challenge",
	100: "extreme_content_preview",
	150: "extreme_dungeon",
	200: "infinite_challenge",
	500: "season_2",
	1000: "extreme_content",
}

var _unlocked: Dictionary = {}  # content_id -> true

func _ready():
	pass

func unlock_by_level(level: int) -> void:
	for lv in _unlock_by_level.keys():
		if lv <= level and not _unlocked.get(_unlock_by_level[lv], false):
			var cid = _unlock_by_level[lv]
			_unlocked[cid] = true
			content_unlocked.emit(cid, cid)

func is_unlocked(content_id: String) -> bool:
	return _unlocked.get(content_id, false)

func get_unlocked_list() -> Array:
	var out: Array[String] = []
	for cid in _unlocked.keys():
		if _unlocked[cid]:
			out.append(cid)
	return out
