extends Label
class_name DamageNumber

# DamageNumber - Floating damage number animation
# 데미지 숫자가 위로 떠오르며 사라지는 애니메이션
#
# Usage:
# 	var dmg_num = DamageNumber.new()
# 	character_node.add_child(dmg_num)
# 	dmg_num.show_damage(15, DamageNumber.Type.DAMAGE)

enum Type {
	DAMAGE,      # 빨간색 (적에게 가한 데미지)
	HEALING,     # 녹색 (회복)
	SELF_DAMAGE, # 주황색 (자신이 받은 데미지)
	BLOCK        # 파란색 (블록/아머 증가)
}

var damage_value: int = 0
var damage_type: Type = Type.DAMAGE

func _ready():
	# Default style
	add_theme_font_size_override("font_size", 20)
	add_theme_color_override("font_color", Color.WHITE)
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", 2)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Default position (center of parent)
	set_anchors_preset(Control.PRESET_CENTER)
	offset_left = -30
	offset_right = 30
	offset_top = -15
	offset_bottom = 15
	
	# Start invisible
	modulate.a = 0

func show_damage(value: int, type: Type = Type.DAMAGE):
	# Show damage number with animation
	damage_value = value
	damage_type = type
	
	# Set text
	text = str(abs(value))
	
	# Set color based on type
	match type:
		Type.DAMAGE:
			add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))  # Red
			add_theme_font_size_override("font_size", 24)
		Type.HEALING:
			add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))  # Green
			text = "+" + text
			add_theme_font_size_override("font_size", 20)
		Type.SELF_DAMAGE:
			add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))  # Orange
			add_theme_font_size_override("font_size", 22)
		Type.BLOCK:
			add_theme_color_override("font_color", Color(0.35, 0.75, 1.0))  # Blue
			text = "🛡+" + text
			add_theme_font_size_override("font_size", 20)
	
	# Animate
	_animate()

func show_text(message: String, color: Color = Color.WHITE, font_size: int = 18):
	# Show floating text with animation (reaction feedback 등)
	text = message
	add_theme_color_override("font_color", color)
	add_theme_font_size_override("font_size", font_size)
	_animate()

func _animate():
	# Animate floating up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Float up
	tween.tween_property(self, "position:y", position.y - 60, 0.8)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	
	# Fade in then fade out
	tween.tween_property(self, "modulate:a", 1.0, 0.1)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)\
		.set_delay(0.3)
	
	# Scale effect
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2)\
		.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)\
		.set_delay(0.2)
	
	# Delete after animation
	tween.chain().tween_callback(queue_free)
