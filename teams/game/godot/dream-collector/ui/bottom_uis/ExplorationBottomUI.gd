extends BaseBottomUI

"""
ExplorationBottomUI - 탐험 로그 UI
시간 경과에 따라 나레이션 로그가 자동으로 쌓임

Layout (564px):
└─ ScrollContainer (full)
   └─ EventLog (VBoxContainer)
      ├─ "AM 10:00 - 꿈 속으로 들어섰다..."
      ├─ "AM 10:30 - 이상한 숲을 지나간다..."
      └─ "AM 11:00 - ⚔️ 전투 발생!"
"""

@onready var scroll_container = $ScrollContainer
@onready var event_log = $ScrollContainer/EventLog

func _ready():
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	add_log("=== 탐험 시작 ===")
	print("[ExplorationBottomUI] Exploration UI activated")

func _on_exit():
	"""UI 비활성화 시"""
	pass

func add_log(message: String, highlight: bool = false):
	"""Add log entry"""
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
