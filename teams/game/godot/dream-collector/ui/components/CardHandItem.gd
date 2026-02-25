extends Control

signal card_clicked(card_index: int)
signal card_hovered(card_index: int)
signal card_unhovered()

var card_data: Dictionary = {}
var card_index: int = -1
var is_selected: bool = false
var is_affordable: bool = true

@onready var cost_label = $VBox/CostLabel
@onready var name_label = $VBox/NameLabel
@onready var type_label = $VBox/TypeLabel
@onready var desc_label = $VBox/DescLabel
@onready var button = $Button
@onready var card_bg = $CardBg

func _ready():
	button.pressed.connect(_on_button_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)

func set_card(data: Dictionary, index: int):
	card_data = data
	card_index = index
	_update_display()

func _update_display():
	if card_data.is_empty():
		return
	
	# Update labels
	cost_label.text = str(card_data.get("cost", 0))
	name_label.text = card_data.get("name", "???")
	type_label.text = card_data.get("type", "")
	desc_label.text = card_data.get("description", "")
	
	# Color by type
	match card_data.get("type", ""):
		"Attack":
			card_bg.color = Color(0.8, 0.3, 0.3, 1)  # Red
		"Defense":
			card_bg.color = Color(0.3, 0.6, 0.8, 1)  # Blue
		"Skill":
			card_bg.color = Color(0.4, 0.8, 0.4, 1)  # Green
		_:
			card_bg.color = Color(0.5, 0.5, 0.5, 1)  # Gray
	
	# Apply theme styles
	cost_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.large)
	name_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	type_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.tiny)
	desc_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.tiny)
	
	_update_affordability()

func set_affordable(affordable: bool):
	is_affordable = affordable
	_update_affordability()

func _update_affordability():
	if not is_affordable:
		modulate = Color(0.5, 0.5, 0.5, 1)  # Gray out
	else:
		modulate = Color(1, 1, 1, 1)

func set_selected(selected: bool):
	is_selected = selected
	if selected:
		scale = Vector2(1.2, 1.2)
		desc_label.visible = true
	else:
		scale = Vector2(1.0, 1.0)
		desc_label.visible = false

func _on_button_pressed():
	if is_affordable:
		card_clicked.emit(card_index)

func _on_mouse_entered():
	if is_affordable:
		card_hovered.emit(card_index)
		# Subtle lift effect
		position.y -= 10

func _on_mouse_exited():
	card_unhovered.emit()
	position.y += 10
