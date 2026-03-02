# scripts/autoloads/SettingsManager.gd
# 설정 관리자 — DEV_SPEC_SHARED.md 기반
extends Node

# ── 전투 설정 ─────────────────────────────────────────
var crisis_slow_enabled: bool = true
var story_mode: bool = true            # true = Story 모드 (0.8초), false = 하드 (0.5초)
var parry_window_story_mode: bool = true
var dodge_window_hard_mode: bool = false   # true = 하드 모드 (1.2초), false = Story (1.8초)
var auto_play_mode: int = 0               # 0=수동, 1=세미오토, 2=풀오토
var battle_speed: float = 1.0             # 1.0 / 1.5 / 2.0 / 2.5
var lumi_enabled: bool = true
var card_anim_speed: float = 1.0

# ── 전투 모드 설정 ────────────────────────────────────
# 기본: 일반전투=ATB, 보스전투=턴베이스
# 단축키(F1/F2)로 강제 전환 가능
var force_atb_mode: bool = false
var force_tb_mode: bool = false

# ── 계산 속성 ─────────────────────────────────────────
func get_parry_window() -> float:
	return 0.8 if (story_mode or parry_window_story_mode) else 0.5

func get_dodge_window() -> float:
	if dodge_window_hard_mode:
		return 1.2
	return 1.8

# ── 전투 모드 결정 ────────────────────────────────────
func get_combat_mode(is_boss: bool) -> String:
	if force_atb_mode:
		return "ATB"
	if force_tb_mode:
		return "TURNBASED"
	# 기본: 보스=턴베이스, 일반=ATB
	return "TURNBASED" if is_boss else "ATB"

# ── 저장/불러오기 ─────────────────────────────────────
func save():
	var config = ConfigFile.new()
	config.set_value("combat", "crisis_slow", crisis_slow_enabled)
	config.set_value("combat", "story_mode", story_mode)
	config.set_value("combat", "auto_play", auto_play_mode)
	config.set_value("combat", "speed", battle_speed)
	config.set_value("combat", "lumi", lumi_enabled)
	config.set_value("combat", "card_anim_speed", card_anim_speed)
	config.save("user://settings.cfg")
	print("[SettingsManager] Settings saved")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err != OK:
		print("[SettingsManager] No saved settings, using defaults")
		return
	crisis_slow_enabled = config.get_value("combat", "crisis_slow", true)
	story_mode = config.get_value("combat", "story_mode", true)
	parry_window_story_mode = story_mode
	auto_play_mode = config.get_value("combat", "auto_play", 0)
	battle_speed = config.get_value("combat", "speed", 1.0)
	lumi_enabled = config.get_value("combat", "lumi", true)
	card_anim_speed = config.get_value("combat", "card_anim_speed", 1.0)
	print("[SettingsManager] Settings loaded")

func _ready():
	load_settings()
