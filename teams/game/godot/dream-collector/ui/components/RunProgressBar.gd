# RunProgressBar.gd
# 4개 이벤트 위치: A=(1) 고정, B·C=구간마다 +2, D=(n) 고정. 표시 (1)-B-C-...(n).
# 삼각형(플레이어): A에서 시작 → C까지 진행 후 다시 A로. C 지나면 B·C가 B+2,C+2로 슬라이드.

extends Control

signal node_reached(node_index: int, node_data: Dictionary)
signal run_completed()

# ─── 설정 ───────────────────────────────────────────
const BAR_HEIGHT = 25
const CAPSULE_MARGIN = 4
const NODE_SIZE = 20
const CURRENT_NODE_SIZE = 28
const PIN_SIZE = 12
const NODE_NUMBER_FONT_SIZE = 10
const ELLIPSIS = "..."
# 선 두께: 원(NODE_SIZE) 대비 비율
const TRACK_HEIGHT_RATIO := 0.20  # 이벤트 노드 사이 연결선 = 원의 20%
const PROGRESS_LINE_HEIGHT_RATIO := 0.15  # 진행선 = 원의 15%
# 이벤트만 원으로 표시 (노드는 선으로만, 다른 씬 없이 로그만)
var _event_indices: Array = []
var _visible_indices: Array = []
var _slot_centers_x: Array = []
var _slot_radii: Array = []  # 각 슬롯 원 반지름(또는 점선 반폭). 진행선이 원을 관통하지 않도록 사용

# Auto-progress settings
const TIME_PER_NODE = 6.0  # 노드/이벤트당 대기 6초

# ─── 경로 데이터 (이벤트 + 노드 순서) ─────────────────
var nodes: Array = []
var current_node_index: int = 0
var progress_to_next: float = 0.0  # 0.0 ~ 1.0 (다음 위치까지 진행도)
var is_auto_progressing: bool = false
var paused: bool = false
var _smooth_progress_ratio: float = 0.0  # 이동 중 구간 내 보간. _draw()에서 사용

# ─── UI 노드 참조 ────────────────────────────────────
@onready var capsule_bg: Panel = $CapsuleBG
@onready var progress_line: ColorRect = $ProgressLine
@onready var nodes_container: Control = $NodesContainer
@onready var current_pin: Label = $CurrentPin

# 콘텐츠 세로 블록: 원 행(BAR_HEIGHT) + 번호 행(16)
const CONTENT_HEIGHT := BAR_HEIGHT + 16

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	_update_minimum_width()
	apply_styles()
	update_display()

func _update_minimum_width() -> void:
	"""노드 경로 폭 = 화면 너비의 1/2, 중앙 정렬"""
	var vp_w: float = get_viewport().get_visible_rect().size.x
	custom_minimum_size.x = int(vp_w * 0.5)
	custom_minimum_size.y = 50

func _get_base_y() -> float:
	"""이벤트 원·선·점선·번호를 모두 세로 중앙에 맞추기 위한 기준 Y"""
	return (size.y - float(CONTENT_HEIGHT)) / 2.0

func _get_track_height() -> int:
	return max(2, int(float(NODE_SIZE) * TRACK_HEIGHT_RATIO))

func _get_progress_line_height() -> int:
	return max(1, int(float(NODE_SIZE) * PROGRESS_LINE_HEIGHT_RATIO))

func _layout_track_and_progress() -> void:
	"""연결선(캡슐)·진행선을 원의 20%/15% 두께로 배치, 세로 중앙 정렬."""
	var track_h: int = _get_track_height()
	var progress_h: int = _get_progress_line_height()
	var bar_width: float = size.x - (CAPSULE_MARGIN * 2)
	var base_y: float = _get_base_y()
	var track_y: float = base_y + (BAR_HEIGHT - float(track_h)) / 2.0
	var progress_y: float = base_y + (BAR_HEIGHT - float(progress_h)) / 2.0

	capsule_bg.position = Vector2(CAPSULE_MARGIN, track_y)
	capsule_bg.size = Vector2(bar_width, float(track_h))

	progress_line.position = Vector2(CAPSULE_MARGIN, progress_y)
	progress_line.size.y = float(progress_h)
	progress_line.visible = false  # 진행선은 _draw()에서 구간별로 그림 (원 관통 방지)
	# 회색 트랙은 _draw()에서 그려 진행선이 위에 오도록 함 (CapsuleBG는 숨김)
	capsule_bg.visible = false

	var capsule_style = capsule_bg.get_theme_stylebox("panel")
	if capsule_style is StyleBoxFlat:
		var cr: int = max(1, track_h / 2)
		capsule_style.corner_radius_top_left = cr
		capsule_style.corner_radius_top_right = cr
		capsule_style.corner_radius_bottom_left = cr
		capsule_style.corner_radius_bottom_right = cr
		capsule_bg.add_theme_stylebox_override("panel", capsule_style)

func apply_styles() -> void:
	# Capsule background (이벤트 노드 사이 연결선 = 원의 20% 두께)
	var track_h: int = _get_track_height()
	var capsule_style = StyleBoxFlat.new()
	capsule_style.bg_color = Color(0.1, 0.1, 0.15)
	var corner_radius = max(1, track_h / 2)
	capsule_style.corner_radius_top_left = corner_radius
	capsule_style.corner_radius_top_right = corner_radius
	capsule_style.corner_radius_bottom_left = corner_radius
	capsule_style.corner_radius_bottom_right = corner_radius
	capsule_style.border_width_left = 1
	capsule_style.border_width_top = 1
	capsule_style.border_width_right = 1
	capsule_style.border_width_bottom = 1
	capsule_style.border_color = Color(0.3, 0.3, 0.4)
	capsule_bg.add_theme_stylebox_override("panel", capsule_style)

	# Progress line (진행선 = 원의 15% 두께)
	progress_line.color = Color(1.0, 0.8, 0.2)

	current_pin.add_theme_font_size_override("font_size", PIN_SIZE)
	current_pin.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	current_pin.text = "▼"

# ─── 노드 설정 ───────────────────────────────────────
func set_nodes(node_data: Array, current_index: int = 0) -> void:
	nodes = node_data
	current_node_index = current_index
	update_display()

# ─── 이벤트 인덱스 (노드 제외, 원+숫자로 표시되는 이벤트만) ───
func _update_event_indices() -> void:
	_event_indices.clear()
	for i in range(nodes.size()):
		if nodes[i].get("type", "") != "general":
			_event_indices.append(i)

# 반환: 표시할 이벤트 슬롯 인덱스(0-based) 또는 -1(ellipsis). (1)-(2)-(3)...(8) → (3) 지나면 (1)-(4)-(5)...(8) 고정.
func _get_visible_event_slots() -> Array:
	var n: int = _event_indices.size()
	if n == 0:
		return []
	if n <= 4:
		return range(n)
	var path_seg: int = _get_path_segment_index()
	# (3) 이벤트는 (1)-(2)-(3) 화면에서 (3) 위치에서 진행. 전환은 실제로 다음 노드로 넘어간 뒤에만.
	var past_event_3: bool = current_node_index > _event_indices[2]
	# 이미 (1)-(4)-(5)...(8) 뷰로 넘어갔으면 되돌리지 않음
	var already_slid: bool = _visible_indices.size() >= 4 and _visible_indices[1] == 3
	if already_slid and path_seg >= 2:
		return [0, 3, 4, -1, n - 1]
	# (3)을 지나서 다음 노드로 advance 된 후에만 → (1) V - (4) - (5) ... (8) 로 전환
	if path_seg == 2 and past_event_3:
		return [0, 3, 4, -1, n - 1]
	# 초반: (1), (2), (3), ... 표시
	if path_seg <= 2:
		return [0, 1, 2, -1, n - 1]
	# 마지막 3이벤트 구간
	if path_seg >= n - 3:
		return [0, n - 3, n - 2, n - 1]
	# 중간: (1), (현재), (현재+1), ... , (n)
	return [0, path_seg, path_seg + 1, -1, n - 1]

func _get_path_segment_index() -> int:
	"""경로(전체 이벤트) 기준 현재 세그먼트. 레이아웃 전환 판단용."""
	var n: int = _event_indices.size()
	if n < 2:
		return 0
	var pos: float = float(current_node_index) + _smooth_progress_ratio
	for i in range(n - 1):
		if pos < float(_event_indices[i + 1]):
			return i
	return n - 2

func _event_index_for_node(full_index: int) -> int:
	"""현재 full_index가 속한 구간의 '다음' 이벤트 인덱스 (레이아웃 블록 계산용)"""
	for ev_i in range(_event_indices.size()):
		if _event_indices[ev_i] >= full_index:
			return ev_i
	return _event_indices.size() - 1

func _get_slot_index_for_event(ev: int) -> int:
	"""이벤트 인덱스 ev가 표시되는 슬롯 인덱스. 없으면 그 다음 슬롯(점선 등) 인덱스."""
	for i in range(_visible_indices.size()):
		if _visible_indices[i] == ev:
			return i
	# 숨겨진 이벤트(점선 구간): 이벤트 seg 다음 슬롯을 끝점으로 사용
	for i in range(_visible_indices.size()):
		if _visible_indices[i] >= 0 and _visible_indices[i] > ev:
			return i
	return _visible_indices.size() - 1

func _get_visible_events() -> Array:
	"""현재 레이아웃에 표시 중인 이벤트 인덱스만 (순서 유지). 슬라이드 후 (1),(4),(5),(n) 등."""
	var out: Array = []
	for ev in _visible_indices:
		if ev >= 0:
			out.append(ev)
	return out

func _get_segment_line_bounds(visible_seg: int, fill: float) -> Dictionary:
	"""진행선 구간: visible_seg = 보이는 구간 인덱스. 원 오른쪽~다음 원 왼쪽."""
	if _slot_centers_x.is_empty() or _slot_radii.is_empty():
		return {"start_x": 0.0, "end_x": 0.0, "partial_fill": 0.0}
	var vis: Array = _get_visible_events()
	if visible_seg < 0 or visible_seg >= vis.size() - 1:
		return {"start_x": 0.0, "end_x": 0.0, "partial_fill": fill}
	var start_slot: int = _get_slot_index_for_event(vis[visible_seg])
	var end_slot: int = _get_slot_index_for_event(vis[visible_seg + 1])
	start_slot = mini(start_slot, _slot_centers_x.size() - 1)
	end_slot = mini(end_slot, _slot_centers_x.size() - 1)
	var r_start: float = float(_slot_radii[start_slot]) if start_slot < _slot_radii.size() else float(NODE_SIZE) / 2.0
	var r_end: float = float(_slot_radii[end_slot]) if end_slot < _slot_radii.size() else float(NODE_SIZE) / 2.0
	var start_x: float = _slot_centers_x[start_slot] + r_start
	var end_x: float = _slot_centers_x[end_slot] - r_end
	return {"start_x": start_x, "end_x": end_x, "partial_fill": fill}

func _get_segment_and_fill(progress_ratio: float = 0.0) -> Array:
	"""보이는 구간 [visible_seg, fill]. A→C 구간: 직전 C 지난 직후=0, 현재 C 도착=1 (삼각형이 A에서 C까지 이동)."""
	var vis: Array = _get_visible_events()
	if vis.size() < 2:
		return [0, 1.0]
	var pos: float = float(current_node_index) + progress_ratio
	var seg: int = 0
	var seg_start: float = float(_event_indices[vis[0]])
	var seg_end: float = float(_event_indices[vis[1]])
	for i in range(vis.size() - 1):
		seg_start = float(_event_indices[vis[i]])
		seg_end = float(_event_indices[vis[i + 1]])
		if pos < seg_end:
			seg = i
			break
		seg = i + 1
	if seg >= vis.size() - 1:
		seg = vis.size() - 2
		seg_start = float(_event_indices[vis[seg]])
		seg_end = float(_event_indices[vis[seg + 1]])
	var fill: float = 0.0
	# A→C 첫 구간이고, B≥3 인 슬라이드 뷰: 직전 C 지난 직후를 0, 현재 C 도착을 1로 (삼각형 A에서 시작)
	if vis.size() >= 3 and vis[0] == 0 and vis[1] >= 3 and seg == 0:
		var c: int = vis[2]
		var prev_c: int = c - 2
		if prev_c >= 0:
			var start_after_prev: float = float(_event_indices[prev_c]) + 1.0
			var end_at_c: float = float(_event_indices[c])
			if end_at_c > start_after_prev:
				fill = (pos - start_after_prev) / (end_at_c - start_after_prev)
			else:
				fill = 1.0 if pos >= end_at_c else 0.0
		elif seg_end > seg_start:
			fill = (pos - seg_start) / (seg_end - seg_start)
	elif seg_end > seg_start:
		fill = (pos - seg_start) / (seg_end - seg_start)
	fill = clampf(fill, 0.0, 1.0)
	return [seg, fill]

func _make_node_circle(node: Dictionary, node_size: int, is_current: bool) -> Panel:
	var node_style = StyleBoxFlat.new()
	node_style.corner_radius_top_left = node_size / 2
	node_style.corner_radius_top_right = node_size / 2
	node_style.corner_radius_bottom_left = node_size / 2
	node_style.corner_radius_bottom_right = node_size / 2
	var border_width = 2 if is_current else 1
	node_style.border_width_left = border_width
	node_style.border_width_top = border_width
	node_style.border_width_right = border_width
	node_style.border_width_bottom = border_width
	if node.get("completed", false):
		node_style.bg_color = Color(0.3, 0.3, 0.35)
		node_style.border_color = Color(0.5, 0.5, 0.55)
	elif is_current:
		node_style.bg_color = Color(0.9, 0.25, 0.25)
		node_style.border_color = Color(1.0, 0.5, 0.5)
	else:
		node_style.bg_color = Color(0.2, 0.2, 0.25)
		node_style.border_color = Color(0.4, 0.4, 0.45)
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(node_size, node_size)
	panel.add_theme_stylebox_override("panel", node_style)
	var icon_size = 14 if is_current else 12
	var icon_label = Label.new()
	icon_label.text = node.get("icon", "?")
	icon_label.add_theme_font_size_override("font_size", icon_size)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.size = Vector2(node_size, node_size)
	panel.add_child(icon_label)
	return panel

# ─── 디스플레이 업데이트 (이벤트만 원, 노드 구간은 선으로 채움) ─────────────────────
func update_display() -> void:
	_layout_track_and_progress()
	if nodes.is_empty():
		return
	_update_event_indices()
	var new_slots: Array = _get_visible_event_slots()
	# (3) 도착 시 (2)(3) 왼쪽으로, (4)(5) 오른쪽에서 들어오는 슬라이드 애니
	if _visible_indices.size() == new_slots.size() and _visible_indices.size() >= 4 and nodes_container.get_child_count() > 0:
		var changed: bool = false
		for i in range(_visible_indices.size()):
			if _visible_indices[i] != new_slots[i]:
				changed = true
				break
		if changed:
			_play_slide_animation(new_slots)
			return
	_visible_indices = new_slots
	for child in nodes_container.get_children():
		nodes_container.remove_child(child)
		child.free()
	_slot_centers_x.clear()
	_slot_radii.clear()
	var bar_width: float = size.x - (CAPSULE_MARGIN * 2)
	var slot_count: int = _visible_indices.size()
	if slot_count == 0:
		return
	# (1)(2)(3)(n) 4개 이벤트 노드 사이 간격 동일: 원만 4등분
	var num_circles: int = 0
	for ev in _visible_indices:
		if ev >= 0:
			num_circles += 1
	var circle_gap: float = bar_width / float(max(1, num_circles - 1))  # 원 사이 동일 간격
	var base_y: float = _get_base_y()
	var circle_row_y: float = base_y
	var number_y: float = base_y + BAR_HEIGHT + 2

	for slot_i in range(slot_count):
		var ev_slot: int = _visible_indices[slot_i]
		var center_x: float
		if ev_slot == -1:
			# 점선(...)은 직전 원과 직후 원 사이 중간
			var circles_before: int = 0
			for j in range(slot_i):
				if _visible_indices[j] >= 0:
					circles_before += 1
			center_x = CAPSULE_MARGIN + (float(circles_before) - 0.5) * circle_gap
		else:
			var circle_index: int = 0
			for j in range(slot_i + 1):
				if _visible_indices[j] >= 0:
					circle_index += 1
			circle_index -= 1
			center_x = CAPSULE_MARGIN + float(circle_index) * circle_gap
		_slot_centers_x.append(center_x)

		if ev_slot == -1:
			_slot_radii.append(10)  # 점선(...) 반폭
			var ellipsis_lbl = Label.new()
			ellipsis_lbl.text = ELLIPSIS
			ellipsis_lbl.add_theme_font_size_override("font_size", 12)
			ellipsis_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
			ellipsis_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ellipsis_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			ellipsis_lbl.position = Vector2(center_x - 10, circle_row_y + (BAR_HEIGHT - 18) / 2)
			ellipsis_lbl.size = Vector2(20, 18)
			nodes_container.add_child(ellipsis_lbl)
			continue

		var full_idx: int = _event_indices[ev_slot]
		var node: Dictionary = nodes[full_idx]
		var is_current: bool = (full_idx == current_node_index)
		var node_size: int = CURRENT_NODE_SIZE if is_current else NODE_SIZE
		_slot_radii.append(node_size / 2)
		var panel = _make_node_circle(node, node_size, is_current)
		panel.set_meta("event_slot", ev_slot)
		panel.position = Vector2(center_x - node_size / 2, circle_row_y + (BAR_HEIGHT - node_size) / 2)
		if ev_slot == 0:
			panel.z_index = 1
		nodes_container.add_child(panel)

		var num_lbl = Label.new()
		num_lbl.set_meta("event_slot", ev_slot)
		if ev_slot == 0:
			num_lbl.z_index = 1
		num_lbl.text = "(%d)" % (ev_slot + 1)
		num_lbl.add_theme_font_size_override("font_size", NODE_NUMBER_FONT_SIZE)
		num_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.position = Vector2(center_x - 22, number_y)
		num_lbl.size = Vector2(44, 14)
		nodes_container.add_child(num_lbl)

	_update_progress_line()
	_update_pin_position()

# ─── 현재 노드 변경 ──────────────────────────────────
func set_current_node(index: int) -> void:
	if index < 0 or index >= nodes.size():
		return
	
	# Mark previous as completed
	if current_node_index < nodes.size():
		nodes[current_node_index]["completed"] = true
		nodes[current_node_index]["current"] = false
	
	# Set new current
	current_node_index = index
	nodes[current_node_index]["current"] = true
	
	update_display()

# ─── 진행도 실시간 업데이트 (부드러운 애니메이션) ──────
func update_progress_smooth(progress_ratio: float) -> void:
	"""이벤트 구간 기준으로 노란 선을 구간별로 부드럽게 채움 (0.0~1.0). 원 관통 없음."""
	if nodes.is_empty():
		return
	_update_event_indices()
	_smooth_progress_ratio = progress_ratio
	queue_redraw()
	var tip_x: float = _get_progress_tip_x(progress_ratio)
	current_pin.position.x = tip_x - PIN_SIZE / 2
	current_pin.position.y = _get_base_y() - 4

func _get_progress_tip_x(progress_ratio: float = 0.0) -> float:
	"""진행선 끝(원 관통 없이 구간 기준)의 x 좌표. 시작 노드부터 (1), (2)... 순으로 이동."""
	if _slot_centers_x.is_empty() or _slot_radii.is_empty():
		return CAPSULE_MARGIN
	var seg_fill: Array = _get_segment_and_fill(progress_ratio)
	var seg: int = seg_fill[0]
	var fill: float = seg_fill[1]
	var b: Dictionary = _get_segment_line_bounds(seg, fill)
	return b.start_x + (b.end_x - b.start_x) * fill

func _update_pin_position() -> void:
	"""구간 기준 진행선 끝에 빨간 핀 배치"""
	if nodes.is_empty():
		return
	var tip_x: float = _get_progress_tip_x(0.0)
	current_pin.position.x = tip_x - PIN_SIZE / 2
	current_pin.position.y = _get_base_y() - 4

func _play_slide_animation(new_slots: Array) -> void:
	"""B·C 위치 원이 A(1) 뒤로 들어가 사라지고, 새 B·C가 오른쪽에서 등장. 삼각형은 완료 후 A로."""
	var base_y: float = _get_base_y()
	var circle_row_y: float = base_y
	var number_y: float = base_y + BAR_HEIGHT + 2
	var target_behind_one: float = _slot_centers_x[0] if _slot_centers_x.size() > 0 else CAPSULE_MARGIN
	var target_panel_x: float = target_behind_one - NODE_SIZE / 2
	var target_label_x: float = target_behind_one - 22
	var start_right: float = size.x + 80.0
	var duration: float = 0.35
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	# 나갈 노드 = 현재 B·C (슬롯 1,2의 이벤트 인덱스)
	var out_b: int = _visible_indices[1] if _visible_indices.size() > 1 else -1
	var out_c: int = _visible_indices[2] if _visible_indices.size() > 2 else -1
	for child in nodes_container.get_children():
		var es: int = child.get_meta("event_slot", -2)
		if es == out_b or es == out_c:
			var to_x: float = target_panel_x if child is Panel else target_label_x
			tween.tween_property(child, "position:x", to_x, duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	# 들어올 노드 = 새 B·C (new_slots[1], new_slots[2])
	var target_centers: Array = [_slot_centers_x[1], _slot_centers_x[2]] if _slot_centers_x.size() >= 3 else [CAPSULE_MARGIN + 100.0, CAPSULE_MARGIN + 200.0]
	for idx in range(2):
		if new_slots.size() <= idx + 1:
			continue
		var ev_slot: int = new_slots[idx + 1]
		if ev_slot < 0 or ev_slot >= _event_indices.size():
			continue
		var full_idx: int = _event_indices[ev_slot]
		var node: Dictionary = nodes[full_idx]
		var node_size: int = NODE_SIZE
		var panel: Panel = _make_node_circle(node, node_size, false)
		panel.set_meta("event_slot", ev_slot)
		panel.position = Vector2(start_right + idx * 60, circle_row_y + (BAR_HEIGHT - node_size) / 2)
		nodes_container.add_child(panel)
		var num_lbl: Label = Label.new()
		num_lbl.set_meta("event_slot", ev_slot)
		num_lbl.text = "(%d)" % (ev_slot + 1)
		num_lbl.add_theme_font_size_override("font_size", NODE_NUMBER_FONT_SIZE)
		num_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num_lbl.position = Vector2(start_right + idx * 60 - 22, number_y)
		num_lbl.size = Vector2(44, 14)
		nodes_container.add_child(num_lbl)
		var target_x: float = target_centers[idx] - node_size / 2
		tween.tween_property(panel, "position:x", target_x, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(num_lbl, "position:x", target_centers[idx] - 22, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.finished.connect(_on_slide_animation_finished.bind(new_slots))

func _on_slide_animation_finished(new_slots: Array) -> void:
	_visible_indices = new_slots
	update_display()
	# (1) 다음에 삼각형(V) 위치 고정: (3) 지난 직후이므로 (1) 오른쪽
	if _slot_centers_x.size() > 0 and _slot_radii.size() > 0:
		var one_right_x: float = _slot_centers_x[0] + _slot_radii[0]
		current_pin.position.x = one_right_x - PIN_SIZE / 2
		current_pin.position.y = _get_base_y() - 4

func _update_progress_line() -> void:
	"""진행선은 _draw()에서 원 오른쪽~다음 원 왼쪽 구간만 그림. 여기서는 redraw만."""
	if nodes.is_empty():
		return
	_smooth_progress_ratio = 0.0
	queue_redraw()

func _draw() -> void:
	"""회색 트랙(안 지나간 곳) 먼저 그린 뒤, 지나간 구간만 노란 진행선으로 위에 그림. 원 관통 없음."""
	var base_y: float = _get_base_y()
	var bar_width: float = size.x - (CAPSULE_MARGIN * 2)
	var track_h: int = _get_track_height()
	var track_y: float = base_y + (BAR_HEIGHT - float(track_h)) / 2.0
	# 1) 회색 트랙 (전체 구간 = 안 지나간 곳)
	var gray: Color = Color(0.1, 0.1, 0.15)
	draw_rect(Rect2(CAPSULE_MARGIN, track_y, bar_width, float(track_h)), gray)
	# 테두리 비슷하게
	draw_rect(Rect2(CAPSULE_MARGIN, track_y, bar_width, 1), Color(0.3, 0.3, 0.4))
	draw_rect(Rect2(CAPSULE_MARGIN, track_y + float(track_h) - 1, bar_width, 1), Color(0.3, 0.3, 0.4))

	if nodes.is_empty() or _slot_centers_x.is_empty() or _slot_radii.is_empty():
		return
	var seg_fill: Array = _get_segment_and_fill(_smooth_progress_ratio)
	var seg: int = seg_fill[0]
	var fill: float = seg_fill[1]
	var progress_h: float = float(_get_progress_line_height())
	var y: float = base_y + (BAR_HEIGHT - progress_h) / 2.0
	var color: Color = Color(1.0, 0.8, 0.2)
	# 2) 지나간 구간: 세그먼트 0(시작~(1))부터 표시. 노드 도착 시에도 이전 구간이 채워지도록 0부터 그림
	var first_seg: int = 0
	for i in range(first_seg, seg):
		var b: Dictionary = _get_segment_line_bounds(i, 1.0)
		var seg_start: float = b.start_x
		var seg_end: float = b.end_x
		if seg_end > seg_start:
			draw_rect(Rect2(seg_start, y, seg_end - seg_start, progress_h), color)
	if seg >= first_seg:
		var b_partial: Dictionary = _get_segment_line_bounds(seg, fill)
		var partial_end: float = b_partial.start_x + (b_partial.end_x - b_partial.start_x) * fill
		if partial_end > b_partial.start_x:
			draw_rect(Rect2(b_partial.start_x, y, partial_end - b_partial.start_x, progress_h), color)

# ─── 리사이즈 이벤트 ─────────────────────────────────
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_minimum_width()
		update_display()

# ─── 자동 진행 시스템 ─────────────────────────────────
func _process(delta: float) -> void:
	if not is_auto_progressing or paused or nodes.is_empty():
		return
	
	# 마지막 노드 도착 시 정지
	if current_node_index >= nodes.size() - 1:
		is_auto_progressing = false
		run_completed.emit()
		print("[RunProgressBar] Run completed!")
		return
	
	# 진행도 업데이트
	progress_to_next += delta / TIME_PER_NODE
	
	# 부드러운 진행선 업데이트
	update_progress_smooth(progress_to_next)
	
	# 다음 노드 도착
	if progress_to_next >= 1.0:
		progress_to_next = 0.0
		_advance_to_next_node()

func _advance_to_next_node() -> void:
	"""다음 노드로 이동하고 시그널 발생"""
	current_node_index += 1
	
	if current_node_index >= nodes.size():
		is_auto_progressing = false
		run_completed.emit()
		return
	
	# 노드 상태 업데이트
	for i in range(nodes.size()):
		nodes[i]["current"] = (i == current_node_index)
		nodes[i]["completed"] = (i < current_node_index)
	
	update_display()
	_update_progress_line()
	
	# 1프레임 대기: 진행 바 반영 후 노드/이벤트 도착 시그널 발생
	await get_tree().process_frame
	
	# Emit signal
	var node_data = nodes[current_node_index]
	node_reached.emit(current_node_index, node_data)
	print("[RunProgressBar] Node reached: ", current_node_index, " - ", node_data)

func start_auto_progress() -> void:
	"""자동 진행 시작"""
	is_auto_progressing = true
	paused = false
	progress_to_next = 0.0
	print("[RunProgressBar] Auto-progress started")

func stop_auto_progress() -> void:
	"""자동 진행 정지"""
	is_auto_progressing = false
	print("[RunProgressBar] Auto-progress stopped")

func pause_progress() -> void:
	"""일시 정지 (이벤트 발생 시)"""
	paused = true
	print("[RunProgressBar] Progress paused")

func resume_progress() -> void:
	"""재개 (이벤트 종료 후)"""
	paused = false
	print("[RunProgressBar] Progress resumed")

# ─── 수동 노드 진행 (버튼으로 다음 노드 이동) ─────────────
func get_next_node_display_text() -> String:
	"""다음 노드 타입에 따른 버튼 라벨 (탐험/전투/상점 등)"""
	if nodes.is_empty():
		return "다음"
	if current_node_index >= nodes.size() - 1:
		return "완료"
	var next_node = nodes[current_node_index + 1]
	var t = next_node.get("type", "narration")
	match t:
		"start":    return "시작"
		"combat":   return "전투"
		"shop":     return "상점"
		"npc":      return "NPC"
		"boss":     return "보스"
		"narration": return "탐험"
		_:          return "탐험"


func set_progress_ratio(ratio: float) -> void:
	"""이동 중 진행선 표시 (0.0 ~ 1.0, 수동 진행 시 트윈용)"""
	progress_to_next = clampf(ratio, 0.0, 1.0)
	update_progress_smooth(progress_to_next)


func advance_to_next_node_manual() -> void:
	"""버튼으로 다음 노드로 이동 (이동 연출 후 호출)"""
	if current_node_index >= nodes.size() - 1:
		is_auto_progressing = false
		run_completed.emit()
		return
	progress_to_next = 0.0
	_advance_to_next_node()
