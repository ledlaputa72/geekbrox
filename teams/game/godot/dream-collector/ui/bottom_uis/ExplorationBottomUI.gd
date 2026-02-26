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

# ─── 타입별 색상 팔레트 ───
const LOG_COLORS = {
	"travel":    {"bg": Color(0.55, 0.45, 0.12, 1), "circle": Color(0.72, 0.60, 0.18, 1)},
	"combat":    {"bg": Color(0.68, 0.18, 0.14, 1), "circle": Color(0.85, 0.28, 0.22, 1)},
	"shop":      {"bg": Color(0.18, 0.38, 0.70, 1), "circle": Color(0.28, 0.52, 0.88, 1)},
	"npc":       {"bg": Color(0.18, 0.52, 0.28, 1), "circle": Color(0.28, 0.68, 0.38, 1)},
	"boss":      {"bg": Color(0.42, 0.14, 0.62, 1), "circle": Color(0.55, 0.22, 0.78, 1)},
	"narration": {"bg": Color(0.28, 0.38, 0.58, 1), "circle": Color(0.38, 0.50, 0.72, 1)},
	"victory":   {"bg": Color(0.65, 0.44, 0.05, 1), "circle": Color(0.85, 0.60, 0.10, 1)},
	"start":     {"bg": Color(0.25, 0.32, 0.50, 1), "circle": Color(0.35, 0.45, 0.65, 1)},
}
const DEFAULT_COLORS = {"bg": Color(0.55, 0.45, 0.12, 1), "circle": Color(0.72, 0.60, 0.18, 1)}

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
	_add_log_box(log_data)
	current_log_index += 1


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
	ps.content_margin_left = 12
	ps.content_margin_right = 12
	ps.content_margin_top = 8
	ps.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", ps)

	var content = HBoxContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("separation", 8)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content)

	# 시간 컬럼 (time_str이 있을 때만)
	if time_str != "":
		var time_lbl = Label.new()
		time_lbl.text = time_str
		time_lbl.add_theme_font_size_override("font_size", 13)
		time_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.85))
		time_lbl.custom_minimum_size = Vector2(72, 0)
		time_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		time_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(time_lbl)

		var sep = Label.new()
		sep.text = "│"
		sep.add_theme_font_size_override("font_size", 13)
		sep.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		sep.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(sep)

	# 내용 레이블
	var text_lbl = Label.new()
	text_lbl.text = text
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

	await get_tree().process_frame
	scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)


func add_log(message: String, highlight: bool = false, event_type: String = ""):
	"""이벤트 서브 메시지 — 모두 타임라인 박스 형식으로 표시
	  highlight=true  + event_type="victory" → 🏆 전투 승리 배너 (황금, 가운데 정렬)
	  highlight=false + event_type=...       → 이벤트 진입 알림 박스 (타입별 색상, 시간 없음)"""
	var type_key = event_type if event_type != "" else "travel"
	var colors = _get_colors(type_key)
	var icon = EVENT_ICONS.get(type_key, "📌")

	if highlight:
		# 전투 승리 등 특별 배너 — 가운데 정렬, 시간 없음
		await _build_log_row(icon, message, "", colors, true)
	else:
		# 이벤트 진입 알림 — 타임라인 박스 (시간 없음)
		await _build_log_row(icon, message, "", colors, false)

	print("[ExplorationBottomUI] add_log (%s): %s" % [type_key, message])


func clear_log():
	for child in event_log.get_children():
		child.queue_free()
	current_log_index = 0
	auto_progress_timer = 0.0
