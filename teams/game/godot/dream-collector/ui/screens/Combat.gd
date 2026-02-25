extends Control

# UI References
@onready var hero_hp_bar = $BattleScene/HeroArea/HeroHPBar
@onready var hero_hp_label = $BattleScene/HeroArea/HeroHPLabel
@onready var hero_atb_bar = $BattleScene/HeroArea/HeroATBBar
@onready var hero_energy_label = $TopBar/HeroEnergy

@onready var monster1 = $BattleScene/MonsterArea/Monster1
@onready var monster2 = $BattleScene/MonsterArea/Monster2

@onready var log_content = $CombatLog/ScrollContainer/LogContent

@onready var end_turn_button = $ActionButtons/ButtonsContainer/EndTurnButton
@onready var auto_button = $ActionButtons/ButtonsContainer/AutoButton
@onready var menu_button = $ActionButtons/ButtonsContainer/MenuButton

var monster_nodes = []

# Energy & Deck UI (created dynamically)
var energy_label: Label
var energy_timer_bar: ProgressBar
var deck_label: Label
var discard_label: Label
var exile_label: Label
var hand_container: HBoxContainer

func _ready():
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
	# Create energy info area (between log and buttons)
	var energy_area = Control.new()
	energy_area.name = "EnergyArea"
	energy_area.position = Vector2(0, 434)
	energy_area.size = Vector2(390, 300)
	add_child(energy_area)
	
	# Energy label
	energy_label = Label.new()
	energy_label.position = Vector2(16, 16)
	energy_label.text = "Energy: ⚡⚡⚡ (3/3)"
	energy_label.add_theme_font_size_override("font_size", 16)
	energy_area.add_child(energy_label)
	
	# Energy timer bar
	energy_timer_bar = ProgressBar.new()
	energy_timer_bar.position = Vector2(16, 48)
	energy_timer_bar.size = Vector2(358, 20)
	energy_timer_bar.max_value = 100
	energy_timer_bar.value = 0
	energy_area.add_child(energy_timer_bar)
	
	# Deck status labels
	deck_label = Label.new()
	deck_label.position = Vector2(16, 80)
	deck_label.text = "📚 Deck: 12"
	energy_area.add_child(deck_label)
	
	discard_label = Label.new()
	discard_label.position = Vector2(150, 80)
	discard_label.text = "🪦 Discard: 0"
	energy_area.add_child(discard_label)
	
	exile_label = Label.new()
	exile_label.position = Vector2(284, 80)
	exile_label.text = "🚫 Exile: 0"
	energy_area.add_child(exile_label)
	
	# Hand container (simple for now)
	hand_container = HBoxContainer.new()
	hand_container.position = Vector2(16, 120)
	hand_container.size = Vector2(358, 150)
	energy_area.add_child(hand_container)

func _initialize_combat():
	# Get monsters from InRun or use default test monsters
	var monsters = _get_test_monsters()
	
	# Store monster UI nodes (before combat starts)
	monster_nodes = [monster1, monster2]
	
	# Initialize CombatManager (this will initialize deck and draw cards)
	CombatManager.start_combat(monsters)
	
	# Initial UI update
	_update_hero_ui()
	_update_monsters_ui()
	_update_deck_ui()
	
	# Store monster UI nodes
	monster_nodes = [monster1, monster2]
	
	# Initial UI update
	_update_hero_ui()
	_update_monsters_ui()
	_update_deck_status()

func _get_test_monsters() -> Array:
	# TODO: Get from GameManager or InRun
	return [
		{
			"name": "Slime",
			"hp": 20,
			"max_hp": 20,
			"atk": 3,
			"def": 1,
			"spd": 8,
			"eva": 5
		},
		{
			"name": "Goblin",
			"hp": 15,
			"max_hp": 15,
			"atk": 5,
			"def": 0,
			"spd": 12,
			"eva": 10
		}
	]

func _process(delta):
	# Update ATB bars every frame
	_update_atb_bars()

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
			node.visible = true
			
			var hp_bar = node.get_node("HPBar")
			var hp_label = node.get_node("HPLabel")
			
			hp_bar.max_value = monster.max_hp
			hp_bar.value = monster.hp
			hp_label.text = "%d/%d" % [monster.hp, monster.max_hp]
		else:
			node.visible = false

func _update_atb_bars():
	# Hero ATB
	hero_atb_bar.value = CombatManager.hero.atb
	
	# Monsters ATB
	var monsters = CombatManager.monsters
	for i in range(monster_nodes.size()):
		if i < monsters.size():
			var node = monster_nodes[i]
			var atb_bar = node.get_node("ATBBar")
			atb_bar.value = monsters[i].atb

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
		# Return to InRun
		get_tree().change_scene_to_file("res://ui/screens/InRun.tscn")
	else:
		add_combat_log("=== DEFEAT ===")
		await get_tree().create_timer(2.0).timeout
		# Return to MainLobby (run failed)
		get_tree().change_scene_to_file("res://ui/screens/MainLobby.tscn")

func add_combat_log(message: String):
	CombatManager.add_log(message)

func _on_end_turn_pressed():
	# Pass - do nothing, just wait
	add_combat_log("Player passed.")

func _on_auto_pressed():
	# TODO: Toggle auto-battle
	add_combat_log("Auto-battle not implemented yet.")

func _on_menu_pressed():
	# TODO: Open pause menu
	add_combat_log("Menu not implemented yet.")

func _on_energy_changed(current: int, max: int):
	hero_energy_label.text = "⚡ %d" % current

func _on_energy_timer_updated(progress: float):
	if energy_timer_bar:
		energy_timer_bar.value = progress * 100

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
	if energy_label:
		var current = CombatManager.get_current_energy()
		var maximum = CombatManager.get_max_energy()
		var energy_icons = ""
		for i in range(maximum):
			if i < current:
				energy_icons += "⚡"
			else:
				energy_icons += "⚪"
		energy_label.text = "Energy: %s (%d/%d)" % [energy_icons, current, maximum]

func _update_hand_ui():
	"""Update hand display (simple labels for now)"""
	if not hand_container:
		return
	
	# Clear existing
	for child in hand_container.get_children():
		child.queue_free()
	
	# Add card labels
	var hand = DeckManager.get_hand_cards()
	for i in range(hand.size()):
		var card = hand[i]
		var btn = Button.new()
		btn.text = "%s\n[%d]" % [card.name, card.cost]
		btn.custom_minimum_size = Vector2(70, 100)
		btn.pressed.connect(_on_card_pressed.bind(i))
		hand_container.add_child(btn)

func _on_card_pressed(card_index: int):
	"""Handle card click"""
	CombatManager.play_card(card_index)
	_update_deck_ui()

# Cheat codes for testing
func _input(event):
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
