extends Control

"""
DreamCardSelection v2 - Steve's Design (2026-02-25)

Layout:
- TopArea: 3 cards (back-facing, always visible)
- SelectedCardsArea: 3 slots (show selected cards progressively)
- LogContainer: 1-line prompt
- StartButton: Appear when all 3 selected
"""

# Stages
enum Stage {
	START,    # 시작
	JOURNEY,  # 여정
	END       # 종료
}

var current_stage: Stage = Stage.START
var selected_cards: Array = []  # [start_card, journey_card, end_card]
var top_card_nodes: Array = []  # 3 cards at top
var selected_card_slots: Array = []  # 3 slots at bottom

# UI References
@onready var top_area = $TopArea
@onready var card_container = $TopArea/CardContainer
@onready var selected_area = $SelectedCardsArea
@onready var selected_container = $SelectedCardsArea/SelectedContainer
@onready var bottom_area = $BottomArea
@onready var log_label = $BottomArea/LogLabel
@onready var start_button = $BottomArea/StartButton
@onready var bottom_nav = $BottomNav

# Constants
const STAGE_PROMPTS = {
	Stage.START: "당신의 꿈의 시작을 선택하세요",
	Stage.JOURNEY: "당신의 꿈의 여정을 선택하세요",
	Stage.END: "당신의 꿈의 마지막을 선택하세요"
}

# Card data (same as before)
const CARD_DATA = {
	Stage.START: [
		{"id": "start_1", "name": "시작", "emoji": "🌅", "node_count": 2, "hours": 4,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "shop", "icon": "🛒"}],
		 "difficulty": "쉬움", "rewards": "🪙50"},
		{"id": "start_2", "name": "여명", "emoji": "🌄", "node_count": 2, "hours": 3,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "npc", "icon": "💬"}],
		 "difficulty": "쉬움", "rewards": "⚡10"},
		{"id": "start_3", "name": "출발", "emoji": "🚪", "node_count": 2, "hours": 5,
		 "nodes": [{"type": "narration", "icon": "📖"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "쉬움", "rewards": "🎴1"}
	],
	Stage.JOURNEY: [
		{"id": "journey_1", "name": "여정", "emoji": "🗺️", "node_count": 3, "hours": 5,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "shop", "icon": "🛒"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "보통", "rewards": "🪙80"},
		{"id": "journey_2", "name": "탐험", "emoji": "🧭", "node_count": 3, "hours": 4,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "npc", "icon": "💬"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "보통", "rewards": "🎴2"},
		{"id": "journey_3", "name": "모험", "emoji": "⛰️", "node_count": 3, "hours": 6,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "combat", "icon": "⚔️"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "어려움", "rewards": "🪙100"}
	],
	Stage.END: [
		{"id": "end_1", "name": "종료", "emoji": "🌆", "node_count": 2, "hours": 2,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "boss", "icon": "💀"}],
		 "difficulty": "어려움", "rewards": "🎴3, 🪙150"},
		{"id": "end_2", "name": "귀환", "emoji": "🏠", "node_count": 2, "hours": 3,
		 "nodes": [{"type": "shop", "icon": "🛒"}, {"type": "boss", "icon": "💀"}],
		 "difficulty": "보통", "rewards": "🎴2, 🪙100"},
		{"id": "end_3", "name": "완성", "emoji": "👑", "node_count": 2, "hours": 2,
		 "nodes": [{"type": "npc", "icon": "💬"}, {"type": "boss", "icon": "💀"}],
		 "difficulty": "어려움", "rewards": "🎴4, ⚡20"}
	]
}

func _ready():
	_setup_ui()
	_create_selected_card_slots()
	_start_stage(Stage.START)

func _setup_ui():
	"""Setup UI styling"""
	# TopArea (brown)
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color(0.6, 0.4, 0.2, 1)
	top_area.add_theme_stylebox_override("panel", top_style)
	
	# SelectedCardsArea (brown)
	var selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.6, 0.4, 0.2, 1)
	selected_area.add_theme_stylebox_override("panel", selected_style)
	
	# BottomArea (dark)
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.1, 0.1, 0.15, 1)
	bottom_area.add_theme_stylebox_override("panel", bottom_style)
	
	# Log label styling
	var log_style = StyleBoxFlat.new()
	log_style.bg_color = Color(1.0, 0.9, 0.4, 1)  # Yellow
	log_style.corner_radius_top_left = 8
	log_style.corner_radius_top_right = 8
	log_style.corner_radius_bottom_left = 8
	log_style.corner_radius_bottom_right = 8
	log_style.content_margin_left = 16
	log_style.content_margin_right = 16
	log_style.content_margin_top = 12
	log_style.content_margin_bottom = 12
	log_label.add_theme_stylebox_override("normal", log_style)
	log_label.add_theme_font_size_override("font_size", 16)
	log_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	
	# Start button
	UITheme.apply_button_style(start_button, "primary")
	start_button.visible = false
	start_button.pressed.connect(_on_start_button_pressed)
	
	# BottomNav
	bottom_nav.set_active_tab(0)
	bottom_nav.tab_pressed.connect(_on_bottom_nav_pressed)

func _create_selected_card_slots():
	"""Create 3 placeholder slots for selected cards"""
	var slot_positions = [
		Vector2(70, 10),    # Left
		Vector2(165, 10),   # Center
		Vector2(260, 10)    # Right
	]
	
	for i in range(3):
		var slot = _create_slot_placeholder(i)
		slot.position = slot_positions[i]
		selected_container.add_child(slot)
		selected_card_slots.append(slot)

func _create_slot_placeholder(index: int) -> Control:
	"""Create placeholder for unselected slot"""
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(100, 160)
	slot.size = Vector2(100, 160)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.5, 0.35, 0.15, 0.3)  # Semi-transparent brown
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.2, 0.1, 1)
	style.set_border_width_all(2)
	style.draw_center = true
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	# Dashed effect (fake with lower alpha)
	panel.add_theme_stylebox_override("panel", style)
	slot.add_child(panel)
	
	# Label
	var label = Label.new()
	label.text = "선택될\n카드\n위치"
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2, 0.6))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(label)
	
	return slot

func _start_stage(stage: Stage):
	"""Start a new stage"""
	current_stage = stage
	
	# Update log
	log_label.text = STAGE_PROMPTS[stage]
	
	# Create top cards (only once, on first stage)
	if top_card_nodes.is_empty():
		_create_top_cards()

func _create_top_cards():
	"""Create 3 cards at top (back-facing)"""
	var card_positions = [
		Vector2(15, 60),
		Vector2(135, 60),
		Vector2(255, 60)
	]
	
	# Get all 9 cards (we'll show backs only)
	var all_cards = []
	all_cards.append_array(CARD_DATA[Stage.START])
	all_cards.append_array(CARD_DATA[Stage.JOURNEY])
	all_cards.append_array(CARD_DATA[Stage.END])
	
	# Shuffle and pick 3 per stage
	var start_cards = CARD_DATA[Stage.START].duplicate()
	var journey_cards = CARD_DATA[Stage.JOURNEY].duplicate()
	var end_cards = CARD_DATA[Stage.END].duplicate()
	
	start_cards.shuffle()
	journey_cards.shuffle()
	end_cards.shuffle()
	
	# For now, show backs for current stage cards
	var current_cards = CARD_DATA[current_stage]
	
	for i in range(3):
		var card = _create_card_back(current_cards[i], i)
		card.position = card_positions[i]
		card_container.add_child(card)
		top_card_nodes.append(card)

func _create_card_back(card_data: Dictionary, index: int) -> Control:
	"""Create card back (🔮)"""
	var card = Control.new()
	card.custom_minimum_size = Vector2(140, 220)
	card.size = Vector2(140, 220)
	card.set_meta("card_data", card_data)
	card.set_meta("is_selected", false)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.15, 0.4, 1)  # Dark purple
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.7, 0.5, 0.9, 1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	card.add_child(panel)
	
	# Crystal ball
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	var icon = Label.new()
	icon.text = "🔮"
	icon.add_theme_font_size_override("font_size", 72)
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon)
	
	var stars = Label.new()
	stars.text = "✨ ✨ ✨"
	stars.add_theme_font_size_override("font_size", 18)
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	vbox.add_child(stars)
	
	# Click button
	var button = Button.new()
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_card_clicked.bind(card, index))
	card.add_child(button)
	
	return card

func _on_card_clicked(card: Control, index: int):
	"""Handle card click"""
	var is_selected = card.get_meta("is_selected")
	
	if is_selected:
		return  # Already selected
	
	var card_data = card.get_meta("card_data")
	
	# Mark as selected
	card.set_meta("is_selected", true)
	selected_cards.append(card_data)
	
	# Disable card button
	var button = card.get_child(card.get_child_count() - 1)
	if button is Button:
		button.disabled = true
	
	# Dim the card (visual feedback)
	var tween = create_tween()
	tween.tween_property(card, "modulate:a", 0.5, 0.3)
	
	# Show selected card in bottom slot
	_show_selected_card_in_slot(card_data, current_stage)
	
	# Check if stage complete
	if selected_cards.size() < 3:
		# Move to next stage
		await get_tree().create_timer(0.5).timeout
		_proceed_to_next_stage()
	else:
		# All done
		await get_tree().create_timer(0.5).timeout
		_complete_selection()

func _show_selected_card_in_slot(card_data: Dictionary, stage: Stage):
	"""Show selected card in corresponding slot"""
	var slot_index = int(stage)  # START=0, JOURNEY=1, END=2
	var slot = selected_card_slots[slot_index]
	
	# Clear placeholder
	for child in slot.get_children():
		child.queue_free()
	
	# Create selected card display
	var card_display = _create_selected_card_display(card_data)
	slot.add_child(card_display)
	
	# Fade in animation
	card_display.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(card_display, "modulate:a", 1.0, 0.4)

func _create_selected_card_display(card_data: Dictionary) -> Control:
	"""Create selected card display (white card with info)"""
	var card = Control.new()
	card.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.95, 0.98, 1)  # White
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
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
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

func _proceed_to_next_stage():
	"""Move to next stage"""
	# Clear top cards
	for card in top_card_nodes:
		card.queue_free()
	top_card_nodes.clear()
	
	# Determine next stage
	var next_stage: Stage
	match current_stage:
		Stage.START:
			next_stage = Stage.JOURNEY
		Stage.JOURNEY:
			next_stage = Stage.END
		_:
			return
	
	# Start next stage
	_start_stage(next_stage)

func _complete_selection():
	"""All 3 cards selected"""
	print("[DreamCardSelection] Complete! Selected:", selected_cards)
	
	# Clear top cards
	for card in top_card_nodes:
		card.queue_free()
	top_card_nodes.clear()
	
	# Update log
	log_label.text = "꿈이 완성되었습니다! 탐험을 시작하세요."
	
	# Show start button
	start_button.visible = true
	start_button.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(start_button, "modulate:a", 1.0, 0.5)
	
	# Pass to GameManager
	if GameManager.has_method("set_dream_cards"):
		GameManager.set_dream_cards(selected_cards)

func _on_start_button_pressed():
	"""Start dream exploration"""
	get_tree().change_scene_to_file("res://ui/screens/InRun_v4.tscn")

func _on_bottom_nav_pressed(tab_index: int):
	"""Handle bottom nav"""
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		_:
			print("[DreamCardSelection] Tab %d not implemented" % tab_index)
