extends BaseBottomUI

"""
ExplorationBottomUI - 이동/탐험 중 UI
단일 스크롤 가능한 이벤트 로그

Layout (564px):
└─ ScrollContainer (full)
   └─ EventLog (VBoxContainer)
      ├─ "AM 12:00 - 출발"
      ├─ "AM 12:30 - 약탈 발견"
      └─ ...
"""

@onready var scroll_container = $ScrollContainer
@onready var event_log = $ScrollContainer/EventLog

func _ready():
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	add_log("=== Exploration Started ===")

func _on_exit():
	"""UI 비활성화 시"""
	pass

func add_log(message: String):
	"""Add log entry"""
	var label = Label.new()
	label.text = "• " + message
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_log.add_child(label)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func clear_log():
	"""Clear all log entries"""
	for child in event_log.get_children():
		child.queue_free()
