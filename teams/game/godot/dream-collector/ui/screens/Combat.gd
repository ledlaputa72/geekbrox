extends Control

# ============================================
# Combat System (ATB + Card Deck Hybrid)
# Phase 1: ATB Basic Combat Implementation
# ============================================

# ─── Node References ──────────────────────
@onready var turn_label: Label = $TopBar/HBox/TurnLabel
@onready var auto_toggle: Button = $TopBar/HBox/AutoToggle
@onready var end_turn_button: Button = $TopBar/HBox/EndTurnButton

# Hero
@onready var hero_sprite: Label = $BattleArea/HeroArea/HeroSprite
@onready var hero_name: Label = $BattleArea/HeroArea/HeroName
@onready var hero_hp_label: Label = $BattleArea/HeroArea/HeroHP/HPLabel
@onready var hero_hp_bar: ProgressBar = $BattleArea/HeroArea/HeroHP/HPBar
@onready var hero_energy: Label = $BattleArea/HeroArea/HeroStats/Energy
@onready var hero_block: Label = $BattleArea/HeroArea/HeroStats/Block
@onready var hero_atb_bar: ProgressBar = $BattleArea/HeroArea/HeroATB/ATBBar

# Enemies
@onready var enemy_nodes: Array = [
	$BattleArea/EnemyArea/Enemy1,
	$BattleArea/EnemyArea/Enemy2,
	$BattleArea/EnemyArea/Enemy3
]

# Combat Log
@onready var log_container: VBoxContainer = $CombatLog/ScrollContainer/LogContainer

# Card Area (Phase 2)
@onready var hand_container: HBoxContainer = $CardHandArea/VBox/HandScroll/HandContainer
@onready var energy_label: Label = $CardHandArea/VBox/EnergyLabel

# ─── Combat State ─────────────────────────
var turn_count: int = 1
var combat_ended: bool = false
var auto_mode: bool = false
var atb_speed_multiplier: float = 1.0

# Hero Stats
var hero: Dictionary = {
	"name": "Hero",
	"hp": 60,
	"max_hp": 60,
	"atk": 10,
	"def": 5,
	"spd": 10,
	"eva": 5,  # %
	"block": 0,
	"atb": 0.0,
	"energy": 3,
	"max_energy": 3
}

# Enemy Stats (3 enemies)
var enemies: Array = []

# Enemy Templates
const ENEMY_TEMPLATES = {
	"Slime": {
		"name": "Slime",
		"hp": 20,
		"max_hp": 20,
		"atk": 8,
		"def": 2,
		"spd": 5,
		"eva": 0,
		"sprite": "👾"
	},
	"Goblin": {
		"name": "Goblin",
		"hp": 12,
		"max_hp": 12,
		"atk": 12,
		"def": 1,
		"spd": 8,
		"eva": 10,
		"sprite": "👾"
	},
	"Bat": {
		"name": "Bat",
		"hp": 8,
		"max_hp": 8,
		"atk": 5,
		"def": 0,
		"spd": 15,
		"eva": 20,
		"sprite": "👾"
	}
}

# ─── Initialization ────────────────────────
func _ready():
	_apply_theme_styles()
	_initialize_combat()
	_update_all_ui()
	add_combat_log("⚔️ Combat Start!")

func _apply_theme_styles():
	# TopBar
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = UITheme.COLORS.panel
	$TopBar.add_theme_stylebox_override("panel", top_style)
	
	# Combat Log
	var log_style = StyleBoxFlat.new()
	log_style.bg_color = UITheme.COLORS.bg_light
	$CombatLog.add_theme_stylebox_override("panel", log_style)
	
	# Card Area
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = UITheme.COLORS.panel
	$CardHandArea.add_theme_stylebox_override("panel", card_style)
	
	# Deck Area
	var deck_style = StyleBoxFlat.new()
	deck_style.bg_color = UITheme.COLORS.panel
	$DeckArea.add_theme_stylebox_override("panel", deck_style)
	
	# Buttons
	UITheme.apply_button_style(auto_toggle, "primary")
	UITheme.apply_button_style(end_turn_button, "primary")

func _initialize_combat():
	# Load enemies (3 random enemies for testing)
	var enemy_types = ["Slime", "Goblin", "Bat"]
	for i in range(3):
		var template = ENEMY_TEMPLATES[enemy_types[i]]
		var enemy = template.duplicate(true)
		enemy["atb"] = 0.0
		enemy["block"] = 0
		enemy["alive"] = true
		enemy["index"] = i
		enemies.append(enemy)
	
	print("[Combat] Initialized: Hero vs %d enemies" % enemies.size())

# ─── ATB System (Phase 1) ──────────────────
func _process(delta):
	if combat_ended:
		return
	
	# Update ATB gauges
	_update_atb_gauges(delta)
	
	# Check for turns
	_check_atb_turns()
	
	# Check win/loss
	_check_win_loss()

func _update_atb_gauges(delta):
	# Hero ATB
	hero.atb += hero.spd * delta * atb_speed_multiplier * 10  # ×10 for 100% scale
	hero.atb = min(100.0, hero.atb)
	hero_atb_bar.value = hero.atb
	
	# Enemy ATB
	for enemy in enemies:
		if enemy.alive:
			enemy.atb += enemy.spd * delta * atb_speed_multiplier * 10
			enemy.atb = min(100.0, enemy.atb)
			
			# Update UI
			var enemy_node = enemy_nodes[enemy.index]
			var atb_bar = enemy_node.get_node("ATBBar")
			atb_bar.value = enemy.atb

func _check_atb_turns():
	# Hero turn
	if hero.atb >= 100.0:
		_execute_hero_turn()
	
	# Enemy turns
	for enemy in enemies:
		if enemy.alive and enemy.atb >= 100.0:
			_execute_enemy_turn(enemy)

# ─── Hero Turn ─────────────────────────────
func _execute_hero_turn():
	print("[Combat] Hero Turn!")
	
	# 1. Auto-attack
	var target = _select_target_auto()
	if target:
		var damage = _calculate_basic_damage(hero, target)
		_deal_damage(target, damage, "Hero")
	
	# 2. Reset ATB
	hero.atb = 0.0
	
	# 3. [Card Time!] (Phase 2)
	# TODO: Start card phase
	# For now: just continue ATB
	
	# Update UI
	_update_hero_ui()

# ─── Enemy Turn ────────────────────────────
func _execute_enemy_turn(enemy: Dictionary):
	print("[Combat] %s Turn!" % enemy.name)
	
	# Attack Hero
	var damage = _calculate_basic_damage(enemy, hero)
	_deal_damage(hero, damage, enemy.name)
	
	# Reset ATB
	enemy.atb = 0.0
	
	# Update UI
	_update_enemy_ui(enemy)
	_update_hero_ui()

# ─── Damage System ─────────────────────────
func _calculate_basic_damage(attacker: Dictionary, defender: Dictionary) -> int:
	# Base damage
	var base_damage = attacker.atk - defender.def
	base_damage = max(1, base_damage)
	
	# Evasion check
	var hit_chance = 1.0 - (defender.eva / 100.0)
	if randf() > hit_chance:
		return 0  # Miss!
	
	# Variance (±10%)
	var variance = randf_range(0.9, 1.1)
	var final_damage = int(base_damage * variance)
	
	return final_damage

func _deal_damage(target: Dictionary, amount: int, attacker_name: String):
	if amount == 0:
		# Miss
		if target == hero:
			add_combat_log("• %s attacks Hero but MISSED!" % attacker_name, Color.GRAY)
		else:
			add_combat_log("• %s attacks %s but MISSED!" % [attacker_name, target.name], Color.GRAY)
		return
	
	# Apply block first
	var blocked = min(target.block, amount)
	amount -= blocked
	target.block -= blocked
	
	# Apply damage to HP
	target.hp -= amount
	target.hp = max(0, target.hp)
	
	# Log
	if target == hero:
		add_combat_log("• %s attacks Hero for %d damage" % [attacker_name, amount], Color.RED)
	else:
		add_combat_log("• %s attacks %s for %d damage" % [attacker_name, target.name, amount], Color.GREEN)
	
	# Check death
	if target.hp <= 0:
		if target != hero:
			target.alive = false
			add_combat_log("• %s defeated!" % target.name, Color.YELLOW)

func _select_target_auto() -> Dictionary:
	"""
	Auto-target: First alive enemy
	"""
	for enemy in enemies:
		if enemy.alive:
			return enemy
	return {}

# ─── Win/Loss ──────────────────────────────
func _check_win_loss():
	# Victory: All enemies dead
	var all_dead = true
	for enemy in enemies:
		if enemy.alive:
			all_dead = false
			break
	
	if all_dead:
		_win_combat()
		return
	
	# Defeat: Hero HP ≤ 0
	if hero.hp <= 0:
		_lose_combat()
		return

func _win_combat():
	combat_ended = true
	add_combat_log("🎉 VICTORY!", Color.GOLD)
	print("[Combat] Victory!")
	
	# TODO: Transition to Victory Screen
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://ui/screens/InRun.tscn")

func _lose_combat():
	combat_ended = true
	add_combat_log("💀 DEFEAT!", Color.RED)
	print("[Combat] Defeat!")
	
	# TODO: Transition to Defeat Screen
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://ui/screens/MainLobby.tscn")

# ─── UI Updates ────────────────────────────
func _update_all_ui():
	_update_hero_ui()
	for enemy in enemies:
		_update_enemy_ui(enemy)

func _update_hero_ui():
	hero_hp_label.text = "HP: %d/%d" % [hero.hp, hero.max_hp]
	hero_hp_bar.value = hero.hp
	hero_hp_bar.max_value = hero.max_hp
	
	# HP bar color
	var hp_percent = float(hero.hp) / hero.max_hp
	if hp_percent > 0.6:
		hero_hp_bar.modulate = Color(0.298, 0.686, 0.314)  # Green
	elif hp_percent > 0.3:
		hero_hp_bar.modulate = Color(1.0, 0.757, 0.027)  # Yellow
	else:
		hero_hp_bar.modulate = Color(0.957, 0.263, 0.212)  # Red
	
	hero_energy.text = "⚡%d" % hero.energy
	hero_block.text = "🛡%d" % hero.block

func _update_enemy_ui(enemy: Dictionary):
	var enemy_node = enemy_nodes[enemy.index]
	
	# Visibility
	if not enemy.alive:
		enemy_node.modulate.a = 0.3  # Fade out
	else:
		enemy_node.modulate.a = 1.0
	
	# HP
	var hp_label = enemy_node.get_node("HBox/Info/HP")
	hp_label.text = "HP: %d/%d" % [enemy.hp, enemy.max_hp]

# ─── Combat Log ────────────────────────────
func add_combat_log(text: String, color: Color = Color.WHITE):
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	log_container.add_child(label)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll = $CombatLog/ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	
	# Limit log entries (keep last 20)
	if log_container.get_child_count() > 20:
		log_container.get_child(0).queue_free()

# ─── Signal Handlers ───────────────────────
func _on_menu_pressed():
	print("[Combat] Menu pressed")
	# TODO: Show pause menu

func _on_auto_toggle_pressed():
	auto_mode = not auto_mode
	
	if auto_mode:
		auto_toggle.text = "🤖 Auto ×1"
		add_combat_log("• Auto mode ON", Color.CYAN)
	else:
		auto_toggle.text = "🤖 Auto"
		add_combat_log("• Auto mode OFF", Color.CYAN)
	
	print("[Combat] Auto mode: %s" % auto_mode)

func _on_end_turn_pressed():
	print("[Combat] End Turn pressed")
	add_combat_log("• Turn %d ended" % turn_count, Color.GRAY)
	turn_count += 1
	turn_label.text = "Turn: %d" % turn_count

func _on_enemy_clicked(index: int):
	if combat_ended:
		return
	
	var enemy = enemies[index]
	if enemy.alive:
		print("[Combat] Enemy clicked: %s" % enemy.name)
		add_combat_log("• Targeted: %s" % enemy.name, Color.YELLOW)

# ─── Cheat Codes (Testing) ─────────────────
func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
	
	match event.keycode:
		KEY_H:  # Heal Hero
			hero.hp = mini(hero.hp + 10, hero.max_hp)
			_update_hero_ui()
			add_combat_log("• Cheat: Hero +10 HP", Color.CYAN)
		
		KEY_J:  # Damage Hero
			hero.hp = maxi(hero.hp - 10, 0)
			_update_hero_ui()
			add_combat_log("• Cheat: Hero -10 HP", Color.CYAN)
		
		KEY_K:  # Kill first enemy
			for enemy in enemies:
				if enemy.alive:
					enemy.hp = 0
					enemy.alive = false
					_update_enemy_ui(enemy)
					add_combat_log("• Cheat: %s defeated!" % enemy.name, Color.CYAN)
					break
		
		KEY_SPACE:  # Speed up ATB
			atb_speed_multiplier = 5.0 if atb_speed_multiplier == 1.0 else 1.0
			add_combat_log("• ATB Speed: ×%.1f" % atb_speed_multiplier, Color.CYAN)
