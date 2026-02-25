extends Control
class_name CharacterNode

"""
CharacterNode - 공용 캐릭터 컴포넌트
Hero, Monster, NPC 모두 이 컴포넌트 사용

Size: 60×120px (세로 사각형)
Features:
- Emoji/Sprite 표시
- HP Bar (선택적)
- 클릭 감지
- 등장 애니메이션 (fly-in from right)
"""

signal character_clicked(character_node: CharacterNode)

# Character data
var character_type: String = "monster"  # "hero", "monster", "npc"
var character_id: String = ""
var character_name: String = ""
var max_hp: int = 100
var current_hp: int = 100
var emoji_icon: String = "👾"
var base_color: Color = Color(0.8, 0.3, 0.3, 1)

# UI nodes
var sprite: ColorRect
var emoji_label: Label
var hp_bar: ProgressBar
var hp_label: Label
var click_button: Button

func _ready():
	# Set size
	custom_minimum_size = Vector2(60, 120)
	size = Vector2(60, 120)
	
	_create_ui()

func _create_ui():
	"""Create UI elements"""
	# Sprite background
	sprite = ColorRect.new()
	sprite.name = "Sprite"
	sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite.color = base_color
	add_child(sprite)
	
	# Emoji icon
	emoji_label = Label.new()
	emoji_label.name = "EmojiLabel"
	emoji_label.text = emoji_icon
	emoji_label.set_anchors_preset(Control.PRESET_CENTER)
	emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	emoji_label.add_theme_font_size_override("font_size", 32)
	sprite.add_child(emoji_label)
	
	# HP Bar
	hp_bar = ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hp_bar.offset_top = 4
	hp_bar.offset_bottom = 14
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_bar.show_percentage = false
	add_child(hp_bar)
	
	# HP Label
	hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hp_label.offset_top = 4
	hp_label.offset_bottom = 14
	hp_label.text = "%d/%d" % [current_hp, max_hp]
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 10)
	add_child(hp_label)
	
	# Click button (invisible overlay)
	click_button = Button.new()
	click_button.name = "ClickButton"
	click_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	click_button.flat = true
	click_button.pressed.connect(_on_clicked)
	add_child(click_button)

func setup(data: Dictionary):
	"""Setup character with data"""
	character_type = data.get("type", "monster")
	character_id = data.get("id", "")
	character_name = data.get("name", "Character")
	max_hp = data.get("max_hp", 100)
	current_hp = data.get("hp", max_hp)
	emoji_icon = data.get("emoji", "👾")
	base_color = data.get("color", Color(0.8, 0.3, 0.3, 1))
	
	# Update UI if already created
	if sprite:
		sprite.color = base_color
	if emoji_label:
		emoji_label.text = emoji_icon
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
	if hp_label:
		hp_label.text = "%d/%d" % [current_hp, max_hp]

func update_hp(new_hp: int):
	"""Update HP"""
	current_hp = clamp(new_hp, 0, max_hp)
	
	if hp_bar:
		hp_bar.value = current_hp
	if hp_label:
		hp_label.text = "%d/%d" % [current_hp, max_hp]
	
	# Hide if dead
	if current_hp <= 0:
		visible = false

func set_hp_bar_visible(visible_flag: bool):
	"""Show/hide HP bar (useful for NPCs)"""
	if hp_bar:
		hp_bar.visible = visible_flag
	if hp_label:
		hp_label.visible = visible_flag

func fly_in_from_right(target_pos: Vector2, duration: float = 0.5):
	"""Fly in animation from right side"""
	# Start position (off-screen right)
	position = Vector2(500, target_pos.y)
	visible = true
	
	# Tween to target
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", target_pos, duration)

func fly_out_to_right(duration: float = 0.3):
	"""Fly out animation to right side"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position:x", 500, duration)
	tween.tween_callback(func(): visible = false)

func _on_clicked():
	"""Handle click"""
	character_clicked.emit(self)
