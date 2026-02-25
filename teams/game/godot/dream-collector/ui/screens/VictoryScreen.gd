extends Control

@onready var title_label = $VBox/TitleLabel
@onready var turns_label = $VBox/StatsPanel/StatsVBox/TurnsLabel
@onready var damage_label = $VBox/StatsPanel/StatsVBox/DamageLabel
@onready var time_label = $VBox/StatsPanel/StatsVBox/TimeLabel
@onready var gold_label = $VBox/StatsPanel/StatsVBox/GoldLabel
@onready var reveries_label = $VBox/StatsPanel/StatsVBox/ReveriesLabel
@onready var continue_button = $VBox/ContinueButton

# Combat stats (passed from Combat scene)
var turns: int = 0
var total_damage: int = 0
var combat_time: float = 0.0
var gold_reward: int = 50
var reveries_reward: int = 10

func _ready():
	_apply_theme_styles()
	_setup_buttons()
	_load_combat_stats()
	_update_display()
	
	# Apply rewards to GameManager
	_apply_rewards()

func _apply_theme_styles():
	# Title
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.843, 0.0))  # Gold
	
	# Continue button
	UITheme.apply_button_style(continue_button, "primary")

func _setup_buttons():
	continue_button.pressed.connect(_on_continue_pressed)

func _load_combat_stats():
	# TODO: Get from CombatManager or passed data
	# For now, use dummy data
	turns = 15
	total_damage = 120
	combat_time = 154.5  # seconds
	
	# Calculate rewards based on difficulty
	if GameManager.has("difficulty_data"):
		var difficulty = GameManager.difficulty_data
		var multiplier = difficulty.get("reward_multiplier", 1.0)
		gold_reward = int(50 * multiplier)
		reveries_reward = int(10 * multiplier)

func _update_display():
	turns_label.text = "Turns: %d" % turns
	damage_label.text = "Total Damage: %d" % total_damage
	
	# Format time as MM:SS
	var minutes = int(combat_time) / 60
	var seconds = int(combat_time) % 60
	time_label.text = "Time: %d:%02d" % [minutes, seconds]
	
	gold_label.text = "🪙 Gold: +%d" % gold_reward
	reveries_label.text = "💎 Reveries: +%d" % reveries_reward

func _apply_rewards():
	"""Apply rewards to GameManager"""
	# Add gold (reveries)
	if GameManager.has("reveries"):
		GameManager.reveries += reveries_reward
		print("[Victory] +%d Reveries (Total: %d)" % [reveries_reward, GameManager.reveries])
	
	# TODO: Add other rewards (cards, relics, etc.)
	
	# Save game
	SaveSystem.save_game()

func _on_continue_pressed():
	# Return to InRun to continue the run
	get_tree().change_scene_to_file("res://ui/screens/InRun.tscn")

# Cheat code for testing
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				_on_continue_pressed()
