# EventLog.gd
# 이벤트 로그 컴포넌트 (시간별 로그)
# 현재 이벤트 강조 표시

extends Control

# ─── 설정 ───────────────────────────────────────────
const LOG_ENTRY_HEIGHT = 50
const MAX_VISIBLE_LOGS = 3

# ─── UI 노드 참조 ────────────────────────────────────
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var log_container: VBoxContainer = $ScrollContainer/LogContainer

# ─── 로그 데이터 ─────────────────────────────────────
var log_entries: Array = []
var current_log_index: int = -1

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()

func apply_styles() -> void:
	# Scroll container
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

# ─── 로그 추가 ───────────────────────────────────────
func add_log(time_text: String, event_text: String, is_current: bool = false) -> void:
	var entry = {
		"time": time_text,
		"event": event_text,
		"current": is_current
	}
	log_entries.append(entry)
	
	if is_current:
		current_log_index = log_entries.size() - 1
	
	_create_log_entry(entry)
	
	# Auto scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func _create_log_entry(entry: Dictionary) -> void:
	var log_panel = Panel.new()
	log_panel.custom_minimum_size = Vector2(0, LOG_ENTRY_HEIGHT)
	
	# Panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.content_margin_left = 16
	panel_style.content_margin_right = 16
	panel_style.content_margin_top = 8
	panel_style.content_margin_bottom = 8
	
	# Color based on current state
	if entry["current"]:
		# Current event (orange highlight)
		panel_style.bg_color = Color(1.0, 0.6, 0.2, 0.9)  # 주황색
	else:
		# Past event (tan/beige)
		panel_style.bg_color = Color(0.85, 0.75, 0.6, 0.8)  # 황토색
	
	log_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Label
	var label = Label.new()
	label.text = "%s %s" % [entry["time"], entry["event"]]
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	log_panel.add_child(label)
	log_container.add_child(log_panel)

# ─── 모든 로그 클리어 ────────────────────────────────
func clear_logs() -> void:
	for child in log_container.get_children():
		child.queue_free()
	log_entries.clear()
	current_log_index = -1

# ─── 로그 데이터 일괄 설정 ───────────────────────────
func set_logs(logs: Array) -> void:
	clear_logs()
	
	for log in logs:
		add_log(log["time"], log["event"], log.get("current", false))
