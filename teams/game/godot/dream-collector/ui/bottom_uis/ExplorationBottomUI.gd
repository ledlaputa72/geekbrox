extends BaseBottomUI

"""
ExplorationBottomUI - 탐험 타임라인 로그 UI

Layout:
└─ ScrollContainer (스크롤바 숨김)
   └─ EventLog (VBoxContainer, 콘텐츠 높이에 따라 확장)
      └─ 각 행: [HBox] 원형 아이콘 | 색상 패널 (시간? + 내용)

타입별 색상:
  travel   → 황금색   combat   → 빨간색
  shop     → 파란색   npc      → 초록색
  boss     → 보라색   narration→ 청회색
  victory  → 황금 주황 (전투 승리 배너)
  start    → 회청색 (여정 시작)
"""

@onready var scroll_container = $ScrollContainer
@onready var event_log = $ScrollContainer/EventLog

var time_logs: Array = []
var current_log_index: int = 0
var auto_progress_timer: float = 0.0
var auto_progress_interval: float = 2.0
var is_paused: bool = false
var _last_shown_was_event: bool = false  # 연속 이벤트 감지용

# ─── 타입별 색상 팔레트 (이미지 기준) ───
const LOG_COLORS = {
	"travel":    {"bg": Color(0.353, 0.333, 0.506, 1), "circle": Color(0.45, 0.42, 0.60, 1)},
	"combat":    {"bg": Color(0.898, 0.224, 0.208, 1), "circle": Color(0.95, 0.35, 0.32, 1)},
	"shop":      {"bg": Color(0.259, 0.647, 0.961, 1), "circle": Color(0.40, 0.72, 1.0, 1)},
	"npc":       {"bg": Color(0.4, 0.733, 0.416, 1), "circle": Color(0.50, 0.82, 0.52, 1)},
	"boss":      {"bg": Color(0.671, 0.278, 0.737, 1), "circle": Color(0.78, 0.40, 0.82, 1)},
	"narration": {"bg": Color(0.4, 0.733, 0.416, 1), "circle": Color(0.50, 0.82, 0.52, 1)},
	"victory":   {"bg": Color(1.0, 0.655, 0.149, 1), "circle": Color(1.0, 0.78, 0.35, 1)},
	"start":     {"bg": Color(0.353, 0.333, 0.506, 1), "circle": Color(0.45, 0.42, 0.60, 1)},
}
const DEFAULT_COLORS = {"bg": Color(0.353, 0.333, 0.506, 1), "circle": Color(0.45, 0.42, 0.60, 1)}
const MAX_LOG_COUNT = 3  # 최대 표시 로그 수 (초과 시 맨 위 오래된 것부터 삭제)

# ─── 이벤트 타입별 기본 아이콘 ───
const EVENT_ICONS = {
	"travel":    "🚶", "combat":    "⚔️",
	"shop":      "🛒", "npc":       "🧝",
	"boss":      "💀", "narration": "📖",
	"victory":   "🏆", "start":     "🚩",
}


func _ready():
	# 스크롤바 숨기기 (스크롤 기능은 유지, 바만 비표시)
	var vbar = scroll_container.get_v_scroll_bar()
	vbar.custom_minimum_size = Vector2.ZERO
	vbar.modulate.a = 0.0
	ui_ready.emit()


func _on_enter():
	"""UI 활성화 시 — 최초 1회만 호출 (영구 보존 UI)
	첫 로그는 auto_progress_interval 후 자동 표시 (즉시 X — 미진행 이벤트 오표시 방지)"""
	time_logs = GameManager.get_dream_time_logs()
	auto_progress_timer = 0.0
	# 첫 로그를 auto_progress_interval(2초) 후에 표시 — 즉시 표시 시
	# 아직 도달하지 않은 이벤트(전투 등)가 먼저 보이는 혼란 방지
	print("[ExplorationBottomUI] Loaded %d time logs, will show first after %.1fs" \
		% [time_logs.size(), auto_progress_interval])


func resume_from_index(idx: int):
	"""복귀 시 로그 인덱스를 이어받음"""
	current_log_index = idx


func _on_exit():
	pass


func _process(delta: float):
	if is_paused or current_log_index >= time_logs.size():
		return
	auto_progress_timer += delta
	if auto_progress_timer >= auto_progress_interval:
		auto_progress_timer = 0.0
		_show_next_log()


func set_paused(paused: bool):
	is_paused = paused


func resume():
	set_paused(false)


func _show_next_log():
	if current_log_index >= time_logs.size():
		return
	var log_data = time_logs[current_log_index]
	
	# 이벤트 로그는 노드 도달 시 show_pending_event()로 표시 (자동 진행 X)
	if log_data.get("type") == "event":
		is_paused = true
		return
	
	_add_log_box(log_data)
	current_log_index += 1


func show_pending_event():
	"""노드 도달 시 호출 — 남은 이동 로그를 빠르게 표시한 뒤 이벤트 로그를 표시"""
	while current_log_index < time_logs.size():
		var log_data = time_logs[current_log_index]
		_add_log_box(log_data)
		current_log_index += 1
		if log_data.get("type") == "event":
			return


# ─── 타임라인 로그 박스 ───

func _get_colors(type_key: String) -> Dictionary:
	return LOG_COLORS.get(type_key, DEFAULT_COLORS)


func _add_log_box(log_data: Dictionary):
	"""타임라인 스타일 로그 행 추가 (time_logs용 — 시간 컬럼 포함)"""
	var log_type = log_data.get("type", "travel")
	var type_key = log_data.get("event_type", log_type) if log_type == "event" else log_type
	var colors = _get_colors(type_key)
	var time_str: String = log_data.get("time", "")

	_build_log_row(
		log_data.get("icon", EVENT_ICONS.get(type_key, "📍")),
		log_data.get("text", ""),
		time_str,
		colors,
		false
	)

	print("[ExplorationBottomUI] Log: %s - %s" % [time_str, log_data.get("text", "")])


func _build_log_row(
		icon: String,
		text: String,
		time_str: String,
		colors: Dictionary,
		centered: bool = false):
	"""공용 행 빌더 — time_str이 비면 시간 컬럼 생략, centered이면 가운데 정렬"""

	# 전체 행 HBox
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# ── 왼쪽: 원형 아이콘 ──
	var circle_wrap = Control.new()
	circle_wrap.custom_minimum_size = Vector2(38, 48)
	circle_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var circle = Panel.new()
	circle.position = Vector2(3, 8)
	circle.size = Vector2(32, 32)
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var cs = StyleBoxFlat.new()
	cs.bg_color = colors.circle
	cs.corner_radius_top_left = 16
	cs.corner_radius_top_right = 16
	cs.corner_radius_bottom_left = 16
	cs.corner_radius_bottom_right = 16
	circle.add_theme_stylebox_override("panel", cs)

	var icon_lbl = Label.new()
	icon_lbl.text = icon
	icon_lbl.add_theme_font_size_override("font_size", 14)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	circle.add_child(icon_lbl)
	circle_wrap.add_child(circle)
	row.add_child(circle_wrap)

	# ── 오른쪽: 색상 패널 ──
	var panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var ps = StyleBoxFlat.new()
	ps.bg_color = colors.bg
	ps.corner_radius_top_left = 10
	ps.corner_radius_top_right = 10
	ps.corner_radius_bottom_left = 10
	ps.corner_radius_bottom_right = 10
	ps.content_margin_left = 5
	ps.content_margin_right = 12
	ps.content_margin_top = 8
	ps.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", ps)

	var content = HBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content)

	# 왼쪽 5px 여유
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(5, 0)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(spacer)

	# 내용 레이블 — "AM 10:00 - 내용" 형식
	var display_text = (time_str + " - " + text) if time_str != "" else text
	var text_lbl = Label.new()
	text_lbl.text = display_text
	text_lbl.add_theme_font_size_override("font_size", 14)
	text_lbl.add_theme_color_override("font_color", Color.WHITE)
	text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if centered:
		text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(text_lbl)

	row.add_child(panel)
	event_log.add_child(row)
	_trim_old_logs()

	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func _trim_old_logs():
	"""로그가 MAX_LOG_COUNT 초과 시 맨 위(가장 오래된) 로그부터 삭제"""
	while event_log.get_child_count() > MAX_LOG_COUNT:
		var oldest = event_log.get_child(0)
		event_log.remove_child(oldest)
		oldest.queue_free()


const NORMAL_ROW_HEIGHT = 48
const VICTORY_EXPANDED_HEIGHT = 72  # 1.5 * 48

func _build_victory_row(icon: String, text: String, colors: Dictionary):
	"""전투 승리 로그 — 펼침(기본, 1.5배 높이) / 클릭 시 축소"""
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size.y = VICTORY_EXPANDED_HEIGHT

	var circle_wrap = Control.new()
	circle_wrap.custom_minimum_size = Vector2(38, VICTORY_EXPANDED_HEIGHT)
	circle_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var circle = Panel.new()
	circle.position = Vector2(3, (VICTORY_EXPANDED_HEIGHT - 32) / 2)
	circle.size = Vector2(32, 32)
	circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cs = StyleBoxFlat.new()
	cs.bg_color = colors.circle
	cs.corner_radius_top_left = 16
	cs.corner_radius_top_right = 16
	cs.corner_radius_bottom_left = 16
	cs.corner_radius_bottom_right = 16
	circle.add_theme_stylebox_override("panel", cs)
	var icon_lbl = Label.new()
	icon_lbl.text = icon
	icon_lbl.add_theme_font_size_override("font_size", 14)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	circle.add_child(icon_lbl)
	circle_wrap.add_child(circle)
	row.add_child(circle_wrap)

	var panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = VICTORY_EXPANDED_HEIGHT
	var ps = StyleBoxFlat.new()
	ps.bg_color = colors.bg
	ps.corner_radius_top_left = 10
	ps.corner_radius_top_right = 10
	ps.corner_radius_bottom_left = 10
	ps.corner_radius_bottom_right = 10
	ps.content_margin_left = 5
	ps.content_margin_right = 12
	ps.content_margin_top = 8
	ps.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", ps)

	var content = HBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(5, 0)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(spacer)

	var text_lbl = Label.new()
	text_lbl.text = text
	text_lbl.add_theme_font_size_override("font_size", 14)
	text_lbl.add_theme_color_override("font_color", Color.WHITE)
	text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(text_lbl)

	row.add_child(panel)
	event_log.add_child(row)
	_trim_old_logs()

	var expanded = true
	var btn = Button.new()
	btn.flat = true
	btn.modulate.a = 0.0
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(btn)

	btn.pressed.connect(func():
		expanded = not expanded
		var target_h = VICTORY_EXPANDED_HEIGHT if expanded else NORMAL_ROW_HEIGHT
		row.custom_minimum_size.y = target_h
		circle_wrap.custom_minimum_size.y = target_h
		circle.position.y = (target_h - 32) / 2
		panel.custom_minimum_size.y = target_h
	)

	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func add_log(message: String, highlight: bool = false, event_type: String = ""):
	"""이벤트 서브 메시지 — 타임라인 박스 형식
	  highlight=true + event_type="victory" → 전투 승리 (펼침/축소, 1.5배 높이)
	  그 외 → 일반 로그 박스"""
	var type_key = event_type if event_type != "" else "travel"
	var colors = _get_colors(type_key)
	var icon = EVENT_ICONS.get(type_key, "📌")

	if highlight and event_type == "victory":
		await _build_victory_row(icon, message, colors)
	else:
		await _build_log_row(icon, message, "", colors, false)

	print("[ExplorationBottomUI] add_log (%s): %s" % [type_key, message])


func clear_log():
	for child in event_log.get_children():
		child.queue_free()
	current_log_index = 0
	auto_progress_timer = 0.0
