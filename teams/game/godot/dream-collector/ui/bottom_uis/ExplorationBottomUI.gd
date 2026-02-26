extends BaseBottomUI

"""
ExplorationBottomUI - 탐험 시간별 로그 UI
GameManager의 dream_time_logs에 따라 매 시간마다 로그 박스를 표시

Layout (564px):
└─ ScrollContainer (full)
   └─ EventLog (VBoxContainer)
      ├─ LogBox: "PM 10:00 출발"
      ├─ LogBox: "PM 11:00 공세계 진입"
      └─ LogBox: "AM 12:00 악몽 - 전투 발생!" (event, orange highlight)
"""

@onready var scroll_container = $ScrollContainer
@onready var event_log = $ScrollContainer/EventLog

# Time log progression
var time_logs: Array = []
var current_log_index: int = 0
var auto_progress_timer: float = 0.0
var auto_progress_interval: float = 2.0  # 2 seconds per log
var is_paused: bool = false  # Pause log progression during events

func _ready():
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	# Load time logs from GameManager
	time_logs = GameManager.get_dream_time_logs()
	current_log_index = 0
	auto_progress_timer = 0.0
	
	print("[ExplorationBottomUI] Loaded %d time logs from GameManager" % time_logs.size())
	
	# Show first log immediately
	if time_logs.size() > 0:
		_show_next_log()

func _on_exit():
	"""UI 비활성화 시"""
	pass

func _process(delta: float):
	"""Auto-progress through time logs"""
	if is_paused or current_log_index >= time_logs.size():
		return  # Paused or all logs shown
	
	auto_progress_timer += delta
	
	if auto_progress_timer >= auto_progress_interval:
		auto_progress_timer = 0.0
		_show_next_log()

func set_paused(paused: bool):
	"""Pause/resume log progression"""
	is_paused = paused
	print("[ExplorationBottomUI] Log progression %s" % ("paused" if paused else "resumed"))

func resume():
	"""Resume log progression (convenience method)"""
	set_paused(false)

func _show_next_log():
	"""Show next time log"""
	if current_log_index >= time_logs.size():
		print("[ExplorationBottomUI] All logs shown")
		return
	
	var log_data = time_logs[current_log_index]
	_add_log_box(log_data)
	
	current_log_index += 1

func _add_log_box(log_data: Dictionary):
	"""Add time-based log box (similar to DreamCardSelection)"""
	var log_box = Panel.new()
	log_box.custom_minimum_size = Vector2(0, 50)
	
	# Style based on log type
	var box_style = StyleBoxFlat.new()
	if log_data.type == "event":
		# Event log (orange highlight)
		box_style.bg_color = Color(0.8, 0.4, 0.2, 1)  # Orange
	else:
		# Travel log (beige)
		box_style.bg_color = Color(0.7, 0.6, 0.4, 1)  # Beige
	
	box_style.corner_radius_top_left = 8
	box_style.corner_radius_top_right = 8
	box_style.corner_radius_bottom_left = 8
	box_style.corner_radius_bottom_right = 8
	box_style.content_margin_left = 12
	box_style.content_margin_right = 12
	box_style.content_margin_top = 8
	box_style.content_margin_bottom = 8
	log_box.add_theme_stylebox_override("panel", box_style)
	
	# HBox for time + text
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	log_box.add_child(hbox)
	
	# Time label (left)
	var time_label = Label.new()
	time_label.text = log_data.time
	time_label.add_theme_font_size_override("font_size", 14)
	time_label.add_theme_color_override("font_color", Color.WHITE)
	time_label.custom_minimum_size = Vector2(80, 0)
	hbox.add_child(time_label)
	
	# Text label (right, expandable)
	var text_label = Label.new()
	if log_data.has("icon"):
		text_label.text = "%s %s" % [log_data.icon, log_data.text]
	else:
		text_label.text = log_data.text
	text_label.add_theme_font_size_override("font_size", 14)
	text_label.add_theme_color_override("font_color", Color.WHITE)
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hbox.add_child(text_label)
	
	# Add to log
	event_log.add_child(log_box)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
	
	print("[ExplorationBottomUI] Time log added: %s - %s" % [log_data.time, log_data.text])
	
	# Trigger event if this is an event log
	if log_data.type == "event":
		_trigger_event(log_data)

func _trigger_event(log_data: Dictionary):
	"""Trigger event when event log appears"""
	# Notify parent screen that an event should happen
	print("[ExplorationBottomUI] Event triggered: %s" % log_data.event_type)
	
	# Emit signal for InRun_v4 to handle
	ui_action_requested.emit("event_triggered", log_data)

func add_log(message: String, highlight: bool = false):
	"""Legacy method - add simple log entry"""
	var label = Label.new()
	label.text = "• " + message
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.body)
	label.add_theme_color_override("font_color", UITheme.COLORS.warning if highlight else UITheme.COLORS.text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_log.add_child(label)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
	
	print("[ExplorationBottomUI] Log added: ", message)

func clear_log():
	"""Clear all log entries"""
	for child in event_log.get_children():
		child.queue_free()
	current_log_index = 0
	auto_progress_timer = 0.0
