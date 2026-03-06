extends BaseBottomUI

"""
CombatBottomUI - Combat bottom bar.
Card hand + log + buttons (2-column layout).
Layout: CardHandArea, GameInfo (Energy/Deck/Discard), CombatLog, ActionButtons.
"""

# Reaction labels: use Unicode escape to avoid "Unicode parsing error" when scene loads (engine Latin-1)
const _TXT_GUARD := "\uBC29\uC5B4"      # Guard
const _TXT_REACTION := "\uB9AC\uC561\uC158"  # Reaction
const _TXT_PARRY := "\uD328\uB9C1"     # Parry
const _TXT_DODGE := "\uD68C\uD53C"     # Dodge

# Class-level signals (GDScript4: must be at top)
signal target_selection_changed(monster_index: int)  # -1=clear, >=0=selected
signal card_play_with_animation_requested(card_item: Control, card, target_type: String, target_index: int)

@onready var card_hand_container = $CardHandArea
@onready var energy_orb = $GameInfo/EnergyOrb
@onready var deck_label = $GameInfo/DeckArea/DeckLabel
@onready var discard_label = $GameInfo/DiscardArea/DiscardLabel
@onready var exile_label = $GameInfo/ExileLabel
@onready var combat_log_content = $CombatLog/ScrollContainer/LogContent
@onready var pass_button = $ActionButtons/PassButton
@onready var auto_button = $ActionButtons/AutoButton
@onready var speed_button = $ActionButtons/SpeedButton
@onready var reaction_button = $ActionButtons/ReactionButton

# Card selection state
var currently_selected_card_index: int = -1
var currently_selected_card_item: Control = null
var _prev_hand_count: int = 0

# Targeting state
var selecting_target: bool = false
var selected_card_index: int = -1
var is_dragging: bool = false
var drag_arrow: Node2D = null

# Reaction button state
var _reaction_card: Card = null
var _reaction_window_active: bool = false
var _excluded_reaction_types: Array = []  # Failed types this window (parry fail -> dodge/guard)

# Drag arrow (ATK card targeting)
var _draw_arrow_from: Vector2 = Vector2.ZERO
var _draw_arrow_to: Vector2 = Vector2.ZERO
var _draw_arrow_visible: bool = false

# New combat manager bridge (CombatManagerATB / CombatManagerTB)
var new_combat_manager: Node = null
var new_hand: Array = []
var _selected_target_index: int = -1
var _targeting_card: Card = null  # Card ref when in target mode
var _auto_enabled: bool = false
var _speed: float = 1.0

const TYPE_TO_DISPLAY = {
	"ATK": "Attack", "SKILL": "Skill",
	"POWER": "Power", "CURSE": "Curse"
}

func _ready():
	if energy_orb:
		var EnergyOrbScript = load("res://ui/components/EnergyOrb.gd")
		energy_orb.set_script(EnergyOrbScript)
		energy_orb._ready()
		energy_orb.set_energy(3, 3)
		energy_orb.set_timer_progress(0.0)
	else:
		push_error("[CombatBottomUI] EnergyOrb node not found")

	_setup_buttons()
	ui_ready.emit()

# === New Combat Manager Bridge ===

func connect_combat_manager(manager: Node):
	"""Connect CombatManagerATB or CombatManagerTB"""
	new_combat_manager = manager
	if "speed_multiplier" in manager:
		_speed = manager.speed_multiplier
		if speed_button:
			speed_button.text = "Speed: %.1f×" % _speed

	if manager.has_signal("hand_updated"):
		manager.hand_updated.connect(_on_new_hand_updated)
	if manager.has_signal("energy_updated"):
		manager.energy_updated.connect(_on_new_energy_updated)
	if manager.has_signal("combat_ended"):
		manager.combat_ended.connect(_on_new_combat_ended_signal)
	if manager.has_signal("battle_log_updated"):
		manager.battle_log_updated.connect(_on_combat_log_updated)
	if manager.has_signal("energy_timer_progress"):
		manager.energy_timer_progress.connect(_on_energy_timer_progress)
	if manager.has_signal("combat_started"):
		manager.combat_started.connect(_on_combat_started_sync)
	# ATB Pass 10s cooldown
	if manager.has_signal("pass_timer_updated"):
		manager.pass_timer_updated.connect(_on_pass_timer_updated)

	# Reaction window: reset and sync with manager state (avoid stale "open" from previous combat)
	_reaction_window_active = false
	_reaction_card = null
	_excluded_reaction_types.clear()
	if "reaction_mgr" in manager and manager.reaction_mgr:
		var rm = manager.reaction_mgr
		if rm.get("reaction_state") == "OPEN":
			_reaction_window_active = true
		if rm.has_signal("reaction_window_opened") and not rm.reaction_window_opened.is_connected(_on_reaction_window_opened):
			rm.reaction_window_opened.connect(_on_reaction_window_opened)
		if rm.has_signal("reaction_window_closed") and not rm.reaction_window_closed.is_connected(_on_reaction_window_closed):
			rm.reaction_window_closed.connect(_on_reaction_window_closed)
		if rm.has_signal("reaction_attempt_failed") and not rm.reaction_attempt_failed.is_connected(_on_reaction_attempt_failed):
			rm.reaction_attempt_failed.connect(_on_reaction_attempt_failed)

	_update_deck_ui()
	# TB: Pass always on. ATB: pass_timer_updated
	if pass_button:
		pass_button.disabled = (manager is CombatManagerATB)
	_update_reaction_button()

func _on_reaction_window_opened(_attack: Dictionary):
	_reaction_window_active = true
	_update_reaction_button()

func _on_reaction_window_closed(_result_type: String):
	_reaction_window_active = false
	_excluded_reaction_types.clear()
	_update_reaction_button()

func _on_reaction_attempt_failed(attempted_type: String):
	"""On parry/dodge fail, exclude type and enable next (dodge/guard) button"""
	if attempted_type not in _excluded_reaction_types:
		_excluded_reaction_types.append(attempted_type)
	_update_reaction_button()

func _card_to_dict(card: Card) -> Dictionary:
	"""Card Resource to Dictionary (CardHandItem format)"""
	var tags_arr: Array = []
	for t in card.tags:
		tags_arr.append(str(t))
	var rate: float = float(card.auto_dodge_success_rate)
	return {
		"name": card.name,
		"cost": card.cost,
		"type": TYPE_TO_DISPLAY.get(card.type, "Attack"),
		"description": card.get_mobile_description(),
		"damage": card.damage,
		"block": card.block,
		"draw": card.draw,
		"tags": tags_arr,
		"auto_dodge_success_rate": rate,
	}

func _on_new_hand_updated(hand: Array):
	if hand == null:
		return
	new_hand = hand.duplicate()
	_update_deck_ui()
	var old_count = _prev_hand_count
	_prev_hand_count = hand.size()
	if hand.is_empty() and card_hand_container and card_hand_container.get_child_count() > 0:
		_run_discard_animation()
		return
	var drawn_count = hand.size() - old_count
	# Defer one frame for layout/node ready (avoid combat enter crash)
	call_deferred("_update_hand_ui", drawn_count if drawn_count > 0 else 0)

func _on_new_energy_updated(current, max_val):
	if energy_orb and energy_orb.has_method("set_energy"):
		energy_orb.set_energy(int(current), int(max_val))
	# Refresh reaction button on energy change (affordability)
	_update_reaction_button()

func _on_new_combat_ended_signal(result: String):
	_reaction_window_active = false
	_reaction_card = null
	_excluded_reaction_types.clear()
	_update_reaction_button()
	if result == "WIN":
		add_combat_log("=== VICTORY ===")
	else:
		add_combat_log("=== DEFEAT ===")

func _get_new_manager_energy() -> int:
	if new_combat_manager and new_combat_manager.has_method("get_energy"):
		return new_combat_manager.get_energy()
	if new_combat_manager and new_combat_manager.get("energy_system"):
		var es = new_combat_manager.energy_system
		if es.has_method("get_current"):
			return es.get_current()
	return 0

# === Lifecycle ===

func _on_enter():
	"""When UI is activated"""
	# New manager signals are connected via connect_combat_manager()
	if not new_combat_manager:
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

	_update_deck_ui()

	if not new_combat_manager:
		if CombatManager.hero:
			var current_energy = 0
			if CombatManager.hero is Dictionary:
				current_energy = int(CombatManager.hero.get("energy", 0))
			else:
				var v = CombatManager.hero.get("energy")
				current_energy = int(v) if v != null else 0
			_on_energy_changed(current_energy, CombatManager.ENERGY_MAX)

	add_combat_log("=== Combat UI Ready ===")

func _on_exit():
	"""When UI is deactivated"""
	_reaction_window_active = false
	_reaction_card = null
	_excluded_reaction_types.clear()
	# Disconnect new manager signals
	if new_combat_manager:
		if "reaction_mgr" in new_combat_manager and new_combat_manager.reaction_mgr:
			var rm = new_combat_manager.reaction_mgr
			if rm.has_signal("reaction_window_opened") and rm.reaction_window_opened.is_connected(_on_reaction_window_opened):
				rm.reaction_window_opened.disconnect(_on_reaction_window_opened)
			if rm.has_signal("reaction_window_closed") and rm.reaction_window_closed.is_connected(_on_reaction_window_closed):
				rm.reaction_window_closed.disconnect(_on_reaction_window_closed)
			if rm.has_signal("reaction_attempt_failed") and rm.reaction_attempt_failed.is_connected(_on_reaction_attempt_failed):
				rm.reaction_attempt_failed.disconnect(_on_reaction_attempt_failed)
		if new_combat_manager.has_signal("hand_updated") and new_combat_manager.hand_updated.is_connected(_on_new_hand_updated):
			new_combat_manager.hand_updated.disconnect(_on_new_hand_updated)
		if new_combat_manager.has_signal("energy_updated") and new_combat_manager.energy_updated.is_connected(_on_new_energy_updated):
			new_combat_manager.energy_updated.disconnect(_on_new_energy_updated)
		if new_combat_manager.has_signal("combat_ended") and new_combat_manager.combat_ended.is_connected(_on_new_combat_ended_signal):
			new_combat_manager.combat_ended.disconnect(_on_new_combat_ended_signal)
		if new_combat_manager.has_signal("battle_log_updated") and new_combat_manager.battle_log_updated.is_connected(_on_combat_log_updated):
			new_combat_manager.battle_log_updated.disconnect(_on_combat_log_updated)
		if new_combat_manager.has_signal("energy_timer_progress") and new_combat_manager.energy_timer_progress.is_connected(_on_energy_timer_progress):
			new_combat_manager.energy_timer_progress.disconnect(_on_energy_timer_progress)
		if new_combat_manager.has_signal("combat_started") and new_combat_manager.combat_started.is_connected(_on_combat_started_sync):
			new_combat_manager.combat_started.disconnect(_on_combat_started_sync)
		if new_combat_manager.has_signal("pass_timer_updated") and new_combat_manager.pass_timer_updated.is_connected(_on_pass_timer_updated):
			new_combat_manager.pass_timer_updated.disconnect(_on_pass_timer_updated)
		new_combat_manager = null
		new_hand.clear()
		_prev_hand_count = 0

	# Disconnect old autoload signals
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

	_cancel_target_selection()

func _setup_buttons():
	"""Setup button connections"""
	# Apply custom styles to buttons
	_apply_button_style(pass_button, UITheme.COLORS.panel)

	# Auto button: off by default, synced on combat_started
	_auto_enabled = false
	auto_button.text = "Auto"
	_apply_button_style(auto_button, UITheme.COLORS.panel)

	_apply_button_style(speed_button, UITheme.COLORS.panel)

	# Reaction button: initially disabled (ASCII only to avoid parse error)
	if reaction_button:
		reaction_button.text = "Defense"
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)

	pass_button.pressed.connect(_on_pass_pressed)
	auto_button.pressed.connect(_on_auto_pressed)
	speed_button.pressed.connect(_on_speed_pressed)
	if reaction_button:
		reaction_button.pressed.connect(_on_reaction_pressed)

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
	if new_combat_manager:
		var deck_size := 0
		var discard_size := 0
		var exile_size := 0
		if new_combat_manager is CombatManagerATB:
			deck_size = new_combat_manager.deck.size()
			discard_size = new_combat_manager.discard_pile.size()
		elif new_combat_manager.get("hand_system"):
			var hs = new_combat_manager.hand_system
			deck_size = hs.get_deck_size()
			discard_size = hs.get_discard_size()
		if deck_label:
			deck_label.text = "%d" % deck_size
		if discard_label:
			discard_label.text = "%d" % discard_size
		if exile_label:
			exile_label.text = "🚫 %d" % exile_size
		if energy_orb and energy_orb.has_method("set_energy"):
			energy_orb.set_energy(_get_new_manager_energy(), 3)
	else:
		if deck_label:
			deck_label.text = "%d" % DeckManager.get_deck_size()
		if discard_label:
			discard_label.text = "%d" % DeckManager.get_discard_size()
		if exile_label:
			exile_label.text = "🚫 %d" % DeckManager.get_exile_size()
		if energy_orb and energy_orb.has_method("set_energy"):
			var current = CombatManager.get_current_energy()
			var maximum = CombatManager.get_max_energy()
			energy_orb.set_energy(current, maximum)

func _get_deck_ui_pos() -> Vector2:
	var deck_area = get_node_or_null("GameInfo/DeckArea")
	if deck_area:
		return card_hand_container.get_global_transform_with_canvas().affine_inverse() * (
			deck_area.get_global_transform_with_canvas().get_origin() + deck_area.size / 2)
	return Vector2(80, card_hand_container.size.y / 2)

func _get_discard_ui_pos() -> Vector2:
	var discard_area = get_node_or_null("GameInfo/DiscardArea")
	if discard_area:
		return card_hand_container.get_global_transform_with_canvas().affine_inverse() * (
			discard_area.get_global_transform_with_canvas().get_origin() + discard_area.size / 2)
	return Vector2(card_hand_container.size.x - 80, card_hand_container.size.y / 2)

func _run_discard_animation():
	"""Animate hand cards to discard then clear"""
	var target = _get_discard_ui_pos()
	var cards = card_hand_container.get_children().duplicate()
	var tween = create_tween()
	tween.set_parallel(true)
	for c in cards:
		tween.tween_property(c, "position", target, 0.25).set_ease(Tween.EASE_IN)
		tween.tween_property(c, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(func():
		for c in cards:
			if is_instance_valid(c):
				c.queue_free()
		_update_reaction_button()
	)

func _update_hand_ui(animate_from_deck_count: int = 0):
	"""Update card hand display (bounds, selected card spacing)"""
	if not card_hand_container:
		return
	for child in card_hand_container.get_children():
		if is_instance_valid(child):
			child.queue_free()

	var hand: Array
	var current_energy: int
	if new_combat_manager:
		hand = new_hand
		current_energy = _get_new_manager_energy()
	else:
		hand = DeckManager.get_hand_cards()
		current_energy = CombatManager.get_current_energy()

	if hand == null or hand.is_empty():
		return
	# Remove nulls (combat manager safety)
	var valid_hand: Array = []
	for c in hand:
		if c != null:
			valid_hand.append(c)
	if valid_hand.is_empty():
		return
	hand = valid_hand

	var card_scene = preload("res://ui/components/CardHandItem.tscn")
	var num_cards = hand.size()
	var card_w = 91.0
	var container_w = max(card_w, card_hand_container.size.x)
	var sel_idx = currently_selected_card_index

	# Left-right bounds, 2x spacing for selected
	var total_span = container_w - card_w
	var positions_x: Array[float] = []
	positions_x.resize(num_cards)
	if num_cards <= 1:
		positions_x[0] = 0.0
	elif sel_idx >= 0:
		var gap_units: float = 0.0
		for i in range(1, num_cards):
			gap_units += 2.0 if (i - 1 == sel_idx or i == sel_idx) else 1.0
		var unit = total_span / gap_units
		positions_x[0] = 0.0
		for i in range(1, num_cards):
			var gap = unit * 2.0 if (i - 1 == sel_idx or i == sel_idx) else unit
			positions_x[i] = positions_x[i - 1] + gap
	else:
		for i in range(num_cards):
			positions_x[i] = i * total_span / float(num_cards - 1)

	# Tilt: selected=0, outer max +/-15
	const MAX_ANGLE = 15.0
	var base_y = 25.0
	var arc_depth = 16.0

	var deck_pos = _get_deck_ui_pos()
	for i in range(num_cards):
		var card = hand[i]
		var card_item = card_scene.instantiate()
		card_hand_container.add_child(card_item)

		var card_dict: Dictionary
		var card_cost: int
		if new_combat_manager and card is Card:
			card_dict = _card_to_dict(card)
			card_cost = card.cost
		elif card is Dictionary:
			card_dict = card
			card_cost = int(card.get("cost", 0))
		else:
			card_dict = {}
			card_cost = 0

		card_item.set_card(card_dict, i)
		card_item.set_affordable(current_energy >= card_cost)
		# Auto: parry disabled + X overlay (manual: normal)
		var is_auto = _auto_enabled
		if new_combat_manager:
			var ai = new_combat_manager.get("auto_ai")
			if ai != null and ai.get("mode") == 2:  # FULL = 2
				is_auto = true
		card_item.set_auto_parry_disabled(is_auto)

		var x_pos = positions_x[i]
		var angle: float = 0.0
		if i != sel_idx and num_cards > 1:
			var t = float(i) / (num_cards - 1)
			angle = lerp(-MAX_ANGLE, MAX_ANGLE, t)
		var normalized_pos = (float(i) / max(1, num_cards - 1) - 0.5) * 2.0 if num_cards > 1 else 0.0
		var y_pos = base_y + abs(normalized_pos) * arc_depth
		if i == sel_idx:
			y_pos -= 40

		var is_new_draw = animate_from_deck_count > 0 and i >= num_cards - animate_from_deck_count
		card_item.position = deck_pos if is_new_draw else Vector2(x_pos, y_pos)
		card_item.set_meta("original_y", y_pos)
		card_item.rotation_degrees = angle
		card_item.z_index = i
		card_item.set_meta("base_x", x_pos)
		card_item.set_meta("base_index", i)

		if i == sel_idx:
			card_item.set_selected(true)
			card_item.z_index = 2000
			currently_selected_card_item = card_item

		card_item.card_clicked.connect(_on_card_pressed)
		card_item.card_hovered.connect(_on_card_hovered.bind(card_item))
		card_item.card_unhovered.connect(_on_card_unhovered.bind(card_item))

		if is_new_draw:
			var final_pos = Vector2(x_pos, y_pos)
			var tw = create_tween()
			tw.tween_property(card_item, "position", final_pos, 0.2).set_ease(Tween.EASE_OUT)

	_update_reaction_button()

func _refresh_hand_layout():
	"""Recalc layout on selection change"""
	call_deferred("_update_hand_ui", 0)

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
	"""Card tap: DEF/SKILL=use; ATK=select+target mode; same card again=cancel"""
	var hand: Array
	if new_combat_manager:
		hand = new_hand
	else:
		hand = DeckManager.get_hand_cards()

	if card_index < 0 or card_index >= hand.size():
		return

	var card = hand[card_index]

	# Energy check
	var card_cost: int
	var current_energy: int
	if new_combat_manager and card is Card:
		card_cost = card.cost
		current_energy = _get_new_manager_energy()
	else:
		card_cost = int(card.get("cost", 0))
		current_energy = CombatManager.get_current_energy()

	if current_energy < card_cost:
		add_combat_log("\uC5D0\uB108\uC9C0 \uBD80\uC871!")  # Energy low
		return

	# Card type: ATK/DEF/SKILL (new) or Attack/Defense (legacy)
	var is_atk: bool
	var card_name: String
	if new_combat_manager and card is Card:
		is_atk = (card.type == "ATK" or card.type == "ATTACK")
		card_name = card.name
	else:
		var display_type = card.get("type", "Attack")
		is_atk = (display_type == "Attack")
		card_name = card.get("name", "???")

	# DEF/SKILL: two-tap (select then use)
	if not is_atk:
		var card_item_def: Control = null
		for child in card_hand_container.get_children():
			if child.card_index == card_index:
				card_item_def = child
				break
		if not card_item_def:
			return
		# Same card tapped again -> use (DEF/SKILL)
		if currently_selected_card_index == card_index and not selecting_target:
			if currently_selected_card_item:
				currently_selected_card_item.set_selected(false)
			var item = card_item_def
			currently_selected_card_index = -1
			currently_selected_card_item = null
			if new_combat_manager and card is Card:
				card_play_with_animation_requested.emit(item, card, "player", -1)
			else:
				request_action("card_played", {"card_index": card_index, "target": -1})
			add_combat_log("%s \uC0AC\uC6A9" % card_name)  # used
			return
		# First tap: select (show, lift like ATK)
		if currently_selected_card_item:
			currently_selected_card_item.set_selected(false)
		_cancel_target_selection()
		currently_selected_card_index = card_index
		currently_selected_card_item = card_item_def
		card_item_def.set_selected(true)
		if card_item_def.has_meta("original_y"):
			card_item_def.position.y = card_item_def.get_meta("original_y") - 40
		else:
			card_item_def.position.y -= 40
		card_item_def.z_index = 2000
		_refresh_hand_layout()
		add_combat_log("%s \uC120\uD0DD \u2014 \uD558\uC580 \uB354 \uB204\uB294 \uC0AC\uC6A9" % card_name)
		return

	# ATK: select then target (drag/tap)
	var card_item: Control = null
	for child in card_hand_container.get_children():
		if child.card_index == card_index:
			card_item = child
			break

	if not card_item:
		return

	# Same card tapped again -> cancel
	if currently_selected_card_index == card_index and selecting_target:
		currently_selected_card_item.set_selected(false)
		currently_selected_card_index = -1
		currently_selected_card_item = null
		_cancel_target_selection()
		_refresh_hand_layout()
		add_combat_log("\uCDE8\uC18C\uB418\uC74C")  # Cancelled
		return

	# Clear previous selection
	if currently_selected_card_item:
		currently_selected_card_item.set_selected(false)

	# Select card (lift)
	currently_selected_card_index = card_index
	currently_selected_card_item = card_item
	card_item.set_selected(true)
	if card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y") - 40
	else:
		card_item.position.y -= 40
	card_item.z_index = 2000
	_refresh_hand_layout()

	# Store card ref (safe if index changes)
	if new_combat_manager and card is Card:
		_targeting_card = card
	else:
		_targeting_card = null

	# Enter target mode + drag arrow
	_enter_target_selection_mode()
	var card_center_global = card_item.get_global_position() + Vector2(card_item.size.x * 0.5, card_item.size.y * 0.3)
	_draw_arrow_from = get_global_transform_with_canvas().affine_inverse() * card_center_global
	_draw_arrow_to = _draw_arrow_from
	_draw_arrow_visible = true
	queue_redraw()
	add_combat_log("%s \uC120\uD0DD \u2014 \uC801\uC744 \uD0ED\uD558\uAC70\uB098 \uB4DC\uB798\uADF8" % card_name)

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
	"""Enter target mode (ATK only)"""
	selecting_target = true
	selected_card_index = currently_selected_card_index

func on_monster_clicked(monster_index: int):
	"""Monster click -> attack immediately"""
	if not selecting_target:
		return

	if new_combat_manager:
		var enemies = new_combat_manager.enemies
		if monster_index < 0 or monster_index >= enemies.size():
			return
		if not enemies[monster_index].is_alive():
			add_combat_log("\uC774\uBBF8 \uC8FD\uC740 \uB300\uC0C1!")  # Already dead
			return
	else:
		var monsters = CombatManager.monsters
		if monster_index < 0 or monster_index >= monsters.size():
			return
		if monsters[monster_index].hp <= 0:
			add_combat_log("\uC774\uBBF8 \uC8FD\uC740 \uB300\uC0C1!")  # Already dead
			return

	# One-click fire (no double-tap confirm)
	_play_card_with_target(currently_selected_card_index, monster_index)

func on_monster_drag_dropped(monster_index: int):
	"""On drop on monster -> use card on it (damage + anim)"""
	if not selecting_target or currently_selected_card_index < 0:
		return
	if new_combat_manager:
		var enemies = new_combat_manager.enemies
		if monster_index < 0 or monster_index >= enemies.size():
			return
		if not enemies[monster_index].is_alive():
			add_combat_log("Target already dead!")
			return
	else:
		var monsters = CombatManager.monsters
		if monster_index < 0 or monster_index >= monsters.size():
			return
		if monsters[monster_index].hp <= 0:
			add_combat_log("Target already dead!")
			return
	_play_card_with_target(currently_selected_card_index, monster_index)

func _get_first_alive_monster() -> int:
	"""Get index of first alive monster"""
	var monsters = CombatManager.monsters
	for i in range(monsters.size()):
		if monsters[i].hp > 0:
			return i
	return -1

func _play_card_with_target(card_index: int, target_index: int):
	"""Use ATK card on monster"""
	# Capture _targeting_card/card_item before cancel (they get nulled)
	var card_item = currently_selected_card_item
	var card: Card = null
	if _targeting_card != null:
		card = _targeting_card
	elif card_index >= 0 and card_index < new_hand.size():
		card = new_hand[card_index]

	_clear_target_selection()
	if card_item:
		card_item.set_selected(false)
	currently_selected_card_index = -1
	currently_selected_card_item = null
	selected_card_index = -1
	_cancel_target_selection()

	if new_combat_manager:
		if card != null:
			card_play_with_animation_requested.emit(card_item, card, "monster", target_index)
			add_combat_log("\u26CF %s \u2192 #%d" % [card.name, target_index + 1])
		else:
			add_combat_log("\uCE74\uB4DC\uB97C \uCC3E\uC744 \uC218 \uC5C6\uC74C (index=%d)" % card_index)
	else:
		_targeting_card = null
		request_action("card_played", {"card_index": card_index, "target": target_index})
		add_combat_log("Attacked target #%d" % (target_index + 1))

func _set_target_selection(monster_index: int):
	_selected_target_index = monster_index
	emit_signal("target_selection_changed", monster_index)

func _clear_target_selection():
	_selected_target_index = -1
	emit_signal("target_selection_changed", -1)

func _cancel_target_selection():
	"""Cancel target + hide drag arrow"""
	selecting_target = false
	selected_card_index = -1
	_targeting_card = null
	_clear_target_selection()
	is_dragging = false

	# Hide drag arrow
	_draw_arrow_visible = false
	queue_redraw()

	if drag_arrow:
		drag_arrow.queue_free()
		drag_arrow = null

# === Button Handlers ===

func _on_pass_pressed():
	"""Pass: ATB=draw 5 (10s cooldown). TB=end turn"""
	if new_combat_manager:
		if new_combat_manager is CombatManagerATB:
			if new_combat_manager.is_pass_ready():
				new_combat_manager.player_pass_atb()
				add_combat_log("Pass \u2014 \uC0C8 \uCE74\uB4DC 5\uC7A5 \uB4DC\uB85C\uC6B0")
			else:
				var remain = new_combat_manager.get_pass_timer_remaining() if new_combat_manager else 0.0
				add_combat_log("Pass \uB300\uAE30\uC911 (%.0f\uCD08 \uD6C4 \uAC00\uB2A5)" % remain)
		elif new_combat_manager.has_method("player_end_turn"):
			new_combat_manager.player_end_turn()
			add_combat_log("\uD2B8\uB80C \uC885\uB8B0")  # Turn end
	else:
		request_action("pass", {})
		add_combat_log("Player passed.")

func _on_auto_pressed():
	"""Auto button"""
	if new_combat_manager:
		_auto_enabled = not _auto_enabled
		var ai = new_combat_manager.get("auto_ai")
		if ai and ai.has_method("set_mode"):
			# ATBAutoAI/TurnBasedAutoAI: FULL=2, MANUAL=0
			if ai is ATBAutoAI:
				ai.set_mode(ATBAutoAI.AutoMode.FULL if _auto_enabled else ATBAutoAI.AutoMode.MANUAL)
			elif ai is TurnBasedAutoAI:
				ai.set_mode(TurnBasedAutoAI.AutoMode.FULL if _auto_enabled else TurnBasedAutoAI.AutoMode.MANUAL)
			else:
				ai.set("mode", 2 if _auto_enabled else 0)
		if _auto_enabled:
			auto_button.text = "Auto: ON"
			_apply_button_style(auto_button, UITheme.COLORS.primary)
		else:
			auto_button.text = "Auto"
			_apply_button_style(auto_button, UITheme.COLORS.panel)
		# On auto toggle refresh parry button/card X
		_update_reaction_button()
		_update_hand_ui(0)
	else:
		request_action("auto_toggle", {})
		if CombatManager.auto_battle_enabled:
			auto_button.text = "Auto: ON"
			_apply_button_style(auto_button, UITheme.COLORS.primary)
		else:
			auto_button.text = "Auto"
			_apply_button_style(auto_button, UITheme.COLORS.panel)

func _on_speed_pressed():
	"""Speed button"""
	if new_combat_manager:
		if _speed == 1.0:
			_speed = 2.0
		elif _speed == 2.0:
			_speed = 3.0
		elif _speed == 3.0:
			_speed = 0.5
		else:
			_speed = 1.0
		if new_combat_manager.has_method("set_speed"):
			new_combat_manager.set_speed(_speed)
		elif "speed_multiplier" in new_combat_manager:
			new_combat_manager.speed_multiplier = _speed
		speed_button.text = "Speed: %.1f×" % _speed
	else:
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
	else:
		add_combat_log("=== DEFEAT ===")
	
	# Note: InRun_v4 handles reward modal via CombatManager.combat_ended signal

func _on_energy_changed(current: int, max_val: int):
	"""Energy changed"""
	if energy_orb:
		energy_orb.set_energy(current, max_val)

func _on_energy_timer_updated(progress: float):
	"""Energy timer updated (legacy CombatManager)"""
	if energy_orb:
		energy_orb.set_timer_progress(progress)

func _on_energy_timer_progress(progress: float):
	"""Energy timer progress (ATB EnergyOrb cooldown gauge)"""
	if energy_orb:
		energy_orb.set_timer_progress(progress)

func _on_hand_changed():
	"""Hand changed"""
	_update_deck_ui()
	_update_hand_ui()

# === Input Handling (Drag Targeting) ===

func _input(event):
	# ESC / back cancel
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if selecting_target or currently_selected_card_item:
			if currently_selected_card_item:
				currently_selected_card_item.set_selected(false)
				currently_selected_card_index = -1
				currently_selected_card_item = null
			_cancel_target_selection()
			_refresh_hand_layout()
			add_combat_log("\uCDE8\uC18C\uB418\uC74C")  # Cancelled

# _process: drag arrow update

func _process(_delta):
	if _draw_arrow_visible and selecting_target:
		_draw_arrow_to = get_global_transform_with_canvas().affine_inverse() * get_global_mouse_position()
		queue_redraw()

# _draw: arrow (ATK targeting)

func _draw():
	if not _draw_arrow_visible:
		return
	var from = _draw_arrow_from
	var to   = _draw_arrow_to
	var dist = from.distance_to(to)
	if dist < 10.0:
		return

	var arrow_color = Color(1.0, 0.85, 0.1, 0.9)
	var line_width  = 4.0
	draw_line(from, to, arrow_color, line_width, true)

	# Arrowhead
	var dir  = (to - from).normalized()
	var perp = Vector2(-dir.y, dir.x)
	var tip_size = 18.0
	draw_line(to, to - dir * tip_size + perp * tip_size * 0.55, arrow_color, line_width, true)
	draw_line(to, to - dir * tip_size - perp * tip_size * 0.55, arrow_color, line_width, true)

# Reaction button refresh

func _set_reaction_button_text(t: String) -> void:
	"""Set reaction label; defer non-ASCII one frame to avoid parse error."""
	if not reaction_button:
		return
	var is_ascii = true
	for i in range(t.length()):
		if t.unicode_at(i) > 127:
			is_ascii = false
			break
	if is_ascii:
		reaction_button.text = t
	else:
		call_deferred("_set_reaction_button_text_deferred", t)

func _set_reaction_button_text_deferred(t: String) -> void:
	if reaction_button:
		reaction_button.text = t

func _is_reaction_window_really_open() -> bool:
	"""리액션 창이 실제로 열려 있을 때만 true. 시그널 누락 시 reaction_mgr 상태로 동기화."""
	if not _reaction_window_active:
		return false
	if not new_combat_manager or not ("reaction_mgr" in new_combat_manager):
		return false
	var rm = new_combat_manager.reaction_mgr
	return rm != null and rm.get("reaction_state") == "OPEN"

func _update_reaction_button():
	"""Pick reaction card by priority PARRY > DODGE > GUARD. Only active when reaction window is really open."""
	if not reaction_button:
		return
	if not new_combat_manager:
		_set_reaction_button_text(_TXT_GUARD)
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)
		return
	# 리액션 창이 실제로 열려 있을 때만 버튼 활성화 (시그널/상태 불일치 방지)
	if not _is_reaction_window_really_open():
		_set_reaction_button_text(_TXT_REACTION)
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)
		return

	_reaction_card = null
	var best_priority = 0  # PARRY(3)/DODGE(2)/GUARD(1)
	var priority_map = {"PARRY": 3, "DODGE": 2, "GUARD": 1}
	if _auto_enabled:
		priority_map["PARRY"] = 0  # Auto: no parry on button (dodge/guard only)
	# TB reaction window: no energy cost for parry/dodge/guard
	var no_energy_check = new_combat_manager is CombatManagerTB and _reaction_window_active

	for card in new_hand:
		if not (card is Card):
			continue
		# Exclude types that failed this window (try next option)
		var excluded = false
		for exc in _excluded_reaction_types:
			if card.has_tag(exc):
				excluded = true
				break
		if excluded:
			continue
		var can_afford = no_energy_check or (card.cost <= _get_new_manager_energy())
		for tag in card.tags:
			var p = int(priority_map.get(tag, 0))
			if p > best_priority and can_afford:
				best_priority = p
				_reaction_card = card

	if _reaction_card != null:
		var tag_found = ""
		for tag in _reaction_card.tags:
			if tag in priority_map:
				tag_found = tag
				break
		var label_map = {"PARRY": _TXT_PARRY, "DODGE": _TXT_DODGE, "GUARD": _TXT_GUARD}
		_set_reaction_button_text(label_map.get(tag_found, _TXT_GUARD))
		reaction_button.disabled = false
		# Active: blue style
		var active_style = StyleBoxFlat.new()
		active_style.bg_color = Color(0.15, 0.42, 0.75)
		active_style.corner_radius_top_left    = 8
		active_style.corner_radius_top_right   = 8
		active_style.corner_radius_bottom_left = 8
		active_style.corner_radius_bottom_right = 8
		active_style.content_margin_left   = 12
		active_style.content_margin_right  = 12
		active_style.content_margin_top    = 10
		active_style.content_margin_bottom = 10
		reaction_button.add_theme_stylebox_override("normal",  active_style)
		reaction_button.add_theme_stylebox_override("hover",   active_style)
		reaction_button.add_theme_stylebox_override("pressed", active_style)
		reaction_button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
		reaction_button.add_theme_color_override("font_color", Color.WHITE)
	else:
		_set_reaction_button_text(_TXT_GUARD)
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)

func _on_reaction_pressed():
	"""Reaction button: use parry/dodge/guard card. Only when reaction window is really open."""
	if _reaction_card == null:
		return
	if not _is_reaction_window_really_open():
		return
	if new_combat_manager:
		new_combat_manager.player_play_card(_reaction_card)
	else:
		var idx = new_hand.find(_reaction_card)
		if idx >= 0:
			request_action("card_played", {"card_index": idx, "target": -1})
	_update_reaction_button()

# Auto button sync (on combat_started)

func _on_pass_timer_updated(remaining: float, _duration: float):
	"""ATB Pass enable when 10s cooldown done"""
	if pass_button and new_combat_manager is CombatManagerATB:
		pass_button.disabled = (remaining > 0)

func _on_combat_started_sync():
	"""Sync Auto button with AI mode on combat start"""
	if not new_combat_manager:
		return
	var ai = new_combat_manager.get("auto_ai")
	if ai and "mode" in ai:
		# FULL=2 (ATB/TB)
		_auto_enabled = (ai.mode == 2)
		if _auto_enabled:
			auto_button.text = "Auto: ON"
			_apply_button_style(auto_button, UITheme.COLORS.primary)
		else:
			auto_button.text = "Auto"
			_apply_button_style(auto_button, UITheme.COLORS.panel)
