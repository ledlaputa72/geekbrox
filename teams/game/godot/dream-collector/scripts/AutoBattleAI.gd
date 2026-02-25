extends Node
class_name AutoBattleAI

## Auto-Battle AI for combat
## Uses heuristic-based decision making

const HP_THRESHOLD_DEFEND: float = 0.3  # Defend if HP below 30%

static func choose_card_to_play(hand: Array, hero: Dictionary, monsters: Array, current_energy: int) -> Dictionary:
	"""
	Choose best card to play based on heuristics
	Returns: { "card_index": int, "target_index": int } or empty dict
	"""
	if hand.is_empty() or current_energy <= 0:
		return {}
	
	# Calculate hero HP ratio
	var hp_ratio = float(hero.hp) / hero.max_hp
	
	# If low HP, prioritize defense
	if hp_ratio < HP_THRESHOLD_DEFEND:
		var defense_card = _find_best_defense_card(hand, current_energy)
		if not defense_card.is_empty():
			return defense_card
	
	# Otherwise, prioritize damage
	var attack_card = _find_best_attack_card(hand, current_energy, monsters)
	if not attack_card.is_empty():
		return attack_card
	
	# Fall back to any playable card
	var any_card = _find_any_playable_card(hand, current_energy)
	return any_card

static func _find_best_defense_card(hand: Array, current_energy: int) -> Dictionary:
	"""Find defense card with best block/cost ratio"""
	var best_card = {}
	var best_ratio = 0.0
	
	for i in range(hand.size()):
		var card = hand[i]
		if card.type != "Defense" or card.cost > current_energy:
			continue
		
		var block = card.get("block", 0)
		var cost = max(1, card.cost)
		var ratio = float(block) / cost
		
		if ratio > best_ratio:
			best_ratio = ratio
			best_card = {"card_index": i, "target_index": -1}
	
	return best_card

static func _find_best_attack_card(hand: Array, current_energy: int, monsters: Array) -> Dictionary:
	"""Find attack card with best damage/cost ratio"""
	var best_card = {}
	var best_ratio = 0.0
	
	# Find first alive monster
	var target_index = -1
	for i in range(monsters.size()):
		if monsters[i].hp > 0:
			target_index = i
			break
	
	if target_index == -1:
		return {}
	
	for i in range(hand.size()):
		var card = hand[i]
		if card.type != "Attack" or card.cost > current_energy:
			continue
		
		var damage = card.get("damage", 0)
		var cost = max(1, card.cost)
		var ratio = float(damage) / cost
		
		if ratio > best_ratio:
			best_ratio = ratio
			best_card = {"card_index": i, "target_index": target_index}
	
	return best_card

static func _find_any_playable_card(hand: Array, current_energy: int) -> Dictionary:
	"""Find any playable card (skill, etc.)"""
	for i in range(hand.size()):
		var card = hand[i]
		if card.cost <= current_energy:
			# Get target for attack cards
			var target_index = -1
			if card.type == "Attack":
				# Would need monsters array here, skip for now
				continue
			return {"card_index": i, "target_index": target_index}
	
	return {}

static func should_continue_playing(hand: Array, current_energy: int) -> bool:
	"""Check if AI should continue playing cards"""
	# Continue if we have energy and playable cards
	for card in hand:
		if card.cost <= current_energy:
			return true
	return false
