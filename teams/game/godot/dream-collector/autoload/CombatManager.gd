extends Node

# Signals
signal combat_log_updated(message: String)
signal entity_updated(entity_type: String, index: int)
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal combat_ended(victory: bool)
signal energy_changed(current: int, max: int)
signal energy_timer_updated(progress: float)

# Combat State
var in_combat: bool = false
var hero: Dictionary = {}
var monsters: Array = []
var combat_log: Array = []

# ATB Settings
const ATB_MAX: float = 100.0
const ATB_CHARGE_RATE: float = 1.0  # Multiplier for delta time

# Energy System Settings
const ENERGY_MAX: int = 3
const ENERGY_TIMER_DURATION: float = 5.0  # Seconds per energy charge
var energy_timer: float = 0.0  # Current timer progress

# Auto-Battle Settings
var auto_battle_enabled: bool = false
var auto_battle_delay: float = 0.5  # Delay between auto plays (seconds)
var auto_battle_timer: float = 0.0

# Speed Settings
var speed_multiplier: float = 1.0  # 1×, 2×, 3×

func _ready():
	pass

func _process(delta):
	if not in_combat:
		return
	
	# Apply speed multiplier
	var scaled_delta = delta * speed_multiplier
	
	# Update ATB for all entities
	_update_atb(scaled_delta)
	
	# Check for turns
	_check_atb_turns()
	
	# Update Energy Timer
	_update_energy_timer(scaled_delta)
	
	# Update Auto-Battle
	if auto_battle_enabled:
		_update_auto_battle(scaled_delta)

func start_combat(monster_data: Array):
	in_combat = true
	combat_log.clear()
	
	# Initialize Hero
	hero = {
		"name": "Hero",
		"hp": 80,
		"max_hp": 80,
		"atk": 10,
		"def": 2,
		"spd": 10,
		"eva": 5,
		"atb": 0.0,
		"energy": 3,
		"block": 0
	}
	
	# Initialize Monsters
	monsters.clear()
	for m_data in monster_data:
		var monster = m_data.duplicate()
		monster["atb"] = randf_range(0, 50)  # Random start for variety
		monster["block"] = 0
		monsters.append(monster)
	
	# Initialize Deck
	var starting_deck = _get_starting_deck()
	DeckManager.initialize_combat_deck(starting_deck)
	
	# Draw starting hand (5 cards)
	DeckManager.draw_cards(5)
	
	# Initialize Energy Timer
	energy_timer = 0.0
	
	add_log("Combat started!")
	add_log("Hero vs %d monsters" % monsters.size())
	add_log("Drew 5 starting cards")
	
	# Emit initial energy state
	energy_changed.emit(hero.energy, ENERGY_MAX)
	energy_timer_updated.emit(0.0)

func end_combat():
	in_combat = false
	hero.clear()
	monsters.clear()
	combat_log.clear()

func _update_atb(delta: float):
	# Hero ATB
	if hero.hp > 0:
		hero.atb += (ATB_MAX / hero.spd) * delta * ATB_CHARGE_RATE
		if hero.atb >= ATB_MAX:
			hero.atb = ATB_MAX  # Cap at max
	
	# Monsters ATB
	for monster in monsters:
		if monster.hp > 0:
			monster.atb += (ATB_MAX / monster.spd) * delta * ATB_CHARGE_RATE
			if monster.atb >= ATB_MAX:
				monster.atb = ATB_MAX  # Cap at max

func _check_atb_turns():
	# Check Hero turn
	if hero.atb >= ATB_MAX and hero.hp > 0:
		_execute_hero_turn()
	
	# Check Monster turns
	for i in range(monsters.size()):
		var monster = monsters[i]
		if monster.atb >= ATB_MAX and monster.hp > 0:
			_execute_monster_turn(i)

func _execute_hero_turn():
	# Hero auto-attack (basic attack)
	var target_index = _get_first_alive_monster()
	
	if target_index == -1:
		# No monsters left - victory
		return
	
	var target = monsters[target_index]
	var damage = _calculate_damage(hero.atk, target.def, target.eva)
	
	if damage > 0:
		_apply_damage(target, damage)
		add_log("%s attacked %s for %d damage" % [hero.name, target.name, damage])
		# Emit damage signal for visual feedback
		damage_dealt.emit("monster", target_index, damage, false)
	else:
		add_log("%s attacked %s but missed!" % [hero.name, target.name])
	
	# Reset ATB
	hero.atb = 0.0
	entity_updated.emit("hero", 0)
	entity_updated.emit("monster", target_index)
	
	# Check victory
	_check_combat_end()

func _execute_monster_turn(monster_index: int):
	var monster = monsters[monster_index]
	
	# Monster attacks hero
	var damage = _calculate_damage(monster.atk, hero.def, hero.eva)
	
	if damage > 0:
		_apply_damage(hero, damage)
		add_log("%s attacked %s for %d damage" % [monster.name, hero.name, damage])
		# Emit damage signal for visual feedback
		damage_dealt.emit("hero", 0, damage, false)
	else:
		add_log("%s attacked %s but missed!" % [monster.name, hero.name])
	
	# Reset ATB
	monster.atb = 0.0
	entity_updated.emit("monster", monster_index)
	entity_updated.emit("hero", 0)
	
	# Check defeat
	_check_combat_end()

func _calculate_damage(atk: int, def: int, eva: int) -> int:
	# Evasion check
	if randf() * 100 < eva:
		return 0  # Evaded
	
	# Damage calculation
	var base_damage = atk - def
	base_damage = max(1, base_damage)  # Minimum 1 damage
	
	# Random variance (90% - 110%)
	var variance = randf_range(0.9, 1.1)
	var final_damage = int(base_damage * variance)
	
	return max(1, final_damage)

func _apply_damage(entity: Dictionary, damage: int):
	# Apply to block first
	if entity.block > 0:
		var blocked = min(entity.block, damage)
		entity.block -= blocked
		damage -= blocked
		
		if damage <= 0:
			return  # All blocked
	
	# Apply remaining damage to HP
	entity.hp -= damage
	entity.hp = max(0, entity.hp)

func _get_first_alive_monster() -> int:
	for i in range(monsters.size()):
		if monsters[i].hp > 0:
			return i
	return -1

func _check_combat_end():
	# Check defeat (hero dead)
	if hero.hp <= 0:
		add_log("Hero has been defeated!")
		in_combat = false
		combat_ended.emit(false)
		return
	
	# Check victory (all monsters dead)
	var all_dead = true
	for monster in monsters:
		if monster.hp > 0:
			all_dead = false
			break
	
	if all_dead:
		add_log("All monsters defeated!")
		in_combat = false
		combat_ended.emit(true)
		return

func add_log(message: String):
	combat_log.append(message)
	combat_log_updated.emit(message)
	print("[Combat] " + message)

func _update_energy_timer(delta: float):
	"""Update energy timer and charge energy when full"""
	# DYNAMIC DURATION: Based on hand size (5 cards = 5 seconds)
	var hand_size = DeckManager.get_hand_size()
	var dynamic_duration = max(1.0, float(hand_size))  # Minimum 1 second
	
	# Increment timer
	energy_timer += delta
	
	# Emit progress signal (based on dynamic duration)
	var progress = energy_timer / dynamic_duration
	energy_timer_updated.emit(progress)
	
	# Check if timer is full (based on dynamic duration)
	if energy_timer >= dynamic_duration:
		energy_timer = 0.0  # Reset timer
		
		# NEW LOGIC: If energy is at max (3), only draw card. Otherwise, charge energy + draw card.
		if hero.energy >= ENERGY_MAX:
			# Energy at max: only draw card
			var drawn_card = DeckManager.draw_card()
			if not drawn_card.is_empty():
				add_log("Drew 1 card: %s" % drawn_card.name)
		else:
			# Energy below max: charge energy AND draw card
			hero.energy += 1
			add_log("+1 Energy ⚡")
			energy_changed.emit(hero.energy, ENERGY_MAX)
			entity_updated.emit("hero", 0)
			
			var drawn_card = DeckManager.draw_card()
			if not drawn_card.is_empty():
				add_log("Drew 1 card: %s" % drawn_card.name)

func _initialize_starting_deck():
	"""Initialize deck for combat"""
	var deck_ids = _get_starting_deck()
	DeckManager.initialize_combat_deck(deck_ids)

func _get_starting_deck() -> Array:
	"""Get starting deck card IDs"""
	# TODO: Get from GameManager or use default
	return [
		"attack_01", "attack_01", "attack_01", "attack_01",  # 4x Strike
		"attack_03", "attack_03", "attack_03",  # 3x Slash
		"defense_01", "defense_01", "defense_01", "defense_01",  # 4x Defend
		"skill_02"  # 1x Focus
	]

# Card Play
func play_card(card_index: int, target_index: int = -1) -> bool:
	"""
	Play a card from hand
	Returns true if successful
	"""
	if card_index < 0 or card_index >= DeckManager.get_hand_size():
		add_log("Invalid card selection")
		return false
	
	var cards = DeckManager.get_hand_cards()
	var card = cards[card_index]
	
	# Check energy cost
	if hero.energy < card.cost:
		add_log("Not enough energy! (Need %d, have %d)" % [card.cost, hero.energy])
		return false
	
	# Check target (safe access with .get())
	var card_target = card.get("target", "none")
	if card_target == "single" and target_index == -1:
		target_index = _get_first_alive_monster()
		if target_index == -1:
			add_log("No valid target!")
			return false
	
	# Spend energy
	hero.energy -= card.cost
	energy_changed.emit(hero.energy, ENERGY_MAX)
	entity_updated.emit("hero", 0)
	
	# Play card from DeckManager (moves to discard)
	DeckManager.play_card(card_index)
	
	# Apply card effects
	_apply_card_effects(card, target_index)
	
	add_log("Played %s (Cost: %d)" % [card.name, card.cost])
	
	return true

func _apply_card_effects(card: Dictionary, target_index: int):
	"""Apply card effects"""
	# Damage
	if card.has("damage"):
		if target_index >= 0 and target_index < monsters.size():
			var target = monsters[target_index]
			var damage = card.damage
			_apply_damage(target, damage)
			add_log("→ %s dealt %d damage to %s" % [card.name, damage, target.name])
			# Emit damage signal for visual feedback
			damage_dealt.emit("monster", target_index, damage, false)
			entity_updated.emit("monster", target_index)
			_check_combat_end()
	
	# Block
	if card.has("block"):
		hero.block += card.block
		add_log("→ Gained %d Block 🛡" % card.block)
		entity_updated.emit("hero", 0)
	
	# Buff
	if card.has("buff"):
		var buff = card.buff
		if buff.stat == "atk":
			hero.atk += buff.value
			add_log("→ ATK +%d (now %d)" % [buff.value, hero.atk])
			entity_updated.emit("hero", 0)
	
	# Draw
	if card.has("draw"):
		DeckManager.draw_cards(card.draw)
		add_log("→ Drew %d cards" % card.draw)

# Energy Management
func can_afford_card(card_cost: int) -> bool:
	return hero.energy >= card_cost

func get_current_energy() -> int:
	return hero.get("energy", 0)

func get_max_energy() -> int:
	return ENERGY_MAX

# Auto-Battle System
func toggle_auto_battle():
	"""Toggle auto-battle on/off"""
	auto_battle_enabled = not auto_battle_enabled
	auto_battle_timer = 0.0
	
	if auto_battle_enabled:
		add_log("🤖 Auto-battle enabled")
	else:
		add_log("🤖 Auto-battle disabled")

func set_speed_multiplier(multiplier: float):
	"""Set combat speed multiplier (1×, 2×, 3×)"""
	speed_multiplier = clamp(multiplier, 0.5, 3.0)
	add_log("⚡ Speed: %.1f×" % speed_multiplier)

func _update_auto_battle(delta: float):
	"""Update auto-battle AI"""
	if not auto_battle_enabled:
		return
	
	# Wait for delay
	auto_battle_timer += delta
	if auto_battle_timer < auto_battle_delay:
		return
	
	# Try to play a card
	var hand = DeckManager.get_hand_cards()
	if hand.is_empty() or hero.energy <= 0:
		return
	
	# Use AI to choose card
	var choice = AutoBattleAI.choose_card_to_play(hand, hero, monsters, hero.energy)
	
	if choice.is_empty():
		# No valid card to play
		return
	
	# Play the chosen card
	var success = play_card(choice.card_index, choice.get("target_index", -1))
	
	if success:
		auto_battle_timer = 0.0  # Reset timer for next play

