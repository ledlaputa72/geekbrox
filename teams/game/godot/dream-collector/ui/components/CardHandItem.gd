extends Control

signal card_clicked(card_index: int)
signal card_hovered(card_index: int)
signal card_unhovered()

var card_data: Dictionary = {}
var card_index: int = -1
var is_selected: bool = false
var is_affordable: bool = true

@onready var cost_label = $CostLabel
@onready var image_area = $ImageArea
@onready var name_label = $ImageArea/NameLabel
@onready var type_label = $ImageArea/TypeLabel
@onready var desc_label = $DescLabel
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
	cost_label.text = str(int(card_data.get("cost", 0)))  # Integer only, no decimal
	name_label.text = card_data.get("name", "???")
	type_label.text = card_data.get("type", "")
	desc_label.text = card_data.get("description", "")
	
	# Color by type (apply to image area for visual distinction)
	match card_data.get("type", ""):
		"Attack":
			image_area.color = Color(0.8, 0.3, 0.3, 1)  # Red
			card_bg.color = Color(0.3, 0.1, 0.1, 1)  # Dark red
		"Defense":
			image_area.color = Color(0.3, 0.6, 0.8, 1)  # Blue
			card_bg.color = Color(0.1, 0.2, 0.3, 1)  # Dark blue
		"Skill":
			image_area.color = Color(0.4, 0.8, 0.4, 1)  # Green
			card_bg.color = Color(0.1, 0.3, 0.1, 1)  # Dark green
		_:
			image_area.color = Color(0.5, 0.5, 0.5, 1)  # Gray
			card_bg.color = Color(0.2, 0.2, 0.2, 1)  # Dark gray
	
	# Apply theme styles
	cost_label.add_theme_font_size_override("font_size", 16)  # Large, prominent
	cost_label.add_theme_color_override("font_color", Color(1, 1, 0.4, 1))  # Yellow/gold
	name_label.add_theme_font_size_override("font_size", 11)  # Medium
	type_label.add_theme_font_size_override("font_size", 8)   # Small
	desc_label.add_theme_font_size_override("font_size", 9)   # Small
	
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
		# No scale change - just show full card and description
		desc_label.visible = true
	else:
		desc_label.visible = false

func _on_button_pressed():
	if is_affordable:
		card_clicked.emit(card_index)

func _on_mouse_entered():
	if is_affordable:
		card_hovered.emit(card_index)
		# Note: Lift effect handled by parent Combat.gd

func _on_mouse_exited():
	card_unhovered.emit()
	# Note: Position restore handled by parent Combat.gd
