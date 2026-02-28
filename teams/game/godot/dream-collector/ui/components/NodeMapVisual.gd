extends Control

# Visual node map with path lines and character

var nodes: Array = []  # Array of node data
var current_node_index: int = 0

# Visual settings
const NODE_RADIUS = 20.0
const NODE_SPACING = 80.0
const LINE_WIDTH = 6.0
const COMPLETED_COLOR = Color(0.3, 0.7, 0.3, 1)  # Green
const PENDING_COLOR = Color(0.5, 0.5, 0.5, 1)  # Gray
const CURRENT_COLOR = Color(1, 0.8, 0.2, 1)  # Gold

# Character animation
var character_pos: Vector2 = Vector2.ZERO
var character_target_pos: Vector2 = Vector2.ZERO
var is_moving: bool = false

func _ready():
	custom_minimum_size = Vector2(0, 100)

func set_nodes(node_data: Array, current_index: int):
	nodes = node_data
	current_node_index = current_index
	_calculate_positions()
	queue_redraw()

func _calculate_positions():
	"""Calculate node positions"""
	if nodes.is_empty():
		return
	
	# Calculate character position
	var start_x = 50.0
	var y_pos = size.y / 2
	
	if current_node_index < nodes.size():
		character_target_pos = Vector2(start_x + current_node_index * NODE_SPACING, y_pos)
		
		if character_pos == Vector2.ZERO:
			character_pos = character_target_pos

func _process(delta):
	# Smooth character movement
	if character_pos.distance_to(character_target_pos) > 1.0:
		character_pos = character_pos.lerp(character_target_pos, delta * 3.0)
		is_moving = true
		queue_redraw()
	else:
		if is_moving:
			is_moving = false
			queue_redraw()

func _draw():
	if nodes.is_empty():
		return
	
	var start_x = 50.0
	var y_pos = size.y / 2
	
	# Draw path lines
	for i in range(nodes.size() - 1):
		var node = nodes[i]
		var next_node = nodes[i + 1]
		
		var start_pos = Vector2(start_x + i * NODE_SPACING, y_pos)
		var end_pos = Vector2(start_x + (i + 1) * NODE_SPACING, y_pos)
		
		# Line color based on progress
		var line_color = PENDING_COLOR
		if i < current_node_index:
			line_color = COMPLETED_COLOR
		
		draw_line(start_pos, end_pos, line_color, LINE_WIDTH, true)
	
	# Draw nodes
	for i in range(nodes.size()):
		var node = nodes[i]
		var pos = Vector2(start_x + i * NODE_SPACING, y_pos)
		
		# Node circle
		var node_color = PENDING_COLOR
		if i < current_node_index:
			node_color = COMPLETED_COLOR
		elif i == current_node_index:
			node_color = CURRENT_COLOR
		
		draw_circle(pos, NODE_RADIUS, node_color)
		
		# Node border
		draw_arc(pos, NODE_RADIUS, 0, TAU, 32, Color.WHITE, 2.0)
		
		# Node icon
		var icon = _get_node_icon(node.type)
		var font = ThemeDB.fallback_font
		var font_size = 16
		var text_size = font.get_string_size(icon, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos = pos - text_size / 2
		text_pos.y += font_size / 2.5  # Center vertically
		draw_string(font, text_pos, icon, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
		
		# Node number (bottom)
		var num_text = str(i + 1)
		var num_size = font.get_string_size(num_text, HORIZONTAL_ALIGNMENT_CENTER, -1, 12)
		var num_pos = Vector2(pos.x - num_size.x / 2, pos.y + NODE_RADIUS + 16)
		draw_string(font, num_pos, num_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	
	# Draw character (walking person emoji)
	var font = ThemeDB.fallback_font
	var char_icon = "👤"
	var font_size = 24
	var char_size = font.get_string_size(char_icon, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var char_pos = character_pos - Vector2(char_size.x / 2, -NODE_RADIUS - 20)
	char_pos.y += font_size / 2.5
	draw_string(font, char_pos, char_icon, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func _get_node_icon(node_type: String) -> String:
	"""Get icon for node type"""
	match node_type:
		"Combat":
			return "⚔"
		"Shop":
			return "🛒"
		"Event":
			return "!"
		"Memory":
			return "💎"
		"Upgrade":
			return "⬆"
		"Boss":
			return "👹"
		_:
			return "?"
