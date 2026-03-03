extends Control
class_name BaseBottomUI

"""
BaseBottomUI - Common base for all BottomUI (Exploration, Combat, Shop, NPC, Story).
Signals: ui_action_requested, ui_ready, ui_closed.
"""

# Common signals
signal ui_action_requested(action_type: String, data: Dictionary)
signal ui_ready()
signal ui_closed()

# Overridable lifecycle
func _on_enter():
	pass

func _on_exit():
	pass

func update_data(data: Dictionary):
	pass

func request_action(action_type: String, data: Dictionary = {}):
	ui_action_requested.emit(action_type, data)

func close_ui():
	ui_closed.emit()
