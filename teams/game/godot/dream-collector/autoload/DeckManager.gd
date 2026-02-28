extends Node

# Signals
signal card_drawn(card: Dictionary)
signal deck_shuffled()
signal hand_changed()

# Card Database
var all_cards: Dictionary = {}

# Deck State
var deck: Array = []  # Cards in draw pile
var hand: Array = []  # Cards in hand
var discard: Array = []  # Cards in discard pile
var exile: Array = []  # Removed cards (not reshuffled)

# Settings
const MAX_HAND_SIZE: int = 10
const STARTING_DECK_SIZE: int = 12

func _ready():
	_load_card_database()

func _load_card_database():
	var file_path = "res://data/cards.json"
	
	if not FileAccess.file_exists(file_path):
		print("[DeckManager] ERROR: cards.json not found!")
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("[DeckManager] ERROR: Failed to open cards.json")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("[DeckManager] ERROR: Failed to parse cards.json: ", json.get_error_message())
		return
	
	var data = json.data
	if data.has("cards"):
		for card_data in data["cards"]:
			all_cards[card_data["id"]] = card_data
		print("[DeckManager] Loaded %d cards" % all_cards.size())
	else:
		print("[DeckManager] ERROR: No 'cards' key in JSON")

func get_card_by_id(card_id: String) -> Dictionary:
	if all_cards.has(card_id):
		return all_cards[card_id].duplicate(true)
	else:
		print("[DeckManager] WARNING: Card '%s' not found" % card_id)
		return {}

func initialize_combat_deck(deck_card_ids: Array):
	"""
	Initialize deck for combat with given card IDs
	deck_card_ids: Array of card id strings (e.g., ["attack_01", "defense_01", ...])
	"""
	deck.clear()
	hand.clear()
	discard.clear()
	exile.clear()
	
	# Add cards to deck
	for card_id in deck_card_ids:
		var card = get_card_by_id(card_id)
		if not card.is_empty():
			deck.append(card)
	
	# Shuffle deck
	shuffle_deck()
	
	print("[DeckManager] Initialized combat deck with %d cards" % deck.size())

func shuffle_deck():
	"""Shuffle the deck"""
	deck.shuffle()
	deck_shuffled.emit()
	print("[DeckManager] Deck shuffled (%d cards)" % deck.size())

func draw_card() -> Dictionary:
	"""
	Draw one card from deck to hand
	Returns the drawn card, or empty dict if failed
	"""
	# Check hand size
	if hand.size() >= MAX_HAND_SIZE:
		print("[DeckManager] Hand is full! Cannot draw.")
		return {}
	
	# Check if deck is empty
	if deck.is_empty():
		# Reshuffle discard pile into deck
		if discard.is_empty():
			print("[DeckManager] Deck and discard pile are empty!")
			return {}
		
		_reshuffle_discard_into_deck()
	
	# Draw card
	var card = deck.pop_front()
	hand.append(card)
	
	card_drawn.emit(card)
	hand_changed.emit()
	
	print("[DeckManager] Drew card: %s (Hand: %d)" % [card.name, hand.size()])
	
	return card

func draw_cards(count: int):
	"""Draw multiple cards"""
	for i in range(count):
		draw_card()

func play_card(card_index: int) -> Dictionary:
	"""
	Play a card from hand
	Returns the played card, or empty dict if invalid index
	"""
	if card_index < 0 or card_index >= hand.size():
		print("[DeckManager] Invalid card index: %d" % card_index)
		return {}
	
	var card = hand[card_index]
	hand.remove_at(card_index)
	discard.append(card)
	
	hand_changed.emit()
	
	print("[DeckManager] Played card: %s (Hand: %d, Discard: %d)" % [card.name, hand.size(), discard.size()])
	
	return card

func play_card_by_id(card_id: String) -> Dictionary:
	"""Play a card by its instance id (for UI convenience)"""
	for i in range(hand.size()):
		if hand[i].id == card_id:
			return play_card(i)
	
	print("[DeckManager] Card not found in hand: %s" % card_id)
	return {}

func exile_card(card_index: int):
	"""Remove a card from hand permanently (this combat)"""
	if card_index < 0 or card_index >= hand.size():
		return
	
	var card = hand[card_index]
	hand.remove_at(card_index)
	exile.append(card)
	
	hand_changed.emit()
	
	print("[DeckManager] Exiled card: %s" % card.name)

func _reshuffle_discard_into_deck():
	"""Move all cards from discard pile to deck and shuffle"""
	print("[DeckManager] Reshuffling discard pile into deck...")
	
	for card in discard:
		deck.append(card)
	
	discard.clear()
	shuffle_deck()

func get_deck_size() -> int:
	return deck.size()

func get_hand_size() -> int:
	return hand.size()

func get_discard_size() -> int:
	return discard.size()

func get_exile_size() -> int:
	return exile.size()

func get_hand_cards() -> Array:
	"""Returns copy of hand array"""
	return hand.duplicate()

# Debug
func print_state():
	print("[DeckManager] State:")
	print("  Deck: %d cards" % deck.size())
	print("  Hand: %d cards" % hand.size())
	print("  Discard: %d cards" % discard.size())
	print("  Exile: %d cards" % exile.size())
