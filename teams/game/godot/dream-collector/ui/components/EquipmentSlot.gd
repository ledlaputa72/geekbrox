# EquipmentSlot.gd — UI_CHARACTER_SCREEN_SPEC
# 72×72px, 빈 슬롯/장착 상태, 희귀도 테두리, LV 배지

extends Button

signal slot_pressed(slot_id: String)

@export var slot_id: String = ""
@export var slot_type: String = "weapon"  # weapon | armor | ring | necklace
@export var slot_label: String = ""

const SLOT_SIZE := 72
const RARITY_BORDER := {
	"COMMON": Color("#5DB85D"),
	"RARE": Color("#5B9BD5"),
	"SPECIAL": Color("#9B59B6"),
	"EPIC": Color("#9B59B6"),
	"LEGENDARY": Color("#F39C12"),
}
const RARITY_BG := {
	"COMMON": Color("#2D4A2D"),
	"RARE": Color("#1E3A5F"),
	"SPECIAL": Color("#3D1F5C"),
	"EPIC": Color("#3D1F5C"),
	"LEGENDARY": Color("#4A3000"),
}
# Equipment.rarity uses "SPECIAL"; slot uses same keys so colors match
const EMPTY_BG := Color("#3A3A4A")
const EMPTY_BORDER := Color(0.4, 0.4, 0.5, 0.8)

var equipped_item: Equipment = null
var _level_label: Label
var _name_label: Label
var _icon_container: Control
var _check_badge: Label

func _ready() -> void:
	text = ""
	custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	size = Vector2(SLOT_SIZE, SLOT_SIZE)
	toggled.connect(_on_toggled)
	pressed.connect(_on_pressed_internal)
	# Skip redraw if set_item/set_empty was already called before entering the tree
	var already_drawn := false
	for c in get_children():
		if c.name.begins_with("_slot_"):
			already_drawn = true
			break
	if not already_drawn:
		_draw_slot()

func _draw_slot() -> void:
	# Clear previous dynamic children (icon/level/name added in set_item)
	for c in get_children():
		if c.name.begins_with("_slot_"):
			c.queue_free()
	# Style by state
	if equipped_item:
		var r = equipped_item.rarity
		var border_c = RARITY_BORDER.get(r, RARITY_BORDER.COMMON)
		var bg_c = RARITY_BG.get(r, RARITY_BG.COMMON)
		_add_style(border_c, bg_c)
		_level_label = Label.new()
		_level_label.name = "_slot_level"
		_level_label.text = "LV.%d" % equipped_item.enhancement_level
		_level_label.add_theme_font_size_override("font_size", 10)
		_level_label.add_theme_color_override("font_color", Color.WHITE)
		_level_label.position = Vector2(4, 2)
		add_child(_level_label)
		# Center icon (same as inventory: slot-type emoji)
		var icon_lbl = Label.new()
		icon_lbl.name = "_slot_icon"
		icon_lbl.text = slot_label if slot_label else _default_slot_icon()
		icon_lbl.add_theme_font_size_override("font_size", 22)
		icon_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		var icon_y: float = float(SLOT_SIZE) * 0.5 - 14.0
		icon_lbl.position = Vector2(0, icon_y)
		icon_lbl.size = Vector2(SLOT_SIZE, 28)
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		add_child(icon_lbl)
		_name_label = Label.new()
		_name_label.name = "_slot_name"
		var type_map = {"weapon": "무기", "armor": "방어구", "ring": "반지", "necklace": "목걸이"}
		var type_str = type_map.get(slot_type, slot_type)
		_name_label.text = type_str
		_name_label.add_theme_font_size_override("font_size", 9)
		_name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
		_name_label.position = Vector2(2, SLOT_SIZE - 14)
		_name_label.size = Vector2(SLOT_SIZE - 4, 12)
		add_child(_name_label)
		_check_badge = Label.new()
		_check_badge.name = "_slot_check"
		_check_badge.text = "✓"
		_check_badge.add_theme_font_size_override("font_size", 12)
		_check_badge.add_theme_color_override("font_color", Color("#51CF66"))
		_check_badge.position = Vector2(SLOT_SIZE - 18, 2)
		add_child(_check_badge)
	else:
		_add_style(EMPTY_BORDER, EMPTY_BG)
		var hint = Label.new()
		hint.name = "_slot_hint"
		hint.text = slot_label if slot_label else _default_slot_icon()
		hint.add_theme_font_size_override("font_size", 11)
		hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		hint.position = Vector2(0, float(SLOT_SIZE) * 0.5 - 10.0)
		hint.size = Vector2(SLOT_SIZE, 20)
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(hint)

func _default_slot_icon() -> String:
	match slot_type:
		"weapon": return "⚔"
		"armor": return "🛡"
		"ring": return "💍"
		"necklace": return "📿"
	return "?"

func _add_style(border_c: Color, bg_c: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_c
	style.set_border_width_all(2)
	style.border_color = border_c
	style.set_corner_radius_all(8)
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style)
	add_theme_stylebox_override("pressed", style)

func set_item(item: Equipment) -> void:
	equipped_item = item
	_draw_slot()

func set_empty() -> void:
	equipped_item = null
	_draw_slot()

func set_check_visible(v: bool) -> void:
	if _check_badge:
		_check_badge.visible = v

func _on_pressed_internal() -> void:
	if slot_id != "":
		slot_pressed.emit(slot_id)

func _on_toggled(_on: bool) -> void:
	pass
