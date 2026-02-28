## SaveSystem.gd
## 게임 저장/불러오기 - AutoLoad 싱글톤
## JSON 형식으로 user://save.json에 저장

extends Node

const SAVE_PATH = "user://save.json"

# ─── 저장 ────────────────────────────────────────────
func save_game() -> void:
	IdleSystem.mark_save_time()

	var save_data = {
		"version": GameManager.VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"reveries": GameManager.reveries,
		"gems": GameManager.gems,
		"energy": GameManager.energy,
		"dream_shards": GameManager.dream_shards,
		"total_runs_completed": GameManager.total_runs_completed,
		"prestige_count": GameManager.prestige_count,
		"base_collection_rate": GameManager.base_collection_rate,
		"last_save_timestamp": IdleSystem.last_save_timestamp,
		"card_multiplier": IdleSystem.card_multiplier,
		"prestige_multiplier": IdleSystem.prestige_multiplier,
		"current_deck": GameManager.current_deck,
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("[SaveSystem] 저장 완료")
	else:
		push_error("[SaveSystem] 저장 실패: " + SAVE_PATH)

# ─── 불러오기 ─────────────────────────────────────────
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveSystem] 저장 파일 없음 → 새 게임 시작")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("[SaveSystem] 불러오기 실패")
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var err = json.parse(json_text)
	if err != OK:
		push_error("[SaveSystem] JSON 파싱 오류")
		return

	var data = json.get_data()

	# 데이터 복원
	GameManager.reveries              = float(data.get("reveries", 0.0))
	GameManager.gems                  = int(data.get("gems", 0))
	GameManager.energy                = int(data.get("energy", 100))
	GameManager.dream_shards          = int(data.get("dream_shards", 0))
	GameManager.total_runs_completed  = int(data.get("total_runs_completed", 0))
	GameManager.prestige_count        = int(data.get("prestige_count", 0))
	GameManager.base_collection_rate  = float(data.get("base_collection_rate", 10.0))
	IdleSystem.last_save_timestamp    = int(data.get("last_save_timestamp", 0))
	IdleSystem.card_multiplier        = float(data.get("card_multiplier", 1.0))
	IdleSystem.prestige_multiplier    = float(data.get("prestige_multiplier", 1.0))
	GameManager.current_deck          = data.get("current_deck", [])

	print("[SaveSystem] 불러오기 완료 (Reveries: %.1f, Gems: %d, Energy: %d, Deck: %d장)" % [
		GameManager.reveries, GameManager.gems, GameManager.energy, GameManager.current_deck.size()
	])

# ─── 초기화 (개발/테스트용) ───────────────────────────
func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	print("[SaveSystem] 저장 데이터 초기화 완료")
