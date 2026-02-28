extends Control

"""
DreamCardSelection - 타로 카드 3단계 선택 화면
Steve의 디자인 요구사항:
- 카드: 가로로 넓은 타로 카드 (140x220)
- 초기: 3장이 상단에 가로로 나란히 (뒤집힌 상태)
- 선택: 선택된 카드가 아래로 내려오며 뒤집히고, 나머지는 사라짐
- 완료: 선택된 3장이 2열로 배치
- 로그: 블록 형태 패널 (홈 화면 "지난 꿈들" 스타일)
"""

# Stages
enum Stage {
	START,    # 시작
	JOURNEY,  # 여정
	END       # 종료
}

var current_stage: Stage = Stage.START
var selected_cards: Array = []  # [start_card, journey_card, end_card]
var card_nodes: Array = []

# UI References
@onready var top_area = $TopArea
@onready var card_container = $TopArea/CardContainer
@onready var bottom_area = $BottomArea
@onready var log_container = $BottomArea/ScrollContainer/LogContainer
@onready var start_button = $BottomArea/StartButton
@onready var bottom_nav = $BottomNav

# Stage names
const STAGE_NAMES = {
	Stage.START: "시작",
	Stage.JOURNEY: "여정",
	Stage.END: "종료"
}

const STAGE_PROMPTS = {
	Stage.START: "당신의 꿈의 시작을 선택하세요",
	Stage.JOURNEY: "당신의 꿈의 여정을 선택하세요",
	Stage.END: "당신의 꿈의 마지막을 선택하세요"
}

# Card data (9 cards total: 3 per stage)
const CARD_DATA = {
	Stage.START: [
		{
			"id": "start_1", 
			"name": "시작", 
			"emoji": "🌅",
			"node_count": 2,
			"hours": 4,
			"nodes": [
				{"type": "combat", "icon": "⚔️"},
				{"type": "shop", "icon": "🛒"}
			],
			"difficulty": "쉬움",
			"rewards": "🪙50"
		},
		{
			"id": "start_2", 
			"name": "여명", 
			"emoji": "🌄",
			"node_count": 2,
			"hours": 3,
			"nodes": [
				{"type": "combat", "icon": "⚔️"},
				{"type": "npc", "icon": "💬"}
			],
			"difficulty": "쉬움",
			"rewards": "⚡10"
		},
		{
			"id": "start_3", 
			"name": "출발", 
			"emoji": "🚪",
			"node_count": 2,
			"hours": 5,
			"nodes": [
				{"type": "narration", "icon": "📖"},
				{"type": "combat", "icon": "⚔️"}
			],
			"difficulty": "쉬움",
			"rewards": "🎴1"
		}
	],
	Stage.JOURNEY: [
		{
			"id": "journey_1", 
			"name": "여정", 
			"emoji": "🗺️",
			"node_count": 3,
			"hours": 5,
			"nodes": [
				{"type": "combat", "icon": "⚔️"},
				{"type": "shop", "icon": "🛒"},
				{"type": "combat", "icon": "⚔️"}
			],
			"difficulty": "보통",
			"rewards": "🪙80"
		},
		{
			"id": "journey_2", 
			"name": "탐험", 
			"emoji": "🧭",
			"node_count": 3,
			"hours": 4,
			"nodes": [
				{"type": "combat", "icon": "⚔️"},
				{"type": "npc", "icon": "💬"},
				{"type": "combat", "icon": "⚔️"}
			],
			"difficulty": "보통",
			"rewards": "🎴2"
		},
		{
			"id": "journey_3", 
			"name": "모험", 
			"emoji": "⛰️",
			"node_count": 3,
			"hours": 6,
			"nodes": [
				{"type": "combat", "icon": "⚔️"},
				{"type": "combat", "icon": "⚔️"},
				{"type": "combat", "icon": "⚔️"}
			],
			"difficulty": "어려움",
			"rewards": "🪙100"
		}
	],
	Stage.END: [
		{
			"id": "end_1", 
			"name": "종료", 
			"emoji": "🌆",
			"node_count": 2,
			"hours": 2,
			"nodes": [
				{"type": "combat", "icon": "⚔️"},
				{"type": "boss", "icon": "💀"}
			],
			"difficulty": "어려움",
			"rewards": "🎴3, 🪙150"
		},
		{
			"id": "end_2", 
			"name": "귀환", 
			"emoji": "🏠",
			"node_count": 2,
			"hours": 3,
			"nodes": [
				{"type": "shop", "icon": "🛒"},
				{"type": "boss", "icon": "💀"}
			],
			"difficulty": "보통",
			"rewards": "🎴2, 🪙100"
		},
		{
			"id": "end_3", 
			"name": "완성", 
			"emoji": "👑",
			"node_count": 2,
			"hours": 2,
			"nodes": [
				{"type": "npc", "icon": "💬"},
				{"type": "boss", "icon": "💀"}
			],
			"difficulty": "어려움",
			"rewards": "🎴4, ⚡20"
		}
	]
}

func _ready():
	_setup_ui()
	_start_stage(Stage.START)

func _setup_ui():
	"""Setup UI styling"""
	# TopArea background (brown)
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color(0.6, 0.4, 0.2, 1)  # Brown
	top_area.add_theme_stylebox_override("panel", top_style)
	
	# BottomArea background (dark)
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.1, 0.1, 0.15, 1)  # Dark
	bottom_area.add_theme_stylebox_override("panel", bottom_style)
	
	# Start button (hidden initially)
	UITheme.apply_button_style(start_button, "primary")
	start_button.visible = false
	start_button.pressed.connect(_on_start_button_pressed)
	
	# BottomNav
	bottom_nav.set_active_tab(0)  # Home tab
	bottom_nav.tab_pressed.connect(_on_bottom_nav_pressed)

func _start_stage(stage: Stage):
	"""Start a new stage with 3 cards"""
	current_stage = stage
	
	# Clear previous cards
	for card in card_nodes:
		card.queue_free()
	card_nodes.clear()
	
	# Clear logs
	for child in log_container.get_children():
		child.queue_free()
	
	# Add stage prompt log
	_add_log_block(STAGE_PROMPTS[stage], Color(1.0, 0.9, 0.4))  # Yellow
	
	# Create 3 cards for this stage
	var cards_data = CARD_DATA[stage]
	_create_cards(cards_data)

func _create_cards(cards_data: Array):
	"""Create 3 tarot cards at top"""
	# Card positions: 3 cards horizontally at top
	# Screen width: 390, Card width: 140
	# Spacing: (390 - 140*3) / 4 = -30/4 = invalid
	# Better: (390 - 140*3) / 2 = gaps on sides
	# Let's use: x = [15, 135, 255] with 120px spacing
	var card_positions = [
		Vector2(15, 60),    # Left
		Vector2(135, 60),   # Center  
		Vector2(255, 60)    # Right
	]
	
	for i in range(3):
		var card = _create_card_node(cards_data[i], i)
		card.position = card_positions[i]
		card.modulate.a = 0  # Start invisible
		card_container.add_child(card)
		card_nodes.append(card)
		
		# Fade in animation
		_animate_card_appear(card, i * 0.15)

func _create_card_node(card_data: Dictionary, index: int) -> Control:
	"""Create a single tarot card (140x220)"""
	var card = Control.new()
	card.custom_minimum_size = Vector2(140, 220)
	card.size = Vector2(140, 220)
	
	# Store metadata
	card.set_meta("card_data", card_data)
	card.set_meta("is_selected", false)
	
	# === Card BACK (visible initially) ===
	var card_back = Panel.new()
	card_back.name = "CardBack"
	card_back.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.25, 0.15, 0.4, 1)  # Dark purple
	back_style.border_width_left = 3
	back_style.border_width_right = 3
	back_style.border_width_top = 3
	back_style.border_width_bottom = 3
	back_style.border_color = Color(0.7, 0.5, 0.9, 1)  # Light purple
	back_style.corner_radius_top_left = 8
	back_style.corner_radius_top_right = 8
	back_style.corner_radius_bottom_left = 8
	back_style.corner_radius_bottom_right = 8
	card_back.add_theme_stylebox_override("panel", back_style)
	card.add_child(card_back)
	
	# Card back content (crystal ball)
	var back_vbox = VBoxContainer.new()
	back_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	back_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_back.add_child(back_vbox)
	
	var back_icon = Label.new()
	back_icon.text = "🔮"
	back_icon.add_theme_font_size_override("font_size", 72)
	back_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	back_vbox.add_child(back_icon)
	
	var stars = Label.new()
	stars.text = "✨ ✨ ✨"
	stars.add_theme_font_size_override("font_size", 18)
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	back_vbox.add_child(stars)
	
	# === Card FRONT (hidden initially) ===
	var card_front = Panel.new()
	card_front.name = "CardFront"
	card_front.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_front.visible = false
	
	var front_style = StyleBoxFlat.new()
	front_style.bg_color = Color(0.3, 0.2, 0.5, 1)  # Purple
	front_style.border_width_left = 3
	front_style.border_width_right = 3
	front_style.border_width_top = 3
	front_style.border_width_bottom = 3
	front_style.border_color = Color(0.7, 0.5, 0.9, 1)
	front_style.corner_radius_top_left = 8
	front_style.corner_radius_top_right = 8
	front_style.corner_radius_bottom_left = 8
	front_style.corner_radius_bottom_right = 8
	card_front.add_theme_stylebox_override("panel", front_style)
	card.add_child(card_front)
	
	# Card front content (detailed info)
	var front_vbox = VBoxContainer.new()
	front_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	front_vbox.add_theme_constant_override("separation", 4)
	card_front.add_child(front_vbox)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	front_vbox.add_child(margin)
	
	var content_vbox = VBoxContainer.new()
	content_vbox.add_theme_constant_override("separation", 6)
	margin.add_child(content_vbox)
	
	# Name
	var name_label = Label.new()
	name_label.text = card_data.name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(name_label)
	
	# Emoji
	var emoji = Label.new()
	emoji.text = card_data.emoji
	emoji.add_theme_font_size_override("font_size", 48)
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(emoji)
	
	# Divider
	var sep1 = HSeparator.new()
	content_vbox.add_child(sep1)
	
	# Node info
	var node_info = Label.new()
	node_info.text = "%d노드, %d시간" % [card_data.node_count, card_data.hours]
	node_info.add_theme_font_size_override("font_size", 13)
	node_info.add_theme_color_override("font_color", Color(0.8, 0.8, 1))
	node_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(node_info)
	
	# Node icons
	var icons_hbox = HBoxContainer.new()
	icons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	icons_hbox.add_theme_constant_override("separation", 4)
	for node in card_data.nodes:
		var icon_label = Label.new()
		icon_label.text = node.icon
		icon_label.add_theme_font_size_override("font_size", 18)
		icons_hbox.add_child(icon_label)
	content_vbox.add_child(icons_hbox)
	
	# Divider
	var sep2 = HSeparator.new()
	content_vbox.add_child(sep2)
	
	# Difficulty
	var difficulty = Label.new()
	difficulty.text = card_data.difficulty
	difficulty.add_theme_font_size_override("font_size", 13)
	difficulty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match card_data.difficulty:
		"쉬움":
			difficulty.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		"보통":
			difficulty.add_theme_color_override("font_color", Color(1, 1, 0.5))
		"어려움":
			difficulty.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	content_vbox.add_child(difficulty)
	
	# Rewards
	var rewards = Label.new()
	rewards.text = card_data.rewards
	rewards.add_theme_font_size_override("font_size", 13)
	rewards.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	rewards.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(rewards)
	
	# Click button (invisible overlay)
	var button = Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_card_clicked.bind(card, index))
	card.add_child(button)
	
	return card

func _animate_card_appear(card: Control, delay: float):
	"""Fade in card"""
	await get_tree().create_timer(delay).timeout
	var tween = create_tween()
	tween.tween_property(card, "modulate:a", 1.0, 0.4)

func _on_card_clicked(card: Control, index: int):
	"""Handle card click - select or confirm"""
	var is_selected = card.get_meta("is_selected", false)
	
	if not is_selected:
		# First click: Mark as selected (move down 20px)
		_select_card(card, index)
	else:
		# Second click: Confirm selection
		var card_data = card.get_meta("card_data")
		_confirm_selection(card, card_data, index)

func _select_card(card: Control, index: int):
	"""First click: Move card down 20px to show selection"""
	# Deselect other cards first
	for i in range(card_nodes.size()):
		var other_card = card_nodes[i]
		if i != index:
			var is_other_selected = other_card.get_meta("is_selected", false)
			if is_other_selected:
				# Move back to original position
				var original_y = other_card.get_meta("original_y")
				var tween = create_tween()
				tween.tween_property(other_card, "position:y", original_y, 0.2)
				other_card.set_meta("is_selected", false)
	
	# Store original position if not stored yet
	if not card.has_meta("original_y"):
		card.set_meta("original_y", card.position.y)
	
	# Move down 20px
	var original_y = card.get_meta("original_y")
	var tween = create_tween()
	tween.tween_property(card, "position:y", original_y + 20, 0.2).set_ease(Tween.EASE_OUT)
	
	# Mark as selected
	card.set_meta("is_selected", true)
	
	print("[DreamCardSelection] Card %d selected (preview)" % index)

func _confirm_selection(card: Control, card_data: Dictionary, index: int):
	"""Second click: Confirm selection and reveal card"""
	print("[DreamCardSelection] Card confirmed: %s" % card_data.name)
	
	# Store selected card
	selected_cards.append(card_data)
	
	# Disable all cards
	for c in card_nodes:
		var btn = c.get_child(c.get_child_count() - 1)
		if btn is Button:
			btn.disabled = true
	
	# Fade out other cards
	for i in range(card_nodes.size()):
		if i != index:
			var other_card = card_nodes[i]
			var tween = create_tween()
			tween.tween_property(other_card, "modulate:a", 0.0, 0.4)
	
	# Wait for others to fade
	await get_tree().create_timer(0.5).timeout
	
	# Flip selected card to reveal
	_flip_card_reveal(card, card_data)
	
	# Wait for flip
	await get_tree().create_timer(0.6).timeout
	
	# Log selection
	var stage_name = STAGE_NAMES[current_stage]
	_add_log_block("'%s' 카드가 공개되었습니다!" % card_data.name, Color(0.5, 1.0, 0.7))
	
	# Wait then proceed
	await get_tree().create_timer(1.5).timeout
	
	if current_stage == Stage.END:
		_complete_selection()
	else:
		_proceed_to_next_stage()

func _flip_card_reveal(card: Control, card_data: Dictionary):
	"""Flip card to reveal front (after confirmation)"""
	var card_back = card.get_node("CardBack")
	var card_front = card.get_node("CardFront")
	
	# Flip animation (scale x)
	var tween = create_tween()
	tween.set_parallel(false)
	
	# Shrink
	tween.tween_property(card, "scale:x", 0.0, 0.2).set_ease(Tween.EASE_IN)
	
	# Switch visibility
	tween.tween_callback(func():
		card_back.visible = false
		card_front.visible = true
	)
	
	# Expand
	tween.tween_property(card, "scale:x", 1.0, 0.2).set_ease(Tween.EASE_OUT)
	
	print("[DreamCardSelection] Card '%s' revealed!" % card_data.name)

func _proceed_to_next_stage():
	"""Proceed to next stage"""
	var next_stage: Stage
	match current_stage:
		Stage.START:
			next_stage = Stage.JOURNEY
		Stage.JOURNEY:
			next_stage = Stage.END
		_:
			return
	
	# Fade out all cards
	for card in card_nodes:
		var tween = create_tween()
		tween.tween_property(card, "modulate:a", 0.0, 0.3)
	
	await get_tree().create_timer(0.5).timeout
	
	# Start next stage
	_start_stage(next_stage)

func _complete_selection():
	"""Complete all 3 selections and show summary"""
	print("[DreamCardSelection] All stages complete!")
	
	# Fade out all cards
	for card in card_nodes:
		var tween = create_tween()
		tween.tween_property(card, "modulate:a", 0.0, 0.4)
	
	await get_tree().create_timer(0.6).timeout
	
	# Clear cards
	for card in card_nodes:
		card.queue_free()
	card_nodes.clear()
	
	# Show selected cards in 2 rows
	_show_selected_cards_summary()
	
	# Clear logs
	for child in log_container.get_children():
		child.queue_free()
	
	# Calculate totals
	var total_nodes = 0
	var total_hours = 0
	var has_boss = false
	for card in selected_cards:
		total_nodes += card.node_count
		total_hours += card.hours
		for node in card.nodes:
			if node.type == "boss":
				has_boss = true
	
	# Show summary log
	_add_log_block("꿈 탐험 시작", Color(0.6, 0.8, 1.0))
	
	# Show start button
	start_button.visible = true
	start_button.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(start_button, "modulate:a", 1.0, 0.5)

func _show_selected_cards_summary():
	"""Show 3 selected cards in 2 rows"""
	# Row 1: Cards 0 and 1 (Start + Journey)
	# Row 2: Card 2 (End)
	var positions = [
		Vector2(50, 80),   # Start (row 1 left)
		Vector2(200, 80),  # Journey (row 1 right)
		Vector2(125, 200)  # End (row 2 center)
	]
	
	for i in range(selected_cards.size()):
		var card_data = selected_cards[i]
		var card = _create_small_card_node(card_data)
		card.position = positions[i]
		card.modulate.a = 0
		card_container.add_child(card)
		card_nodes.append(card)
		
		# Fade in
		var tween = create_tween()
		tween.tween_property(card, "modulate:a", 1.0, 0.4)
		await get_tree().create_timer(0.15).timeout

func _create_small_card_node(card_data: Dictionary) -> Control:
	"""Create a small card for summary display (100x160)"""
	var card = Control.new()
	card.custom_minimum_size = Vector2(100, 160)
	card.size = Vector2(100, 160)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.9, 0.9, 0.95, 1)  # White
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.4, 0.6, 1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)
	card.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	vbox.add_child(margin)
	
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	margin.add_child(content)
	
	# Name
	var name = Label.new()
	name.text = card_data.name
	name.add_theme_font_size_override("font_size", 14)
	name.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(name)
	
	# Emoji
	var emoji = Label.new()
	emoji.text = card_data.emoji
	emoji.add_theme_font_size_override("font_size", 36)
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(emoji)
	
	# Info
	var info = Label.new()
	info.text = "%d노드\n%d시간" % [card_data.node_count, card_data.hours]
	info.add_theme_font_size_override("font_size", 11)
	info.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(info)
	
	return card

func _add_log_block(message: String, bg_color: Color):
	"""Add log message as styled panel block (like DreamItem)"""
	var panel = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = message
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))  # Dark text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(label)
	
	log_container.add_child(panel)
	
	# Add spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	log_container.add_child(spacer)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll = log_container.get_parent() as ScrollContainer
	if scroll:
		scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

func _on_start_button_pressed():
	"""Start dream exploration"""
	print("[DreamCardSelection] Starting dream exploration...")
	
	# Pass selected cards to GameManager
	if GameManager.has_method("set_dream_cards"):
		GameManager.set_dream_cards(selected_cards)
	else:
		GameManager.set_meta("dream_cards", selected_cards)
	
	# Navigate to InRun_v4
	get_tree().change_scene_to_file("res://ui/screens/InRun_v4.tscn")

func _on_bottom_nav_pressed(tab_index: int):
	"""Handle bottom nav press"""
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		_:
			print("[DreamCardSelection] Tab %d not implemented" % tab_index)
