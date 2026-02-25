extends Control

# Node references
@onready var status_bar: Panel = $StatusBar
@onready var hp_label: Label = $StatusBar/HBox/HPContainer/HPLabel
@onready var hp_bar: ProgressBar = $StatusBar/HBox/HPContainer/HPBar
@onready var energy_label: Label = $StatusBar/HBox/EnergyContainer/EnergyLabel
@onready var energy_bar: ProgressBar = $StatusBar/HBox/EnergyContainer/EnergyBar
@onready var reveries_label: Label = $StatusBar/HBox/ReveriesLabel

@onready var node_map_visual: Control = $NodeMapVisual
@onready var current_node_icon: Label = $MainView/CurrentNodeIcon

@onready var action_bar: Panel = $ActionBar
@onready var skip_button: Button = $ActionBar/HBox/SkipButton
@onready var auto_button: Button = $ActionBar/HBox/AutoButton
@onready var menu_button: Button = $ActionBar/HBox/MenuButton

@onready var node_panel: Panel = $NodePanel
@onready var title_label: Label = $NodePanel/VBox/TitleLabel
@onready var desc_label: Label = $NodePanel/VBox/DescLabel
@onready var choices_container: VBoxContainer = $NodePanel/VBox/ChoicesContainer
@onready var choice1: Button = $NodePanel/VBox/ChoicesContainer/Choice1
@onready var choice2: Button = $NodePanel/VBox/ChoicesContainer/Choice2

# Run state
var current_hp: int = 6
var max_hp: int = 10
var current_energy: int = 2
var max_energy: int = 3
var reveries: int = 125

# Node data structure
var nodes: Array = [
	{"id": 1, "type": "Memory", "icon": "💎", "completed": true, "current": false},
	{"id": 2, "type": "Combat", "icon": "⚔️", "completed": true, "current": false},
	{"id": 3, "type": "Event", "icon": "❓", "completed": false, "current": true},
	{"id": 4, "type": "Shop", "icon": "🛒", "completed": false, "current": false},
	{"id": 5, "type": "Combat", "icon": "⚔️", "completed": false, "current": false},
	{"id": 6, "type": "Upgrade", "icon": "⬆️", "completed": false, "current": false},
	{"id": 7, "type": "Memory", "icon": "💎", "completed": false, "current": false},
	{"id": 8, "type": "Combat", "icon": "⚔️", "completed": false, "current": false},
	{"id": 9, "type": "Event", "icon": "❓", "completed": false, "current": false},
	{"id": 10, "type": "Boss", "icon": "👹", "completed": false, "current": false}
]

var current_node_index: int = 2  # 0-based (node 3)

func _ready():
	_apply_theme_styles()
	_update_status_bar()
	_generate_node_map()
	_update_current_node()

func _apply_theme_styles():
	# Status bar
	var status_style = StyleBoxFlat.new()
	status_style.bg_color = UITheme.COLORS.panel
	status_bar.add_theme_stylebox_override("panel", status_style)
	
	# HP bar
	hp_bar.modulate = Color(0.298, 0.686, 0.314)  # Green
	
	# Energy bar
	energy_bar.modulate = Color(0.129, 0.588, 0.953)  # Blue
	
	# Reveries label
	reveries_label.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))  # Gold
	
	# Action bar
	var action_style = StyleBoxFlat.new()
	action_style.bg_color = UITheme.COLORS.panel
	action_bar.add_theme_stylebox_override("panel", action_style)
	
	# Node panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.corner_radius_top_left = UITheme.RADIUS.large
	panel_style.corner_radius_top_right = UITheme.RADIUS.large
	node_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Action bar buttons
	UITheme.apply_button_style(skip_button, "primary")
	UITheme.apply_button_style(auto_button, "primary")
	UITheme.apply_button_style(menu_button, "primary")
	
	# Node panel buttons
	UITheme.apply_button_style(choice1, "primary")
	UITheme.apply_button_style(choice2, "skill")

func _update_status_bar():
	# HP
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
	hp_bar.value = (float(current_hp) / max_hp) * 100
	
	# Update HP bar color based on percentage
	var hp_percent = float(current_hp) / max_hp
	if hp_percent > 0.6:
		hp_bar.modulate = Color(0.298, 0.686, 0.314)  # Green
	elif hp_percent > 0.3:
		hp_bar.modulate = Color(1.0, 0.757, 0.027)  # Yellow
	else:
		hp_bar.modulate = Color(0.957, 0.263, 0.212)  # Red
	
	# Energy
	energy_label.text = "EN: %d/%d" % [current_energy, max_energy]
	energy_bar.value = (float(current_energy) / max_energy) * 100
	
	# Reveries
	reveries_label.text = "R: %d" % reveries

func _generate_node_map():
	# Update visual node map
	if node_map_visual:
		node_map_visual.set_nodes(nodes, current_node_index)

func _update_current_node():
	if current_node_index < 0 or current_node_index >= nodes.size():
		return
	
	var node = nodes[current_node_index]
	
	# Update main icon
	current_node_icon.text = node.icon
	
	# Update panel
	title_label.text = "Current Node: %s %s" % [node.type, node.icon]
	
	# Update based on node type
	match node.type:
		"Event":
			desc_label.text = "\"Two paths diverge...\""
			choice1.visible = true
			choice2.visible = true
			choice1.text = "[A] Safe path (20 R)"
			choice2.text = "[B] Risky path (50% chance 50R)"
		
		"Memory":
			desc_label.text = "10 Reveries collected"
			choice1.visible = true
			choice2.visible = false
			choice1.text = "Collect"
		
		"Combat":
			desc_label.text = "Enemy ahead!"
			choice1.visible = true
			choice2.visible = false
			choice1.text = "Fight"
		
		"Shop":
			desc_label.text = "A mysterious merchant appears..."
			choice1.visible = true
			choice2.visible = false
			choice1.text = "Enter Shop"
		
		"Upgrade":
			desc_label.text = "Choose an upgrade for your deck"
			choice1.visible = true
			choice2.visible = false
			choice1.text = "View Upgrades"
		
		"Boss":
			desc_label.text = "Final challenge awaits!"
			choice1.visible = true
			choice2.visible = false
			choice1.text = "Face Boss"

func _advance_to_next_node():
	# Mark current as completed
	nodes[current_node_index].current = false
	nodes[current_node_index].completed = true
	
	# Move to next node
	current_node_index += 1
	
	if current_node_index >= nodes.size():
		print("Run completed!")
		# TODO: Show victory screen
		return
	
	# Mark next as current
	nodes[current_node_index].current = true
	
	# Update UI
	_generate_node_map()
	_update_current_node()

# Signal handlers
func _on_choice1_pressed():
	var node = nodes[current_node_index]
	
	match node.type:
		"Event":
			# Safe path
			reveries += 20
			print("Chose safe path, gained 20 reveries")
		
		"Memory":
			# Collect
			reveries += 10
			print("Collected 10 reveries")
		
		"Combat":
			# Start combat
			print("Starting combat...")
			get_tree().change_scene_to_file("res://ui/screens/Combat.tscn")
		
		"Shop":
			# Open shop
			print("Opening shop...")
			# TODO: Load shop overlay
		
		"Upgrade":
			# Show upgrades
			print("Showing upgrades...")
			# TODO: Show upgrade modal
		
		"Boss":
			# Start boss fight
			print("Starting boss fight...")
			# TODO: Load combat scene with boss
	
	_update_status_bar()
	_advance_to_next_node()

func _on_choice2_pressed():
	var node = nodes[current_node_index]
	
	if node.type == "Event":
		# Risky path - 50% chance
		if randf() > 0.5:
			reveries += 50
			print("Risk paid off! Gained 50 reveries")
		else:
			print("Risk failed! No reward")
		
		_update_status_bar()
		_advance_to_next_node()

func _on_skip_button_pressed():
	print("Skip pressed")
	# TODO: Implement skip/fast-forward

func _on_auto_button_pressed():
	print("Auto pressed")
	# TODO: Toggle auto-play mode

func _on_menu_button_pressed():
	print("Menu pressed")
	# TODO: Show pause menu or return to main lobby
	get_tree().change_scene_to_file("res://ui/screens/MainLobby.tscn")

# Cheat codes for testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_H:  # Heal
				current_hp = mini(current_hp + 2, max_hp)
				_update_status_bar()
			KEY_J:  # Damage
				current_hp = maxi(current_hp - 2, 0)
				_update_status_bar()
			KEY_K:  # Energy +
				current_energy = mini(current_energy + 1, max_energy)
				_update_status_bar()
			KEY_L:  # Energy -
				current_energy = maxi(current_energy - 1, 0)
				_update_status_bar()
			KEY_SPACE:  # Advance node
				_on_choice1_pressed()
