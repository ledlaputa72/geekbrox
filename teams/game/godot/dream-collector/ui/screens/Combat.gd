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

func _ready():
	_apply_theme_styles()
	_setup_buttons()
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

func _initialize_combat():
	# Get monsters from InRun or use default test monsters
	var monsters = _get_test_monsters()
	
	# Initialize CombatManager
	CombatManager.start_combat(monsters)
	
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
	# TODO: Update energy timer bar UI
	pass

func _on_hand_changed():
	# TODO: Update hand UI
	_update_deck_status()

func _update_deck_status():
	"""Update deck status in combat log"""
	var deck_size = DeckManager.get_deck_size()
	var hand_size = DeckManager.get_hand_size()
	var discard_size = DeckManager.get_discard_size()
	
	add_combat_log("📚 Deck: %d | ✋ Hand: %d | 🪦 Discard: %d" % [deck_size, hand_size, discard_size])

# Cheat codes for testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_D:  # Draw card
				DeckManager.draw_card()
				_update_deck_status()
			KEY_P:  # Play first card
				if DeckManager.get_hand_size() > 0:
					CombatManager.play_card(0)
					_update_deck_status()
			KEY_S:  # Print deck state
				DeckManager.print_state()
			KEY_1:  # Draw 5 cards
				DeckManager.draw_cards(5)
				_update_deck_status()
