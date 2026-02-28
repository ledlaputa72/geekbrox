# RunProgressBar.gd
# 런 진행 바 - 캡슐 형태 with 노드 아이콘들
# 노란 라인으로 진행도 표시, 빨간 핀으로 현재 위치 표시
# 자동 진행: 시간 경과로 화살표가 이동하고 노드 도착 시 시그널 발생

extends Control

signal node_reached(node_index: int, node_data: Dictionary)
signal run_completed()

# ─── 설정 ───────────────────────────────────────────
const BAR_HEIGHT = 25
const CAPSULE_MARGIN = 4
const NODE_SIZE = 20
const CURRENT_NODE_SIZE = 28
const PIN_SIZE = 12

# Auto-progress settings
const TIME_PER_NODE = 6.0  # 노드당 6초 (이전: 3.0초 → 2배 증가)

# ─── 노드 데이터 ─────────────────────────────────────
var nodes: Array = []
var current_node_index: int = 0
var progress_to_next: float = 0.0  # 0.0 ~ 1.0 (다음 노드까지 진행도)
var is_auto_progressing: bool = false
var paused: bool = false

# ─── UI 노드 참조 ────────────────────────────────────
@onready var capsule_bg: Panel = $CapsuleBG
@onready var progress_line: ColorRect = $ProgressLine
@onready var nodes_container: Control = $NodesContainer
@onready var current_pin: Label = $CurrentPin

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	update_display()

func apply_styles() -> void:
	# Capsule background (black rounded)
	var capsule_style = StyleBoxFlat.new()
	capsule_style.bg_color = Color(0.1, 0.1, 0.15)  # 검은색
	var corner_radius = int(BAR_HEIGHT / 2.0)
	capsule_style.corner_radius_top_left = corner_radius
	capsule_style.corner_radius_top_right = corner_radius
	capsule_style.corner_radius_bottom_left = corner_radius
	capsule_style.corner_radius_bottom_right = corner_radius
	capsule_style.border_width_left = 1  # 2 → 1 (절반)
	capsule_style.border_width_top = 1
	capsule_style.border_width_right = 1
	capsule_style.border_width_bottom = 1
	capsule_style.border_color = Color(0.3, 0.3, 0.4)  # 회색 테두리
	capsule_bg.add_theme_stylebox_override("panel", capsule_style)
	
	# Progress line (yellow, 더 얇게)
	progress_line.color = Color(1.0, 0.8, 0.2)  # 노란색
	
	# Current pin (red arrow, 작게)
	current_pin.add_theme_font_size_override("font_size", PIN_SIZE)
	current_pin.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))  # 빨간색
	current_pin.text = "▼"

# ─── 노드 설정 ───────────────────────────────────────
func set_nodes(node_data: Array, current_index: int = 0) -> void:
	nodes = node_data
	current_node_index = current_index
	update_display()

# ─── 디스플레이 업데이트 ─────────────────────────────
func update_display() -> void:
	if nodes.is_empty():
		return
	
	# Clear existing nodes (즉시 삭제 — queue_free는 다음 프레임까지 지연되어 노드 표시 불일치 발생)
	for child in nodes_container.get_children():
		nodes_container.remove_child(child)
		child.free()
	
	# Calculate positions
	var bar_width = size.x - (CAPSULE_MARGIN * 2)
	var node_count = nodes.size()
	var spacing = bar_width / (node_count - 1) if node_count > 1 else 0
	
	# Create node icons
	for i in range(node_count):
		var node = nodes[i]
		var x_pos = CAPSULE_MARGIN + (spacing * i)
		var is_current = node.get("current", false)
		
		# Node size (current node is larger)
		var node_size = CURRENT_NODE_SIZE if is_current else NODE_SIZE
		var icon_size = 14 if is_current else 12  # 28→14, 24→12 (절반)
		
		# Node panel (circle)
		var node_panel = Panel.new()
		node_panel.custom_minimum_size = Vector2(node_size, node_size)
		node_panel.position = Vector2(x_pos - node_size / 2, (BAR_HEIGHT - node_size) / 2)
		
		# Node style
		var node_style = StyleBoxFlat.new()
		node_style.corner_radius_top_left = node_size / 2
		node_style.corner_radius_top_right = node_size / 2
		node_style.corner_radius_bottom_left = node_size / 2
		node_style.corner_radius_bottom_right = node_size / 2
		
		# Border width (thicker for current, 축소에 맞춤)
		var border_width = 2 if is_current else 1  # 4→2, 3→1 (절반)
		node_style.border_width_left = border_width
		node_style.border_width_top = border_width
		node_style.border_width_right = border_width
		node_style.border_width_bottom = border_width
		
		# Color based on state
		if node.get("completed", false):
			node_style.bg_color = Color(0.3, 0.3, 0.35)  # 회색 (완료)
			node_style.border_color = Color(0.5, 0.5, 0.55)
		elif is_current:
			node_style.bg_color = Color(0.9, 0.25, 0.25)  # 밝은 빨간색 (현재)
			node_style.border_color = Color(1.0, 0.5, 0.5)
		else:
			node_style.bg_color = Color(0.2, 0.2, 0.25)  # 어두운 회색 (미완료)
			node_style.border_color = Color(0.4, 0.4, 0.45)
		
		node_panel.add_theme_stylebox_override("panel", node_style)
		
		# Node icon
		var icon_label = Label.new()
		icon_label.text = node.get("icon", "?")
		icon_label.add_theme_font_size_override("font_size", icon_size)
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_label.size = Vector2(node_size, node_size)
		node_panel.add_child(icon_label)
		
		nodes_container.add_child(node_panel)
	
	# Update progress line (will be updated smoothly from outside)
	_update_progress_line()
	
	# Update current pin position (above the enlarged node)
	var current_x = CAPSULE_MARGIN + (spacing * current_node_index)
	current_pin.position.x = current_x - PIN_SIZE / 2
	current_pin.position.y = -4  # Just above the top of enlarged node (축소된 크기에 맞춤)

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
	"""Update yellow line smoothly (0.0 to 1.0)"""
	if nodes.is_empty():
		return
	
	var bar_width = size.x - (CAPSULE_MARGIN * 2)
	var node_count = nodes.size()
	
	# Calculate total progress (current_node_index + progress_ratio)
	var total_progress = float(current_node_index) + progress_ratio
	var normalized_progress = total_progress / (node_count - 1) if node_count > 1 else 0.0
	
	progress_line.size.x = bar_width * normalized_progress
	progress_line.position.x = CAPSULE_MARGIN

func _update_progress_line() -> void:
	"""Update progress line to current node (called on node change)"""
	if nodes.is_empty():
		return
	
	var bar_width = size.x - (CAPSULE_MARGIN * 2)
	var node_count = nodes.size()
	var progress = float(current_node_index) / (node_count - 1) if node_count > 1 else 0.0
	
	progress_line.size.x = bar_width * progress
	progress_line.position.x = CAPSULE_MARGIN

# ─── 리사이즈 이벤트 ─────────────────────────────────
func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
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
	
	# 1프레임 대기: 노드 표시가 화면에 완전히 반영된 뒤 이벤트 시그널 발생
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
