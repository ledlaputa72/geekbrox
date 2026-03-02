# UI.gd — Stub Autoload
# 전역 UI 알림/팝업 인터페이스 (실제 구현 전 stub)
extends Node

func show_notice(message: String, _duration: float = 2.0) -> void:
	print("[UI] Notice: ", message)

func show_combo_banner(combo_name: String, multiplier: float) -> void:
	print("[UI] Combo: %s x%.1f" % [combo_name, multiplier])

func show_damage_number(_amount: int, _pos: Vector2, _is_crit: bool = false) -> void:
	pass

func hide_notice() -> void:
	pass

func show_popup(title: String, body: String) -> void:
	print("[UI] Popup: %s — %s" % [title, body])
