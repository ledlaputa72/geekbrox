# VFX.gd — Stub Autoload
# 실제 VFX 구현 전까지 사용하는 빈 인터페이스
extends Node

func play(_vfx_name: String, _target: Node = null) -> void:
	pass

func play_at(_pos: Vector2, _vfx_name: String) -> void:
	pass

func stop(_vfx_name: String) -> void:
	pass

func flash(_target: Node, _color: Color = Color.WHITE, _duration: float = 0.2) -> void:
	pass

func shake(_target: Node, _intensity: float = 5.0, _duration: float = 0.3) -> void:
	pass
