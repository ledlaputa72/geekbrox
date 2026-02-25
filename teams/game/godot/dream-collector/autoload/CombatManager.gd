extends Node

# Signals
signal combat_log_updated(message: String)
signal entity_updated(entity_type: String, index: int)
signal combat_ended(victory: bool)

# Combat State
var in_combat: bool = false
var hero: Dictionary = {}
var monsters: Array = []
var combat_log: Array = []

# ATB Settings
const ATB_MAX: float = 100.0
const ATB_CHARGE_RATE: float = 1.0  # Multiplier for delta time

func _ready():
	pass

func _process(delta):
	if not in_combat:
		return
	
	# Update ATB for all entities
	_update_atb(delta)
	
	# Check for turns
	_check_atb_turns()

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
	
	add_log("Combat started!")
	add_log("Hero vs %d monsters" % monsters.size())

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

# Card Play (for Phase 2+)
func play_card(card_id: String, target_index: int = -1):
	# TODO: Implement in Phase 2
	add_log("Card play not implemented yet.")

# Energy System (for Phase 2+)
func add_energy(amount: int):
	# TODO: Implement in Phase 2
	pass
