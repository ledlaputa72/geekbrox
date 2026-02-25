extends Control

@onready var title_label = $VBox/TitleLabel
@onready var message_label = $VBox/StatsPanel/StatsVBox/MessageLabel
@onready var turns_label = $VBox/StatsPanel/StatsVBox/TurnsLabel
@onready var damage_label = $VBox/StatsPanel/StatsVBox/DamageLabel
@onready var time_label = $VBox/StatsPanel/StatsVBox/TimeLabel
@onready var node_label = $VBox/StatsPanel/StatsVBox/NodeLabel
@onready var reveries_label = $VBox/StatsPanel/StatsVBox/ReveriesLabel
@onready var retry_button = $VBox/RetryButton

# Combat stats
var turns: int = 0
var total_damage: int = 0
var combat_time: float = 0.0
var nodes_completed: int = 0
var total_nodes: int = 10
var reveries_collected: int = 0

func _ready():
	_apply_theme_styles()
	_setup_buttons()
	_load_combat_stats()
	_update_display()

func _apply_theme_styles():
	# Title
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))  # Red
	
	# Message
	message_label.add_theme_font_size_override("font_size", 16)
	
	# Retry button
	UITheme.apply_button_style(retry_button, "primary")

func _setup_buttons():
	retry_button.pressed.connect(_on_retry_pressed)

func _load_combat_stats():
	# TODO: Get from CombatManager or passed data
	turns = 8
	total_damage = 75
	combat_time = 83.0  # seconds
	
	# Get run progress from GameManager
	nodes_completed = 3  # TODO: Get actual progress
	reveries_collected = GameManager.get("reveries", 0)

func _update_display():
	turns_label.text = "Turns Survived: %d" % turns
	damage_label.text = "Total Damage: %d" % total_damage
	
	# Format time
	var minutes = int(combat_time) / 60
	var seconds = int(combat_time) % 60
	time_label.text = "Time: %d:%02d" % [minutes, seconds]
	
	node_label.text = "Reached Node: %d/%d" % [nodes_completed, total_nodes]
	reveries_label.text = "💎 Reveries Collected: %d" % reveries_collected

func _on_retry_pressed():
	# Return to main lobby (run failed)
	get_tree().change_scene_to_file("res://ui/screens/MainLobby.tscn")

# Cheat code for testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				_on_retry_pressed()
