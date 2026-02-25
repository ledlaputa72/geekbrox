# CircleTransition.gd
# Circle wipe transition effect (Iris transition)
# Expands from center to reveal next scene

extends CanvasLayer

# ─── 시그널 ─────────────────────────────────────────
signal transition_finished

# ─── 설정 ───────────────────────────────────────────
const TRANSITION_DURATION = 1.0  # seconds
const CENTER_POSITION = Vector2(0.5, 0.4)  # Slightly above center (viewport area)

# ─── UI 노드 참조 ────────────────────────────────────
@onready var color_rect: ColorRect = $ColorRect
@onready var shader_material: ShaderMaterial = color_rect.material

# ─── 상태 ───────────────────────────────────────────
var is_transitioning: bool = false

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	# Get actual screen size for aspect ratio correction
	var screen_size = get_viewport().get_visible_rect().size
	shader_material.set_shader_parameter("screen_size", screen_size)
	
	# Start invisible (fully revealed)
	shader_material.set_shader_parameter("progress", 1.0)
	shader_material.set_shader_parameter("center", CENTER_POSITION)
	visible = false

# ─── Transition In (Close - 검은 원이 축소, 화면 가림) ────
func transition_in() -> void:
	"""Circle closes (shrinks to center), hiding current scene"""
	if is_transitioning:
		return
	
	is_transitioning = true
	visible = true
	
	# Animate progress: 1.0 (open) → 0.0 (closed)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(value: float): shader_material.set_shader_parameter("progress", value),
		1.0,
		0.0,
		TRANSITION_DURATION
	)
	
	await tween.finished
	is_transitioning = false
	transition_finished.emit()

# ─── Transition Out (Open - 검은 원이 확대, 화면 공개) ────
func transition_out() -> void:
	"""Circle opens (expands from center), revealing next scene"""
	if is_transitioning:
		return
	
	is_transitioning = true
	visible = true
	
	# Animate progress: 0.0 (closed) → 1.0 (open)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(
		func(value: float): shader_material.set_shader_parameter("progress", value),
		0.0,
		1.0,
		TRANSITION_DURATION
	)
	
	await tween.finished
	visible = false
	is_transitioning = false
	transition_finished.emit()

# ─── Full Transition (Close → Change Scene → Open) ────
func full_transition(target_scene: String) -> void:
	"""Complete transition: close → change scene → open"""
	await transition_in()  # Close circle
	
	# Change scene
	get_tree().change_scene_to_file(target_scene)
	
	# Wait 1 frame for scene to load
	await get_tree().process_frame
	
	await transition_out()  # Open circle

# ─── 즉시 닫기 (디버그용) ──────────────────────────────
func snap_closed() -> void:
	shader_material.set_shader_parameter("progress", 0.0)
	visible = true

func snap_open() -> void:
	shader_material.set_shader_parameter("progress", 1.0)
	visible = false
