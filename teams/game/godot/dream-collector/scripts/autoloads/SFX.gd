# SFX.gd — Stub Autoload
# 실제 SFX 구현 전까지 사용하는 빈 인터페이스
extends Node

func play(_sfx_name: String, _volume_db: float = 0.0) -> void:
	pass

func play_at(_pos: Vector2, _sfx_name: String) -> void:
	pass

func stop(_sfx_name: String) -> void:
	pass

func set_music(_track_name: String, _fade_duration: float = 1.0) -> void:
	pass

func stop_music(_fade_duration: float = 1.0) -> void:
	pass
