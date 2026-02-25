extends Control

# UI References
@onready var hero_hp_bar = $BattleScene/HeroArea/HeroHPBar
@onready var hero_hp_label = $BattleScene/HeroArea/HeroHPLabel
@onready var hero_atb_bar = $BattleScene/HeroArea/HeroATBBar
@onready var hero_energy_label = $TopBar/HeroEnergy

@onready var monster1 = $BattleScene/MonsterArea/Monster1
@onready var monster2 = $BattleScene/MonsterArea/Monster2
@onready var monster3 = null  # Will be created dynamically (right bottom)
@onready var monster4 = null  # Will be created dynamically (right top)

@onready var log_content = $CombatLog/ScrollContainer/LogContent

@onready var end_turn_button = $ActionButtons/ButtonsContainer/EndTurnButton
@onready var auto_button = $ActionButtons/ButtonsContainer/AutoButton
@onready var menu_button = $ActionButtons/ButtonsContainer/MenuButton

var monster_nodes = []

# Energy & Deck UI (created dynamically)
var energy_orb: Control  # Custom energy orb with radial progress
var deck_label: Label
var discard_label: Label
var exile_label: Label
var hand_container: Control  # Changed from HBoxContainer for free positioning

func _ready():
	_setup_monsters_horizontal()  # NEW: 3 monsters horizontal, hide ATB
	_apply_theme_styles()
	_setup_buttons()
	_create_energy_and_deck_ui()
	_initialize_combat()
	
	# Connect to CombatManager signals
	CombatManager.combat_log_updated.connect(_on_combat_log_updated)
	CombatManager.entity_updated.connect(_on_entity_updated)
	CombatManager.combat_ended.connect(_on_combat_ended)
	CombatManager.energy_changed.connect(_on_energy_changed)
	CombatManager.energy_timer_updated.connect(_on_energy_timer_updated)
	
	# Connect to DeckManager signals
	DeckManager.hand_changed.connect(_on_hand_changed)

func _setup_monsters_horizontal():
	"""Setup 4 monsters in 2x2 grid and hide ATB bars"""
	# Hide ATB bars
	var hero_atb = $BattleScene/HeroArea/HeroATBBar
	if hero_atb:
		hero_atb.visible = false
	
	# Hide Monster1 ATB (left bottom)
	var m1_atb = monster1.get_node_or_null("ATBBar")
	if m1_atb:
		m1_atb.visible = false
	
	# Hide Monster2 ATB (left top)
	var m2_atb = monster2.get_node_or_null("ATBBar")
	if m2_atb:
		m2_atb.visible = false
	
	# Create Monster3 (right bottom) - duplicate Monster1
	if not monster3:
		monster3 = monster1.duplicate()
		monster3.name = "Monster3"
		monster3.offset_left = -20  # Right side
		monster3.offset_right = 40
		monster3.offset_top = 0
		monster3.offset_bottom = 120
		monster3.z_index = 10  # Front layer
		$BattleScene/MonsterArea.add_child(monster3)
		
		# Hide Monster3 ATB
		var m3_atb = monster3.get_node_or_null("ATBBar")
		if m3_atb:
			m3_atb.visible = false
	
	# Create Monster4 (right top) - duplicate Monster2
	if not monster4:
		monster4 = monster2.duplicate()
		monster4.name = "Monster4"
		monster4.offset_left = 10  # Right side, back 50% (to the RIGHT)
		monster4.offset_right = 70
		monster4.offset_top = -60
		monster4.offset_bottom = 60
		monster4.z_index = 5  # Back layer
		$BattleScene/MonsterArea.add_child(monster4)
		
		# Hide Monster4 ATB
		var m4_atb = monster4.get_node_or_null("ATBBar")
		if m4_atb:
			m4_atb.visible = false

func _apply_theme_styles():
	# Apply UITheme styles
	for button in [end_turn_button, auto_button, menu_button]:
		UITheme.apply_button_style(button, "primary")

func _setup_buttons():
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	auto_button.pressed.connect(_on_auto_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _create_energy_and_deck_ui():
	"""Create energy and deck info UI dynamically"""
	# Create energy info area (between battle scene and log)
	var energy_area = Control.new()
	energy_area.name = "EnergyArea"
	energy_area.position = Vector2(0, 334)  # Moved up from 434
	energy_area.size = Vector2(390, 300)
	add_child(energy_area)
	
	# NEW LAYOUT: Cards at top, info at bottom
	
	# Hand container (Control for free positioning and z-ordering) - MOVED TO TOP
	hand_container = Control.new()
	hand_container.name = "HandContainer"
	hand_container.position = Vector2(16, 0)  # Top of EnergyArea
	hand_container.size = Vector2(358, 150)
	energy_area.add_child(hand_container)
	
	# Energy orb - BELOW CARDS (left side, circular with radial progress)
	var EnergyOrbScript = load("res://ui/components/EnergyOrb.gd")
	energy_orb = Control.new()
	energy_orb.set_script(EnergyOrbScript)
	energy_orb.position = Vector2(8, 160)  # Below cards, left edge
	energy_orb.custom_minimum_size = Vector2(50, 50)
	energy_area.add_child(energy_orb)
	
	# Initialize orb
	energy_orb.set_energy(3, 3)
	energy_orb.set_timer_progress(0.0)
	
	# Deck status labels - BELOW ENERGY ORB
	deck_label = Label.new()
	deck_label.position = Vector2(65, 175)  # Right of energy orb
	deck_label.text = "📚 Deck: 12"
	deck_label.add_theme_font_size_override("font_size", 12)
	energy_area.add_child(deck_label)
	
	discard_label = Label.new()
	discard_label.position = Vector2(180, 175)  # Next to deck
	discard_label.text = "🪦 Discard: 0"
	discard_label.add_theme_font_size_override("font_size", 12)
	energy_area.add_child(discard_label)
	
	exile_label = Label.new()
	exile_label.position = Vector2(295, 175)  # Next to discard
	exile_label.text = "🚫 Exile: 0"
	exile_label.add_theme_font_size_override("font_size", 12)
	energy_area.add_child(exile_label)

func _initialize_combat():
	# Get monsters from InRun or use default test monsters
	var monsters = _get_test_monsters()
	
	# Store monster UI nodes (before combat starts) - NOW 4 MONSTERS (2x2)
	monster_nodes = [monster1, monster2, monster3, monster4]
	
	# Add click detection to monsters
	_setup_monster_clicks()
	
	# Initialize CombatManager (this will initialize deck and draw cards)
	CombatManager.start_combat(monsters)
	
	# Initial UI update
	_update_hero_ui()
	_update_monsters_ui()
	_update_deck_ui()
	_update_hand_ui()  # Show initial 5 cards immediately!

func _setup_monster_clicks():
	"""Add click detection to monster nodes"""
	for i in range(monster_nodes.size()):
		var monster_node = monster_nodes[i]
		
		# Add button overlay for click detection
		var btn = Button.new()
		btn.name = "ClickButton"
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.flat = true
		btn.pressed.connect(_on_monster_clicked.bind(i))
		monster_node.add_child(btn)

func _on_monster_clicked(monster_index: int):
	"""Handle monster click"""
	if selecting_target:
		_select_target(monster_index)
	else:
		# Show monster info
		if monster_index < CombatManager.monsters.size():
			var monster = CombatManager.monsters[monster_index]
			add_combat_log("👾 %s - HP: %d/%d" % [monster.name, monster.hp, monster.max_hp])
	_update_monsters_ui()
	_update_deck_ui()

func _get_test_monsters() -> Array:
	# TODO: Get from GameManager or InRun
	return [
		{
			"name": "Slime1",
			"hp": 20,
			"max_hp": 20,
			"atk": 3,
			"def": 1,
			"spd": 8,
			"eva": 5
		},
		{
			"name": "Slime2",
			"hp": 15,
			"max_hp": 15,
			"atk": 5,
			"def": 0,
			"spd": 12,
			"eva": 10
		},
		{
			"name": "Goblin1",
			"hp": 12,
			"max_hp": 12,
			"atk": 4,
			"def": 0,
			"spd": 15,
			"eva": 15
		},
		{
			"name": "Goblin2",
			"hp": 18,
			"max_hp": 18,
			"atk": 6,
			"def": 2,
			"spd": 10,
			"eva": 8
		}
	]

func _process(delta):
	# Update ATB bars every frame
	_update_atb_bars()
	
	# Animate targeting arrows (pulse effect)
	if selecting_target and not targeting_arrows.is_empty():
		var pulse = (sin(Time.get_ticks_msec() / 200.0) + 1.0) / 2.0  # 0.0 to 1.0
		var alpha = lerp(0.5, 1.0, pulse)
		
		for arrow_container in targeting_arrows:
			if arrow_container and is_instance_valid(arrow_container):
				# Update all children (Line2D and Polygon2D)
				for child in arrow_container.get_children():
					child.modulate.a = alpha

func _update_hero_ui():
	var hero = CombatManager.hero
	
	hero_hp_bar.max_value = hero.max_hp
	hero_hp_bar.value = hero.hp
	hero_hp_label.text = "%d/%d" % [hero.hp, hero.max_hp]
	hero_energy_label.text = "⚡ %d" % hero.energy

func _update_monsters_ui():
	var monsters = CombatManager.monsters
	
	for i in range(monster_nodes.size()):
		var node = monster_nodes[i]
		
		if i < monsters.size():
			var monster = monsters[i]
			
			# Hide dead monsters (HP <= 0)
			if monster.hp <= 0:
				node.visible = false
				continue
			
			node.visible = true
			
			var hp_bar = node.get_node("HPBar")
			var hp_label = node.get_node("HPLabel")
			
			hp_bar.max_value = monster.max_hp
			hp_bar.value = monster.hp
			hp_label.text = "%d/%d" % [monster.hp, monster.max_hp]
		else:
			node.visible = false

func _update_atb_bars():
	# ATB bars are now hidden - skip update
	return
	# (ATB system still runs in background for timing)

func _on_entity_updated(entity_type: String, index: int):
	if entity_type == "hero":
		_update_hero_ui()
	elif entity_type == "monster":
		_update_monsters_ui()

func _on_combat_log_updated(message: String):
	var label = Label.new()
	label.text = "• " + message
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	log_content.add_child(label)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll = $CombatLog/ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func _on_combat_ended(victory: bool):
	if victory:
		add_combat_log("=== VICTORY ===")
		await get_tree().create_timer(2.0).timeout
		# Go to Victory screen
		get_tree().change_scene_to_file("res://ui/screens/VictoryScreen.tscn")
	else:
		add_combat_log("=== DEFEAT ===")
		await get_tree().create_timer(2.0).timeout
		# Go to Defeat screen
		get_tree().change_scene_to_file("res://ui/screens/DefeatScreen.tscn")

func add_combat_log(message: String):
	CombatManager.add_log(message)

func _on_end_turn_pressed():
	# Pass - do nothing, just wait
	add_combat_log("Player passed.")

func _on_auto_pressed():
	CombatManager.toggle_auto_battle()
	
	# Update button text
	if CombatManager.auto_battle_enabled:
		auto_button.text = "Auto: ON"
	else:
		auto_button.text = "Auto: OFF"

func _on_menu_pressed():
	# TODO: Open pause menu
	add_combat_log("Menu not implemented yet.")

func _on_energy_changed(current: int, max_val: int):
	hero_energy_label.text = "⚡ %d" % current
	if energy_orb:
		energy_orb.set_energy(current, max_val)

func _on_energy_timer_updated(progress: float):
	if energy_orb:
		energy_orb.set_timer_progress(progress)

func _on_hand_changed():
	_update_deck_ui()
	_update_hand_ui()

func _update_deck_ui():
	"""Update deck status labels"""
	if deck_label:
		deck_label.text = "📚 Deck: %d" % DeckManager.get_deck_size()
	if discard_label:
		discard_label.text = "🪦 Discard: %d" % DeckManager.get_discard_size()
	if exile_label:
		exile_label.text = "🚫 Exile: %d" % DeckManager.get_exile_size()
	if energy_orb:
		var current = CombatManager.get_current_energy()
		var maximum = CombatManager.get_max_energy()
		energy_orb.set_energy(current, maximum)

func _update_hand_ui():
	"""Update hand display with overlapping fan layout (Slay the Spire style)"""
	if not hand_container:
		return
	
	# Clear existing
	for child in hand_container.get_children():
		child.queue_free()
	
	# Get hand
	var hand = DeckManager.get_hand_cards()
	if hand.is_empty():
		return
	
	# Create card items with overlapping fan layout
	var card_scene = preload("res://ui/components/CardHandItem.tscn")
	var num_cards = hand.size()
	var current_energy = CombatManager.get_current_energy()
	
	# Fan layout parameters (Slay the Spire style - heavy vertical overlap with arc)
	var spread_angle = 30.0  # Degrees (reduced for tighter fan)
	var card_spacing = 35.0  # Horizontal spacing between cards
	var card_push_distance = 60.0  # How far to push cards when one is selected
	var base_y = 30.0        # Base Y position for CENTER cards (70% visible)
	var arc_depth = 20.0     # Edge cards drop 20px (50% visible)
	
	# Calculate total width and starting X
	var total_width = (num_cards - 1) * card_spacing
	var start_x = (hand_container.size.x - total_width) / 2
	
	for i in range(num_cards):
		var card = hand[i]
		var card_item = card_scene.instantiate()
		hand_container.add_child(card_item)
		
		# Set card data
		card_item.set_card(card, i)
		card_item.set_affordable(current_energy >= card.cost)
		
		# Calculate fan position
		var t = float(i) / max(1, num_cards - 1) if num_cards > 1 else 0.5
		var angle = lerp(-spread_angle / 2, spread_angle / 2, t)
		
		# X position (evenly spaced, overlapping)
		var x_pos = start_x + i * card_spacing
		
		# Y position - Arc curve (center cards higher = more visible)
		# Center cards (70% visible), edge cards (50% visible)
		var normalized_pos = (t - 0.5) * 2  # -1 (left) to 1 (right)
		var arc_offset = abs(normalized_pos) * arc_depth  # Edge cards drop by arc_depth
		var y_pos = base_y + arc_offset
		
		card_item.position = Vector2(x_pos, y_pos)
		
		# Store original Y for hover/selection effects
		card_item.set_meta("original_y", y_pos)
		
		# Rotate card (slight fan effect)
		card_item.rotation_degrees = angle
		
		# Z-index: Later cards appear on top (stacking effect)
		# This creates the "top 30% visible" overlap
		card_item.z_index = i
		
		# Store card's original position in metadata
		card_item.set_meta("base_x", x_pos)
		card_item.set_meta("base_index", i)
		
		# If this card is currently selected, restore selection state
		if i == currently_selected_card_index:
			card_item.set_selected(true)
			# Lift card to show 80-100% (from base_y+arc_offset, lift ~40px)
			card_item.position.y = y_pos - 40
			card_item.z_index = 2000
			currently_selected_card_item = card_item
			
			# Push adjacent cards away
			_push_adjacent_cards(i, num_cards, card_push_distance)
		
		# Connect signals
		card_item.card_clicked.connect(_on_card_pressed)
		card_item.card_hovered.connect(_on_card_hovered.bind(card_item))
		card_item.card_unhovered.connect(_on_card_unhovered.bind(card_item))

func _push_adjacent_cards(selected_index: int, total_cards: int, push_distance: float):
	"""Push cards left and right of selected card"""
	for child in hand_container.get_children():
		if not child.has_meta("base_index"):
			continue
		
		var card_index = child.get_meta("base_index")
		var base_x = child.get_meta("base_x")
		
		if card_index < selected_index:
			# Card is to the left - push left
			child.position.x = base_x - push_distance
		elif card_index > selected_index:
			# Card is to the right - push right
			child.position.x = base_x + push_distance
		else:
			# This is the selected card - keep at base position
			child.position.x = base_x

func _reset_card_positions():
	"""Reset all cards to their base positions"""
	for child in hand_container.get_children():
		if child.has_meta("base_x"):
			child.position.x = child.get_meta("base_x")

func _on_card_pressed(card_index: int):
	"""Handle card click - Two-stage selection"""
	var hand = DeckManager.get_hand_cards()
	if card_index < 0 or card_index >= hand.size():
		return
	
	var card = hand[card_index]
	
	# Check affordability
	if CombatManager.get_current_energy() < card.cost:
		add_combat_log("Not enough energy!")
		return
	
	# Find card item in hand_container
	var card_item: Control = null
	for child in hand_container.get_children():
		if child.card_index == card_index:
			card_item = child
			break
	
	if not card_item:
		return
	
	# STAGE 1: Card selection (first click)
	if currently_selected_card_index != card_index:
		# Deselect previous card
		if currently_selected_card_item:
			currently_selected_card_item.set_selected(false)
			_restore_card_position(currently_selected_card_item)
			_reset_card_positions()  # Reset pushed cards
		
		# Select new card
		currently_selected_card_index = card_index
		currently_selected_card_item = card_item
		card_item.set_selected(true)
		
		# Lift card up to show 80-100% (from 50-70% visible)
		if card_item.has_meta("original_y"):
			var original_y = card_item.get_meta("original_y")
			card_item.position.y = original_y - 40  # Lift 40px to show 80-100%
		else:
			card_item.position.y -= 40
		
		# Bring to front
		card_item.z_index = 2000
		
		# Push adjacent cards away
		var total_cards = hand_container.get_child_count()
		_push_adjacent_cards(card_index, total_cards, 60.0)
		
		add_combat_log("Selected: %s (Drag to target or click to use)" % card.name)
		return
	
	# STAGE 2: Card usage (second click on same card)
	# For non-attack cards, play directly
	if card.type != "Attack":
		# Deselect card
		currently_selected_card_item.set_selected(false)
		_restore_card_position(currently_selected_card_item)
		_reset_card_positions()
		currently_selected_card_index = -1
		currently_selected_card_item = null
		
		# Play directly (no target)
		CombatManager.play_card(card_index, -1)
		_update_deck_ui()
	else:
		# Attack cards use drag targeting - just inform user
		add_combat_log("Drag to target or use old click-to-target")

func _restore_card_position(card_item: Control):
	"""Restore card to original position"""
	if card_item and card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y")

func _on_card_hovered(card_index: int, card_item: Control):
	"""Handle card hover - Slay the Spire style lift effect"""
	if not card_item:
		return
	
	# Skip hover effect if card is already selected
	if card_index == currently_selected_card_index:
		return
	
	# Store original position if not already stored
	if not card_item.has_meta("original_y"):
		card_item.set_meta("original_y", card_item.position.y)
	
	# Lift card up (subtle hover)
	var original_y = card_item.get_meta("original_y")
	card_item.position.y = original_y - 20  # Move up 20px
	
	# Bring to front (below selected cards)
	card_item.z_index = 1000  # Top of unselected cards

func _on_card_unhovered(card_item: Control):
	"""Handle card unhover - restore original position"""
	if not card_item:
		return
	
	# Skip if card is selected (position managed by selection)
	if card_item == currently_selected_card_item:
		return
	
	# Restore original Y position
	if card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y")

var selecting_target: bool = false
var selected_card_index: int = -1

# Card selection state
var currently_selected_card_index: int = -1
var currently_selected_card_item: Control = null

# Targeting arrows
var targeting_arrows: Array = []  # Array of Line2D nodes

# Drag targeting
var is_dragging: bool = false
var drag_start_pos: Vector2
var drag_arrow: Node2D = null

func _start_target_selection(card_index: int):
	"""Start target selection mode"""
	selecting_target = true
	selected_card_index = card_index
	add_combat_log("Select a target...")
	
	# Clear any existing arrows
	_clear_targeting_arrows()
	
	# Create targeting arrows from selected card to each monster
	if currently_selected_card_item:
		var card_global_pos = currently_selected_card_item.global_position + currently_selected_card_item.size / 2
		
		for i in range(monster_nodes.size()):
			if i < CombatManager.monsters.size() and CombatManager.monsters[i].hp > 0:
				var monster_node = monster_nodes[i]
				
				# Highlight monster
				monster_node.modulate = Color(1.5, 1.5, 1.5, 1)
				
				# Create arrow line (container for line + arrowhead)
				var arrow_container = Node2D.new()
				arrow_container.name = "TargetArrow_%d" % i
				add_child(arrow_container)
				
				# Line
				var line = Line2D.new()
				line.width = 4
				line.default_color = Color(1, 0.2, 0.2, 0.8)  # Red with transparency
				line.begin_cap_mode = Line2D.LINE_CAP_ROUND
				line.end_cap_mode = Line2D.LINE_CAP_ROUND
				
				# Calculate points (card center → monster center)
				var monster_global_pos = monster_node.global_position + monster_node.size / 2
				var start_pos = card_global_pos
				var end_pos = monster_global_pos
				
				# Shorten the line a bit so arrowhead sits at the end
				var direction = (end_pos - start_pos).normalized()
				var arrow_length = start_pos.distance_to(end_pos) - 20
				var line_end = start_pos + direction * arrow_length
				
				line.add_point(start_pos)
				line.add_point(line_end)
				arrow_container.add_child(line)
				
				# Arrowhead (triangle polygon)
				var arrowhead = Polygon2D.new()
				var arrow_size = 15
				var perpendicular = Vector2(-direction.y, direction.x)
				arrowhead.polygon = PackedVector2Array([
					end_pos,  # Tip
					line_end - direction * arrow_size + perpendicular * arrow_size * 0.5,  # Left wing
					line_end - direction * arrow_size - perpendicular * arrow_size * 0.5   # Right wing
				])
				arrowhead.color = Color(1, 0.2, 0.2, 0.9)  # Slightly more opaque
				arrow_container.add_child(arrowhead)
				
				# Store container
				targeting_arrows.append(arrow_container)
	else:
		# Fallback: just highlight monsters
		for i in range(monster_nodes.size()):
			var monster_node = monster_nodes[i]
			if i < CombatManager.monsters.size() and CombatManager.monsters[i].hp > 0:
				monster_node.modulate = Color(1.5, 1.5, 1.5, 1)

func _cancel_target_selection():
	"""Cancel target selection (but keep card selected)"""
	selecting_target = false
	selected_card_index = -1
	is_dragging = false
	
	# Clear targeting arrows
	_clear_targeting_arrows()
	
	# Clear drag arrow
	if drag_arrow:
		drag_arrow.queue_free()
		drag_arrow = null
	
	# Reset monster visuals
	for monster_node in monster_nodes:
		monster_node.modulate = Color(1, 1, 1, 1)

func _clear_targeting_arrows():
	"""Remove all targeting arrows"""
	for arrow in targeting_arrows:
		if arrow:
			arrow.queue_free()
	targeting_arrows.clear()

# Drag targeting system
func _start_drag_targeting():
	"""Start drag targeting mode"""
	selecting_target = true
	selected_card_index = currently_selected_card_index
	
	# Highlight monsters
	for i in range(monster_nodes.size()):
		var monster_node = monster_nodes[i]
		if i < CombatManager.monsters.size() and CombatManager.monsters[i].hp > 0:
			monster_node.modulate = Color(1.5, 1.5, 1.5, 1)
	
	add_combat_log("Drag to target...")

func _update_drag_arrow():
	"""Update drag arrow to follow mouse"""
	if not currently_selected_card_item:
		return
	
	# Clear old arrow
	if drag_arrow:
		drag_arrow.queue_free()
		drag_arrow = null
	
	# Create new arrow from card to mouse
	var card_global_pos = currently_selected_card_item.global_position + currently_selected_card_item.size / 2
	var mouse_pos = get_global_mouse_position()
	
	drag_arrow = Node2D.new()
	drag_arrow.name = "DragArrow"
	add_child(drag_arrow)
	
	# Line
	var line = Line2D.new()
	line.width = 5
	line.default_color = Color(1, 0.3, 0.3, 0.9)
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var direction = (mouse_pos - card_global_pos).normalized()
	var arrow_length = card_global_pos.distance_to(mouse_pos) - 20
	var line_end = card_global_pos + direction * arrow_length
	
	line.add_point(card_global_pos)
	line.add_point(line_end)
	drag_arrow.add_child(line)
	
	# Arrowhead
	var arrowhead = Polygon2D.new()
	var arrow_size = 20
	var perpendicular = Vector2(-direction.y, direction.x)
	arrowhead.polygon = PackedVector2Array([
		mouse_pos,
		line_end - direction * arrow_size + perpendicular * arrow_size * 0.5,
		line_end - direction * arrow_size - perpendicular * arrow_size * 0.5
	])
	arrowhead.color = Color(1, 0.3, 0.3, 1)
	drag_arrow.add_child(arrowhead)
	
	# Check if hovering over a monster
	_highlight_hovered_monster()

func _highlight_hovered_monster():
	"""Highlight monster under mouse"""
	var mouse_pos = get_global_mouse_position()
	
	for i in range(monster_nodes.size()):
		var monster_node = monster_nodes[i]
		if i < CombatManager.monsters.size() and CombatManager.monsters[i].hp > 0:
			var rect = Rect2(monster_node.global_position, monster_node.size)
			if rect.has_point(mouse_pos):
				monster_node.modulate = Color(2, 2, 2, 1)  # Extra bright
			else:
				monster_node.modulate = Color(1.5, 1.5, 1.5, 1)  # Normal bright

func _end_drag_targeting():
	"""End drag and select target if over monster"""
	# Clear drag arrow
	if drag_arrow:
		drag_arrow.queue_free()
		drag_arrow = null
	
	# Check if mouse is over a monster
	var mouse_pos = get_global_mouse_position()
	var target_found = false
	
	for i in range(monster_nodes.size()):
		var monster_node = monster_nodes[i]
		if i < CombatManager.monsters.size() and CombatManager.monsters[i].hp > 0:
			var rect = Rect2(monster_node.global_position, monster_node.size)
			if rect.has_point(mouse_pos):
				# Target selected!
				_select_target(i)
				target_found = true
				break
	
	if not target_found:
		# No target - just cancel targeting mode (keep card selected)
		_cancel_target_selection()
		add_combat_log("Drag again to target")

func _select_target(target_index: int):
	"""Select target and play card"""
	if not selecting_target:
		return
	
	# Play card
	CombatManager.play_card(selected_card_index, target_index)
	
	# Deselect card and reset positions (BEFORE cancel, to avoid double-reset)
	if currently_selected_card_item:
		currently_selected_card_item.set_selected(false)
		_restore_card_position(currently_selected_card_item)
		_reset_card_positions()
		currently_selected_card_index = -1
		currently_selected_card_item = null
	
	# Clear targeting arrows and reset state
	_cancel_target_selection()
	
	# Update UI
	_update_deck_ui()

# Input handling (drag targeting + cheat codes)
func _input(event):
	# Drag targeting for selected attack cards
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start drag if card is selected
				if currently_selected_card_item:
					var card = DeckManager.get_hand_cards()[currently_selected_card_index]
					if card.type == "Attack":
						is_dragging = true
						drag_start_pos = get_global_mouse_position()
						_start_drag_targeting()
			else:
				# End drag
				if is_dragging:
					is_dragging = false
					_end_drag_targeting()
	
	elif event is InputEventMouseMotion:
		# Update drag arrow
		if is_dragging:
			_update_drag_arrow()
	
	# Cheat codes
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_D:  # Draw card
				DeckManager.draw_card()
				_update_deck_ui()
			KEY_P:  # Play first card
				if DeckManager.get_hand_size() > 0:
					CombatManager.play_card(0)
					_update_deck_ui()
			KEY_S:  # Print deck state
				DeckManager.print_state()
			KEY_1:  # Draw 5 cards
				DeckManager.draw_cards(5)
				_update_deck_ui()
			KEY_A:  # Toggle auto-battle
				_on_auto_pressed()
			KEY_BRACKETLEFT:  # Speed down
				var speed = CombatManager.speed_multiplier - 0.5
				CombatManager.set_speed_multiplier(speed)
			KEY_BRACKETRIGHT:  # Speed up
				var speed = CombatManager.speed_multiplier + 0.5
				CombatManager.set_speed_multiplier(speed)
			KEY_ESCAPE:  # Cancel selection
				if selecting_target or currently_selected_card_item:
					# Deselect card completely
					if currently_selected_card_item:
						currently_selected_card_item.set_selected(false)
						_restore_card_position(currently_selected_card_item)
						_reset_card_positions()
						currently_selected_card_index = -1
						currently_selected_card_item = null
					_cancel_target_selection()
					add_combat_log("Selection cancelled.")
