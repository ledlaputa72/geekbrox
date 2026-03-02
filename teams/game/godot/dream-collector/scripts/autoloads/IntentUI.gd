# IntentUI.gd — Stub Autoload
# 적 행동 의도 표시 UI 인터페이스 (실제 UI 구현 전 stub)
extends Node

func show_normal(label: String, value: int) -> void:
	print("[IntentUI] Intent: %s %d" % [label, value])

func show_multi(label: String, value: int, times: int) -> void:
	print("[IntentUI] Multi Intent: %s %dx%d" % [label, value, times])

func show_buff(label: String) -> void:
	print("[IntentUI] Buff Intent: ", label)

func show_unknown() -> void:
	pass

func hide() -> void:
	pass

func clear() -> void:
	pass
