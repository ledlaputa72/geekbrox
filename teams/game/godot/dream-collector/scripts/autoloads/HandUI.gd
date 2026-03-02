# HandUI.gd — Stub Autoload
# 카드 손패 UI 인터페이스 (실제 UI 구현 전 stub)
extends Node

func refresh(hand: Array) -> void:
	print("[HandUI] Hand refreshed: %d cards" % hand.size())

func shake_card(_card: Resource) -> void:
	pass

func highlight_card(_card: Resource, _color: Color = Color.YELLOW) -> void:
	pass

func clear_highlights() -> void:
	pass

func animate_draw(_card: Resource) -> void:
	pass

func animate_discard(_card: Resource) -> void:
	pass

func set_playable(_card: Resource, _can_play: bool) -> void:
	pass
