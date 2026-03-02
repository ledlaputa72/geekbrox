# scripts/combat/turnbased/TurnBasedHandSystem.gd
# 덱/손패/버림더미/셔플 관리 — DEV_SPEC_TURNBASED.md 기반
class_name TurnBasedHandSystem
extends Node

const HAND_MAX = 10

var deck      : Array[Card] = []
var hand      : Array[Card] = []
var discard   : Array[Card] = []

signal hand_updated(hand: Array[Card])
signal deck_empty_reshuffled
signal deck_size_changed(deck_size: int, discard_size: int)

func initialize(deck_list: Array[Card]):
	deck = deck_list.duplicate()
	deck.shuffle()
	hand.clear()
	discard.clear()
	print("[TBHand] 덱 초기화: %d장" % deck.size())
	emit_signal("deck_size_changed", deck.size(), discard.size())

func draw_to_hand(n: int):
	for _i in range(n):
		if hand.size() >= HAND_MAX:
			print("[TBHand] 손패 최대(%d장)" % HAND_MAX)
			break
		if deck.is_empty():
			_reshuffle()
		if deck.is_empty():
			print("[TBHand] 덱과 버림더미 모두 비어있음")
			break
		var card = deck.pop_front()
		hand.append(card)
	emit_signal("hand_updated", hand)
	emit_signal("deck_size_changed", deck.size(), discard.size())
	HandUI.refresh(hand)  # autoload stub — 실제 UI 구현 전까지 print로 출력

func draw_cards(n: int):
	draw_to_hand(n)

func discard_card(card: Card):
	hand.erase(card)
	discard.append(card)
	emit_signal("hand_updated", hand)
	emit_signal("deck_size_changed", deck.size(), discard.size())

func discard_remaining():
	for card in hand:
		discard.append(card)
	hand.clear()
	emit_signal("hand_updated", hand)
	emit_signal("deck_size_changed", deck.size(), discard.size())

func _reshuffle():
	deck = discard.duplicate()
	discard.clear()
	deck.shuffle()
	emit_signal("deck_empty_reshuffled")
	print("[TBHand] 덱 셔플! %d장 복귀" % deck.size())

func get_hand() -> Array[Card]:
	return hand

func get_deck_size() -> int:
	return deck.size()

func get_discard_size() -> int:
	return discard.size()

func _debug_hand():
	var names = []
	for c in hand:
		names.append(c.name)
	print("[TBHand] 손패(%d): %s" % [hand.size(), ", ".join(names)])
