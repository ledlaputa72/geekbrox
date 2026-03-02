# ComboHintUI.gd — Stub Autoload
# ATB 콤보 힌트 UI 인터페이스 (실제 UI 구현 전 stub)
extends Node

func show(hint_text: String) -> void:
	print("[ComboHintUI] Hint: ", hint_text)

func hide() -> void:
	pass

func flash(combo_name: String) -> void:
	print("[ComboHintUI] Combo! ", combo_name)

func clear() -> void:
	pass
