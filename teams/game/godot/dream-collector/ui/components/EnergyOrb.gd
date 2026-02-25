extends Control

# Circular energy orb with radial progress

var current_energy: int = 3
var max_energy: int = 3
var timer_progress: float = 0.0  # 0.0 to 1.0

const ORB_RADIUS = 20.0
const PROGRESS_WIDTH = 4.0

func _ready():
	custom_minimum_size = Vector2(50, 50)
	queue_redraw()

func set_energy(current: int, maximum: int):
	current_energy = current
	max_energy = maximum
	queue_redraw()

func set_timer_progress(progress: float):
	timer_progress = clamp(progress, 0.0, 1.0)
	queue_redraw()

func _draw():
	var center = size / 2
	
	# Background orb (dark circle)
	draw_circle(center, ORB_RADIUS, Color(0.2, 0.2, 0.3, 1))
	
	# Orb border (light outline)
	draw_arc(center, ORB_RADIUS, 0, TAU, 32, Color(0.4, 0.4, 0.5, 1), 2.0)
	
	# Energy number (in center) - properly centered
	var font = ThemeDB.fallback_font
	var font_size = 20
	var text = str(current_energy)
	var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	
	# Center text: X centered, Y at center + half font size (visual centering)
	var text_x = center.x - text_size.x / 2
	var text_y = center.y + font_size / 2.5  # Empirical offset for visual centering
	
	draw_string(font, Vector2(text_x, text_y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(1, 1, 0.4, 1))
	
	# Radial progress (clockwise from top)
	if timer_progress > 0.0:
		var start_angle = -PI / 2  # Start at top (12 o'clock)
		var end_angle = start_angle + timer_progress * TAU
		var num_points = max(3, int(abs(end_angle - start_angle) / 0.1))
		draw_arc(center, ORB_RADIUS + PROGRESS_WIDTH, start_angle, end_angle, num_points, Color(1, 0.8, 0.2, 1), PROGRESS_WIDTH, true)
