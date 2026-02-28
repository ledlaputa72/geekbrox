extends BaseBottomUI

"""
CombatBottomUI - 전투 중 UI
카드 핸드 + 로그 + 버튼 (2분할 구조)

Layout (564px):
├─ CardHandArea (220px) ← 카드 팬 레이아웃
├─ GameInfo (50px) ← Energy Orb, Deck/Discard/Exile
├─ CombatLog (230px) ← 스크롤 가능
└─ ActionButtons (64px) ← Pass, Auto, Speed
"""

@onready var card_hand_container = $CardHandArea
@onready var energy_orb = $GameInfo/EnergyOrb
@onready var deck_label = $GameInfo/DeckLabel
@onready var discard_label = $GameInfo/DiscardLabel
@onready var exile_label = $GameInfo/ExileLabel
@onready var combat_log_content = $CombatLog/ScrollContainer/LogContent
@onready var pass_button = $ActionButtons/PassButton
@onready var auto_button = $ActionButtons/AutoButton
@onready var speed_button = $ActionButtons/SpeedButton

# Card selection state
var currently_selected_card_index: int = -1
var currently_selected_card_item: Control = null

# Targeting state
var selecting_target: bool = false
var selected_card_index: int = -1
var is_dragging: bool = false
var drag_arrow: Node2D = null

func _ready():
	# Load EnergyOrb script dynamically
	if energy_orb:
		var EnergyOrbScript = load("res://ui/components/EnergyOrb.gd")
		energy_orb.set_script(EnergyOrbScript)
		# Call _ready() manually after setting script
		energy_orb._ready()
		# Set initial energy
		energy_orb.set_energy(3, 3)
		energy_orb.set_timer_progress(0.0)
		print("[CombatBottomUI] EnergyOrb initialized: 3/3")
	else:
		print("[CombatBottomUI] ERROR: energy_orb node not found!")
	
	_setup_buttons()
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	print("[CombatBottomUI] _on_enter called")
	
	# Connect to managers
	if not CombatManager.combat_log_updated.is_connected(_on_combat_log_updated):
		CombatManager.combat_log_updated.connect(_on_combat_log_updated)
	if not CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.connect(_on_entity_updated)
	if not CombatManager.combat_ended.is_connected(_on_combat_ended):
		CombatManager.combat_ended.connect(_on_combat_ended)
	if not CombatManager.energy_changed.is_connected(_on_energy_changed):
		CombatManager.energy_changed.connect(_on_energy_changed)
	if not CombatManager.energy_timer_updated.is_connected(_on_energy_timer_updated):
		CombatManager.energy_timer_updated.connect(_on_energy_timer_updated)
	if not DeckManager.hand_changed.is_connected(_on_hand_changed):
		DeckManager.hand_changed.connect(_on_hand_changed)
	
	print("[CombatBottomUI] Signals connected")
	
	# Initial update (safe - will be updated again after combat starts)
	_update_deck_ui()
	
	# Sync initial energy from CombatManager
	if CombatManager.hero and "energy" in CombatManager.hero:
		var current_energy = CombatManager.hero.get("energy", 0)
		_on_energy_changed(current_energy, CombatManager.ENERGY_MAX)
		print("[CombatBottomUI] Initial energy synced: %d" % current_energy)
	
	# Don't update hand yet - wait for combat to start
	# _update_hand_ui()
	
	add_combat_log("=== Combat UI Ready ===")

func _on_exit():
	"""UI 비활성화 시"""
	# Disconnect signals
	if CombatManager.combat_log_updated.is_connected(_on_combat_log_updated):
		CombatManager.combat_log_updated.disconnect(_on_combat_log_updated)
	if CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.disconnect(_on_entity_updated)
	if CombatManager.combat_ended.is_connected(_on_combat_ended):
		CombatManager.combat_ended.disconnect(_on_combat_ended)
	if CombatManager.energy_changed.is_connected(_on_energy_changed):
		CombatManager.energy_changed.disconnect(_on_energy_changed)
	if CombatManager.energy_timer_updated.is_connected(_on_energy_timer_updated):
		CombatManager.energy_timer_updated.disconnect(_on_energy_timer_updated)
	if DeckManager.hand_changed.is_connected(_on_hand_changed):
		DeckManager.hand_changed.disconnect(_on_hand_changed)
	
	# Clear selection
	_cancel_target_selection()

func _setup_buttons():
	"""Setup button connections"""
	# Apply custom styles to buttons
	_apply_button_style(pass_button, UITheme.COLORS.panel)  # Secondary
	
	# Auto button style depends on state
	var auto_color = UITheme.COLORS.primary if CombatManager.auto_battle_enabled else UITheme.COLORS.panel
	_apply_button_style(auto_button, auto_color)
	auto_button.text = "Auto: ON" if CombatManager.auto_battle_enabled else "Auto"
	
	_apply_button_style(speed_button, UITheme.COLORS.panel)  # Secondary
	
	pass_button.pressed.connect(_on_pass_pressed)
	auto_button.pressed.connect(_on_auto_pressed)
	speed_button.pressed.connect(_on_speed_pressed)

func _apply_button_style(button: Button, bg_color: Color):
	"""Apply custom style to button"""
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
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	button.add_theme_color_override("font_color", UITheme.COLORS.text)

# === Combat Log ===

func add_combat_log(message: String):
	"""Add combat log entry"""
	var label = Label.new()
	label.text = "• " + message
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_log_content.add_child(label)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll = $CombatLog/ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

# === Deck & Hand UI ===

func _update_deck_ui():
	"""Update deck status labels and energy orb"""
	if deck_label:
		deck_label.text = "📚 %d" % DeckManager.get_deck_size()
	if discard_label:
		discard_label.text = "🪦 %d" % DeckManager.get_discard_size()
	if exile_label:
		exile_label.text = "🚫 %d" % DeckManager.get_exile_size()
	
	if energy_orb and energy_orb.has_method("set_energy"):
		var current = CombatManager.get_current_energy()
		var maximum = CombatManager.get_max_energy()
		energy_orb.set_energy(current, maximum)

func _update_hand_ui():
	"""Update card hand display with overlapping fan layout"""
	# Clear existing cards
	for child in card_hand_container.get_children():
		child.queue_free()
	
	var hand = DeckManager.get_hand_cards()
	if hand.is_empty():
		return
	
	# Create card items
	var card_scene = preload("res://ui/components/CardHandItem.tscn")
	var num_cards = hand.size()
	var current_energy = CombatManager.get_current_energy()
	
	# Fan layout parameters
	var spread_angle = 30.0
	var card_spacing = 35.0
	var base_y = 30.0
	var arc_depth = 20.0
	
	var total_width = (num_cards - 1) * card_spacing
	var start_x = (card_hand_container.size.x - total_width) / 2
	
	for i in range(num_cards):
		var card = hand[i]
		var card_item = card_scene.instantiate()
		card_hand_container.add_child(card_item)
		
		card_item.set_card(card, i)
		card_item.set_affordable(current_energy >= card.cost)
		
		# Calculate position
		var t = float(i) / max(1, num_cards - 1) if num_cards > 1 else 0.5
		var angle = lerp(-spread_angle / 2, spread_angle / 2, t)
		
		var x_pos = start_x + i * card_spacing
		var normalized_pos = (t - 0.5) * 2
		var arc_offset = abs(normalized_pos) * arc_depth
		var y_pos = base_y + arc_offset
		
		card_item.position = Vector2(x_pos, y_pos)
		card_item.set_meta("original_y", y_pos)
		card_item.rotation_degrees = angle
		card_item.z_index = i
		
		card_item.set_meta("base_x", x_pos)
		card_item.set_meta("base_index", i)
		
		# Restore selection
		if i == currently_selected_card_index:
			card_item.set_selected(true)
			card_item.position.y = y_pos - 40
			card_item.z_index = 2000
			currently_selected_card_item = card_item
			_push_adjacent_cards(i, num_cards, 60.0)
		
		# Connect signals
		card_item.card_clicked.connect(_on_card_pressed)
		card_item.card_hovered.connect(_on_card_hovered.bind(card_item))
		card_item.card_unhovered.connect(_on_card_unhovered.bind(card_item))

func _push_adjacent_cards(selected_index: int, total_cards: int, push_distance: float):
	"""Push adjacent cards away"""
	for child in card_hand_container.get_children():
		if not child.has_meta("base_index"):
			continue
		
		var card_index = child.get_meta("base_index")
		var base_x = child.get_meta("base_x")
		
		if card_index < selected_index:
			child.position.x = base_x - push_distance
		elif card_index > selected_index:
			child.position.x = base_x + push_distance
		else:
			child.position.x = base_x

func _reset_card_positions():
	"""Reset all cards to base positions"""
	for child in card_hand_container.get_children():
		if child.has_meta("base_x"):
			child.position.x = child.get_meta("base_x")

func _restore_card_position(card_item: Control):
	"""Restore card to original Y position"""
	if card_item and card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y")

# === Card Interaction ===

func _on_card_pressed(card_index: int):
	"""Handle card click - Two-stage selection"""
	var hand = DeckManager.get_hand_cards()
	if card_index < 0 or card_index >= hand.size():
		return
	
	var card = hand[card_index]
	
	if CombatManager.get_current_energy() < card.cost:
		add_combat_log("Not enough energy!")
		return
	
	var card_item: Control = null
	for child in card_hand_container.get_children():
		if child.card_index == card_index:
			card_item = child
			break
	
	if not card_item:
		return
	
	# STAGE 1: Selection
	if currently_selected_card_index != card_index:
		if currently_selected_card_item:
			currently_selected_card_item.set_selected(false)
			_restore_card_position(currently_selected_card_item)
			_reset_card_positions()
		
		currently_selected_card_index = card_index
		currently_selected_card_item = card_item
		card_item.set_selected(true)
		
		if card_item.has_meta("original_y"):
			var original_y = card_item.get_meta("original_y")
			card_item.position.y = original_y - 40
		else:
			card_item.position.y -= 40
		
		card_item.z_index = 2000
		
		var total_cards = card_hand_container.get_child_count()
		_push_adjacent_cards(card_index, total_cards, 60.0)
		
		add_combat_log("Selected: %s" % card.name)
		return
	
	# STAGE 2: Usage
	if card.type != "Attack":
		# Non-attack card: use immediately (no target needed)
		currently_selected_card_item.set_selected(false)
		_restore_card_position(currently_selected_card_item)
		_reset_card_positions()
		currently_selected_card_index = -1
		currently_selected_card_item = null
		
		request_action("card_played", {"card_index": card_index, "target": -1})
	else:
		# Attack card: enter target selection mode
		_enter_target_selection_mode()
		add_combat_log("Drag to target")

func _on_card_hovered(card_index: int, card_item: Control):
	"""Handle card hover"""
	if not card_item or card_index == currently_selected_card_index:
		return
	
	if not card_item.has_meta("original_y"):
		card_item.set_meta("original_y", card_item.position.y)
	
	var original_y = card_item.get_meta("original_y")
	card_item.position.y = original_y - 20
	card_item.z_index = 1000

func _on_card_unhovered(card_item: Control):
	"""Handle card unhover"""
	if not card_item or card_item == currently_selected_card_item:
		return
	
	if card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y")

# === Targeting ===

func _enter_target_selection_mode():
	"""Enter target selection mode for attack cards"""
	selecting_target = true
	selected_card_index = currently_selected_card_index
	add_combat_log("Click a monster to attack")
	print("[CombatBottomUI] Target selection mode entered - Click a monster or press ESC to cancel")

func on_monster_clicked(monster_index: int):
	"""Handle monster click from InRun_v4 (public method)"""
	print("[CombatBottomUI] Monster clicked: index %d, selecting_target=%s" % [monster_index, selecting_target])
	
	if not selecting_target:
		print("[CombatBottomUI] Not in target selection mode, ignoring click")
		return
	
	# Check if monster is alive
	var monsters = CombatManager.monsters
	if monster_index < 0 or monster_index >= monsters.size():
		print("[CombatBottomUI] Invalid monster index: %d" % monster_index)
		return
	
	if monsters[monster_index].hp <= 0:
		add_combat_log("Target already dead!")
		print("[CombatBottomUI] Monster %d is already dead" % monster_index)
		return
	
	# Play card with selected target
	_play_card_with_target(currently_selected_card_index, monster_index)

func _get_first_alive_monster() -> int:
	"""Get index of first alive monster"""
	var monsters = CombatManager.monsters
	for i in range(monsters.size()):
		if monsters[i].hp > 0:
			return i
	return -1

func _play_card_with_target(card_index: int, target_index: int):
	"""Play selected attack card with target"""
	# Reset selection state
	if currently_selected_card_item:
		currently_selected_card_item.set_selected(false)
		_restore_card_position(currently_selected_card_item)
		_reset_card_positions()
	
	currently_selected_card_index = -1
	currently_selected_card_item = null
	selecting_target = false
	selected_card_index = -1
	
	# Play card
	request_action("card_played", {"card_index": card_index, "target": target_index})
	add_combat_log("Attacked target #%d" % (target_index + 1))

func _cancel_target_selection():
	"""Cancel targeting"""
	selecting_target = false
	selected_card_index = -1
	is_dragging = false
	
	if drag_arrow:
		drag_arrow.queue_free()
		drag_arrow = null

# === Button Handlers ===

func _on_pass_pressed():
	"""Pass button"""
	request_action("pass", {})
	add_combat_log("Player passed.")

func _on_auto_pressed():
	"""Auto button"""
	request_action("auto_toggle", {})
	
	if CombatManager.auto_battle_enabled:
		auto_button.text = "Auto: ON"
		_apply_button_style(auto_button, UITheme.COLORS.primary)  # Blue when ON
	else:
		auto_button.text = "Auto"
		_apply_button_style(auto_button, UITheme.COLORS.panel)  # Gray when OFF

func _on_speed_pressed():
	"""Speed button"""
	var speed = CombatManager.speed_multiplier
	
	if speed == 1.0:
		speed = 2.0
	elif speed == 2.0:
		speed = 3.0
	elif speed == 3.0:
		speed = 0.5
	else:
		speed = 1.0
	
	request_action("speed_change", {"speed": speed})
	speed_button.text = "Speed: %.1f×" % speed

# === Signal Handlers ===

func _on_entity_updated(entity_type: String, index: int):
	"""Entity updated"""
	pass  # TopArea handles this

func _on_combat_log_updated(message: String):
	"""Combat log updated"""
	add_combat_log(message)

func _on_combat_ended(victory: bool):
	"""Combat ended - log result"""
	if victory:
		add_combat_log("=== VICTORY ===")
		print("[CombatBottomUI] Combat ended - VICTORY")
	else:
		add_combat_log("=== DEFEAT ===")
		print("[CombatBottomUI] Combat ended - DEFEAT")
	
	# Note: InRun_v4 handles reward modal via CombatManager.combat_ended signal

func _on_energy_changed(current: int, max_val: int):
	"""Energy changed"""
	if energy_orb:
		energy_orb.set_energy(current, max_val)
		print("[CombatBottomUI] Energy updated: %d/%d" % [current, max_val])
	else:
		print("[CombatBottomUI] ERROR: energy_orb is null!")

func _on_energy_timer_updated(progress: float):
	"""Energy timer updated"""
	if energy_orb:
		energy_orb.set_timer_progress(progress)
	else:
		print("[CombatBottomUI] ERROR: energy_orb is null for timer!")

func _on_hand_changed():
	"""Hand changed"""
	_update_deck_ui()
	_update_hand_ui()

# === Input Handling (Drag Targeting) ===

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if selecting_target or currently_selected_card_item:
				if currently_selected_card_item:
					currently_selected_card_item.set_selected(false)
					_restore_card_position(currently_selected_card_item)
					_reset_card_positions()
					currently_selected_card_index = -1
					currently_selected_card_item = null
				_cancel_target_selection()
				add_combat_log("Selection cancelled.")
